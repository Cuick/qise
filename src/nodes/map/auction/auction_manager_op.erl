-module(auction_manager_op).

%%
%% Include files
%%

-define(AUCTION_ETS,auction_ets).
-define(STALL_ITEM_ETS,stall_item_ets).

-include("auction_define.hrl").
-include("auction_def.hrl").
-include("error_msg.hrl").
-include("mnesia_table_def.hrl").
-include("string_define.hrl").
-compile(export_all).


%% auction_ets : {Id,RoleId,RoleName,RoleLevel,NickName,StallItems,CreateTime,Logs}
%% StallItems : [{ItemId,Money}]
%% stall_item_ets {ItemId,SearchName,StallId,#playeritems{ownerid = {stall,RoleId}},Money}
%% Money :  {Silver,Gold,Ticket}
init()->
	ets:new(?AUCTION_ETS,[ordered_set,named_table]),
	ets:new(?STALL_ITEM_ETS,[set,named_table]),
	auction_stall_id_gen:init(),
	load_from_db(),
	FirstWaitTime = 10*60*1000,
	erlang:send_after(FirstWaitTime,self(),over_due_check).

over_due_check()->
	Now = timer_center:get_correct_now(),
	try
		NeedDels =  ets:foldl(fun(StallInfo,StallsTmp)->
		case timer:now_diff(Now, get_stall_by(time,StallInfo)) >= ?ACUTION_OVERDUA_TIME*1000 of
			true->
				[get_stall_by(stallid,StallInfo)|StallsTmp];
			_->
				StallsTmp
		end end,[], ?AUCTION_ETS),
		lists:foreach(fun(StallId)-> proc_overdue_stall(StallId) end,NeedDels)
	catch
		E:R->slogger:msg("auction start_over_due_check ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end,
	erlang:send_after(?ACUTION_OVERDUA_CHECK_DURATION,self(),over_due_check).

proc_all_auctions_down()->
	ets:foldl(fun(StallInfo,_)-> proc_overdue_stall(get_stall_by(stallid,StallInfo)) end,[],?AUCTION_ETS),
	slogger:msg("finish all_auctions_down ~n").

load_from_db()->
	Auctions = auction_db:get_auction_info(),
	put(end_index,erlang:length(Auctions)),
	lists:map(fun(StallInfo)->
		Id = auction_db:get_id(StallInfo),
		{RoleId,RoleName,RoleLevel} = auction_db:get_roleinfo(StallInfo),
		NickName = auction_db:get_nickname(StallInfo),
		Items = auction_db:get_items(StallInfo),
		CreateTime = auction_db:get_create_time(StallInfo),
		Logs = auction_db:get_ext(StallInfo),
		auction_stall_id_gen:load_by_db(Id),
		FitlerItems = 
		lists:filter(fun({ItemId,Money})->
						case playeritems_db:load_item_info(ItemId,RoleId) of
							[]->
								slogger:msg("auction_manager_op playeritems_db:load_item_info error RoleId ~p ItemId ~p ~n",[RoleId,ItemId]),
								false;
							[PlayerItemDb]->
								PlayerItem = items_op:make_playeritem_by_db(PlayerItemDb),
								ItemName =  item_template_db:get_name(item_template_db:get_item_templateinfo(playeritems_db:get_entry(PlayerItem))),
								TruelyItemInfo = PlayerItem#playeritems{ownerguid = RoleId},
								update_item_to_ets(TruelyItemInfo,Id,Money,ItemName),
								true
						end
					end,Items),
		update_stall_to_ets(Id,RoleId,RoleName,RoleLevel,NickName,FitlerItems,CreateTime,Logs)
	end,Auctions).

get_stall_info(StallId)->
	case ets:lookup(?AUCTION_ETS, StallId) of
		[]->[];
        [StallInfo]-> StallInfo  
	end.

get_stall_item_info(ItemId)->
	case ets:lookup(?STALL_ITEM_ETS, ItemId) of
		[]->[];
        [ItemInfo]-> ItemInfo  
	end.

get_stall_by_role(RoleId)->
  	case ets:match_object(?AUCTION_ETS, {'_',RoleId,'_','_','_','_','_','_'}) of
		[]->[];
		[StallInfo]->StallInfo
	end.

get_stall_by_rolename(RoleName)->
  	case ets:match_object(?AUCTION_ETS, {'_','_',RoleName,'_','_','_','_','_'}) of
		[]->[];
		[StallInfo]->StallInfo
	end.

update_stall_to_db(Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs)->
	auction_db:save_stall_info(Id,{RoleId,RoleName,RoleLevel},NickName,Items,CreateTime,Logs).

update_stall_to_ets({Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	update_stall_to_ets(Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs).

update_stall_to_ets(Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs)->
	try
		ets:insert(?AUCTION_ETS, {Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})
	catch
		_Error:Reason->
			slogger:msg("add_stall_to_ets error ~p ~n",[Reason]),
			{error,Reason}
	end.

update_item_to_ets(PlayerItemInfo,StallId,Money,ItemName)->
	try
		SearchName = transform_to_search_name(ItemName),
		ets:insert(?STALL_ITEM_ETS, {playeritems_db:get_id(PlayerItemInfo),SearchName,StallId,PlayerItemInfo,Money})
	catch
		_Error:Reason->
			slogger:msg("update_item_to_ets error ~p ~n",[Reason]),
			{error,Reason}
	end.
	
transform_to_search_name(ItemName) when is_binary(ItemName) ->
	unicode:characters_to_list(ItemName,unicode);
transform_to_search_name(ItemName) ->
	BinName = list_to_binary(ItemName),
	unicode:characters_to_list(BinName,unicode).

del_stall(Id)->
	auction_stall_id_gen:recycle_id(Id),
	auction_db:del_stall(Id),
	ets:delete(?AUCTION_ETS,Id).

del_item(ItemId)->
	ets:delete(?STALL_ITEM_ETS,ItemId).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall overdue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_overdue_stall(StallId)->
	StallInfo = get_stall_info(StallId),
	StallItems = get_stall_by(items,StallInfo),
	SellerId = get_stall_by(roleid,StallInfo),
	PlayerItems = lists:map(fun({ItemId,_})->
				StallItemInfo = get_stall_item_info(ItemId),
				get_stall_item_by(playeritem,StallItemInfo)
			end,StallItems), 
	send_by_step(?REBACK_ITEM_NUM_ONCE_MAIL,SellerId,PlayerItems),
	del_stall(StallId).

send_by_step(_,_,[])->
	nothing;
send_by_step(Len,SellerId,PlayerItems)->
	case length(PlayerItems) > Len of
		true->
			{FrontL,LeftL}= lists:split(Len, PlayerItems),
			send_stall_item_reback(SellerId,FrontL),
			send_by_step(Len,SellerId,LeftL);
		_->
			send_stall_item_reback(SellerId,PlayerItems)
	end.

send_stall_item_reback(SellerId,PlayerItems)->
	{From,Title,Body} = make_overdue_mail_body(),
	case mail_op:auction_send_by_playeritems(From,SellerId,Title,Body,PlayerItems,0,0) of
		{ok}->
			lists:foreach(fun(PlayerItem)-> ItemId = playeritems_db:get_id(PlayerItem),del_item(ItemId) end,PlayerItems);
		_->
			slogger:msg("send_stall_item_reback mail PlayerItems ~p error ~n",[PlayerItems])
	end.


reback_item_to_role(RoleIds) when is_list(RoleIds)->
	lists:foreach(fun(RoleId)-> reback_item_to_role(RoleId) end,RoleIds);

reback_item_to_role(RoleId)->
	{From,Title,Body} = make_overdue_mail_body(),
	TableName = db_split:get_owner_table(playeritems, RoleId),
	AllAuctionItems = loadrole({stall,RoleId},TableName),							   
  	lists:foreach(fun(PlayerItemDb)->
						ItemId = element(2,PlayerItemDb),
						NewPlayerItem = setelement(1,PlayerItemDb,playeritems),
						case get_stall_item_info(ItemId) of
							[]->
								%%send mail to role
								 mail_op:auction_send_by_playeritems(From,RoleId,Title,Body,[NewPlayerItem],0,0);
							_->
								nothing
						end
				end,AllAuctionItems).
	
loadrole(Ownerguid,TableName)->
	case dal:read_index_rpc(TableName, Ownerguid, 3) of
		{ok,ItemsRecordList}-> ItemsRecordList;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
apply_stalls_search(RoleId,?ACUTION_SERCH_TYPE_ALL,_Str,Index)->
	{StallResult,TotalNum} = proc_stalls_search(?ACUTION_SERCH_TYPE_ALL,Index),
	Stalls = 
	lists:map(fun(StallInfo)->
			auction_packet:make_stall_base_info(
					get_stall_by(stallid,StallInfo),
					get_stall_by(stallname,StallInfo),
					get_stall_by(roleid,StallInfo),
					get_stall_by(rolename,StallInfo),
					get_stall_by(rolelevel,StallInfo),
					length(get_stall_by(items,StallInfo)))					  
		end, StallResult),
	Msg = auction_packet:encode_stalls_search_s2c(Index,TotalNum,Stalls),
	role_pos_util:send_to_role_clinet(RoleId,Msg);

apply_stalls_search(RoleId,?ACUTION_SERCH_TYPE_ITEMNAME,[],Index)->
	apply_stalls_search(RoleId,?ACUTION_SERCH_TYPE_ALL,[],Index);
apply_stalls_search(RoleId,?ACUTION_SERCH_TYPE_ITEMNAME,Str,Index)->
	{StallItems,TotalNum} = proc_stalls_search(?ACUTION_SERCH_TYPE_ITEMNAME,Str,Index),
	StallItemsSend = 
	lists:map(fun(StallItemInfo)->
			StallId = get_stall_item_by(stallid,StallItemInfo),
			StallInfo = get_stall_info(StallId),
			Ownerid = get_stall_by(roleid,StallInfo),
			{Silver,Gold,Ticket} = get_stall_item_by(money,StallItemInfo),
			SendItem = role_packet:make_item_by_playeritem(get_stall_item_by(playeritem,StallItemInfo)),
			IsOnline = 
			case role_pos_util:is_role_online(Ownerid) of
				true->
					1;
				_->
					0
			end,
			auction_packet:make_serch_item_info(SendItem,Silver,Gold,Ticket,StallId,Ownerid,get_stall_by(rolename,StallInfo),length(get_stall_by(items,StallInfo)),IsOnline)
		end, StallItems),
	Msg = auction_packet:encode_stalls_search_item_s2c(Index,TotalNum,lists:reverse(StallItemsSend)),
	role_pos_util:send_to_role_clinet(RoleId,Msg).

%%{Stalls,TotalNum}
proc_stalls_search(?ACUTION_SERCH_TYPE_ALL,Index)->
	{StallsOri,TotalNum} = 
	ets:foldl(fun(StallTmp,{OriList,TableIndex})->
			NowTableIndex = TableIndex+1,
			if
				(NowTableIndex >= Index ) and (NowTableIndex < Index+?ACUTION_SERCH_RECORD_NUM)->
					{[StallTmp|OriList],TableIndex+1};
				true->
					{OriList,NowTableIndex}
			end end,{[],0}, ?AUCTION_ETS),
	{lists:reverse(StallsOri),TotalNum}.

%%{StallItems,TotalNum}
proc_stalls_search(?ACUTION_SERCH_TYPE_ITEMNAME,Str,Index)->
	AllStallItemsNoSort = lists:reverse(proc_stalls_search_by_itemstr(Str)),
	AllStallItems = 
	lists:sort(fun(StallItemTmp1,StallItemTmp2)->serch_item_sort_fun(StallItemTmp1,StallItemTmp2) end, AllStallItemsNoSort),
	StallItemsLength = length(AllStallItems),
	if
		StallItemsLength >= Index-> 
			SendStallItems = lists:sublist(AllStallItems,Index,?ACUTION_SERCH_ITEM_RECORD_NUM);
		true->
			SendStallItems = []
	end,
	{SendStallItems,StallItemsLength}.

proc_stalls_search_by_itemstr(Str)->
	SeachStr = transform_to_search_name(Str),
	ets:foldl(fun(StallItemInfo,StallsItemTmp)->
		ItemName = get_stall_item_by(searchname,StallItemInfo),
		case list_util:is_part_of(SeachStr,ItemName) of
			true->
				[StallItemInfo|StallsItemTmp];
			false->
				StallsItemTmp
	end end,[], ?STALL_ITEM_ETS).

serch_item_sort_fun(StallItemTmp1,StallItemTmp2)->
	PlayerItem1 = get_stall_item_by(playeritem,StallItemTmp1),
	PlayerItem2 = get_stall_item_by(playeritem,StallItemTmp2),
	ItemTemplate1 = playeritems_db:get_entry(PlayerItem1),
	ItemTemplate2 = playeritems_db:get_entry(PlayerItem2),
	if
		ItemTemplate1< ItemTemplate2->
			true;
		ItemTemplate1>ItemTemplate2->
			false;
		true->
			{Silver1,Gold1,_Ticket1} = get_stall_item_by(money,StallItemTmp1),
			{Silver2,Gold2,_Ticket2} = get_stall_item_by(money,StallItemTmp2),
			if
				Gold1<Gold2->
					true;
				Gold1>Gold2->
					false;
				true->
					if
						Silver1=<Silver2->
							true;
						true->
							false
					end
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall Details Look Up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
apply_stall_myself(RoleId,DefaultStallName)->
	case get_stall_by_role(RoleId) of
		[]->
			Msg = auction_packet:encode_stall_detail_s2c(RoleId,0,DefaultStallName,[],[],1),
			role_pos_util:send_to_role_clinet(RoleId, Msg);
		StallInfo->
			send_detail_by_stall_info(RoleId,StallInfo)
	end.	

apply_stall_detail(RoleId,StallId)->
	update_stall_items_to_role(RoleId,StallId).

apply_stall_detail_by_rolename(RoleId,RoleName)->
	RoleNameBin = list_to_binary(RoleName),
	case get_stall_by_rolename(RoleNameBin) of
		[]->
			role_pos_util:send_to_role_clinet(RoleId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_ERROR_ID));
		StallInfo->
			send_detail_by_stall_info(RoleId,StallInfo)
	end.	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				Stall Name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
apply_stall_rename(RoleId,StallName)->
	case get_stall_by_role(RoleId) of
		[]->
			nothing;
		StallInfo->
			RoleId = get_stall_by(roleid,StallInfo),
			RoleName = get_stall_by(rolename,StallInfo),
			RoleLevel = get_stall_by(rolelevel,StallInfo),
			StallItems = get_stall_by(items,StallInfo),
			Logs = get_stall_by(log,StallInfo),
			StallId = get_stall_by(stallid,StallInfo),
			CreateTime = get_stall_by(time,StallInfo),
			update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,CreateTime,Logs),
			update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,CreateTime,Logs)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall Item Up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_stall_items_to_role(RoleId,StallId)->
	case get_stall_info(StallId) of
		[]->
			role_pos_util:send_to_role_clinet(RoleId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_ERROR_ID));
		StallInfo->
			send_detail_by_stall_info(RoleId,StallInfo)
	end.

