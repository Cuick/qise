-module (dead_valley_handle).

-include ("login_pb.hrl").

-export ([process_msg/1]).

process_msg(#dead_valley_enter_c2s{zone_id = ZoneId}) ->
	dead_valley_op:enter_map(ZoneId);

process_msg(#dead_valley_leave_c2s{}) ->
	dead_valley_op:leave_map();

process_msg(#dead_valley_trap_touch_c2s{trap_id = TrapId}) ->
	dead_valley_op:touch_trap(TrapId);

process_msg(#dead_valley_trap_leave_c2s{trap_id = TrapId}) ->
	dead_valley_op:leave_trap(TrapId);

process_msg(#dead_valley_query_zone_info_c2s{}) ->
	dead_valley_op:query_zone_info();

process_msg(_) ->
	nothing.