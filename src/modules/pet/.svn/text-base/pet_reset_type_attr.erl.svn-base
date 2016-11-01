-module(pet_reset_type_attr).

-export([do_pet_reset_type_attr/4]).

-include("pet_def.hrl").
-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("webgame.hrl").
-include("common_define.hrl").
-include("role_struct.hrl").

% 防御类
-define(DEFENSE_ATTR, 1).
% 减免类
-define(IMMUNITY_ATTR, 2).

% 宠物资质精炼
do_pet_reset_type_attr(PetId, Type, AttrList, RoleState) ->
	% 该宠物是否存在
	case pet_op:get_pet_gminfo(PetId) of
		[] ->
			{error, ?ERROR_PET_NOEXIST};
		GmPetInfo ->
			% 属性是否重复锁定
			case is_lock_repeat(AttrList) of
				true ->
					{error, ?ERROR_PET_TYPE_ATTR_LOCK_REPEAT};
				false ->
					% 该类型最大可锁定条数
					case pet_reset_type_attr_db:get_pet_type_attr_value_config(Type) of
						{error, Code} ->
							{error, Code};
						PetTypeAttrValueList ->
							% 本次锁定条数
							case length(AttrList) > length(PetTypeAttrValueList) of
								true ->
									{error, ?ERROR_SYSTEM};
								false ->
									case AttrList =:= [] of
										true ->
											{error, ?ERROR_PET_TYPE_ATTR_NOT_ALL_LOCK};
										false ->
											LockNum = length(PetTypeAttrValueList) - length(AttrList),
											% 锁定条数对应信息
											case pet_reset_type_attr_db:get_lock_info(Type, LockNum) of
												{error, Code} ->
													{error, Code};
												LockInfo ->
													% 金币是否充足
													Gold = LockInfo#pet_type_attr_lock_config.gold,
													case role_op:check_money(?MONEY_GOLD, Gold) of
														false ->
															{error, ?ERROR_LESS_GOLD};
														true ->
															% 道具是否充足
															PropNumList = LockInfo#pet_type_attr_lock_config.prop_list,
															case equipment_move:prop_enough(PropNumList) of
																false ->
																	{error, ?ERROR_PET_TYPE_ATTR_NOT_ENOUGH};
																true ->
																	% 属性是否存在
																	case is_exist_attr(AttrList, Type) of
																		{error, Code} ->
																			{error, Code};
																		true ->
																			%%玩家ID
													  						RoleId = get(roleid),
													  						%%玩家名称
													  						RoleInfo = get(creature_info),
													  						RoleName = get_name_from_roleinfo(RoleInfo),
													  						% 仙仆名称
													  						PetName = get_name_from_petinfo(GmPetInfo),
																			% 计算精炼后的属性
																			NewGmPetInfo = computer_attr(AttrList, GmPetInfo, Type),
																			% 获取潜能修炼属性列表
																			[NewMagic,NewFar,NewNear] = get_ability_attr(NewGmPetInfo, Type),
																			[OldMagic,OldFar,OldNear] = get_ability_attr(GmPetInfo, Type),
																			% 锁定属性
																			LockAttr = json:encode([1,2,3]--AttrList),
																			FieldValue = [RoleId,RoleName,PetId,PetName,Type,LockAttr,OldMagic,OldFar,OldNear,NewMagic,NewFar,NewNear],
		                      					  							gm_logger_role:insert_log_pet_alility_riseup(FieldValue),
																			% 更新内存数据
																			pet_op:update_gm_pet_info_all(NewGmPetInfo),
																			% 计算、保存
																			pet_util:recompute_attr(reset, PetId),
																			% 扣除道具
																			ok = equipment_move:delete_prop(PropNumList),
																			% 扣钱
																			role_op:money_change(?MONEY_GOLD, -Gold, reset),
                                                                            broadcast_op:pet_reset(NewGmPetInfo, get(broadcast_reset)),
																			{ok, RoleState, get_attr(NewGmPetInfo, Type)}
																	end
															end
													end
											end
									end
							end
					end
			end
	end. 

% 属性是否重复锁定
is_lock_repeat([]) ->
	false;
is_lock_repeat([H|T]) ->
	case lists:member(H, T) of
		true ->
			true;
		false ->
			is_lock_repeat(T)
	end.

% 属性是否存在
is_exist_attr([], Type) ->
	true;
