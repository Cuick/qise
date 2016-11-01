-module(auction_op).
-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("item_struct.hrl").
-include("mnesia_table_def.hrl").
-include("auction_define.hrl").

load_from_db(StallName)->
	put(my_stall_name,StallName).

export_for_db()->
	get(my_stall_name).

export_for_copy()->
	get(my_stall_name).

load_by_copy(StallName)->
	put(my_stall_name,StallName).

proc_rename(StallName)->
	if
		length(StallName) < 100->
			put(my_stall_name,StallName),
			auction_manager:stall_rename(get(roleid),StallName);
		true->
			slogger:msg("kick_out, yanzengyan,auction_op:proc_rename~n"),
			role_op:kick_out(get(roleid))
	end.		

proc_item_up_stall(Slot,Moneys)->
	case package_op:get_iteminfo_in_package_slot(Slot) of
		[]->
			slogger:msg(" proc_item_up_stall error Slot roleid ~p ~n",[get(roleid)]);
		ItemInfo->
			RoleName = get_name_from_roleinfo(get(creature_info)),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			ItemName = get_name_from_iteminfo(ItemInfo),
			PlayerItem = items_op:build_item_by_fullinfo(ItemInfo),
			case get_isbonded_from_iteminfo(ItemInfo) of
				0->
					case auction_manager:apply_up_stall({get(roleid),RoleName,RoleLevel}, {PlayerItem,Moneys,get(my_stall_name),ItemName}) of
						ok->
							items_op:lost_from_stall_by_playeritem(PlayerItem);
						_->
							nothing
					end;
				_->
					nothing
			end
	end.

proc_recede_item(ItemId)->
	MyId = get(roleid),
	case package_op:get_empty_slot_in_package() of
		0->
			role_op:send_data_to_gate(auction_packet:encode_stall_opt_result_s2c(?ERROR_PACKEGE_FULL));
		[EmpSlot]->
			case auction_manager:apply_recede_item(MyId,ItemId) of
				{ok,PlayerItem}->
					NewPlayerItem = PlayerItem#playeritems{ownerguid = MyId},
					items_op:obtain_from_auction_by_playeritem(NewPlayerItem, EmpSlot,got_down_stall);
				_->
					nothing
			end
	end.

proc_stalls_search(Index)->
	case Index>=0 of
		true->
			auction_manager:stalls_search(get(roleid),?ACUTION_SERCH_TYPE_ALL,[],Index);
		_->
			nothing
	end.

proc_stalls_item_search(Index,Str)->
	case Index>=0 of
		true->
			auction_manager:stalls_search(get(roleid),?ACUTION_SERCH_TYPE_ITEMNAME,Str,Index);
		_->
			nothing
	end.
	
proc_stall_detail(StallId)->
	if
		StallId=:=0->
			auction_manager:stall_detail_myself(get(roleid),get(my_stall_name));
		true->
			auction_manager:stall_detail(get(roleid),StallId)
	end.	

proc_stall_detail_by_rolename(RoleName)->
	auction_manager:stall_detail_by_rolename(get(roleid),RoleName).

proc_buy_item_c2s(StallId,ItemId)->
	Gold = get_gold_from_roleinfo(get(creature_info)),
	Silver = get_silver_from_roleinfo(get(creature_info)),
	Ticket = get_ticket_from_roleinfo(get(creature_info)),
	MyName = get_name_from_roleinfo(get(creature_info)),
	MyId = get(roleid),
	case package_op:get_empty_slot_in_package() of
		0->
			role_op:send_data_to_gate(auction_packet:encode_stall_opt_result_s2c(?ERROR_PACKEGE_FULL));
		[EmpSlot]->
			case auction_manager:apply_buy_item({MyId,MyName},StallId,ItemId,{Silver,Gold,Ticket}) of
				{ok,{DelSilver,DelGold,_DelTicket},PlayerItem}->
					if
						DelGold =/= 0->
							role_op:money_change( ?MONEY_GOLD, -DelGold,lost_stall_buy);
						true->
							nothing
					end,
					if
						DelSilver =/= 0->
							role_op:money_change( ?MONEY_SILVER, -DelSilver,lost_stall_buy);
						true->
							nothing
					end,
					items_op:obtain_from_auction_by_playeritem(PlayerItem, EmpSlot,stall_buy);
				_->
					nothing
			end
	end.
