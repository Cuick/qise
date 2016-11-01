-module (open_service_auction_op).

-include ("common_define.hrl").
-include ("error_msg.hrl").

-export ([query_info/0,bid/1]).

query_info() ->
	case open_service_auction_manager:query_activity_info() of
		{ok, StartTime, EndTime, LeftSecs, LastBid, AuctionInfo} ->
			StartParam = festival_packet:make_timer(StartTime),
			EndParam = festival_packet:make_timer(EndTime),
			Info = [open_service_auction_packet:mk_info(Auction) || Auction <- AuctionInfo],
			AuctionProto = open_service_auction_db:get_auction_proto_info(),
			Base = open_service_auction_db:get_auction_base(AuctionProto),
			Increment = open_service_auction_db:get_auction_increment(AuctionProto),
			Msg = open_service_auction_packet:encode_query_open_service_auction_info_s2c(
				StartParam, EndParam, LeftSecs, Base, Increment, LastBid, Info),
			role_op:send_data_to_gate(Msg);
		{error, ErrNo} ->
			Msg = open_service_auction_packet:encode_query_open_service_auction_info_failed_s2c(ErrNo),
			role_op:send_data_to_gate(Msg)
	end.

bid(Gold) ->
	RoleId = get(roleid),
	Result = case role_open_service_auction_db:role_open_service_auction_db(RoleId) of
		[] ->	
			AuctionProto = open_service_auction_db:get_auction_proto_info(),
			Base = open_service_auction_db:get_auction_base(AuctionProto),
			if
				Gold =< Base ->
					?OPEN_SERVICE_AUCTION_GOLD_LESS_BASE;
				true ->
					case role_op:check_money(?MONEY_GOLD, Gold) of
						true ->
							case open_service_auction_manager:bid(RoleId, Gold) of
								ok ->
									role_op:money_change(?MONEY_GOLD, -Gold, open_service_auction_bid),
									0;
								{error, ErrNo} ->
									ErrNo
							end;
						false ->
							?ERROR_LESS_MONEY
					end
			end;
		_ ->
			?OPEN_SERVICE_AUCTION_BID_TWICE
	end,
	Msg = open_service_auction_packet:encode_open_service_auction_bid_s2c(Result),
	role_op:send_data_to_gate(Msg).

