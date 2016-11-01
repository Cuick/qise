-module(pet_util).

-compile(export_all).

-include("game_rank_define.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("pet_struct.hrl").
-include("color_define.hrl").
-include("fighting_force_define.hrl").


-define(P1,0.8).
-define(P2,10).
-define(P3,2250).
-define(QUALITY_FACTOR,[{1,1.215},{2,1.227},{3,1.2},{4,1.252},{5,1.264}]).
-define(NPETS_ERROR, 9993).
%% recompute 3d
%%recompute_attr(OriPetInfo)->
%%	{NewQuality,SkillNum,NewSpeed,NewDisPlayId,NewDropRate} = update_quality_and_skillnum(OriPetInfo),
%%	PetInfo1 = OriPetInfo#gm_pet_info{quality = NewQuality,maxskillnum = SkillNum},
%%	{Strength,Intelligence,Agile,Stamina} = get_cur_four_d(PetInfo1),
%%	NewPetInfo = PetInfo1#gm_pet_info{quality = NewQuality,strength = Strength,intelligence = Intelligence,agile = Agile,
%%					stamina = Stamina,move_speed = NewSpeed,displayid = NewDisPlayId,drop_rate = NewDropRate},
%%	pet_op:update_pet_info_all(NewPetInfo),
%%	pet_attr:only_self_update(get_id_from_petinfo(NewPetInfo),
%%		[{strength , Strength},{intelligence , Intelligence},{agile , Agile},{stamina,Stamina},{pet_quality,NewQuality},{pet_skill_num,SkillNum},
%%		{movespeed,NewSpeed},{displayid,NewDisPlayId},{pet_drop_rate,NewDropRate}]).

%%
%%return {Min,Max}
%%

%%
%%return {Power_Add,Hitrate_Add,Dodge_Add,Criticalrate_Add,CriticalDamage_Add,Life_Add,Defense_Add} 
%%
%% @doc 根据宠物的级别，成长，模型给宠物初始化基本属性
%% TODO 其中defense目前设置的是0，后面要添加上相关的数值
get_system_attr_add(Level, Growth, ProtoId)->
	% 获取宠物成长的加成
	{PetGrowHp, PetGrowPower, PetGrowHitRate, PetGrowDodge, 
		PetGrowCriticalRate, PetGrowCriticalDamage,_GrowToughness} = 
	GrowthAttr = pet_growth_proto_db:get_growth_pet_attr(Growth),
	% 获取宠物模型基础值
	PetProtoInfo =  pet_proto_db:get_info(ProtoId),
	% {生命，攻击，命中，闪避，暴击，暴伤，韧性}
	PetProtoAttr = pet_proto_db:get_born_abilities(PetProtoInfo),
	{PetProtoHp, PetProtoPower, PetProtoHitRate, PetProtoDodge, PetProtoCriticalRate, PetProtoCriticalDamage,PetProtoToughness, PetProto_MagicDefense, PetProto_FarDefense, PetProto_NearDefense, _MagicImmunity, _FarImmunity, _NearImmunity} = PetProtoAttr,
	% 获取级别加成
	PetLevelInfo = pet_level_db:get_info(Level),
	{PetLvlHp, PetLvlPower, PetLvlHitRate, PetLvlDodge, 
		PetLvlCriticalRate, PetLvlCriticalDamage,PetLvlToughness, PetLvl_MagicDefense, PetLvl_FarDefense, PetLvl_NearDefense} = pet_level_db:get_sysaddattr(PetLevelInfo),
    %%宠物基础值
	Base_Power = PetGrowPower + trunc(PetProtoPower*PetLvlPower/100),
	Base_HitRate = PetGrowHitRate + trunc(PetProtoHitRate*PetLvlHitRate/100),
    Base_Dodge = PetGrowDodge + trunc(PetProtoDodge*PetLvlDodge/100),
	Base_CriticalRate = PetGrowCriticalRate + trunc(PetProtoCriticalRate*PetLvlCriticalRate/100),
    Base_CriticalDamage = PetGrowCriticalDamage + trunc(PetProtoCriticalDamage*PetLvlCriticalDamage/100),
    Base_Life = PetGrowHp + trunc(PetProtoHp*PetLvlHp/100),
    Base_Toughness = trunc(PetProtoToughness*PetLvlToughness/100),
    Base_MagicDefense = trunc(PetProto_MagicDefense*PetLvl_MagicDefense/100), 
    Base_FarDefense = trunc(PetProto_FarDefense*PetLvl_FarDefense/100), 
    Base_NearDefense = trunc(PetProto_NearDefense*PetLvl_NearDefense/100),
    % slogger:msg("aaaaaaaaaaaaaaaaaaaaaa2~p~n",[{Base_MagicDefense,Base_FarDefense,Base_NearDefense}]),
    {Base_Power, Base_HitRate, Base_Dodge, Base_CriticalRate, Base_CriticalDamage, Base_Life, Base_Toughness,  Base_MagicDefense, Base_FarDefense, Base_NearDefense}.
    %%gongji	 mingzhong	   shanbi		baoji				baoshang			shengmin  