send_detail_by_stall_info(RoleId,StallInfo)->
	ItemAndMoneys =  get_stall_by(items,StallInfo),
	Logs = get_stall_by(log,StallInfo),
	StallId = get_stall_by(stallid,StallInfo),
	Ownerid = get_stall_by(roleid,StallInfo),
	Stallname = get_stall_by(stallname,StallInfo),
	IsOwnerOnline = 
		case role_pos_util:is_role_online(Ownerid) of
			true->
				1;
			_->
				0
		end,
	Stallitems = lists:map(fun({ItemId,{Silver,Gold,Ticket}})->
						StallItemInfo = get_stall_item_info(ItemId),		   
						PlayerItem = get_stall_item_by(playeritem,StallItemInfo),
						StallItem = role_packet:make_item_by_playeritem(PlayerItem),
						auction_packet:make_stall_item(StallItem,Silver,Gold,Ticket)
						end, ItemAndMoneys),
	Msg = auction_packet:encode_stall_detail_s2c(Ownerid,StallId,Stallname,Stallitems,Logs,IsOwnerOnline),
	role_pos_util:send_to_role_clinet(RoleId, Msg).

%%return stallid
proc_create_stall(RoleId,RoleName,RoleLevel,StallName,OriStallItem)->
	case auction_stall_id_gen:gen_id() of
		[]->
			[];
		NewIndex->
			put(end_index,NewIndex),
			Now = timer_center:get_correct_now(),
			update_stall_to_ets(NewIndex,RoleId,RoleName,RoleLevel,StallName,[OriStallItem],Now,[]),
			update_stall_to_db(NewIndex,RoleId,RoleName,RoleLevel,StallName,[OriStallItem],Now,[]),  %%todo async save
			NewIndex
	end.			

