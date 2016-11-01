-module (skill_pull_or_push).

-export ([on_check/2, on_cast/6]).

on_check(_, _) ->
	true.

on_cast(_, ManaChanged, CastResult, SkillId, SkillLevel, Distance) ->
	Now = timer_center:get_correct_now(),
	AffectRoles = lists:foldl(fun({TargetId, DamageInfo, _}, Acc) ->
		case DamageInfo of
			{critical,_} ->
				[TargetId | Acc];
			{normal, _} ->
				[TargetId | Acc];
			_ ->
				Acc
		end
	end, [], CastResult),
	SelfId = get(roleid),
	AffectRoles2 = lists:filter(fun(TargetId) -> TargetId =/= SelfId end, AffectRoles),
	put(skill_pull_or_push, {SkillId, Now, AffectRoles2, Distance}),
	{ManaChanged, CastResult}.