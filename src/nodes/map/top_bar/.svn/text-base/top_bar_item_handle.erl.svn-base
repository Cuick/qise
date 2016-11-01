-module (top_bar_item_handle).

-include ("login_pb.hrl").

-export ([process_msg/1]).

process_msg(#temp_activity_contents_c2s{item_id = ItemId}) ->
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	top_bar_manager:get_temp_activity_contents(RoleId, ItemId);

process_msg(#temp_activity_get_award_c2s{activity_id = ActivityId}) ->
	top_bar_manager_op:get_activity_awards(ActivityId);

process_msg(_) ->
	nothing.