proc_item_upstall(RoleId,StallId,PlayerItem,Money,ItemName)->
	update_item_to_ets(PlayerItem,StallId,Money,ItemName),
	update_stall_items_to_role(RoleId,StallId).
				
apply_up_stall({RoleId,RoleName,RoleLevel},{PlayerItem,Money,StallName,ItemName})->
	OriItemId = playeritems_db:get_id(PlayerItem),
	Now = timer_center:get_correct_now(),
	case get_stall_by_role(RoleId) of
		[]->					%%new stall
			case proc_create_stall(RoleId,RoleName,RoleLevel,StallName,{OriItemId,Money}) of
				[]->
					error;
				StallId->
					proc_item_upstall(RoleId,StallId,PlayerItem,Money,ItemName),
					ok
			end;
		StallInfo->	
			StallId = get_stall_by(stallid,StallInfo),
			OriItems = get_stall_by(items,StallInfo),
			case lists:keymember(OriItemId, 1, OriItems) of
				false->
					StallItems = OriItems ++ [{OriItemId,Money}],
					Logs = get_stall_by(log,StallInfo),
					case length(StallItems) > ?ACUTION_ITEMS_MAXNUM of
						true->
							error;
						_->
							update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Now,Logs),
							update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Now,Logs),  %%todo async save
							proc_item_upstall(RoleId,StallId,PlayerItem,Money,ItemName),
							ok
					end;
				true->
					ok
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall Item Down
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%down or buy return : update/delete
proc_delete_item(StallId,RoleId,ItemId,StallInfo,NewLog)->
	RoleName = get_stall_by(rolename,StallInfo),
	RoleLevel = get_stall_by(rolelevel,StallInfo),
	StallName = get_stall_by(stallname,StallInfo),
	StallItems = lists:keydelete(ItemId, 1, get_stall_by(items,StallInfo)),
	Now = timer_center:get_correct_now(),
	OriLogs= 
	if
		NewLog=/= []->
			[NewLog|get_stall_by(log,StallInfo)];
		true->
			get_stall_by(log,StallInfo)
	end,
	Logs = lists:sublist(OriLogs,?ACUTION_MAX_LOG_NUM),
	CreateTime = get_stall_by(time,StallInfo),
	del_item(ItemId),
	if
		StallItems =/= []->		%%has left
			update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Now,Logs),
			update_stall_to_db(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Now,Logs),
			update;
		true->					%%not left -> del
			update_stall_to_ets(StallId,RoleId,RoleName,RoleLevel,StallName,StallItems,Now,Logs),
			delete
			%%update_stall_items_to_role(RoleId,StallId),
			%%del_stall(StallId)
	end.

