%% Author: SQ.Wang
%% Created: 2011-12-23
%% Description: TODO: Add description to equipment_move
-module(equipment_move).

%%
%% Include files
%%
-export([equipment_move/2, prop_enough/1, delete_prop/1]).

-include("error_msg.hrl").
-include("equipment_define.hrl").
-include("equipment_up_def.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
%%
%% Exported Functions
%%

%%
%% API Functions
%%
equipment_move(FromSlot,ToSlot)->
	case package_op:get_iteminfo_in_normal_slot(FromSlot) of 
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		FromEquip->
			FromStars = get_enchantments_from_iteminfo(FromEquip),
			FromSockets = get_socketsinfo_from_iteminfo(FromEquip),
			FromEnchant = get_enchant_from_iteminfo(FromEquip),
			Flag = FromSockets =:= [] andalso FromStars =:= 0 andalso FromEnchant =:= [],
			if
				Flag ->
					Errno = [];
				true ->
					case package_op:get_iteminfo_in_normal_slot(ToSlot) of
						[]->
							Errno = ?ERROR_EQUIPMENT_NOEXIST;
						ToEquip->
							ToLevel = get_level_from_iteminfo(ToEquip),
							% 该等级装备强化转移信息
							case equipment_move_info(ToLevel) of
								{error, Errno} ->
									ok;
								EquimentMoveInfo ->
									% 装备品质是否符合要求
									EquipmentMoveQuality = EquimentMoveInfo#equipment_move.quality_list,
									case lists:member(get_qualty_from_iteminfo(FromEquip), EquipmentMoveQuality) andalso lists:member(get_qualty_from_iteminfo(ToEquip), EquipmentMoveQuality) of
										false ->
											Errno = ?ERROR_EQUIPMENT_MOVE_QUALITY;
										true ->
											% 转移道具是否充足
											PropList = EquimentMoveInfo#equipment_move.prop_list,
											case prop_enough(PropList) of
												false ->
													Errno = ?ERROR_EQUIPMENT_MOVE_PROP_NOT_ENOUGH;
												true ->
													FromInvent = get_inventorytype_from_iteminfo(FromEquip),
													ToInvent = get_inventorytype_from_iteminfo(ToEquip),
													case FromInvent =:= ToInvent of
														false ->
															Errno = ?ERROR_EQUIPMENT_CANNOT_MOVE;
														true ->
															Money = EquimentMoveInfo#equipment_move.need_cupro,
															case role_op:check_money(?MONEY_BOUND_SILVER, Money) of
																true->
																	Errno=[],
																	% FromStars = get_enchantments_from_iteminfo(FromEquip),
																	% FromSockets = get_socketsinfo_from_iteminfo(FromEquip),
																	% FromEnchant = get_enchant_from_iteminfo(FromEquip),
																	role_op:money_change(?MONEY_BOUND_SILVER, -Money, lost_equip_move),
																	% 扣除道具
																	ok = delete_prop(PropList),
																	equipment_op:change_enchantment_attr(FromSlot,0),
																	equipment_op:change_enchantment_attr(ToSlot,FromStars),
																	equipment_op:change_socket_attr(FromSlot,[]),
																	equipment_op:change_socket_attr(ToSlot,FromSockets),
																	equipment_op:change_enchant_attr(FromSlot,[]),
																	equipment_op:change_enchant_attr(ToSlot,FromEnchant),
																	equipment_op:recompute_equipment_attr(FromSlot,get_id_from_iteminfo(FromEquip)),
																	equipment_op:recompute_equipment_attr(ToSlot,get_id_from_iteminfo(ToEquip)),
																	% slogger:msg("sssssssssssssssssssssToEquip:~p~n",[get_id_from_iteminfo(ToEquip)]),	
																	ToEquipAfter = package_op:get_iteminfo_in_normal_slot(ToSlot),
																	ToStarsAfter = get_enchantments_from_iteminfo(ToEquipAfter),
																	ToSocketsAfter = get_socketsinfo_from_iteminfo(ToEquipAfter),
																	ToEnchantAfter = get_enchant_from_iteminfo(ToEquipAfter),
																	
																	FromEquipTemplateId = get_template_id_from_iteminfo(FromEquip),
																	ToEquipTemplateId = get_template_id_from_iteminfo(ToEquipAfter),
																	Rusult = [{ToEquipTemplateId,ToStarsAfter}|ToSocketsAfter] ++ ToEnchantAfter,
																	gm_logger_role:role_enchantments_item(get(roleid),FromEquipTemplateId,move,Rusult,get(level)),
																	Message = equipment_packet:encode_equipment_move_s2c(),
																	role_op:send_data_to_gate(Message);
																false->
																	Errno=?ERROR_LESS_MONEY
															end
													end
											end
									end
							end
					end
			end
	end,
	if 
		Errno =/= []->
			Message_failed = equipment_packet:encode_equipment_riseup_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
		true->
			nothing
	end.

%check_level(FromLevel,ToLevel)->
%	Func = fun({_,Info},Acc)->
%				  if
%						Acc =:= [] ->
%					  	{FSLevel,FELevel} = element(#equipment_move.flevel,Info),
%					  	if
%							(FromLevel >= FSLevel) and (FromLevel =< FELevel) ->
%							{TSLevel,TELevel} = element(#equipment_move.tlevel,Info),
%							if
%						  		(ToLevel >= TSLevel) and (ToLevel =< TELevel) ->
%							  		true;
%						  		true->
%							  		false
%							end;
%						true->
%							Acc
%					  end;
%					true->
%					  Acc
%				  end
%		   end,
%	ets:foldl(Func, [],?EQUIPMENT_MOVE_ETS).

%get_move_money(FromLevel)->
%	Func = fun({_,Info},Acc)->
%				   if
%					  Acc =:= [] ->
%					  	{FSLevel,FELevel} = element(#equipment_move.flevel,Info),
%					  	if
%						  	(FromLevel >= FSLevel) and (FromLevel =< FELevel) ->
%								element(#equipment_move.needmoney,Info);
%							true->
%								Acc
%						end;
%					  true->
%						Acc
%					end
%		   end,
%	ets:foldl(Func,[],?EQUIPMENT_MOVE_ETS).

% 强化转移信息
equipment_move_info(ToLevel) ->
	{_OtherList, EquipmentMoveInfoList} = lists:unzip(lists:keysort(#equipment_move.tlevel, ets:tab2list(?EQUIPMENT_MOVE_ETS))),
	equipment_move_info2(ToLevel, EquipmentMoveInfoList).

equipment_move_info2(_ToLevel, []) ->
	{error, ?ERROR_SYSTEM};
equipment_move_info2(ToLevel, [H|T]) ->
	HLevel = H#equipment_move.tlevel,
	case ToLevel =< HLevel of
		true ->
			[{HLevel, EquipmentMoveInfo}] = ets:lookup(?EQUIPMENT_MOVE_ETS, HLevel),
			EquipmentMoveInfo;
		false ->
			equipment_move_info2(ToLevel, T)
	end.

% 某类道具是否充足
prop_enough([]) ->
	true;
prop_enough([H|T]) ->
	{ClassId, Num} = H,
	case item_util:is_has_enough_item_in_package_by_class(ClassId, Num) of
		true ->
			prop_enough(T);
		false ->
			false
	end.

% 删除某类道具
delete_prop([]) ->
	ok;
delete_prop([H|T]) ->
	{ClassId, Num} = H,
	item_util:consume_items_by_classid(ClassId, Num),
	delete_prop(T).
