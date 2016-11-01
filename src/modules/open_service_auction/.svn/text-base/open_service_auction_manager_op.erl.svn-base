-module (open_service_auction_manager_op).

-include ("error_msg.hrl").
-include ("mnesia_table_def.hrl").
-include ("string_define.hrl").

-define (OPEN_SERVICE_AUCTION_ROLE_BID_SYS_ID, 1193).
-define (OPEN_SERVICE_AUCTION_RESULT_SYS_ID, 1194).
-define (VALID_DURATION, 25 * 24 * 60 * 60 * 1000 * 1000).

-export ([init/0, get_info/0, bid/2, do_time_check/0, do_awards_check/0]).

init() ->
	OpenState = check_overdue(),
	put(state, OpenState),
	RoleAuctionInfo = [{RoleId, RoleName, BidTime, BidMax} || {_, RoleId, RoleName, BidTime, BidMax} <-
		role_open_service_auction_db:get_auction_max_info()],
	put(bid_max, RoleAuctionInfo),
	if
		OpenState ->
			put(info, load_info()),
			do_time_check();
		true ->
			%% send gold awards check
			awards_check()
	end.

get_info() ->
	case get(state) of
		false ->
			{error, ?OPEN_SERVICE_AUCTION_OVERDUE};
		true ->
			OpenTime = util:get_server_start_time(),
			StartSecs = calendar:datetime_to_gregorian_seconds(OpenTime),
			AuctionProto = open_service_auction_db:get_auction_proto_info(),
			Duration = open_service_auction_db:get_auction_duration(AuctionProto),
			EndTime = calendar:gregorian_seconds_to_datetime(StartSecs + Duration),
			Now = calendar:now_to_local_time(timer_center:get_correct_now()),
			NowSecs = calendar:datetime_to_gregorian_seconds(Now),
			LeftSecs = StartSecs + Duration - NowSecs,
			BidMax2 = case get(bid_max) of
				[] ->
					0;
				RoleAuctionInfo ->
					[{_, _, _, BidMax} | _ ] = RoleAuctionInfo,
					BidMax
			end,
			{ok, OpenTime, EndTime, LeftSecs, BidMax2, get(info)}
	end.

bid(RoleId, Bid) ->
	Now = timer_center:get_correct_now(),
	case get(state) of
		false ->
			{error, ?OPEN_SERVICE_AUCTION_OVERDUE};
		true ->
			case get(bid_max) of
				[] ->
					update_role_auction_info(RoleId, Bid),
					%% bid_broadcast(RoleId, Now, Bid),
					ok;
				RoleAuctionInfo ->
					[{RoleId2, RoleName, _, BidMax} | _] = RoleAuctionInfo,
					AuctionProto = open_service_auction_db:get_auction_proto_info(),
					Increment = open_service_auction_db:get_auction_increment(AuctionProto),
					if
						Bid >= BidMax + Increment ->
							role_open_service_auction_db:delete_role_from_auction_max(RoleId2),
							update_role_auction_info(RoleId, Bid),
							give_back_gold(RoleId2, RoleName, BidMax),
							%% bid_broadcast(RoleId, Now, Bid),
							ok;
						true ->
							{error, ?OPEN_SERVICE_AUCTION_GOLD_NOT_ENOUGH}
					end
			end
	end.

do_time_check() ->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	OpenTime = util:get_server_start_time(),
	StartSecs = calendar:datetime_to_gregorian_seconds(OpenTime),
	AuctionProto = open_service_auction_db:get_auction_proto_info(),
	Duration = open_service_auction_db:get_auction_duration(AuctionProto),
	LeftSecs = StartSecs + Duration - NowSecs,
	if
		LeftSecs >= 60 * 60 ->
			normal_broadcast(),
			next_check(30 * 60);
		LeftSecs > 30 * 60 ->
			normal_broadcast(),
			next_check(LeftSecs - 30 * 60);
		LeftSecs =:= 30 * 60 ->
			broadcast_min(30),
			next_check(10 * 60);
		LeftSecs >= 20 * 60 ->
			broadcast_min(LeftSecs div 60),
			next_check(10 * 60);
		LeftSecs > 10 * 60 ->
			broadcast_min(LeftSecs div 60),
			next_check(LeftSecs - 10 * 60);
		LeftSecs =:= 10 * 60 ->
			broadcast_min(10),
			next_check(60);
		LeftSecs >= 2 * 60 ->
			broadcast_min(LeftSecs div 60),
			next_check(60);
		LeftSecs > 60 ->
			broadcast_min(LeftSecs div 60),
			next_check(LeftSecs - 60);
		LeftSecs =:= 60 ->
			broadcast_sec(60),
			next_check(10);
		LeftSecs >= 20 ->
			broadcast_sec(LeftSecs),
			next_check(10);
		LeftSecs > 10 ->
			broadcast_sec(10),
			next_check(LeftSecs - 10);
		LeftSecs =:= 10 ->
			broadcast_sec(10),
			next_check(1);
		LeftSecs > 0 ->
			broadcast_sec(LeftSecs),
			next_check(1);
		true  ->
			broadcast_over(),
			put(state, false),
			awards_check()
	end.