apply_recede_item(RoleId,ItemId)->
	case get_stall_item_info(ItemId) of
		[]->
			role_pos_util:send_to_role_clinet(RoleId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_ITEM)),
			error;
		StallItemInfo->
			StallId = get_stall_item_by(stallid,StallItemInfo),
			PlayerItem = get_stall_item_by(playeritem,StallItemInfo),
			case get_stall_info(StallId) of
				[]->
					role_pos_util:send_to_role_clinet(RoleId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_STALL)),
					error;
				StallInfo->
					OwnerId = get_stall_by(roleid,StallInfo),
					if
						OwnerId =/= RoleId->
							slogger:msg("apply_recede_item from stall error. not belong ~p OwnerId ~p ~n",[OwnerId,RoleId]),
							error;
						true->
							case proc_delete_item(StallId,RoleId,ItemId,StallInfo,[]) of
								update->
									update_stall_items_to_role(RoleId,StallId);
								delete->
									%%update to role empty before del_stall
									update_stall_items_to_role(RoleId,StallId),
									del_stall(StallId)
							end,		
							{ok,PlayerItem}
					end
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%		  Stall Item Buy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc_deal_log(SellerId,SellerName,BuyerId,BuyerName,StallItemInfo,{Silver,Gold,_}=Moneys)->
%%	{{Year,Month,Day},{Hour,Min,Sec}} = calendar:now_to_local_time(timer_center:get_correct_now()),
	LogStr = make_deal_log_str(BuyerName,Silver,Gold,StallItemInfo),
	sell_notify(LogStr),
	LogStr.

