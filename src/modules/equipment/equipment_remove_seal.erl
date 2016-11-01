%% Author: SQ.Wang
%% Created: 2011-12-20
%% Description: TODO: Add description to equipment_relieve_seal
-module(equipment_remove_seal).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("common_define.hrl").
-include("item_define.hrl").
-include("item_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).


%%
%% API Functions
%%
equipment_remove_seal(EquipSlot,ItemSlot)->
	case package_op:get_iteminfo_in_normal_slot(EquipSlot) of
		[]->
			Errno = ?ERROR_EQUIPMENT_NOEXIST;
		EquipInfo->
			EquipTempId = get_template_id_from_iteminfo(EquipInfo),
			case enchantments_db:get_relieve_seal_info(EquipTempId) of
				[]->
					Errno = ?ERROR_EQUIPMENT_CANT_SEAL;
				ConsumeInfo->
					Itemlist = enchantments_db:get_relieve_seal_needitem(ConsumeInfo),
					Count = enchantments_db:get_relieve_seal_needitemcount(ConsumeInfo),
					NeedMoney = enchantments_db:get_relieve_seal_needmoney(ConsumeInfo),
					NewTempId = enchantments_db:get_relieve_seal_result(ConsumeInfo),
					case package_op:get_iteminfo_in_package_slot(ItemSlot) of
						[]->
							Errno = ?ERROR_MISS_ITEM;
						ItemInfo->
							ItemId = get_template_id_from_iteminfo(ItemInfo),
							case lists:member(ItemId,Itemlist) of
								false->
									Errno = ?ERROR_EQUIPMENT_SOCKETS_NOT_MATCHED;
								_->
									HasCount = package_op:get_count_from_iteminfo(ItemInfo),
									case HasCount >= Count of
										true->
											LeftNeed = 0,
											LeftItem = [],
											IsEnough = true,
											HasItem = true;
										_->
											LeftNeed = Count - HasCount,
											[LeftItem] = Itemlist -- [ItemId],
											HasItem = package_op:get_counts_by_template_in_package(LeftItem) >= LeftNeed,
											IsEnough = false
									end,
									HasMoney = role_op:check_money(?MONEY_BOUND_SILVER,NeedMoney),
									if
										not HasItem ->
											Errno = ?ERROR_MISS_ITEM;
										not HasMoney->
											Errno = ?ERROR_LESS_MONEY;
										true->
											case package_op:can_added_to_package(NewTempId, 1) of
												0 ->
													Errno = ?ERROR_PACKAGE_FULL;
												_ ->
												Errno = [],
												role_op:money_change(?MONEY_BOUND_SILVER,-NeedMoney,remove_seal),
												EquipStars = get_enchantments_from_iteminfo(EquipInfo),
												EquipSockets = get_socketsinfo_from_iteminfo(EquipInfo),
												EquipEnchant = get_enchant_from_iteminfo(EquipInfo),
												role_op:proc_destroy_item(EquipInfo,remove_seal),
												{ok,[ResultId]} = role_op:auto_create_and_put(NewTempId,1,remove_seal),
												if
													not IsEnough ->
														% 不足的情况,必然使用了绑定的解封石头,直接设置为绑定的
														role_op:consume_item(ItemInfo, HasCount),
														role_op:consume_items(LeftItem, LeftNeed);
													true->
														role_op:consume_item(ItemInfo, Count)
												end,
												equipment_op:change_enchantment_attr_itemid(ResultId,EquipStars),
												equipment_op:change_socket_attr_by_itemid(ResultId,EquipSockets),
												equipment_op:change_enchant_attr_by_itemid(ResultId,EquipEnchant),
												equipment_op:recompute_equipment_attr(EquipSlot,ResultId),
												Message = equipment_packet:encode_equipment_remove_seal_s2c(),
												role_op:send_data_to_gate(Message),

												
												EquipAfter = items_op:get_item_info(ResultId),
												ToStarsAfter = get_enchantments_from_iteminfo(EquipAfter),
												ToSocketsAfter = get_socketsinfo_from_iteminfo(EquipAfter),
												ToEnchantAfter = get_enchant_from_iteminfo(EquipAfter),
												ToEquipTemplateId = get_template_id_from_iteminfo(EquipAfter),
												Rusult = [{ToEquipTemplateId,ToStarsAfter}|ToSocketsAfter] ++ ToEnchantAfter,
												gm_logger_role:role_enchantments_item(get(roleid),EquipTempId,remove_seal,Rusult,get(level))
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

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
