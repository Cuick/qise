-module (npc_travel_battle).

-export ([init/0, proc_special_msg/1, is_start_section/1]).

-include ("travel_battle_def.hrl").
-include ("ai_define.hrl").
-include ("npc_struct.hrl").
-include ("creature_define.hrl").


init()->
	put(npc_travel_battle_start_time,{0,0,0}),
	put(npc_travel_battle_cur_section,?NPC_TRAVEL_BATTLE_SECTION_PREPARE),
	put(buff_show, 0),
	put(npc_travel_battle_before_prepare, 0),
	send_check().

proc_special_msg(npc_travel_battle_check)->
	do_check();

proc_special_msg(_) ->
	nothing.

is_start_section(Section)->
	 (get(npc_travel_battle_cur_section)=:=Section).

do_check() ->
	case get(npc_travel_battle_cur_section) of
		?NPC_TRAVEL_BATTLE_SECTION_PREPARE ->
			Roles = mapop:get_map_roles_id(),
			RoleNum = length(Roles),
			case RoleNum =:= 3 orelse (get(npc_travel_battle_before_prepare) 
				>= 5) of
				true ->
					do_prepare();
				false ->
					put(npc_travel_battle_before_prepare, 
						get(npc_travel_battle_before_prepare) + 1)
			end;
		?NPC_TRAVEL_BATTLE_SECTION_BATTLE ->
			BuffShow = get(buff_show),
			BuffShow2 = if
				BuffShow rem ?TRAVEL_BATTLE_BUFF_SHOW_DURATION =:= 0 ->
					npc_ai:handle_event(?EVENT_SECTION_UNITS_SPAWN),
					1;
				true ->
					BuffShow + 1
			end,
			put(buff_show, BuffShow2)			
	end,
	send_check().

send_check()->
	timer:send_after(?NPC_TRAVEL_BATTLE_CHECK_INTERVAL,npc_travel_battle_check).

do_prepare()->
	NpcInfo = npc_db:get_creature_spawns_info_by_id(get(id)),
	NpcProtoId = npc_db:get_spawn_protoid(NpcInfo),
	StageInfo = travel_battle_db:get_stage_info_by_npc_id(NpcProtoId),
	PrepareTime = travel_battle_db:get_stage_prepare_time(StageInfo),
	case get(npc_travel_battle_start_time) of
		{0,0,0}->
			%%prepare time
			prepare_brd(trunc(PrepareTime / 1000)),
			put(npc_travel_battle_start_time, now());
		PreStartTime->
			LeftTime = (PrepareTime * 1000 - timer:now_diff(now(), PreStartTime)),
			case LeftTime =< 0 of
				true->
					put(npc_travel_battle_cur_section, ?NPC_TRAVEL_BATTLE_SECTION_BATTLE);
				_-> %%prepare time
					prepare_brd(trunc(LeftTime / 1000000) + 1)
			end
	end.

prepare_brd(LeftSecond)->
	Msg = travel_battle_packet:encode_travel_battle_prepare_s2c(LeftSecond),
	broadcast_to_all_map_roles(Msg).

broadcast_to_all_map_roles(Msg) ->
	lists:foreach(fun(RoleId)->npc_op:send_to_other_client(RoleId, Msg) end,mapop:get_map_roles_id()). 
