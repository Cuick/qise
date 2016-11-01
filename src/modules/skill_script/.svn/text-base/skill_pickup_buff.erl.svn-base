-module (skill_pickup_buff).

-include ("creature_define.hrl").
-include ("travel_battle_def.hrl").

-export([on_check/2, on_cast/5]).

-include ("npc_struct.hrl").

%%true/false
on_check(SkillInfo,TargetInfo)->
	case get_npcflags_from_npcinfo(TargetInfo) of
		?CREATURE_PICKUP_BUFF ->
			SelfInfo = get(creature_info),
			MyPos = creature_op:get_pos_from_creature_info(SelfInfo),
			TargetPos = creature_op:get_pos_from_creature_info(TargetInfo),
			case util:is_in_range(MyPos, TargetPos, ?TRAVEL_BATTLE_PICKUP_BUFF_RANGE) of
				true ->
					true;
				false ->
					range
			end;
		_ ->
			state
	end.

on_cast(TargetId,ManaChanged,CastResult,_,_) ->
	{[], [{TargetId, {normal, 0}, []}]}.