%%
%%
%% @doc 目前技能和装备加成都没有，回头策划计划后，再添加上。
compute_attr(Class,Attr,SkillEff,EquipEff)->
	case SkillEff of
		[] ->
			Attr;
		_ ->
			case Attr of
			 {_PowerAttr,_HitrateAttr,_DodgeAttr,_CriticalrateAttr,_CriticaldamageAttr,_LifeAttr,_Toughness,_MagicDefenseAttr,_FarDefenseAttr,_NearDefenseAttr} ->
			 	MyAttr = {_PowerAttr,_HitrateAttr,_DodgeAttr,_CriticalrateAttr,_CriticaldamageAttr,_LifeAttr,_Toughness,0,0,0},
				% slogger:msg("11111111112: ~p,:~p ,~n",[Attr,SkillEff]),%skill  [{hpmax,30177}]
				lists:foldl(fun({Key,Value},Acc) -> 
					% slogger:msg("11111111113~p~n",[Acc]),
					{PowerAttr1,HitrateAttr1,DodgeAttr1,CriticalrateAttr1,CriticaldamageAttr1,LifeAttr1,Toughness1,MagicDefenseAttr1,FarDefenseAttr1,NearDefenseAttr1} = Acc,
					% slogger:msg("11111111115~p~n",[Acc]),
							case Key of
								hpmax ->
									NewLifeAttr = LifeAttr1 + Value;
								_ ->
									NewLifeAttr = LifeAttr1
							end,
							case Key of
								hitrate ->
									NewHitrateAttr = HitrateAttr1 + Value;
								_ ->
									NewHitrateAttr = HitrateAttr1
							end,
							% case Key of
							% 	magicdefense ->
							% 		NewMagicDefenseAttr = MagicDefenseAttr1 + Value;
							% 	_ ->
							% 		NewMagicDefenseAttr = MagicDefenseAttr1
							% end,
							% case Key of
							% 	rangedefense ->
							% 		NewFarDefenseAttr = FarDefenseAttr1 + Value;
							% 	_ ->
							% 		NewFarDefenseAttr = FarDefenseAttr1
							% end,
							% case Key of
							% 	meleedefense ->
							% 		NewNearDefenseAttr = NearDefenseAttr1 + Value;
							% 	_ ->
							% 		NewNearDefenseAttr = NearDefenseAttr
							% end,
							case Key of
								magicdefense ->
									NewMagicDefenseAttr = MagicDefenseAttr1 + Value;
								_ ->
									NewMagicDefenseAttr = 0
							end,
							case Key of
								rangedefense ->
									NewFarDefenseAttr = FarDefenseAttr1 + Value;
								_ ->
									NewFarDefenseAttr = 0
							end,
							case Key of
								meleedefense ->
									NewNearDefenseAttr = NearDefenseAttr1 + Value;
								_ ->
									NewNearDefenseAttr = 0
							end,
							case Key of
								magicpower ->
									NewPowerAttr = PowerAttr1 + Value;
								rangepower ->
									NewPowerAttr = PowerAttr1 + Value;
								meleepower ->
									NewPowerAttr = PowerAttr1 + Value;
								_ ->
									NewPowerAttr = PowerAttr1
							end,
							case Key of
								criticalrate ->
									NewCriticalrateAttr = CriticalrateAttr1 + Value;
								_ ->
									NewCriticalrateAttr = CriticalrateAttr1
							end,
							case Key of
								dodge ->
									NewDodgeAttr = DodgeAttr1 + Value;
								_ ->
									NewDodgeAttr = DodgeAttr1
							end,
							case Key of
								toughness ->
									NewToughness = Toughness1 + Value;
								_ ->
									NewToughness = Toughness1
							end,
							case Key of
								criticaldamage ->
									NewCriticaldamageAttr = CriticaldamageAttr1 + Value;
								_ ->
									NewCriticaldamageAttr = CriticaldamageAttr1
							end,
							% slogger:msg("aaaaaaaaaaaaaaaaaaaaaSkillEff :~p ,old FarDefenseAttr1:~p,{Key,Value}:~p~n",[SkillEff,FarDefenseAttr1,{Key,Value}]),
							{NewPowerAttr,NewHitrateAttr,NewDodgeAttr,NewCriticalrateAttr,NewCriticaldamageAttr,NewLifeAttr,NewToughness,NewMagicDefenseAttr,NewFarDefenseAttr,NewNearDefenseAttr}

					end,MyAttr,SkillEff);
			_ ->
				% slogger:msg("11111111114~p~n",[Attr]),
				Attr
		end
	end.

    % {NewPowerAttr,NewHitrateAttr,NewDodgeAttr,NewCriticalrateAttr,NewCriticaldamageAttr,NewLifeAttr,NewToughness,NewMagicDefenseAttr,NewFarDefenseAttr,NewNearDefenseAttr}.
	%{PowerAttr,HitrateAttr,DodgeAttr,CriticalrateAttr,CriticaldamageAttr,LifeAttr,DefenseAttr} = Attr,
	%{Skill_PowerAttr,Skill_HitrateAttr,Skill_DodgeAttr,Skill_CriticalrateAttr,Skill_CriticaldamageAttr,Skill_LifeAttr,Skill_DefenseAttr} = SkillEff,
	%{Equip_PowerAttr,Equip_HitrateAttr,Equip_DodgeAttr,Equip_CriticalrateAttr,Equip_CriticaldamageAttr,Equip_LifeAttr,Equip_DefenseAttr} = EquipEff,
    %Power = erlang:trunc(PowerAttr+Skill_PowerAttr+Equip_PowerAttr),
    %Hitrate = erlang:trunc(HitrateAttr+Skill_HitrateAttr+Equip_HitrateAttr),
    %Dodge = erlang:trunc(DodgeAttr+Skill_DodgeAttr+Equip_DodgeAttr),
    %Criticalrate = erlang:trunc(CriticalrateAttr+Skill_CriticalrateAttr+Equip_CriticalrateAttr),
    %Criticaldamage = erlang:trunc(CriticaldamageAttr+Skill_CriticaldamageAttr+Equip_CriticaldamageAttr),
    %Life = erlang:trunc(LifeAttr+Skill_LifeAttr+Equip_LifeAttr),
    %Defense = erlang:trunc(DefenseAttr+Skill_DefenseAttr+Equip_DefenseAttr),
	%{Power,Hitrate,Dodge,Criticalrate,Criticaldamage,Life,Defense}.

