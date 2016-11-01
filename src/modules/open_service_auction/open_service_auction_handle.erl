-module (open_service_auction_handle).

-include ("login_pb.hrl").

-export ([process_msg/1]).

process_msg(#query_open_service_aution_info_c2s{}) ->
	open_service_auction_op:query_info();

process_msg(#open_service_aution_bid_c2s{bid = Gold}) ->
	open_service_auction_op:bid(Gold);

process_msg(_) ->
	nothing.