next_check(Secs) ->
	erlang:send_after(Secs * 1000, self(), {bid_time_check}).

check_overdue() ->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	OpenTime = util:get_server_start_time(),
	StartSecs = calendar:datetime_to_gregorian_seconds(OpenTime),
	AuctionProto = open_service_auction_db:get_auction_proto_info(),
	Duration = open_service_auction_db:get_auction_duration(AuctionProto),
	NowSecs >= StartSecs - 24 * 60 * 60 andalso NowSecs =< (StartSecs + Duration).

normal_broadcast() ->
	chat_manager:gm_speek(language:get_string(?STR_OPEN_CHARGE_AUCTION_NOTICE_NORMAL)).

broadcast_min(Min) ->
	Param = util:sprintf(language:get_string(?STR_OPEN_CHARGE_AUCTION_NOTICE_MIN), [Min]),
	chat_manager:gm_speek(Param).

broadcast_sec(Sec) ->
	Param = util:sprintf(language:get_string(?STR_OPEN_CHARGE_AUCTION_NOTICE_SEC), [Sec]),
	chat_manager:gm_speek(Param).

bid_broadcast(RoleId, _, Bid) ->
	RoleInfo = role_db:get_role_info(RoleId),
	RoleName = role_db:get_name(RoleInfo),
	ParamRole = system_chat_util:make_role_param(RoleId, RoleName, env:get(serverid, [])),
    ParamBid = system_chat_util:make_int_param(Bid),
    MsgInfo = [ParamRole,ParamBid],
    system_chat_op:system_broadcast(?OPEN_SERVICE_AUCTION_ROLE_BID_SYS_ID,MsgInfo).

load_info() ->
	AllInfo = role_open_service_auction_db:load_auction_info(),
	AllInfo2 = lists:sort(fun(A, B) ->
		{_, _, _, _, BidA} = A,
		{_, _, _, _, BidB} = B,
		BidA > BidB
	end, AllInfo),
	[{RoleId, Name, Time, Bid} || {_, RoleId, Name, Time, Bid} <- AllInfo2].

update_role_auction_info(RoleId, Bid) ->
	RolePos = role_pos_util:where_is_role(RoleId),
	RoleName = role_pos_db:get_role_rolename(RolePos),
	Now = timer_center:get_correct_now(),
	role_open_service_auction_db:save_auction_max(RoleId, RoleName, Now, Bid),
	put(bid_max, [{RoleId, RoleName, Now, Bid}]),
	bid_broadcast(RoleId, Now, Bid),
	role_open_service_auction_db:add_role_to_auction_info(RoleId, RoleName, Now, Bid),
	Info = [open_service_auction_packet:mk_info({0, RoleName, Now, Bid})],
	Msg = open_service_auction_packet:encode_open_service_auction_info_update_s2c(Info),
	role_pos_util:send_to_all_online_clinet(Msg),
	AllInfo = [{RoleId, RoleName, Now, Bid} | get(info)],
	Length = erlang:length(AllInfo),
	if 
		Length > 20 ->
			{AllInfo2, DeleteInfo} = lists:split(20, AllInfo),
			put(info, AllInfo2),
			lists:foreach(fun({Id, _, _, _}) ->
				role_open_service_auction_db:delete_role_from_auction_info(Id)
			end, DeleteInfo);
		true ->
			put(info, AllInfo)
	end.

give_back_gold(RoleId, RoleName, AddCount) ->
	RoleInfo = role_db:get_role_info(RoleId),
	Account = role_db:get_account(RoleInfo),
	Transaction = 
	fun()->
		case mnesia:read(account, Account) of
			[]->
				[];
			[Account0]->
				#account{roleids = RoleIds, gold = OldGold} = Account0,
				NewGold = OldGold + AddCount,
				NewAccount = Account0#account{gold = NewGold},
				mnesia:write(NewAccount),
				{NewAccount, RoleIds}
		end
	end,
	case dal:run_transaction_rpc(Transaction) of
		{ok,[]}->
			slogger:msg("open_service_auction_manager_op:give_back_gold, cannot find account: ~p, Gold: ~p~n", 
				[Account, AddCount]);
		{ok,{Result, RoleIdList}}->
			#account{username=Account,roleids=RoleIds,gold=TotalGold} = Result,
			send_give_back_gold_mail(RoleName, AddCount, TotalGold),
			FRole = fun(RoleId2) ->
				case role_pos_util:where_is_role(RoleId2) of
					[]->
						nothing;
					RolePos->
						Node = role_pos_db:get_role_mapnode(RolePos),
						Proc = role_pos_db:get_role_pid(RolePos),
						role_processor:account_charge(Node, Proc, {gm_account_charge, AddCount, TotalGold})
				end
			end,
			lists:foreach(FRole, RoleIds);
		_->
			slogger:msg("open_service_auction_manager_op:give_back_gold, unknow error!!!! (account,~p) error! Count ~p ",
				[Account,AddCount])
	end.