%%
%%recompute_attr 宠物属性计算包含与客户端通信及对AOI的广播
%%

%%
%%位阶变化后计算属性
%%
recompute_attr(grade_and_quality,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_pet_gminfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			SkillEff = get_skill_attr_self(PetId),
			EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
            Grade = get_grade_from_petinfo(GmPetInfo),
            Quality = get_quality_from_petinfo(GmPetInfo),
            Level = get_level_from_petinfo(GmPetInfo),
            Savvy = get_savvy_from_petinfo(GmPetInfo),

%            Quality_Value_Info = get_quality_value_info_from_mypetinfo(PetInfo),
%            {Quality_Value_Power,Quality_Value_Hitrate,Quality_Value_Dodge,Quality_Value_Criticalrate,Quality_Value_Criticaldamage,Quality_Value_Life,Quality_Value_Defense} = Quality_Value_Info,
%            Quality_Value_Up_Info = get_quality_value_up_info_from_mypetinfo(PetInfo),
            Grade_Riseup_Lucky = get_grade_riseup_lucky_from_mypetinfo(PetInfo),
            Quality_Riseup_Lucky = get_quality_riseup_lucky_from_mypetinfo(PetInfo),
			PetStage = get_quality_riseup_retries_from_mypetinfo(PetInfo),

            AttrAdd = get_system_attr_add(Level, Grade, ProtoId),
            % slogger:msg("aaaaaaaaaaaa1:~p,compute_attr:~p~n",[AttrAdd ,compute_attr(Class,AttrAdd,SkillEff,EquipEff)]),
			{Power,Hitrate,Dodge,Criticalrate,CriticalDamage,Life,Toughness,MagicDefense,FarDefense,NearDefense}=
				compute_attr(Class,AttrAdd,SkillEff,EquipEff),
			% slogger:msg("aaaaaaaaaaaa2:~p~n",[AttrAdd]),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power,				
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
                                            dodge = Dodge,
                                            life = Life,
                                            hpmax = Life,
                                            defense = 0
           %                                  magic_defense = MagicDefense,
											% far_defense = FarDefense,
											% near_defense = NearDefense
											},
			% slogger:msg("aaaaaaaaaaaa3:~p~n",[NewGmPetInfo]),
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			% slogger:msg("aaaaaaaaaaaa4:~p~n",[NewGmPetInfo]),
			{PowerAttr,HitrateAttr,DodgeAttr,CriticalrateAttr,CriticaldamageAttr,LifeAttr,_Toughness,MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr} = AttrAdd,
            % slogger:msg("aaaaaaaaaaaa5:~p~n",[NewGmPetInfo]),
            NewPetInfo = set_attr_to_mypetinfo(PetInfo,AttrAdd),
            % slogger:msg("aaaaaaaaaaaa6:~p~n",[NewGmPetInfo]),
            pet_op:update_pet_info_all(NewPetInfo),
            % slogger:msg("aaaaaaaaaaaa7:~p~n",[NewGmPetInfo]),
			pet_attr:only_self_update(PetId,
									[{pet_power,PowerAttr},
									 {pet_hitrate,HitrateAttr},
                                     {pet_dodge,DodgeAttr},
									 {pet_criticalrate,CriticalrateAttr},
                                     {pet_life,LifeAttr},
                                     % {pet_defense,{MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr}},
									 {power,Power},
									 {hitrate,Hitrate},
                                     {dodge,Dodge},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {life,Life},
                                     % {defense,{MagicDefense,FarDefense,NearDefense}},
                                     {pet_grade,Grade},
                                     {pet_quality,Quality},
                                     {pet_savvy,Savvy},
%                                     {pet_quality_value_power,Quality_Value_Power},
%                                     {pet_quality_value_hitrate,Quality_Value_Hitrate},
%                                     {pet_quality_value_dodge,Quality_Value_Dodge},
%                                     {pet_quality_value_criticalrate,Quality_Value_Criticalrate},
%                                     {pet_quality_value_life,Quality_Value_Life},
%                                     {pet_quality_value_defense,Quality_Value_Defense},
%                                     {pet_quality_value_up,Quality_Value_Up_Info},
                                     {pet_grade_riseup_lucky,Grade_Riseup_Lucky},
                                     {pet_quality_riseup_lucky,Quality_Riseup_Lucky},
									 {pet_stage, PetStage}
									]),
