%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (travel_battle_handle).

-include ("login_pb.hrl").

-export ([process_msg/1]).

process_msg(#travel_battle_query_role_info_c2s{})->
	travel_battle_op:query_role_info();

process_msg(#travel_battle_register_c2s{stage = Stage})->
	travel_battle_op:register(Stage);

process_msg(#travel_battle_open_shop_c2s{})->
	travel_battle_shop:get_shop_items();

process_msg(#travel_battle_shop_buy_c2s{item_id = ItemId, count = Count}) ->
	travel_battle_shop:buy(ItemId, Count);
	
process_msg(#travel_battle_show_rank_page_c2s{page = Page}) ->
	travel_battle_op:show_rank_page(Page);

process_msg(#travel_battle_lottery_c2s{}) ->
	travel_battle_op:lottery();

process_msg(#travel_battle_cancel_match_c2s{}) ->
	travel_battle_op:cancel_match();

process_msg(#travel_battle_leave_c2s{}) ->
	travel_battle_op:leave();

process_msg(_) ->
	nothing.