sell_notify(LogStr)->
	todo.

apply_buy_item({BuyerId,BuyerName},StallId,ItemId,{Silver,Gold,Ticket})->
	case get_stall_info(StallId) of
		[]->
			role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_STALL)),
			error;
		StallInfo->
			SellerId = get_stall_by(roleid,StallInfo),
			SellerName = get_stall_by(rolename,StallInfo),
			if
				BuyerId =:= SellerId->
					role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_BUY_ERROR_SELF)),
					error;
				true->
					case lists:keyfind(ItemId, 1, get_stall_by(items,StallInfo)) of
						false->
							role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_ITEM)),
							error;
						{_,{NeedSilver,NeedGold,NeedTicket} = Moneys}->
							case get_stall_item_info(ItemId) of
								[]->
									role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_STALL_RECEDE_NO_ITEM)),
									error;
								StallItemInfo->
									PlayerItem = get_stall_item_by(playeritem,StallItemInfo),
									if
										(Silver>=NeedSilver) and (Gold>=NeedGold) and (Ticket>=NeedTicket)->
											{MFrom,MTitle,MBody} = make_seller_deal_mail_body(BuyerName,StallItemInfo,Moneys),
											%%send seller's money
											case mail_op:auction_send_by_playeritems(MFrom,SellerId,MTitle,MBody,[],NeedSilver,NeedGold) of
												{ok}->
													NewLog = proc_deal_log(SellerId,SellerName,BuyerId,BuyerName,StallItemInfo,Moneys),
													case proc_delete_item(StallId,SellerId,ItemId,StallInfo,NewLog) of
														update->
															update_stall_items_to_role(SellerId,StallId),
															update_stall_items_to_role(BuyerId,StallId);
														delete->
															%%update to role empty before del_stall
															update_stall_items_to_role(SellerId,StallId),
															update_stall_items_to_role(BuyerId,StallId),
															del_stall(StallId)
													end,
													%% logger
													StallItemInfo_s = make_itemname_str(StallItemInfo),
													gm_logger_role:role_auction_log(SellerId,BuyerId,StallItemInfo_s,NeedSilver,NeedGold),		
													{ok,{NeedSilver,NeedGold,NeedTicket},PlayerItem};
												MailError->
													slogger:msg("mail send error ~p ~n",[MailError]),
													error
											end;
										true->
											role_pos_util:send_to_role_clinet(BuyerId,auction_packet:encode_stall_opt_result_s2c(?ERROR_LESS_MONEY)),
											error
									end
							end
					end
			end
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 					Log And Mail Str
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%make_money_str(Silver) when Silver>=10000 ->
%%	integer_to_list(trunc(Silver/10000)) ++ language:get_string(?STR_SILVER_10000) ++ make_money_str(Silver rem 10000);
%%make_money_str(Silver) when Silver>=100 ->
%%	SilMoney = trunc(Silver/100),
%%	if
%%		SilMoney =:= 0->
%%			make_money_str(Silver rem 100);
%%		true->
%%			integer_to_list(SilMoney) ++ language:get_string(?STR_SILVER_100)++ make_money_str(Silver rem 100)
%%	end;		
make_money_str(Silver)->
	if
		Silver =:=0->
			[];
		true->
			integer_to_list(Silver) ++ language:get_string(?STR_MONEY)
	end.
