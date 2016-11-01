-module(skill_chong_feng).
-export([on_cast/5,on_check/2]).

%%true/false
on_check(_,_)->
	role_op:can_move(get(creature_info)).

%%å²é
on_cast(TargetId,ManaChanged,CastResult,SkillID,SkillLevel)->			
	[].