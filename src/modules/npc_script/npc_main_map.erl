-module (npc_main_map).

-include("ai_define.hrl").

-export ([init/0, proc_special_msg/1]).

-define(CHECK_TIME_DURATION,4 * 60 * 60 * 1000).

init() ->
	send_check().
	
proc_special_msg(npc_main_map_create_boss_check)->
	npc_ai:handle_event(?EVENT_SECTION_UNITS_SPAWN),
	send_check().

send_check()->
	erlang:send_after(?CHECK_TIME_DURATION,self(),npc_main_map_create_boss_check).