send_give_back_gold_mail(RoleName, AddCount, TotalGold) ->
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_OPEN_CHARGE_AUCTION_GOLD_RETURN_TITLE),
	Content = util:sprintf(language:get_string(?STR_OPEN_CHARGE_AUCTION_GOLD_RETURN_CONTENT), [AddCount]),
	mail_op:gm_send_multi(FromName,RoleName,Title,Content,[],0).

broadcast_over() ->
	chat_manager:gm_speek(language:get_string(?STR_OPEN_CHARGE_AUCTION_NOTICE_OVER)),
	send_mail_to_winner(),
	broadcast_result().

send_mail_to_winner() ->
	case get(bid_max) of
		undefined ->
			nothing;
		[] ->
			nothing;
		BidMax ->
			[{RoleId, RoleName, _, _} | _] = BidMax,
			slogger:msg("yanzengyan, in open_service_auction_manager_op, winner: ~p~n", [RoleId]),
			FromName = language:get_string(?STR_SYSTEM),
			Title = language:get_string(?STR_OPEN_CHARGE_AUCTION_WINNER_TITLE),
			Content = language:get_string(?STR_OPEN_CHARGE_AUCTION_WINNER_CONTENT),
			mail_op:gm_send_multi(FromName,RoleName,Title,Content,[],0)
	end.

broadcast_result() ->
	case get(bid_max) of
		undefined ->
			nothing;
		[] ->
			nothing;
		BidMax ->
			[{RoleId, RoleName, _, Bid} | _] = BidMax,
			RoleInfo = role_db:get_role_info(RoleId),
			ParamRole = system_chat_util:make_role_param(RoleId, RoleName, env:get(serverid, [])),
		    ParamBid = system_chat_util:make_int_param(Bid),
		    MsgInfo = [ParamRole,ParamBid],
		    system_chat_op:system_broadcast(?OPEN_SERVICE_AUCTION_RESULT_SYS_ID,MsgInfo)
	end.

awards_check() ->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{Date, {H, M, S}} = Now, 
	Week = calendar:day_of_the_week(Date),
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	NextMondaySecs = NowSecs + (8 - Week) * 24 * 60 * 60 - ((H * 60 + M) * 60 + S),
	LeftSecs = NextMondaySecs - NowSecs,
	erlang:send_after(LeftSecs * 1000, self(), {next_awards_check}),
	if
		Week =:= 1 ->
			send_awards();
		true ->
			nothing
	end.

do_awards_check() ->
	erlang:send_after(7 * 24 * 60 * 60 * 1000, self(), {next_awards_check}),
	send_awards().

send_awards() ->
	Now = timer_center:get_correct_now(),
	{Date, _} = calendar:now_to_local_time(Now),
	ValidRoles = lists:filter(fun({RoleId, _, _, _}) ->
		RoleInfo = role_db:get_role_info(RoleId),
		CheckResult = if
			RoleInfo =/= [] ->
				timer:now_diff(Now, role_db:get_offline(RoleInfo)) =< ?VALID_DURATION;
			true ->
				false
		end,
		if
			not CheckResult ->
				role_open_service_auction_db:delete_role_from_auction_max(RoleId);
			true ->
				nothing
		end,
		CheckResult
	end, get(bid_max)),
	put(bid_max, ValidRoles),
	SendRoles = lists:filter(fun({_, _, SendTime, _}) ->
		SendTime =/= Date
	end, ValidRoles),
	lists:foreach(fun({RoleId, RoleName, _, BidMax}) ->
		do_send_awards(RoleId),
		role_open_service_auction_db:save_auction_max(RoleId, RoleName, Date, BidMax),
		put(bid_max, lists:keyreplace(RoleId, 1, get(bid_max), {RoleId, RoleName, Date, BidMax}))
	end, SendRoles).

do_send_awards(RoleId) ->
	RoleInfo = role_db:get_role_info(RoleId),
	RoleName = role_db:get_name(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_OPEN_CHARGE_AUCTION_AWARDS_TITLE),
	Content = language:get_string(?STR_OPEN_CHARGE_AUCTION_AWARDS_CONTENT),
	mail_op:gm_send_with_gold(FromName,RoleName,Title,Content,0,0,0,1000).