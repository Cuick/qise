%% Author: MacX
%% Created: 2010-12-16
%% Description: TODO: Add description to achieve_equipment_script
-module(achieve_equipment_script).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([todo/2]).
-include("item_define.hrl").
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").
%%
%% API Functions
%%
todo(_AchieveId,Target)->
	[{Msg,List,Count}] = Target,
	case Msg of
		body_equipment->
			BodyItemsId = package_op:get_body_items_id(),
			MatchFun = fun(ItemId,Acc)->
							case items_op:get_item_info(ItemId) of
								[]->
									Acc;
								ItemInfo->
									Quality = get_qualty_from_iteminfo(ItemInfo),
									case lists:member(Quality, List) of
										true->
											Acc + 1;
										false->
											Acc
									end
							end
					   end,
			MatchResult = lists:foldl(MatchFun, 0, BodyItemsId),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		target_equipment->
			Fun = fun(TargetSlot,Acc)->
						  case package_op:get_item_id_in_slot(TargetSlot) of
							  []->
								  Acc;
							  ItemId->
								  [ItemId|Acc]
						  end
				  end,
			Result = [Fun(TargetSlot,[])||TargetSlot<-List],
			case length(Result) =:= length(List) of
				true->
					{true,length(Result)};
				_->
					{false,length(Result)}
			end;
		pet_equipment->
			MatchResult = lists:foldl(fun(PetInfo,Result)->
											  EquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
											  EquipInfoList = pet_equip_op:get_body_items_info(EquipInfo),
											  Num = lists:foldl(fun(EquipmentInfo,Acc)->
																	  Quality = package_op:get_qualty_from_iteminfo(EquipmentInfo),
																	  case lists:member(Quality,List) of
																		  true->
																			  Acc + 1;
																		  false->
																			  Acc
																	  end
																  end,0,EquipInfoList),
											  if
												  Num >= Result ->
													  Num;
												  true->
													  Result
											  end
										end,0,get(pets_info)),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		enchantments->
			BodyItemsId = package_op:get_body_items_id(),
			MatchFun = fun(ItemId,Acc)->
						    case items_op:get_item_info(ItemId) of
								[]->
									Acc;
								ItemInfo->
									Enchantments = get_enchantments_from_iteminfo(ItemInfo),
									case lists:member(Enchantments, List) of
										true->
											Acc + 1;
										false->
											Acc
									end
							end
					   end,
			MatchResult = lists:foldl(MatchFun, 0, BodyItemsId),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		inlay->
			BodyItemsId = package_op:get_body_items_id(),
			MatchFun = fun(ItemId,Acc)->
							case items_op:get_item_info(ItemId) of
								[]->
									Acc;
								ItemInfo->
									SocketInfo = get_socketsinfo_from_iteminfo(ItemInfo),
									case SocketInfo of
										[]->
											Acc;
										_->
											Len = lists:foldl(fun({_,StoneTmpId},Acc1)->
															  case item_template_db:get_item_templateinfo(StoneTmpId) of
																  []->
																	  Acc1;
																  TemplateInfo->
																	  StoneLevel = item_template_db:get_level(TemplateInfo),
																	  case lists:member(StoneLevel, List) of
																		  true->
																			  Acc1+1;
																		  false->
																			  Acc1
																	  end
															  end
													  end, 0, SocketInfo),
											Acc+Len
									end
								end
					   end,
			MatchResult = lists:foldl(MatchFun, 0, BodyItemsId),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		enchant->
			BodyItemsId = package_op:get_body_items_id(),
			MatchFun = fun(ItemId,Acc)->
							case items_op:get_item_info(ItemId) of
								[]->
									Acc;
								ItemInfo->
									ItemCless = get_class_from_iteminfo(ItemInfo),
									if ItemCless =:= ?ITEM_TYPE_RIDE ->
										   Acc;
									   true->
										   Quality = get_qualty_from_iteminfo(ItemInfo),
										   Enchant = get_enchant_from_iteminfo(ItemInfo),
										   case Enchant of
												[]->
													Acc;
												_->
													case lists:member(Quality, List) of
														true->
															Acc+1;
														false->
															Acc
													end
											end
									end
								end
					   end,
			MatchResult = lists:foldl(MatchFun, 0, BodyItemsId),
			if
				MatchResult >= Count->
					{true,MatchResult};
				true->
					{false,MatchResult}
			end;
		target_enchant->
			Fun = fun(TargetSlot,Acc)->
						  case package_op:get_iteminfo_in_normal_slot(TargetSlot) of
							  []->
								  [0|Acc];
							  ItemInfo->
								  Enchent = get_enchantments_from_iteminfo(ItemInfo),
								  [Enchent|Acc]
						  end
				  end,
			ResultEnchent = lists:foldl(Fun,[],List),
			RightItem = lists:foldl(fun(EnchantTemp,Result)->
											if
												EnchantTemp >= Count->
													[EnchantTemp|Result];
												true->
													Result
											end
										end,[],ResultEnchent),
			case length(RightItem) =:= length(List) of
				true->
					{true,length(RightItem)};
				_->
					{false,length(RightItem)}
			end;
		_->
			{other}
	end.
%%
%% Local Functions
%%