is_exist_attr([H|T], Type) ->
	case pet_reset_type_attr_db:get_attr_info(Type, H) of
		{error, Code} ->
			{error, Code};
		_Other ->
			is_exist_attr(T, Type)
	end.

% 获取属性列表
get_attr(GmPetInfo, ?DEFENSE_ATTR) ->
    % [GmPetInfo#gm_pet_info.magic_defense,
    %  GmPetInfo#gm_pet_info.far_defense,
    %  GmPetInfo#gm_pet_info.near_defense];
    tuple_to_list(GmPetInfo#gm_pet_info.refresh_defense);
get_attr(GmPetInfo, ?IMMUNITY_ATTR) ->
    [GmPetInfo#gm_pet_info.magic_immunity,
     GmPetInfo#gm_pet_info.far_immunity,
     GmPetInfo#gm_pet_info.near_immunity];
get_attr(_, _) -> slogger:msg("~p get attr error", [?MODULE]), [0, 0, 0].

% 获取潜能修炼属性列表
get_ability_attr(GmPetInfo, ?DEFENSE_ATTR) ->
    [MagicDefense,FarDefense,NearDefense] = [GmPetInfo#gm_pet_info.magic_defense,
     GmPetInfo#gm_pet_info.far_defense,
     GmPetInfo#gm_pet_info.near_defense],
    [MagicDefense2,FarDefense2,NearDefense2] = tuple_to_list(GmPetInfo#gm_pet_info.refresh_defense),
    [MagicDefense+MagicDefense2,FarDefense+FarDefense2,NearDefense+NearDefense2];
get_ability_attr(GmPetInfo, ?IMMUNITY_ATTR) ->
    [GmPetInfo#gm_pet_info.magic_immunity,
     GmPetInfo#gm_pet_info.far_immunity,
     GmPetInfo#gm_pet_info.near_immunity];
get_ability_attr(_, _) -> slogger:msg("~p get attr error", [?MODULE]), [0, 0, 0].

% 计算精炼后的属性
computer_attr([], GmPetInfo, _Type) ->
	GmPetInfo;
computer_attr([H|T], GmPetInfo, Type) ->
	NewGmPetInfo = do_computer_attr({Type, H}, GmPetInfo),
	computer_attr(T, NewGmPetInfo, Type).

do_computer_attr({?DEFENSE_ATTR, 1}, GmPetInfo) ->
	AttrInfo = pet_reset_type_attr_db:get_attr_info(?DEFENSE_ATTR, 1),
	{OldMagicDefense,_Far_defense,_Near_defense} = GmPetInfo#gm_pet_info.refresh_defense,
	% {_PetProtoHp, _PetProtoPower, _PetProtoHitRate, _PetProtoDodge, _PetProtoCriticalRate, _PetProtoCriticalDamage, _ProtoToughness, ProtoMagicDefense, _ProtoFarDefense, _ProtoNearDefense, _ProtoMagicImmunity, _ProtoFarImmunity, _ProtoNearImmunity} = pet_proto_db:get_born_abilities(pet_proto_db:get_info(GmPetInfo#gm_pet_info.proto)),
	{_, _, _, _, _, _, _, Base_MagicDefense, _Base_FarDefense, _Base_NearDefense}= pet_util:get_system_attr_add(GmPetInfo#gm_pet_info.level, GmPetInfo#gm_pet_info.grade, GmPetInfo#gm_pet_info.proto),
	NewMagicDefense = new_attr_value(OldMagicDefense, AttrInfo,?DEFENSE_ATTR) + Base_MagicDefense,
	GmPetInfo#gm_pet_info{refresh_defense = {NewMagicDefense,_Far_defense,_Near_defense}};

do_computer_attr({?DEFENSE_ATTR, 2}, GmPetInfo) ->
	AttrInfo = pet_reset_type_attr_db:get_attr_info(?DEFENSE_ATTR, 2),
	{_MagicDefense,OldFarDefense,_Near_defense} = GmPetInfo#gm_pet_info.refresh_defense,
	% {_PetProtoHp, _PetProtoPower, _PetProtoHitRate, _PetProtoDodge, _PetProtoCriticalRate, _PetProtoCriticalDamage, _ProtoToughness, _ProtoMagicDefense, ProtoFarDefense, _ProtoNearDefense, _ProtoMagicImmunity, _ProtoFarImmunity, _ProtoNearImmunity} = pet_proto_db:get_born_abilities(pet_proto_db:get_info(GmPetInfo#gm_pet_info.proto)),
	{_, _, _, _, _, _, _, _Base_MagicDefense, Base_FarDefense, _Base_NearDefense}= pet_util:get_system_attr_add(GmPetInfo#gm_pet_info.level, GmPetInfo#gm_pet_info.grade, GmPetInfo#gm_pet_info.proto),
	NewFarDefense = new_attr_value(OldFarDefense, AttrInfo,?DEFENSE_ATTR) + Base_FarDefense,
	GmPetInfo#gm_pet_info{refresh_defense = {_MagicDefense,NewFarDefense,_Near_defense}};

do_computer_attr({?DEFENSE_ATTR, 3}, GmPetInfo) ->
	AttrInfo = pet_reset_type_attr_db:get_attr_info(?DEFENSE_ATTR, 3),
	{_MagicDefense,_FarDefense,OldNearDefense} = GmPetInfo#gm_pet_info.refresh_defense,
	% {_PetProtoHp, _PetProtoPower, _PetProtoHitRate, _PetProtoDodge, _PetProtoCriticalRate, _PetProtoCriticalDamage, _ProtoToughness, _ProtoMagicDefense, _ProtoFarDefense, ProtoNearDefense, _ProtoMagicImmunity, _ProtoFarImmunity, _ProtoNearImmunity} = pet_proto_db:get_born_abilities(pet_proto_db:get_info(GmPetInfo#gm_pet_info.proto)),
	{_, _, _, _, _, _, _, _Base_MagicDefense, _Base_FarDefense, Base_NearDefense}= pet_util:get_system_attr_add(GmPetInfo#gm_pet_info.level, GmPetInfo#gm_pet_info.grade, GmPetInfo#gm_pet_info.proto),
	NewNearDefense = new_attr_value(OldNearDefense, AttrInfo,?DEFENSE_ATTR) + Base_NearDefense,
	GmPetInfo#gm_pet_info{refresh_defense = {_MagicDefense,_FarDefense,NewNearDefense}};

do_computer_attr({?IMMUNITY_ATTR, 1}, GmPetInfo) ->
	AttrInfo = pet_reset_type_attr_db:get_attr_info(?IMMUNITY_ATTR, 1),
	OldMagicImmunity = GmPetInfo#gm_pet_info.magic_immunity,
	{_PetProtoHp, _PetProtoPower, _PetProtoHitRate, _PetProtoDodge, _PetProtoCriticalRate, _PetProtoCriticalDamage, _ProtoToughness, _ProtoMagicDefense, _ProtoFarDefense, _ProtoNearDefense, ProtoMagicImmunity, _ProtoFarImmunity, _ProtoNearImmunity} = pet_proto_db:get_born_abilities(pet_proto_db:get_info(GmPetInfo#gm_pet_info.proto)),
	NewMagicImmunity = new_attr_value(OldMagicImmunity, AttrInfo,?IMMUNITY_ATTR) + ProtoMagicImmunity,
	GmPetInfo#gm_pet_info{magic_immunity = NewMagicImmunity};

do_computer_attr({?IMMUNITY_ATTR, 2}, GmPetInfo) ->
	AttrInfo = pet_reset_type_attr_db:get_attr_info(?IMMUNITY_ATTR, 2),
	OldFarImmunity = GmPetInfo#gm_pet_info.far_immunity,
	{_PetProtoHp, _PetProtoPower, _PetProtoHitRate, _PetProtoDodge, _PetProtoCriticalRate, _PetProtoCriticalDamage, _ProtoToughness, _ProtoMagicDefense, _ProtoFarDefense, _ProtoNearDefense, _ProtoMagicImmunity, ProtoFarImmunity, _ProtoNearImmunity} = pet_proto_db:get_born_abilities(pet_proto_db:get_info(GmPetInfo#gm_pet_info.proto)),
	NewFarImmunity = new_attr_value(OldFarImmunity, AttrInfo,?IMMUNITY_ATTR) + ProtoFarImmunity,
	GmPetInfo#gm_pet_info{far_immunity = NewFarImmunity};

do_computer_attr({?IMMUNITY_ATTR, 3}, GmPetInfo) ->
	AttrInfo = pet_reset_type_attr_db:get_attr_info(?IMMUNITY_ATTR, 3),
	OldNearImmunity = GmPetInfo#gm_pet_info.near_immunity,
	{_PetProtoHp, _PetProtoPower, _PetProtoHitRate, _PetProtoDodge, _PetProtoCriticalRate, _PetProtoCriticalDamage, _ProtoToughness, _ProtoMagicDefense, _ProtoFarDefense, _ProtoNearDefense, _ProtoMagicImmunity, _ProtoFarImmunity, ProtoNearImmunity} = pet_proto_db:get_born_abilities(pet_proto_db:get_info(GmPetInfo#gm_pet_info.proto)),
	NewNearImmunity = new_attr_value(OldNearImmunity, AttrInfo,?IMMUNITY_ATTR) + ProtoNearImmunity,
	GmPetInfo#gm_pet_info{near_immunity = NewNearImmunity};

do_computer_attr(_Other, GmPetInfo) ->
	GmPetInfo.

% 计算新的属性值
new_attr_value(OldAttrValue, AttrInfo,Tag) ->
	if
		Tag =:= ?DEFENSE_ATTR ->
			BroadcastValue = 400;
		true ->
			BroadcastValue = 100
	end,
	RandomValueList = lists:keysort(2, AttrInfo#pet_type_attr_value_config.random_attr_value),
	RandomNum = util:random_num(),
	try
		lists:foldl(fun(Ele, Acc) ->
					{Value, Random} = Acc,
					{Value2, Prob} = Ele,
					case Random =< Prob of
						true ->
							throw({value, Value2});
						false ->
							{Value, Random - Prob}
					end
			end, {0, RandomNum}, RandomValueList),
		OldAttrValue
	catch
		throw:{value, AttrValue} ->
      if
        (OldAttrValue < BroadcastValue) andalso (AttrValue >= BroadcastValue) ->
          put(broadcast_reset, AttrValue);
        true -> ok
      end,
			trunc(AttrValue)
	end.

do_pet_reset_type_attr2(PetId, Type, AttrList, RoleState) ->
	% 该宠物是否存在
	case pet_op:get_pet_gminfo(PetId) of
		[] ->
			{error, ?ERROR_PET_NOEXIST};
		GmPetInfo ->
			% 是否出战
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_BATTLE ->
					{error, ?ERROR_PET_NO_PACKAGE};
				_Other ->
					% 属性是否重复锁定
					case is_lock_repeat(AttrList) of
						true ->
							{error, ?ERROR_PET_TYPE_ATTR_LOCK_REPEAT};
						false ->
							% 该类型最大可锁定条数
							case pet_reset_type_attr_db:get_pet_type_attr_value_config(Type) of
								{error, Code} ->
									{error, Code};
								PetTypeAttrValueList ->
									% 本次锁定条数
									case length(AttrList) > length(PetTypeAttrValueList) of
										true ->
											{error, ?ERROR_SYSTEM};
										false ->
											case AttrList =:= [] of
												true ->
													{error, ?ERROR_PET_TYPE_ATTR_NOT_ALL_LOCK};
												false ->
													LockNum = length(PetTypeAttrValueList) - length(AttrList),
													% 锁定条数对应信息
													case pet_reset_type_attr_db:get_lock_info(Type, LockNum) of
														{error, Code} ->
															{error, Code};
														LockInfo ->
															% 金币是否充足
															Gold = LockInfo#pet_type_attr_lock_config.gold,
															case role_op:check_money(?MONEY_GOLD, Gold) of
																false ->
																	{error, ?ERROR_LESS_GOLD};
																true ->
																	% 道具是否充足
																	PropNumList = LockInfo#pet_type_attr_lock_config.prop_list,
																	case equipment_move:prop_enough(PropNumList) of
																		false ->
																			{error, ?ERROR_PET_TYPE_ATTR_NOT_ENOUGH};
																		true ->
																			% 属性是否存在
																			case is_exist_attr(AttrList, Type) of
																				{error, Code} ->
																					{error, Code};
																				true ->
																					% 计算精炼后的属性
																					NewGmPetInfo = computer_attr(AttrList, GmPetInfo, Type),
																					% 更新内存数据
																					pet_op:update_gm_pet_info_all(NewGmPetInfo),
																					% 计算、保存
																					pet_util:recompute_attr(reset, PetId),
																					% 扣除道具
																					ok = equipment_move:delete_prop(PropNumList),
																					% 扣钱
																					role_op:money_change(?MONEY_GOLD, -Gold, reset),
                                                                                    broadcast_op:pet_reset(NewGmPetInfo, get(broadcast_reset)),
																					{ok, RoleState, get_attr(NewGmPetInfo, Type)}
																			end
																	end
															end
													end
											end
									end
							end
					end
			end
	end. 