-module(special_combat).

-compile(export_all).

-include("data_struct.hrl").

-include("common_define.hrl").
-include("skill_define.hrl").
-include("little_garden.hrl").

-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%%   一些特殊写的技能
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%伤害反弹直接根据bufferid写死在了程序里,注意
proc_reflect_destory(TargetInfo,DamageInfo)->
	BufferList = creature_op:get_buffer_from_creature_info(TargetInfo),
	case lists:keyfind(?COMBAT_RELECT_BUFF,1,BufferList) of
		{_,BuffLevel}->										%%有反弹
			case DamageInfo of
				missing->
					Damage = 0;
				immune ->
					Damage = 0;
				{critical,CRD}->
					Damage = CRD; 				
				{normal,Dmg}->
					Damage = Dmg
			end,  
			BufferInfo = buffer_db:get_buffer_info(?COMBAT_RELECT_BUFF,BuffLevel),					
			[RefectValue] = buffer_db:get_buffer_effect_arguments(BufferInfo),
			
			erlang:trunc((Damage*RefectValue)/100);
		_->
			0
	end.
	
%%   %技能不耗蓝	直接根据bufferid写死在了程序里,注意	
proc_mp_resume(CreatureInfo,SkillInfo)->
	BufferList = creature_op:get_buffer_from_creature_info(CreatureInfo),
	MP = skill_db:get_cost(SkillInfo),	
	case ((MP =:= 0) or lists:keymember(?COMBAT_MP_BUFF,1,BufferList )) of 	
		true->			
			[];
		_ -> 			
			%%io:format("MP~p~n",[MP]),	
			MaxMp = creature_op:get_mpmax_from_creature_info(CreatureInfo),
			NewMp = erlang:min(creature_op:get_mana_from_creature_info(CreatureInfo) + MP,MaxMp),
			[{mp,NewMp}]		
	end.