% slogger:msg("aaaaaaaaaaaa8:~p~n",[NewGmPetInfo]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
% slogger:msg("aaaaaaaaaaaa9:~p~n",[NewGmPetInfo]),
			role_op:recompute_pet_attr(),
% slogger:msg("aaaaaaaaaaaa0:~p~n",[NewGmPetInfo]),
			pet_op:save_pet_to_db(PetId)
	end;
%%
%%资质变化后计算属性
%%
recompute_attr(quality_value,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_pet_gminfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			SkillEff = get_skill_attr_self(PetId),
			EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
			Grade = get_grade_from_petinfo(GmPetInfo),
            Level = get_level_from_petinfo(GmPetInfo),
            Quality = get_quality_from_petinfo(GmPetInfo),

            Quality_Value_Info = get_quality_value_info_from_mypetinfo(PetInfo),
            {Quality_Value_Power,Quality_Value_Hitrate,Quality_Value_Dodge,Quality_Value_Criticalrate,Quality_Value_Criticaldamage,Quality_Value_Life,Quality_Value_Defense} = Quality_Value_Info,

            AttrAdd = get_system_attr_add(Level, Grade, ProtoId),
			{Power,Hitrate,Dodge,Criticalrate,CriticalDamage,Life,Toughness,MagicDefense,FarDefense,NearDefense}=compute_attr(Class,AttrAdd,SkillEff,EquipEff),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power,				
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
                                            dodge = Dodge,
                                            life = Life,
                                            hpmax = Life,
                                            defense = 0
           %                                  magic_defense = MagicDefense,
											% far_defense = FarDefense,
											% near_defense = NearDefense
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			{PowerAttr,HitrateAttr,DodgeAttr,CriticalrateAttr,CriticaldamageAttr,LifeAttr,_Toughness,MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr} = AttrAdd,
            NewPetInfo = set_attr_to_mypetinfo(PetInfo,AttrAdd),
            pet_op:update_pet_info_all(NewPetInfo),
			pet_attr:only_self_update(PetId,
									[{pet_power,PowerAttr},
									 {pet_hitrate,HitrateAttr},
									 {pet_dodge,DodgeAttr},
									 {pet_criticalrate,CriticalrateAttr},
                                     {pet_life,LifeAttr},
                                     % {pet_defense,{MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr}},
									 {power,Power},
									 {hitrate,Hitrate},
                                     {dodge,Dodge},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {life,Life},
                                     % {defense,{MagicDefense,FarDefense,NearDefense}},
                                     {pet_quality_value_power,Quality_Value_Power},
                                     {pet_quality_value_hitrate,Quality_Value_Hitrate},
                                     {pet_quality_value_dodge,Quality_Value_Dodge},
                                     {pet_quality_value_criticalrate,Quality_Value_Criticalrate},
                                     {pet_quality_value_life,Quality_Value_Life},
                                     {pet_quality_value_defense,Quality_Value_Defense}
									]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			role_op:recompute_pet_attr(),
			pet_op:save_pet_to_db(PetId)
	end;

%%
%%技能变化后计算属性
%%
recompute_attr(skill,{PetId,SkillId,OldLevel,SkillLevel,Type})->
	% slogger:msg("sssssssssssssssssssss:~p~n",[{PetId,SkillId,OldLevel,SkillLevel,Type}]),	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			SkillEff = case Type of
							same ->
								OldEff = pet_skill_op:get_skill_add_buff(SkillId, OldLevel),
								DelEff = [{K,-V}||{K,V}<-OldEff,(K =:= magicdefense orelse K =:= rangedefense orelse K =:= meleedefense)],
								NewEff= pet_skill_op:get_skill_add_buff(SkillId, SkillLevel),
								% NewEff= get_skill_attr_self(PetId),
								% slogger:msg("sssssssssssssssssssss2:~p~n",[{DelEff++NewEff,get_skill_attr_self(PetId)}]),	
								DelEff++NewEff;
								% NewEff;
							diff ->
								% slogger:msg("ssssssswwwwwwwww~p,~p~n",[pet_skill_op:get_skill_add_buff(SkillId, SkillLevel),get_skill_attr_self(PetId)]),
								pet_skill_op:get_skill_add_buff(SkillId, SkillLevel);
								% get_skill_attr_self(PetId);
							forget ->
								OldEff = pet_skill_op:get_skill_add_buff(SkillId, OldLevel),
								Eff1 = [{K,-V}||{K,V}<-OldEff,(K =:= magicdefense orelse K =:= rangedefense orelse K =:= meleedefense)],
								Eff2 = [{K2,0}||{K2,_V}<-OldEff,(K2 =/= magicdefense andalso K2 =/= rangedefense andalso K2 =/= meleedefense)],
								Eff1 ++ Eff2;
							_ ->
								[]
						end,
			GmPetInfo = pet_op:get_pet_gminfo(PetId),
			AttrAdd = get_attr_from_mypetinfo(PetInfo),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			% SkillEff = get_skill_attr_self(PetId),
			% slogger:msg("sssssssssssssssssssss:~p~n",[SkillEff]),
			EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
			% slogger:msg("sssssssssssssssssssss3aa,yuanlai:~p,add:~p~n",[AttrAdd,SkillEff]),
			{Power,Hitrate,Dodge,Criticalrate,CriticalDamage,Life,Toughness,MagicDefense,FarDefense,NearDefense} = 
				compute_attr(Class,AttrAdd,SkillEff,EquipEff),
						% my_compute_attr(Attr,SkillEff),
			% slogger:msg("sssssssssssssssssssss3,add:~p,all:~p,Power:~p,AttrAdd:~p~n",[SkillEff,{MagicDefense,FarDefense,NearDefense},Power,AttrAdd]),
			Magic_defense = GmPetInfo#gm_pet_info.magic_defense,
			Far_defense = GmPetInfo#gm_pet_info.far_defense,
			Near_defense = GmPetInfo#gm_pet_info.near_defense,
			% slogger:msg("aaaaaaaaaaaaaaaaaaaaaa self Far_defense :~p ,skill FarDefense:~p~n",[Far_defense,FarDefense]),
			lists:foreach(fun({Key,_Value}) -> 
					case Key of
						magicpower ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{power,make_value(Power)}]);
						rangepower ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{power,make_value(Power)}]);
						meleepower ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{power,make_value(Power)}]);
						hitrate ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											hitrate = Hitrate},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{hitrate,make_value(Hitrate)}]);
						criticalrate ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											criticalrate = Criticalrate},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{criticalrate,make_value(Criticalrate)}]);
						criticaldamage ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											criticaldamage = CriticalDamage},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{criticaldestroyrate,make_value(CriticalDamage)}]);
						dodge ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											dodge = Dodge},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{dodge,make_value(Dodge)}]);
						hpmax ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											hpmax = Life,
											life = Life},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{life,make_value(Life)}]);
						toughness ->
							% NewGmPetInfo = GmPetInfo#gm_pet_info{
							% 				toughness = Toughness},
							% pet_op:update_gm_pet_info_all(NewGmPetInfo),
							% pet_attr:only_self_update(PetId,
							% 						[{toughness,make_value(Toughness)}]);
							no_pet_toughness;

						magicdefense ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											magic_defense = MagicDefense + Magic_defense},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{pet_magic_defense,MagicDefense + Magic_defense}]);
						rangedefense ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											far_defense = FarDefense + Far_defense},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{pet_far_defense,FarDefense + Far_defense}]);
						meleedefense ->
							NewGmPetInfo = GmPetInfo#gm_pet_info{
											near_defense = NearDefense + Near_defense},
							pet_op:update_gm_pet_info_all(NewGmPetInfo),
							pet_attr:only_self_update(PetId,
													[{pet_near_defense,NearDefense + Near_defense}])

					end
				end,SkillEff),
			% NewGmPetInfo = GmPetInfo#gm_pet_info{
			% 								power = Power,				
			% 								hitrate = Hitrate,		
			% 								criticalrate = Criticalrate,
			% 								criticaldamage = CriticalDamage, 		
   %                                          dodge = Dodge,
   %                                          life = Life,
   %                                          hpmax = Life,
   %                                          defense = 0,
   %                                          magic_defense = MagicDefense + Magic_defense,
			% 								far_defense = FarDefense + Far_defense,
			% 								near_defense = NearDefense + Near_defense
			% 								},
			% pet_op:update_gm_pet_info_all(NewGmPetInfo),
			% pet_attr:only_self_update(PetId,
			% 						[{power,Power},
			% 						 {hitrate,Hitrate},
   %                                   {dodge,Dodge},
			% 						 {criticalrate,Criticalrate},
			% 						 {criticaldestroyrate,CriticalDamage},
			% 						 {pet_magic_defense,MagicDefense + Magic_defense},
			% 						 {pet_far_defense,FarDefense + Far_defense},
			% 						 {pet_near_defense,NearDefense + Near_defense},
			% 						 {life,Life}
   %                                   % {defense,{MagicDefense,FarDefense,NearDefense}}
			% 						]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			role_op:recompute_pet_attr(),
			RoleAttr = get(other_attr),
			Msg = role_packet:encode_role_attribute_s2c(get(roleid),RoleAttr),
			role_op:send_data_to_gate(Msg),
			pet_op:save_pet_to_db(PetId)
	end;

%%
%%装备变化后计算属性
%%
recompute_attr(equip,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_pet_gminfo(PetId),
			AttrAdd = get_attr_from_mypetinfo(PetInfo),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			SkillEff = get_skill_attr_self(PetId),
			EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
			{Power,Hitrate,Dodge,Criticalrate,CriticalDamage,Life,Toughness,MagicDefense,FarDefense,NearDefense}=
				compute_attr(Class,AttrAdd,SkillEff,EquipEff),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power,				
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
                                            dodge = Dodge,
                                            life = Life,
                                            hpmax = Life,
                                            defense = 0
           %                                  magic_defense = MagicDefense,
											% far_defense = FarDefense,
											% near_defense = NearDefense
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			pet_attr:only_self_update(PetId,
									[{power,Power},
									 {hitrate,Hitrate},
                                     {dodge,Dodge},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {life,Life}
                                     % {defense,{MagicDefense,FarDefense,NearDefense}}
									]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			% role_op:recompute_pet_attr(),
			role_op:recompute_pet_attr(),
			RoleAttr = get(other_attr),
			Msg = role_packet:encode_role_attribute_s2c(get(roleid),RoleAttr),
			role_op:send_data_to_gate(Msg),
			pet_op:save_pet_to_db(PetId)
	end;
recompute_attr(create_delate,PetId)->
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			role_op:recompute_pet_attr(),
			RoleAttr = get(other_attr),
			Msg = role_packet:encode_role_attribute_s2c(get(roleid),RoleAttr);
		PetInfo->
			GmPetInfo = pet_op:get_pet_gminfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			SkillEff = get_skill_attr_self(PetId),
			EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
            Grade = get_grade_from_petinfo(GmPetInfo),
            Quality = get_quality_from_petinfo(GmPetInfo),
            Level = get_level_from_petinfo(GmPetInfo),
            Savvy = get_savvy_from_petinfo(GmPetInfo),
            Grade_Riseup_Lucky = get_grade_riseup_lucky_from_mypetinfo(PetInfo),
            Quality_Riseup_Lucky = get_quality_riseup_lucky_from_mypetinfo(PetInfo),
			PetStage = get_quality_riseup_retries_from_mypetinfo(PetInfo),

            AttrAdd = get_system_attr_add(Level, Grade, ProtoId),

			{Power,Hitrate,Dodge,Criticalrate,CriticalDamage,Life,Toughness,MagicDefense,FarDefense,NearDefense}=
				compute_attr(Class,AttrAdd,SkillEff,EquipEff),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power,				
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
                                            dodge = Dodge,
                                            life = Life,
                                            hpmax = Life,
                                            defense = 0
           %                                  magic_defense = MagicDefense,
											% far_defense = FarDefense,
											% near_defense = NearDefense
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			{PowerAttr,HitrateAttr,DodgeAttr,CriticalrateAttr,CriticaldamageAttr,LifeAttr,_Toughness,MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr} = AttrAdd,
            NewPetInfo = set_attr_to_mypetinfo(PetInfo,AttrAdd),
            pet_op:update_pet_info_all(NewPetInfo),
			pet_attr:only_self_update(PetId,
									[{pet_power,PowerAttr},
									 {pet_hitrate,HitrateAttr},
                                     {pet_dodge,DodgeAttr},
									 {pet_criticalrate,CriticalrateAttr},
                                     {pet_life,LifeAttr},
									 {power,Power},
									 {hitrate,Hitrate},
                                     {dodge,Dodge},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {life,Life},
                                     {pet_grade,Grade},
                                     {pet_quality,Quality},
                                     {pet_savvy,Savvy},
                                     {pet_grade_riseup_lucky,Grade_Riseup_Lucky},
                                     {pet_quality_riseup_lucky,Quality_Riseup_Lucky},
									 {pet_stage, PetStage}
									]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			role_op:recompute_pet_attr(),
			RoleAttr = get(other_attr),
			Msg = role_packet:encode_role_attribute_s2c(get(roleid),RoleAttr),
			role_op:send_data_to_gate(Msg)
		end;
%% 
%%等级变化后计算属性 
%%
%%等级影响系统加成点 和玩家可分配点数
%% 
recompute_attr(levelup,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_pet_gminfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			SkillEff = get_skill_attr_self(PetId),
			EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
			Grade = get_grade_from_petinfo(GmPetInfo),
            Level = get_level_from_petinfo(GmPetInfo),
            NewExp = get_exp_from_petinfo(GmPetInfo),
            Quality = get_quality_from_petinfo(GmPetInfo),


			% Magic_defense = GmPetInfo#gm_pet_info.magic_defense,
			% Far_defense = GmPetInfo#gm_pet_info.far_defense,
			% Near_defense = GmPetInfo#gm_pet_info.near_defense,



%            Quality_Value_Info = get_quality_value_info_from_mypetinfo(PetInfo),
%            {Quality_Value_Power,Quality_Value_Hitrate,Quality_Value_Dodge,Quality_Value_Criticalrate,Quality_Value_Criticaldamage,Quality_Value_Life,Quality_Value_Defense} = Quality_Value_Info,

            AttrAdd = get_system_attr_add(Level,Grade,ProtoId),
			{Power,Hitrate,Dodge,Criticalrate,CriticalDamage,Life,Toughness,MagicDefense,FarDefense,NearDefense}=
				compute_attr(Class,AttrAdd,SkillEff,EquipEff),
			% slogger:msg("aaaaaaaaaaaaaaaaaaaaaa32~p,new:~p~n",[AttrAdd,{MagicDefense,FarDefense,NearDefense}]),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power,				
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
                                            dodge = Dodge,
                                            life = Life,
                                            hpmax = Life,
                                            defense = 0,
                                            magic_defense = MagicDefense,
											far_defense = FarDefense,
											near_defense = NearDefense
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			{PowerAttr,HitrateAttr,DodgeAttr,CriticalrateAttr,CriticaldamageAttr,LifeAttr,_Toughness,MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr} = AttrAdd,
            NewPetInfo = set_attr_to_mypetinfo(PetInfo,AttrAdd),
            pet_op:update_pet_info_all(NewPetInfo),
			pet_attr:only_self_update(PetId,
									[{pet_power,PowerAttr},
									 {pet_hitrate,HitrateAttr},
                                     {pet_dodge,DodgeAttr},
									 {pet_criticalrate,CriticalrateAttr},
                                     {pet_life,LifeAttr},
                                     % {pet_defense,{MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr}},
									 {power,Power},
									 {hitrate,Hitrate},
                                     {dodge,Dodge},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {life,Life},
                                     % {defense,{MagicDefense,FarDefense,NearDefense}},
                                     {expr,NewExp},
                                     {level,Level}
									]),
			pet_attr:self_update_and_broad(PetId,[{level,Level},{expr,NewExp}]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			role_op:recompute_pet_attr(),
			pet_op:save_pet_to_db(PetId)
	end;


%% 
%%宠物模板变换
%%
%% 
recompute_attr(proto,{PetId,OldProtoId})->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_pet_gminfo(PetId),
			ProtoId = get_proto_from_petinfo(GmPetInfo),
			PetProtoInfo = pet_proto_db:get_info(ProtoId),
			SkillEff = get_skill_attr_self(PetId),
			EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
			EquipEff = pet_equip_op:get_attr_by_equipinfo(EquipInfo),
			Class = pet_proto_db:get_class(PetProtoInfo),
            Grade = get_grade_from_petinfo(GmPetInfo),
            Quality = get_quality_from_petinfo(GmPetInfo),
            Level = get_level_from_petinfo(GmPetInfo),
            Savvy = get_savvy_from_petinfo(GmPetInfo),
            Name = get_name_from_petinfo(GmPetInfo),

%            Quality_Value_Info = get_quality_value_info_from_mypetinfo(PetInfo),
 %           {Quality_Value_Power,Quality_Value_Hitrate,Quality_Value_Dodge,Quality_Value_Criticalrate,Quality_Value_Criticaldamage,Quality_Value_Life,Quality_Value_Defense} = Quality_Value_Info,
%            Quality_Value_Up_Info = get_quality_value_up_info_from_mypetinfo(PetInfo),
            Grade_Riseup_Lucky = get_grade_riseup_lucky_from_mypetinfo(PetInfo),
            Quality_Riseup_Lucky = get_quality_riseup_lucky_from_mypetinfo(PetInfo),

            AttrAdd = get_system_attr_add(Level,Grade,ProtoId),

			{Power,Hitrate,Dodge,Criticalrate,CriticalDamage,Life,Toughness,MagicDefense,FarDefense,NearDefense}=
				compute_attr(Class,AttrAdd,[],EquipEff),
			NewGmPetInfo = GmPetInfo#gm_pet_info{
											power = Power,				
											hitrate = Hitrate,		
											criticalrate = Criticalrate,
											criticaldamage = CriticalDamage, 		
                                            dodge = Dodge,
                                            life = Life,
                                            hpmax = Life,
                                            defense = 0,
                                            name = Name,
                                            magic_defense = MagicDefense,
											far_defense = FarDefense,
											near_defense = NearDefense
											},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
			{PowerAttr,HitrateAttr,DodgeAttr,CriticalrateAttr,CriticaldamageAttr,LifeAttr,_Toughness,MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr} = AttrAdd,
            NewPetInfo = set_attr_to_mypetinfo(PetInfo,AttrAdd),
            pet_op:update_pet_info_all(NewPetInfo),
			pet_attr:only_self_update(PetId,
									[{pet_power,PowerAttr},
									 {pet_hitrate,HitrateAttr},
                                     {pet_dodge,DodgeAttr},
									 {pet_criticalrate,CriticalrateAttr},
                                     {pet_life,LifeAttr},
                                     % {pet_defense,{MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr}},
									 {power,Power},
									 {hitrate,Hitrate},
                                     {dodge,Dodge},
									 {criticalrate,Criticalrate},
									 {criticaldestroyrate,CriticalDamage},
									 {life,Life},
                                     % {defense,{MagicDefense,FarDefense,NearDefense}},
                                     {pet_grade,Grade},
                                     {pet_quality,Quality},
                                     {pet_savvy,Savvy},
%                                     {pet_quality_value_power,Quality_Value_Power},
%                                     {pet_quality_value_hitrate,Quality_Value_Hitrate},
%                                     {pet_quality_value_dodge,Quality_Value_Dodge},
%                                     {pet_quality_value_criticalrate,Quality_Value_Criticalrate},
%                                     {pet_quality_value_life,Quality_Value_Life},
%                                     {pet_quality_value_defense,Quality_Value_Defense},
%                                     {pet_quality_value_up,Quality_Value_Up_Info},
                                     {pet_grade_riseup_lucky,Grade_Riseup_Lucky},
                                     {pet_quality_riseup_lucky,Quality_Riseup_Lucky}
									]),
			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE->
					pet_attr:self_update_and_broad(PetId,
									[{pet_proto,ProtoId},
									 {name,Name},
									 {pet_quality,Quality}
									]);
				_->
					pet_attr:only_self_update(PetId,
									[{pet_proto,ProtoId},
									 {name,Name},
									 {pet_quality,Quality}
									]),
					nothing
			end,
			pet_op:save_pet_to_db(PetId),
			role_op:recompute_pet_attr()
	end;
%%
%%悟性变化后发送所有属性
%%
recompute_attr(savvy,PetId)->	
	case lists:keyfind(PetId,#my_pet_info.petid,get(pets_info)) of
		false->
			nothing;
		PetInfo->
			GmPetInfo = pet_op:get_pet_gminfo(PetId),
            Savvy = get_savvy_from_petinfo(GmPetInfo),
			NewGmPetInfo = GmPetInfo#gm_pet_info{savvy = Savvy},
			pet_op:update_gm_pet_info_all(NewGmPetInfo),
           		pet_op:update_pet_info_all(PetInfo),
			pet_attr:only_self_update(PetId, [{pet_savvy,Savvy}]),
			pet_op:save_pet_to_db(PetId)
	end;

% 类型转换后
recompute_attr(type_change, PetId) ->	
	case pet_op:get_pet_gminfo(PetId) of
		false ->
			nothing;
		GmPetInfo ->
			pet_attr:only_self_update(PetId, [{class, GmPetInfo#gm_pet_info.class}]),
%			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			% 出战中则重新计算玩家属性
			role_op:recompute_pet_attr(),
			% 存数据库
			pet_op:save_pet_to_db(PetId)
	end;

% 精炼
recompute_attr(reset, PetId) ->	
	case GmPetInfo = pet_op:get_pet_gminfo(PetId) of
		false ->
			% slogger:msg("aaaaaaaaaaaa,reset:~p~n",[PetId]),
			nothing;
		GmPetInfo ->
			pet_attr:only_self_update(PetId, [{pet_magic_defense, GmPetInfo#gm_pet_info.magic_defense}, {pet_far_defense, GmPetInfo#gm_pet_info.far_defense}, {pet_near_defense, GmPetInfo#gm_pet_info.near_defense}, {pet_magic_immunity, GmPetInfo#gm_pet_info.magic_immunity}, {pet_far_immunity, GmPetInfo#gm_pet_info.far_immunity}, {pet_near_immunity, GmPetInfo#gm_pet_info.near_immunity}]),

			role_op:recompute_pet_attr(),

			pet_fighting_force:hook_on_change_pet_fighting_force(PetId),
			% 存数据库
			% slogger:msg("aaaaaaaaaaaa,save:~p~n",[PetId]),
			pet_op:save_pet_to_db(PetId)
	end;

%% 
%%重新计算所有属性 
%% 
recompute_attr(all,PetId)->	
	todo.

%%
%%更新宠物交易锁定状态
%%
update_pet_lock_state(PetId,LockState)->
	pet_attr:only_self_update(PetId,[{pet_lock,LockState}]).

get_skill_attr_self(PetId)->
	pet_skill_op:get_skill_addition_for_pet(PetId).

get_skill_attr_master(PetId)->
	pet_skill_op:get_skill_addition_for_role(PetId).

	
power_key(Class)->
	case Class of
		?CLASS_MAGIC ->
			magicpower;		       
		?CLASS_RANGE ->
			rangepower;
		?CLASS_MELEE ->
			meleepower;
		_->
			nothing
	end.

get_pet_quality_color(Quality)->
	case Quality of
		1->?COLOR_WHITE;
		2->?COLOR_GREEN;
		3->?COLOR_BLUE;
		4->?COLOR_PURPLE;
		5->?COLOR_GOLDEN;
		_->0
	end.

%% 计算宠物转换到人物的属性
compute_attr_to_role(PetId) ->
	GmPetInfo = pet_op:get_pet_gminfo(PetId),
	case GmPetInfo of
		#gm_pet_info{life = Life, 
					quality = Quality,
					hitrate = Hitrate,
					criticalrate = Criticalrate,
					criticaldamage = Criticaldamage,
					dodge = Dodge,
					% defense = Defense,
					power = Power,
					class = Class,
					grade = Grade,
					magic_defense = MagicDefense,
					far_defense = FarDefense,
					near_defense = NearDefense,
					magic_immunity = MagicImmunity,
					far_immunity = FarImmunity,
					near_immunity = NearImmunity
		} ->
			% 根据宠物的类型决定添加玩家的攻击属性
			PowerAttr = case Class of
								1 -> [{magicpower, Power}]; % 魔攻
								2 -> [{rangepower, Power}]; % 远攻
								3 -> [{meleepower, Power}]	% 近攻
						end,
			AttrList = [{hpmax, Life}, {hitrate, erlang:max(0,Hitrate - 900)}, {power, Power}, {criticalrate, Criticalrate}, {dodge, Dodge}, {magicdefense, MagicDefense}, {rangedefense, FarDefense}, {meleedefense, NearDefense}, {magicimmunity, MagicImmunity}, {rangeimmunity, FarImmunity}, {meleeimmunity, NearImmunity} | PowerAttr],
			GradeInfo = pet_quality_proto_db:get_info(Quality),
			QualityProperties = pet_quality_proto_db:get_quality_properties_from_info(GradeInfo),
			MyPetInfo = pet_op:get_pet_info(PetId),
			Property = pet_quality_proto_db:get_quality_proto_property_from_properties(QualityProperties, MyPetInfo#my_pet_info.quality_riseup_retries),
			case Property of
					{_Level2, Rate, _MinGrowth, _MaxGrowth} ->
						[ {AttrName, erlang:trunc(AttrValue * Rate / 100) } || {AttrName, AttrValue} <- AttrList];
				_ -> []
			end;
		_ -> Code = ?NPETS_ERROR, throw({error, Code})
	end.

compute_attr_to_role() ->
	F = fun(GmPetInfo,{Acc,AccPetSpecies}) ->
		case GmPetInfo of
			#gm_pet_info{
					id = PetId,
					life = Life, 
					quality = Quality,
					hitrate = Hitrate,
					criticalrate = Criticalrate,
					criticaldamage = Criticaldamage,
					dodge = Dodge,
					proto = ProtoId,
					% defense = Defense,
					power = Power,
					class = Class,
					grade = Grade,
					magic_defense = MagicDefense,
					far_defense = FarDefense,
					near_defense = NearDefense,
					magic_immunity = MagicImmunity,
					far_immunity = FarImmunity,
					near_immunity = NearImmunity,
					refresh_defense = {Magic_defense,Far_defense,Near_defense}
			}  ->

				PetProtoInfo = pet_proto_db:get_info(ProtoId),
				PetSpecies = pet_proto_db:get_species(PetProtoInfo),
				%case lists:any(fun(PetSpecy)->PetSpecy =:=PetSpecies  end,AccPetSpecies) of
				% 	true ->
				% 		{Acc,AccPetSpecies};
				% 	false ->
						GradeInfo = pet_quality_proto_db:get_info(Quality),
						QualityProperties = pet_quality_proto_db:get_quality_properties_from_info(GradeInfo),
						MyPetInfo = pet_op:get_pet_info(PetId),
						Property = pet_quality_proto_db:get_quality_proto_property_from_properties(QualityProperties, MyPetInfo#my_pet_info.quality_riseup_retries),
						Rate = case Property of
								{_Level2, Rate0, _MinGrowth, _MaxGrowth} ->
									Rate0;
								_ -> 0
							end,
						Fun = fun(Name,Value) ->
							case Name of
								hpmax ->
									{Name ,Value + erlang:trunc(Life * Rate / 100)};
								hitrate ->
									{Name ,Value + erlang:trunc(erlang:max(0,Hitrate - 900) * Rate / 100)};
								power ->
									{Name ,Value + erlang:trunc(Power * Rate / 100)};
								criticalrate ->
									{Name ,Value + erlang:trunc(Criticalrate * Rate / 100)};
								dodge ->
									{Name ,Value + erlang:trunc(Dodge * Rate / 100)};
								% defense ->
								% 	{Name ,Value + erlang:trunc(Defense * Rate / 100)};
								magicdefense ->
									{Name ,Value + erlang:trunc((MagicDefense + Magic_defense)* Rate / 100)};
								rangedefense ->
									{Name ,Value + erlang:trunc((FarDefense + Far_defense)* Rate / 100)};
								meleedefense ->
									{Name ,Value + erlang:trunc((NearDefense + Near_defense)* Rate / 100)};
								magicimmunity ->
									{Name ,Value + erlang:trunc(MagicImmunity * Rate / 100)};
								rangeimmunity ->
									{Name ,Value + erlang:trunc(FarImmunity * Rate / 100)};
								meleeimmunity ->
									{Name ,Value + erlang:trunc(NearImmunity * Rate / 100)};
								magicpower ->
									{Name ,erlang:trunc(Power * Rate / 100) + Value};
								rangepower ->
									{Name ,erlang:trunc(Power * Rate / 100) + Value};
								meleepower ->
									{Name ,erlang:trunc(Power * Rate / 100) + Value}

							end

						end,
						{[Fun(Name,Value)||{Name,Value}<-Acc],AccPetSpecies};
				% end;
				
			_ -> {Acc,AccPetSpecies}
		end
	end,
	{Add_Attr,_} = lists:foldl(F,{[{hpmax, 0}, {hitrate, 0}, {power, 0}, {criticalrate, 0}, {dodge, 0}, {magicdefense, 0}, {rangedefense, 0}, {meleedefense, 0}, {magicimmunity, 0}, {rangeimmunity, 0}, {meleeimmunity, 0}, {magicpower, 0}, {rangepower, 0}, {meleepower, 0}],[]}, get(gm_pets_info)),
	Add_Attr.


make_value(Value) ->
	if Value < 0 -> 
			0;
		true ->
			Value
	end.