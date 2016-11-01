-module (boss_dead_valley).

-export ([init/0, choose_skill/2]).

-include ("npc_struct.hrl").

init() ->
	CreatureInfo = creature_op:get_creature_info(),
	HpMax = creature_op:get_hpmax_from_creature_info(CreatureInfo),
	NpcId = creature_op:get_id_from_creature_info(CreatureInfo),
	dead_valley_zone_manager:boss_init(NpcId, HpMax).


choose_skill(SelfInfo,EnemyInfo) ->
	case get_skilllist_from_npcinfo(SelfInfo) of
		[] ->
			[];
		SkillList ->
			Length = length(SkillList),
			{SkillId, _, _} = lists:nth(random:uniform(Length), SkillList),
			EnemyId = creature_op:get_id_from_creature_info(EnemyInfo),
			{SkillId, EnemyId}
	end.