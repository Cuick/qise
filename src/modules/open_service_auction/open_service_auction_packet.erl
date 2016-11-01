-module (open_service_auction_packet).

-include ("login_pb.hrl").
-include ("open_service_auction_def.hrl").

-export ([handle/2, encode_query_open_service_auction_info_s2c/7, 
	encode_query_open_service_auction_info_failed_s2c/1,
	encode_open_service_auction_bid_s2c/1, encode_open_service_auction_info_update_s2c/1,
	mk_info/1]).

handle(Message = #query_open_service_aution_info_c2s{}, RolePid) ->
	RolePid ! {open_service_auction, Message};

handle(Message = #open_service_aution_bid_c2s{}, RolePid) ->
	RolePid ! {open_service_auction, Message};

handle(_,_)->
	nothing.

encode_query_open_service_auction_info_s2c(StartTime, EndTime, LeftSecs, Base, Increment, LastBid, AuctionInfo) ->
	login_pb:encode_query_open_service_auction_info_s2c(
		#query_open_service_auction_info_s2c{start_time = StartTime, 
		end_time = EndTime, left_seconds = LeftSecs, base = Base,
		increment = Increment, last_bid = LastBid, info = AuctionInfo}).

encode_query_open_service_auction_info_failed_s2c(Reason) ->
	login_pb:encode_query_open_service_auction_info_failed_s2c(
		#query_open_service_auction_info_failed_s2c{reason = Reason}).

encode_open_service_auction_bid_s2c(Result) ->
	login_pb:encode_open_service_auction_bid_s2c(
		#open_service_auction_bid_s2c{result = Result}).

encode_open_service_auction_info_update_s2c(Info) ->
	login_pb:encode_open_service_auction_info_update_s2c(
		#open_service_auction_info_update_s2c{info = Info}).

mk_info({_, Name, Time, Bid}) ->
	{{Year, Month, Day}, {Hour, Min, _}} = calendar:now_to_local_time(Time),
	#bi{year = Year, mon = Month, day = Day, hour = Hour, min = Min, name = Name, bid = Bid}.