make_moneys_str(Silver,Gold)->
	if
		Gold =:= 0->
			make_money_str(Silver);
		true->
			integer_to_list(Gold) ++ language:get_string(?STR_GOLD) ++make_money_str(Silver)
	end.
  
make_itemname_str(StallItemInfo)->
	SearchName = get_stall_item_by(searchname,StallItemInfo),
	Count = playeritems_db:get_count(get_stall_item_by(playeritem,StallItemInfo)),
	binary_to_list(unicode:characters_to_binary(SearchName))++"X"++ integer_to_list(Count).

make_deal_log_str(BuyerName,Silver,Gold,StallItemInfo)->
%%		integer_to_list(Month)++ [230,156,136]
%%		++ integer_to_list(Day)++ [230,151,165] 
%%		++ integer_to_list(Hour) ++ ":"
%%		++ integer_to_list(Min) ++ ":"
%%		++ integer_to_list(Sec) ++ "  "
		{{_Year,_Month,_Day},{Hour,Min,_Sec}} = calendar:now_to_local_time(timer_center:get_correct_now()),
		util:safe_binary_to_list(BuyerName) 
		++ [228,187,165] 
		++ make_moneys_str(Silver,Gold)
		++ language:get_string(?STR_AUCTION_DEAL_LOG)
		++ make_itemname_str(StallItemInfo)
		++[227,128,144]
		++ integer_to_list(Hour)
		++ ":"
		++ integer_to_list(Min)
		++[227,128,145].

