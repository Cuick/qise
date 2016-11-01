-module(pet_inherit_op).

-export([pet_inherit/3,pet_inherit_preview/3]).

-include("pet_def.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").

pet_inherit(MainPetId, AssistantPetId, RoleState) ->
	case travel_battle_op:is_in_zone() of
		false ->
			do_inherit(MainPetId, AssistantPetId, RoleState);
		true ->
			{error, ?TRAVEL_BATTLE_INVALID_OPERATION}
	end.

do_inherit(MainPetId, AssistantPetId, RoleState) ->
	% 不可使用同一宠物继承
	case MainPetId =:= AssistantPetId of
		true ->
			{error, ?ERROR_PET_INHERIT_SAME};
		false ->
			% 主、副宠是否存在
			MainGmPetInfo = pet_op:get_pet_gminfo(MainPetId),
			AssistantGmPetInfo = pet_op:get_pet_gminfo(AssistantPetId),
			case MainGmPetInfo =:= [] orelse AssistantGmPetInfo =:= [] of
				true ->
					{error, ?ERROR_PET_NOEXIST};
				false ->
					% 主、副宠是否出战
					case pet_util:get_state_from_petinfo(MainGmPetInfo) =:= ?PET_STATE_BATTLE orelse pet_util:get_state_from_petinfo(AssistantGmPetInfo) =:= ?PET_STATE_BATTLE of
						true ->
							{error, ?ERROR_PET_NO_PACKAGE};
						false ->
							% skill
							pet_inherit_skill(MainPetId, AssistantPetId),
							% 保留两者最大成长
							case MainGmPetInfo#gm_pet_info.grade >= AssistantGmPetInfo#gm_pet_info.grade of
								true ->
									Grade = MainGmPetInfo#gm_pet_info.grade,
									NewMainGmPetInfo = MainGmPetInfo;
								false ->
									Grade = AssistantGmPetInfo#gm_pet_info.grade,
									NewMainGmPetInfo = MainGmPetInfo#gm_pet_info{grade = Grade}
							end,
							% 保留两者最大资质属性
							% 魔防
							case NewMainGmPetInfo#gm_pet_info.magic_defense >= AssistantGmPetInfo#gm_pet_info.magic_defense of
								true ->
									MagicDefense = NewMainGmPetInfo#gm_pet_info.magic_defense,
									NewMainGmPetInfo2 = NewMainGmPetInfo;
								false ->
									MagicDefense = AssistantGmPetInfo#gm_pet_info.magic_defense,
									NewMainGmPetInfo2 = NewMainGmPetInfo#gm_pet_info{magic_defense = MagicDefense}
							end,
							% 远防
							case NewMainGmPetInfo2#gm_pet_info.far_defense >= AssistantGmPetInfo#gm_pet_info.far_defense of
								true ->
									FarDefense = NewMainGmPetInfo2#gm_pet_info.far_defense,
									NewMainGmPetInfo3 = NewMainGmPetInfo2;
								false ->
									FarDefense = AssistantGmPetInfo#gm_pet_info.far_defense,
									NewMainGmPetInfo3 = NewMainGmPetInfo2#gm_pet_info{far_defense = FarDefense}
							end,
							% 近防
							case NewMainGmPetInfo3#gm_pet_info.near_defense >= AssistantGmPetInfo#gm_pet_info.near_defense of
								true ->
									NearDefense = NewMainGmPetInfo3#gm_pet_info.near_defense,
									NewMainGmPetInfo4 = NewMainGmPetInfo3;
								false ->
									NearDefense = AssistantGmPetInfo#gm_pet_info.near_defense,
									NewMainGmPetInfo4 = NewMainGmPetInfo3#gm_pet_info{near_defense = NearDefense}
							end,
							
							% 魔免疫
							case NewMainGmPetInfo4#gm_pet_info.magic_immunity >= AssistantGmPetInfo#gm_pet_info.magic_immunity of
								true ->
									MagicImmunity = NewMainGmPetInfo4#gm_pet_info.magic_immunity,
									NewMainGmPetInfo5 = NewMainGmPetInfo4;
								false ->
									MagicImmunity = AssistantGmPetInfo#gm_pet_info.magic_immunity,
									NewMainGmPetInfo5 = NewMainGmPetInfo4#gm_pet_info{magic_immunity = MagicImmunity}
							end,
							% 远免疫
							case NewMainGmPetInfo5#gm_pet_info.far_immunity >= AssistantGmPetInfo#gm_pet_info.far_immunity of
								true ->
									FarImmunity = NewMainGmPetInfo5#gm_pet_info.far_immunity,
									NewMainGmPetInfo6 = NewMainGmPetInfo5;
								false ->
									FarImmunity = AssistantGmPetInfo#gm_pet_info.far_immunity,
									NewMainGmPetInfo6 = NewMainGmPetInfo5#gm_pet_info{far_immunity = FarImmunity}
							end,
							% 近免疫
							case NewMainGmPetInfo6#gm_pet_info.near_immunity >= AssistantGmPetInfo#gm_pet_info.near_immunity of
								true ->
									NearImmunity = NewMainGmPetInfo6#gm_pet_info.near_immunity,
									NewMainGmPetInfo7 = NewMainGmPetInfo6;
								false ->
									NearImmunity = AssistantGmPetInfo#gm_pet_info.near_immunity,
									NewMainGmPetInfo7 = NewMainGmPetInfo6#gm_pet_info{near_immunity = NearImmunity}
							end,
							% 保留两者最大等级
							case NewMainGmPetInfo7#gm_pet_info.level >= AssistantGmPetInfo#gm_pet_info.level of
								true ->
									Level = NewMainGmPetInfo7#gm_pet_info.level,
									NewMainGmPetInfo8 = NewMainGmPetInfo7;
								false ->
									Level = AssistantGmPetInfo#gm_pet_info.level,
									NewMainGmPetInfo8 = NewMainGmPetInfo7#gm_pet_info{totalexp = AssistantGmPetInfo#gm_pet_info.totalexp, level = Level}
							end,
							% 保留两者最大品质,位阶取品质好的宠物的位阶
							MainMyPetInfo = pet_op:get_pet_info(MainPetId),
							AssistantMyPetInfo = pet_op:get_pet_info(AssistantPetId),
							case NewMainGmPetInfo8#gm_pet_info.quality >= AssistantGmPetInfo#gm_pet_info.quality of
								true ->
                                    if 
                                        NewMainGmPetInfo8#gm_pet_info.quality == AssistantGmPetInfo#gm_pet_info.quality ->
                                            %如果主宠和副宠的品质一样，那么取位阶的最大值
                                            PetStage = erlang:max(MainMyPetInfo#my_pet_info.quality_riseup_retries,AssistantMyPetInfo#my_pet_info.quality_riseup_retries),
                                            NewMainMyPetInfo = MainMyPetInfo#my_pet_info{quality_riseup_retries = PetStage};
                                        true ->
                                            %如果主宠的品质比副宠的品质好，那么保留主宠的位阶
                                            PetStage = MainMyPetInfo#my_pet_info.quality_riseup_retries,
                                            NewMainMyPetInfo = MainMyPetInfo
                                    end,
									Quality = NewMainGmPetInfo8#gm_pet_info.quality,
									NewMainGmPetInfo9 = NewMainGmPetInfo8;
								false ->
                                    %如果副宠的品质好，那么取副宠的品质和副宠的位阶
									Quality = AssistantGmPetInfo#gm_pet_info.quality,
									NewMainGmPetInfo9 = NewMainGmPetInfo8#gm_pet_info{quality = Quality},
                                    PetStage = AssistantMyPetInfo#my_pet_info.quality_riseup_retries,
                                    NewMainMyPetInfo = MainMyPetInfo#my_pet_info{quality_riseup_retries = PetStage}
							end,
							% 重新计算主宠基础属性
							PetTempLateId = get_proto_from_petinfo(NewMainGmPetInfo9),
							BaseAttr = pet_util:get_system_attr_add(Level, Grade, PetTempLateId),
							PetEquipInfo = NewMainMyPetInfo#my_pet_info.equipinfo,
							% Base_Toughness,  Base_MagicDefense, Base_FarDefense, Base_NearDefense

							{A,B,C} = NewMainGmPetInfo4#gm_pet_info.refresh_defense,
							{D,E,F} = AssistantGmPetInfo#gm_pet_info.refresh_defense,
							G = erlang:max(A, D),
							H = erlang:max(B, E),
							I = erlang:max(C, F),
							RefreshDefense = {G,H,I},
							NewMainGmPetInfo10 = NewMainGmPetInfo9#gm_pet_info{refresh_defense = RefreshDefense},
							{Power, HitRate, Dodge, CriticalRate, CriticalDamage, Life, _Toughness,_MagicDefense,_FarDefense,_NearDefense} = pet_util:compute_attr(NewMainGmPetInfo10#gm_pet_info.class, BaseAttr, pet_util:get_skill_attr_self(MainPetId), pet_equip_op:get_attr_by_equipinfo(PetEquipInfo)),
							NewMainGmPetInfo11 = NewMainGmPetInfo10#gm_pet_info{life = Life, power = Power, hitrate = HitRate, criticalrate = CriticalRate, criticaldamage = CriticalDamage, dodge = Dodge, refresh_defense = RefreshDefense},
							% 删除副宠
							pet_op:delete_pet(AssistantPetId, true),
							% 更新内存
							pet_op:update_gm_pet_info_all(NewMainGmPetInfo11),
							pet_op:update_pet_info_all(NewMainMyPetInfo),
							pet_attr:only_self_update(MainPetId,
                            [{pet_grade, Grade},
                            {pet_magic_defense, MagicDefense},
                            {pet_far_defense, FarDefense},
                            {pet_near_defense, NearDefense},
                            {pet_stage, PetStage},
                            {level, Level},
                            {pet_magic_immunity, MagicImmunity},
                            {pet_far_immunity, FarImmunity},
                            {pet_near_immunity, NearImmunity},
                            {pet_quality,Quality},
                            {pet_power, Power},
                            {hitrate, HitRate},
                            {dodge, Dodge},
                            {criticalrate, CriticalRate},
                            {pet_criticaldamage, CriticalDamage},
                            {life, Life},
                            {pet_defense1, RefreshDefense}
                            % {defense, RefreshDefense}
                            ]),
							% 保存数据库
							pet_op:save_pet_to_db(MainPetId),
							% 重新计算战斗力
							pet_fighting_force:hook_on_change_pet_fighting_force(MainPetId),

							Msg = pet_packet:encode_pet_inherit_s2c(MainPetId),
							role_op:send_data_to_gate(Msg),

							{ok, RoleState}
					end
			end
	end.


pet_inherit_skill(MainPetId, AssistantPetId) ->
	MainSkillList = get_skill_list(MainPetId),
	OtherSkillList = get_skill_list(AssistantPetId),
	NewMainSkillList = compare(MainSkillList,OtherSkillList),
	NewOtherSkillList = compare(OtherSkillList,NewMainSkillList),
	NewSkillList = lists:reverse(lists:keysort(2,NewOtherSkillList ++ NewMainSkillList)),
	put_skill(MainPetId,NewSkillList).




get_skill_list(PetId) ->
	case lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			% slogger:msg("aaaaaaaaaaaaaaaaaaaaaNo such pet~p~n",[{PetId}]),
			nothing;
		{_MainPetId,OriSkillsInfo}->
				SkillList = lists:foldl(fun({Slot,{CurSlotSkill,Level,_},Status},Acc)->
								
								case Status of
								 	?PET_SKILL_SLOT_ACTIVE ->
								 		Acc ++ [{CurSlotSkill,Level,0}];
								 	_ ->
								 		Acc
								 end 
							end,[],OriSkillsInfo)
	end.

compare(FirsrSkillList,SecondSkillList) ->
	F =fun(SkillId,Level) ->
		 case check_echo(SkillId,Level,SecondSkillList) of
			true ->
				[];
			false ->
				{SkillId,Level,0}
		end
	end,
	NewList = [F(SkillId,Level)||{SkillId,Level,_}<-FirsrSkillList],
	lists:flatten(NewList).

check_echo(SkillId,Level,OtherSkillList) ->
	lists:foldl(fun({OSkillId,OLevel,_Time},Acc) -> 
		if
			SkillId =:=  OSkillId->
				if Level =< OLevel->
						true;
					true ->
						Acc
				end;
			true ->
				Acc
		end
	end,false,OtherSkillList).

put_skill(PetId,SkillList) ->
	case lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			nothing;
		{_PetId,OriSkillsInfo}->
				{NewSkillList,_LeftSkills} = lists:foldl(fun({Slot,_,Status},{Acc,SkillListAcc})->
								
								if Status =/= ?PET_SKILL_SLOT_NOT_OPEN ->
										case SkillListAcc of
											[] ->
												NewSlot = {Slot,{0,0,0},?PET_SKILL_SLOT_INACTIVE},
												{lists:keyreplace(Slot,1,Acc,NewSlot),[]};
											[Head|Tail] ->
												NewSlot = {Slot,Head,?PET_SKILL_SLOT_ACTIVE},
												{lists:keyreplace(Slot,1,Acc,NewSlot),Tail}
										end;
									true->
										{Acc,SkillListAcc}
								end
							end,{OriSkillsInfo,SkillList},OriSkillsInfo),

				put(pets_skill_info,lists:keyreplace(PetId,1,get(pets_skill_info),{PetId,NewSkillList})),
				%% slot info 
				SlotInfo = lists:map(fun({Slot,_,SlotState})-> pet_packet:make_psll(Slot,SlotState) end,NewSkillList),
				SlotInitMsg = pet_packet:encode_init_pet_skill_slots_s2c(pet_packet:make_psl(PetId,SlotInfo)),
				role_op:send_data_to_gate(SlotInitMsg),
				%%skill info
				Skills = lists:map(fun({Slot,{SkillId,Level,CastTime},_})-> pet_packet:make_psk(Slot,SkillId,Level) end,NewSkillList),
				SendSkillInfo = pet_packet:encode_learned_pet_skill_s2c(pet_packet:make_ps(PetId,Skills)),
				role_op:send_data_to_gate(SendSkillInfo),

				lists:map(fun({Slot,{SkillId,Level,_CastTime},_})-> 
					SkillMsgBin = pet_packet:encode_update_pet_skill_s2c(PetId,pet_packet:make_psk(Slot,SkillId,Level)),
					role_op:send_data_to_gate(SkillMsgBin) 
				end,NewSkillList)		
	end.

pet_inherit_preview(MainPetId, AssistantPetId, RoleState) ->
% do_inherit(MainPetId, AssistantPetId, RoleState) ->
	% 不可使用同一宠物继承
	case MainPetId =:= AssistantPetId of
		true ->
			{error, ?ERROR_PET_INHERIT_SAME};
		false ->
			% 主、副宠是否存在
			MainGmPetInfo = pet_op:get_pet_gminfo(MainPetId),
			AssistantGmPetInfo = pet_op:get_pet_gminfo(AssistantPetId),
			case MainGmPetInfo =:= [] orelse AssistantGmPetInfo =:= [] of
				true ->
					{error, ?ERROR_PET_NOEXIST};
				false ->
					% 主、副宠是否出战
					case pet_util:get_state_from_petinfo(MainGmPetInfo) =:= ?PET_STATE_BATTLE orelse pet_util:get_state_from_petinfo(AssistantGmPetInfo) =:= ?PET_STATE_BATTLE of
						true ->
							{error, ?ERROR_PET_NO_PACKAGE};
						false ->
							% skill
							pet_inherit_skill(MainPetId, AssistantPetId),
							% 保留两者最大成长
							case MainGmPetInfo#gm_pet_info.grade >= AssistantGmPetInfo#gm_pet_info.grade of
								true ->
									Grade = MainGmPetInfo#gm_pet_info.grade,
									NewMainGmPetInfo = MainGmPetInfo;
								false ->
									Grade = AssistantGmPetInfo#gm_pet_info.grade,
									NewMainGmPetInfo = MainGmPetInfo#gm_pet_info{grade = Grade}
							end,
							% 保留两者最大资质属性
							% 魔防
							case NewMainGmPetInfo#gm_pet_info.magic_defense >= AssistantGmPetInfo#gm_pet_info.magic_defense of
								true ->
									MagicDefense = NewMainGmPetInfo#gm_pet_info.magic_defense,
									NewMainGmPetInfo2 = NewMainGmPetInfo;
								false ->
									MagicDefense = AssistantGmPetInfo#gm_pet_info.magic_defense,
									NewMainGmPetInfo2 = NewMainGmPetInfo#gm_pet_info{magic_defense = MagicDefense}
							end,
							% 远防
							case NewMainGmPetInfo2#gm_pet_info.far_defense >= AssistantGmPetInfo#gm_pet_info.far_defense of
								true ->
									FarDefense = NewMainGmPetInfo2#gm_pet_info.far_defense,
									NewMainGmPetInfo3 = NewMainGmPetInfo2;
								false ->
									FarDefense = AssistantGmPetInfo#gm_pet_info.far_defense,
									NewMainGmPetInfo3 = NewMainGmPetInfo2#gm_pet_info{far_defense = FarDefense}
							end,
							% 近防
							case NewMainGmPetInfo3#gm_pet_info.near_defense >= AssistantGmPetInfo#gm_pet_info.near_defense of
								true ->
									NearDefense = NewMainGmPetInfo3#gm_pet_info.near_defense,
									NewMainGmPetInfo4 = NewMainGmPetInfo3;
								false ->
									NearDefense = AssistantGmPetInfo#gm_pet_info.near_defense,
									NewMainGmPetInfo4 = NewMainGmPetInfo3#gm_pet_info{near_defense = NearDefense}
							end,
							
							% 魔免疫
							case NewMainGmPetInfo4#gm_pet_info.magic_immunity >= AssistantGmPetInfo#gm_pet_info.magic_immunity of
								true ->
									MagicImmunity = NewMainGmPetInfo4#gm_pet_info.magic_immunity,
									NewMainGmPetInfo5 = NewMainGmPetInfo4;
								false ->
									MagicImmunity = AssistantGmPetInfo#gm_pet_info.magic_immunity,
									NewMainGmPetInfo5 = NewMainGmPetInfo4#gm_pet_info{magic_immunity = MagicImmunity}
							end,
							% 远免疫
							case NewMainGmPetInfo5#gm_pet_info.far_immunity >= AssistantGmPetInfo#gm_pet_info.far_immunity of
								true ->
									FarImmunity = NewMainGmPetInfo5#gm_pet_info.far_immunity,
									NewMainGmPetInfo6 = NewMainGmPetInfo5;
								false ->
									FarImmunity = AssistantGmPetInfo#gm_pet_info.far_immunity,
									NewMainGmPetInfo6 = NewMainGmPetInfo5#gm_pet_info{far_immunity = FarImmunity}
							end,
							% 近免疫
							case NewMainGmPetInfo6#gm_pet_info.near_immunity >= AssistantGmPetInfo#gm_pet_info.near_immunity of
								true ->
									NearImmunity = NewMainGmPetInfo6#gm_pet_info.near_immunity,
									NewMainGmPetInfo7 = NewMainGmPetInfo6;
								false ->
									NearImmunity = AssistantGmPetInfo#gm_pet_info.near_immunity,
									NewMainGmPetInfo7 = NewMainGmPetInfo6#gm_pet_info{near_immunity = NearImmunity}
							end,
							% 保留两者最大等级
							case NewMainGmPetInfo7#gm_pet_info.level >= AssistantGmPetInfo#gm_pet_info.level of
								true ->
									Level = NewMainGmPetInfo7#gm_pet_info.level,
									NewMainGmPetInfo8 = NewMainGmPetInfo7;
								false ->
									Level = AssistantGmPetInfo#gm_pet_info.level,
									NewMainGmPetInfo8 = NewMainGmPetInfo7#gm_pet_info{totalexp = AssistantGmPetInfo#gm_pet_info.totalexp, level = Level}
							end,
							% 保留两者最大品质,位阶取品质好的宠物的位阶
							MainMyPetInfo = pet_op:get_pet_info(MainPetId),
							AssistantMyPetInfo = pet_op:get_pet_info(AssistantPetId),
							case NewMainGmPetInfo8#gm_pet_info.quality >= AssistantGmPetInfo#gm_pet_info.quality of
								true ->
                                    if 
                                        NewMainGmPetInfo8#gm_pet_info.quality == AssistantGmPetInfo#gm_pet_info.quality ->
                                            %如果主宠和副宠的品质一样，那么取位阶的最大值
                                            PetStage = erlang:max(MainMyPetInfo#my_pet_info.quality_riseup_retries,AssistantMyPetInfo#my_pet_info.quality_riseup_retries),
                                            NewMainMyPetInfo = MainMyPetInfo#my_pet_info{quality_riseup_retries = PetStage};
                                        true ->
                                            %如果主宠的品质比副宠的品质好，那么保留主宠的位阶
                                            PetStage = MainMyPetInfo#my_pet_info.quality_riseup_retries,
                                            NewMainMyPetInfo = MainMyPetInfo
                                    end,
									Quality = NewMainGmPetInfo8#gm_pet_info.quality,
									NewMainGmPetInfo9 = NewMainGmPetInfo8;
								false ->
                                    %如果副宠的品质好，那么取副宠的品质和副宠的位阶
									Quality = AssistantGmPetInfo#gm_pet_info.quality,
									NewMainGmPetInfo9 = NewMainGmPetInfo8#gm_pet_info{quality = Quality},
                                    PetStage = AssistantMyPetInfo#my_pet_info.quality_riseup_retries,
                                    NewMainMyPetInfo = MainMyPetInfo#my_pet_info{quality_riseup_retries = PetStage}
							end,
							% 重新计算主宠基础属性
							PetTempLateId = get_proto_from_petinfo(NewMainGmPetInfo9),
							BaseAttr = pet_util:get_system_attr_add(Level, Grade, PetTempLateId),
							PetEquipInfo = NewMainMyPetInfo#my_pet_info.equipinfo,
							% Base_Toughness,  Base_MagicDefense, Base_FarDefense, Base_NearDefense

							{A,B,C} = NewMainGmPetInfo4#gm_pet_info.refresh_defense,
							{D,E,F} = AssistantGmPetInfo#gm_pet_info.refresh_defense,
							G = erlang:max(A, D),
							H = erlang:max(B, E),
							I = erlang:max(C, F),
							RefreshDefense = {G,H,I},
							NewMainGmPetInfo10 = NewMainGmPetInfo9#gm_pet_info{refresh_defense = RefreshDefense},
							{Power, HitRate, Dodge, CriticalRate, CriticalDamage, Life, _Toughness,_MagicDefense,_FarDefense,_NearDefense} = pet_util:compute_attr(NewMainGmPetInfo10#gm_pet_info.class, BaseAttr, pet_util:get_skill_attr_self(MainPetId), pet_equip_op:get_attr_by_equipinfo(PetEquipInfo)),
							NewMainGmPetInfo11 = NewMainGmPetInfo10#gm_pet_info{life = Life, power = Power, hitrate = HitRate, criticalrate = CriticalRate, criticaldamage = CriticalDamage, dodge = Dodge, refresh_defense = RefreshDefense},			
							New_pet_info=[Power, HitRate, Dodge, CriticalRate, CriticalDamage, Life, MagicDefense+G, FarDefense+H, NearDefense+I, MagicImmunity, FarImmunity, NearImmunity],
							Msg = pet_packet:encode_pet_inherit_preview_s2c(New_pet_info),
							role_op:send_data_to_gate(Msg),
							{ok, RoleState}
					end
			end
	end.