-module (skill_equipment).

-include ("creature_define.hrl").
-include ("dead_valley_def.hrl").

-export([on_check/2, on_cast/5]).

-include ("npc_struct.hrl").

%%true/false
on_check(SkillInfo,TargetInfo)->
	case get_npcflags_from_npcinfo(TargetInfo) of
		?CREATURE_EQUIPMENT ->
			{State, _, _, _, _, _, _, Points, _} = get(dead_valley_info),
			ProtoInfo = dead_valley_db:get_proto_info(),
			{_, _, ConsumeVal} = dead_valley_db:get_proto_points(ProtoInfo),
			case package_op:get_empty_slot_in_package() of
				0 ->
					package_full;
				_ ->
					if
						State =:= true, Points >= ConsumeVal ->
							true;
						true ->
							dead_valley_points
					end
			end;
		_ ->
			state
	end.

on_cast(TargetId,_,_,_,_) ->
	{[], [{TargetId, {normal, 0}, []}]}.