%%{MSend,MTitle,MBody}
make_seller_deal_mail_body(BuyerName,StallItemInfo,{Silver,Gold,_})->
%%	{
%%		[231,179,187,231,187,159],[231,137,169,229,147,129,229,148,174,229,135,186],
%%		util:safe_binary_to_list(BuyerName)++
%%		[229,156,168,230,130,168,231,154,132,230,145,138,228,189,141,228,184,138,232,180,173,228,185,176,228,186,134]++
%%		make_itemname_str(StallItemInfo) ++ ","	++ [230,156,172,230,172,161,228,186,164,230,152,147,230,148,182,229,133,165,228,184,186,58]++
%%		make_moneys_str(Silver,Gold) ++ [44,232,175,183,231,130,185,229,135,187,34,230,148,182,229,143,150,34,233,162,134,229,143,150,230,156,172,230,172,161,228,186,164,230,152,147,230,137,128,229,190,151,46,232,175,183,228,184,141,232,166,129,229,155,158,229,164,141,230,173,164,233,130,174,228,187,182,46]	   		
%%	}.
	MailSender = language:get_string(?STR_SYSTEM),
	MailTitle = language:get_string(?STR_AUCTION_SELL_MAIL_TITLE),
%%	MailContextFormat = language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT),
	MailContext = util:safe_binary_to_list(BuyerName) 
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT1)
					++ make_itemname_str(StallItemInfo)
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT2)
					++ make_moneys_str(Silver,Gold)
					++ language:get_string(?STR_AUCTION_SELL_MAIL_CONTEXT3),
	{MailSender,MailTitle,MailContext}.

%%{MSend,MTitle,MBody}
make_overdue_mail_body()->
	%%{[231,179,187,231,187,159],[230,145,138,228,189,141,229,183,178,232,191,135,230,156,159],
	%%[230,130,168,231,154,132,230,145,138,228,189,141,229,156,168,228,186,140,229,141,129,229,155,155,229,176,143,230,151,182,228,185,139,229,134,133,229,183,178,230,178,161,230,156,137,228,187,187,228,189,149,230,147,141,228,189,156,44,230,145,138,228,189,141,229,183,178,230,146,164,233,148,128,44,230,137,128,230,156,137,231,137,169,229,147,129,232,191,148,232,191,152,44,232,175,183,229,143,138,230,151,182,230,148,182,229,143,150,231,137,169,229,147,129,46]}.
	MailSender = language:get_string(?STR_SYSTEM),
	MailTitle = language:get_string(?STR_AUCTION_OVERDUE_MAIL_TITLE),
	MailContext = language:get_string(?STR_AUCTION_OVERDUE_MAIL_CONTEXT),
	{MailSender,MailTitle,MailContext}.

%%Stall item : {stallid,roleid,rolename,rolelevel,stallname,items,time,log}

get_stall_by(stallid,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	Id;
get_stall_by(roleid,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	RoleId;
get_stall_by(rolename,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	RoleName;
get_stall_by(rolelevel,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	RoleLevel;
get_stall_by(stallname,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	NickName;
get_stall_by(items,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	Items;
get_stall_by(time,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	CreateTime;
get_stall_by(log,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs})->
	Logs.

set_stall_by(stallid,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs},Value)->
	{Value,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs};
set_stall_by(roleid,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs},Value)->
	{Id,Value,RoleName,RoleLevel,NickName,Items,CreateTime,Logs};
set_stall_by(rolename,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs},Value)->
	{Id,RoleId,Value,RoleLevel,NickName,Items,CreateTime,Logs};
set_stall_by(rolelevel,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,Value,NickName,Items,CreateTime,Logs};
set_stall_by(stallname,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,RoleLevel,Value,Items,CreateTime,Logs};
set_stall_by(items,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,RoleLevel,NickName,Value,CreateTime,Logs};
set_stall_by(time,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,RoleLevel,NickName,Items,Value,Logs};
set_stall_by(log,{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Logs},Value)->
	{Id,RoleId,RoleName,RoleLevel,NickName,Items,CreateTime,Value}.

%% {itemid,searchname,stallid,playeritem,money}

get_stall_item_by(itemid,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Itemid;
get_stall_item_by(searchname,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Searchname;
get_stall_item_by(stallid,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Stallid;
get_stall_item_by(playeritem,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Playeritem;
get_stall_item_by(money,{Itemid,Searchname,Stallid,Playeritem,Money})->
	Money.

set_stall_item_by(itemid,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Searchname,Stallid,Playeritem,Money};
set_stall_item_by(searchname,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Value,Stallid,Playeritem,Money};
set_stall_item_by(stallid,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Searchname,Value,Playeritem,Money};
set_stall_item_by(playeritem,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Searchname,Stallid,Value,Money};
set_stall_item_by(money,{Itemid,Searchname,Stallid,Playeritem,Money},Value)->
	{Itemid,Searchname,Stallid,Playeritem,Value}.
	
