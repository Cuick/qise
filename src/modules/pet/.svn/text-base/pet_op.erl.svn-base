-module(pet_op).

-compile(export_all).

-include("data_struct.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("game_rank_define.hrl").
-include("skill_define.hrl").
-include("error_msg.hrl").
-include("mnesia_table_def.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("base_define.hrl").
-include("pet_def.hrl").
-include("title_def.hrl").

-define(TYPR_CHANGE_GOLD, 0).			% 宠物类型转换花费元宝
-define(TYPR_CHANGE_PROP, 1).			% 宠物类型转换消耗道具
% heart
-define(CHECK_TIME, 10*60*1000).		%check pet heart
-define(TIMT_RULE, 10*60*1000).


init()->
	put(gm_pets_info,[]),
	put(pets_info,[]),
	put(last_pet_switch_time,{0,0,0}),
	put(max_pet_num,0),
	put(buy_pet_slot,0),	
	put(present_pet_slot,0),		%%赠送的宠物槽位
	put(mypets_add_talent,[]),
	put(pet_can_buy_goods,[]),		%%在宠物商店可以买的物品列表
	put(pet_refresh_used,[]),		%%已用刷新次数
	put(pet_account,0),				%%宠物商店积分
	put(pet_luck_high,0),     		%%幸运值
	pet_skill_op:init_pet_skill_info().

hook_on_got_exp(Value)->
	case get_out_pet() of
		[]->
			nothing;
		PetInfo->
			pet_level_op:obt_exp(PetInfo, Value)
	end.

hook_on_role_levelup(Level)->
	LevelInfo = role_petnum_db:get_info(Level),
	LevelDefault = role_petnum_db:get_default_num(LevelInfo),
	Level_skill_slot = role_petnum_db:get_skill_slot(LevelInfo),
	pet_skill_op:check_slot_state(Level_skill_slot),
	pet_skill_op:send_up_data(),
	CurSlot = get(max_pet_num) - get(buy_pet_slot) - get(present_pet_slot),
	case LevelDefault > CurSlot of
		true->
			put(max_pet_num,LevelDefault+get(buy_pet_slot)+get(present_pet_slot));
		_->
			nothing
	end. 

hook_on_be_attack(_EnemyId)->
	nothing.

hook_on_attack()->
	nothing.

hook_on_dead()->
	call_back().

load_from_db(RolePetInfo)->
	case RolePetInfo of
		{{buy_pet_slot,BuyPetSlotNum},{present_pet_slot,PresentPetSlot}}->
			nothing;
		_->
			BuyPetSlotNum = 0,
			PresentPetSlot = 0
	end,
	init_form_dbinfo(BuyPetSlotNum,PresentPetSlot).	

init_form_dbinfo(BuyPetSlotNum,PresentPetSlot)->
	init(),
	pet_hostel:init_put(),
	put(buy_pet_slot,BuyPetSlotNum),
	put(present_pet_slot,PresentPetSlot),
	hook_on_role_levelup(get(level)),
	pet_shop_op:put_shop_info(),
	lists:foreach(fun(PetDbInfo)->
	    {{GmPetInfo,PetInfo},PetRoom} = load_pet_from_db(PetDbInfo),
	    pet_hostel:put_room_info(PetRoom),
		put(gm_pets_info,[GmPetInfo|get(gm_pets_info)]),
		put(pets_info,[PetInfo|get(pets_info)])
	end,pets_db:load_pets_info(get(roleid))).
	
hook_on_online_join_map()->	
	case get_out_pet() of
		[]->
			nothing;
		OutGmPetInfo->
			compute_heart_start(get_id_from_petinfo(OutGmPetInfo)),
			NewInfo = change_pet_state(OutGmPetInfo,?PET_STATE_BATTLE),
			switch_pet_to_battle([],NewInfo)
	end.

send_init_data()->
	% slogger:msg("111111111111111111111111111111~p~n",[get(pets_info)]),
	SendPets = lists:map(fun(PetInfo)->	
		#my_pet_info{petid = PetId} =PetInfo,
		PetEquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
		pet_packet:make_pet(PetInfo,get_pet_gminfo(PetId),pet_equip_op:get_body_items_info(PetEquipInfo)) 
	end, get(pets_info)),
	% slogger:msg("111111111111111111111111111113:~p~n",[SendPets]),
	PetsMsg = pet_packet:encode_init_pets_s2c(SendPets, get(max_pet_num), get(present_pet_slot)),
	role_op:send_data_to_gate(PetsMsg),
	% Sex = get_gender_from_petinfo(GmPetInfo),
	% case Sex of
	% 	2 ->
	% 		ProtoId = get_proto_from_petinfo(GmPetInfo),
	% 		pet_attr:self_update_and_broad(PetId, [{pet_gender,Sex},{pet_proto,ProtoId + 100}]);
	% 	_ ->
	% 		nothing
	% end,
	% pet_shop_op:send_can_buy_goods(),
	pet_hostel:send_opend_room_data(),
	pet_skill_op:send_init_data().

save_to_db()->
	lists:foreach(fun(PetInfo)->
		#my_pet_info{petid = PetId} =PetInfo,
		save_pet_by_info(PetInfo,get_pet_gminfo(PetId)) end, get(pets_info)).

save_roleinfo_to_db()->
	{{buy_pet_slot,get(buy_pet_slot)},{present_pet_slot,get(present_pet_slot)}}.

get_max_petnum()->
	get(max_pet_num).

get_cur_petnum()->
	erlang:length(get(pets_info)).

get_petids()->
	lists:map(fun(PetInfo)->
		get_id_from_mypetinfo(PetInfo) end, get(pets_info)).

%%return true |false
get_empty_pet_slot()->	
	get(max_pet_num) > length(get(pets_info)).

swap_slot(_PetId,_Slot)->
	nothing.
			
save_pet_to_db(PetId)->
	case get_pet_info(PetId) of
		[]->
			slogger:msg("save_pet_to_db [] RoleId ~p PetId ~p ~n ",[get(roleid),PetId]);
		PetInfo->
			save_pet_by_info(PetInfo,get_pet_gminfo(PetId))
	end.

load_pet_from_db([])->
	{{[],[]},[]};
load_pet_from_db(PetDbInfo)->
	PetId = pets_db:get_petid(PetDbInfo),
	Proto = pets_db:get_protoid(PetDbInfo),
	% 由于宠物相关属性全部保存在一个字段里，当增加新属性时该tuple长度会发生变化，因此在玩家登陆初始化宠物时要做特殊处理
	NewPetInfo = handle_db_change(pets_db:get_petinfo(PetDbInfo), Proto),
	{create_petinfo_bydbinfo(PetId, Proto, NewPetInfo, pets_db:get_skillinfo(PetDbInfo), pets_db:get_equipinfo(PetDbInfo)),pets_db:get_roominfo(PetDbInfo)}.

handle_db_change(PetAttrInfo, Proto) ->
	TupleSize = size(PetAttrInfo),
	case TupleSize of
		24 ->
			PetAttrInfo;
		29 ->
			list_to_tuple(tuple_to_list(PetAttrInfo)++[{0,0,0}]);
		_ ->
			% 增加魔防、远防、近防、魔免疫、远免疫、近免疫六种属性及宠物类型
			PetProtoInfo = pet_proto_db:get_info(Proto),
			if 
				TupleSize =:= 17 ->
					{_PetProtoHp, _PetProtoPower, _PetProtoHitRate, _PetProtoDodge, _PetProtoCriticalRate, _PetProtoCriticalDamage, _ProtoToughness, ProtoMagicDefense, ProtoFarDefense, ProtoNearDefense, ProtoMagicImmunity, ProtoFarImmunity, ProtoNearImmunity} = pet_proto_db:get_born_abilities(PetProtoInfo),
					{Level,Name,Gender,Mana,Exp,Quality_Value_Info,Quality_Value_Up_Info,State,TradeLock,ChangeNameFlag, Grade,Quality,Savvy,Grade_Riseup_Retries,Grade_Riseup_Lucky,Quality_Riseup_Retries,Quality_Riseup_Lucky} = PetAttrInfo,
					case Quality_Riseup_Retries =:= 0 orelse Quality_Riseup_Retries =:= undefined of
						true ->
							PetStage = 1;
						false ->
							PetStage = Quality_Riseup_Retries
					end,
					{Level,Name,Gender,Mana,Exp,Quality_Value_Info,Quality_Value_Up_Info,State,TradeLock,ChangeNameFlag, Grade,Quality,Savvy,Grade_Riseup_Retries,Grade_Riseup_Lucky, PetStage, Quality_Riseup_Lucky, ProtoMagicDefense, ProtoFarDefense, ProtoNearDefense, ProtoMagicImmunity, ProtoFarImmunity, ProtoNearImmunity, 2};
				TupleSize =:= 23 ->
					{Level,Name,Gender,Mana,Exp,Quality_Value_Info,Quality_Value_Up_Info,State,TradeLock,ChangeNameFlag, Grade,Quality,Savvy,Grade_Riseup_Retries,Grade_Riseup_Lucky,Quality_Riseup_Retries,Quality_Riseup_Lucky, ProtoMagicDefense, ProtoFarDefense, ProtoNearDefense, ProtoMagicImmunity, ProtoFarImmunity, ProtoNearImmunity} = PetAttrInfo,
					{Level,Name,Gender,Mana,Exp,Quality_Value_Info,Quality_Value_Up_Info,State,TradeLock,ChangeNameFlag, Grade,Quality,Savvy,Grade_Riseup_Retries,Grade_Riseup_Lucky,Quality_Riseup_Retries,Quality_Riseup_Lucky, ProtoMagicDefense, ProtoFarDefense, ProtoNearDefense, ProtoMagicImmunity, ProtoFarImmunity, ProtoNearImmunity, 2};
				true ->
					PetAttrInfo
			end
	end.

save_pet_by_info(PetInfo,GmPetInfo)->
	#gm_pet_info{id =PetId,master = RoleId,proto = Proto} = GmPetInfo,
	SavePetinfo = make_dbinfo_from_petinfo(PetInfo,GmPetInfo),
	SkillInfo = pet_skill_op:get_pet_skillallinfo(PetId),
	EquipInfo = pet_equip_op:export_for_db(PetInfo),
	Pet_room = pet_hostel:get_pet_room(PetId),
	RoleRoom = get(pet_hostel),
	% slogger:msg("sadfasdfsadf~p~n",[RoleRoom]),
	pet_hostel_db:save_role_hostel_info(RoleId,RoleRoom),
	pets_db:save_pet_info(RoleId,PetId,Proto,SavePetinfo,SkillInfo,EquipInfo,Pet_room,[]).

load_by_copy({Out_pet, PetNum,BuyPetSolt,PresentPetSlot,PetInfos,GmPetInfos,Last_switch_time,Can_buy_goods,Refresh_used,Account,Luck_high,OPenRoom,ActiveList,SkillInfo})->
	put(pet_out,Out_pet),
	put(max_pet_num,PetNum),
	put(buy_pet_slot,BuyPetSolt),
	put(present_pet_slot,PresentPetSlot),
	put(pets_info,PetInfos),
	put(gm_pets_info,GmPetInfos),
	put(last_pet_switch_time,Last_switch_time),
	put(pet_can_buy_goods,Can_buy_goods),		%%在宠物商店可以买的物品列表
	put(pet_refresh_used,Refresh_used),		%%已用刷新次数
	put(pet_account,Account),				%%宠物商店积分
	put(pet_luck_high,Luck_high),      		%%幸运值
	put(pet_hostel,OPenRoom),
	put(active_room,ActiveList),
	case get_out_pet() of
		[]->
			nothing;
		OutGmPetInfo->
			update_gm_pet_info_all(OutGmPetInfo)
	end,
	pet_skill_op:load_by_copy(SkillInfo).


export_for_copy()->
	{
	 get(pet_out),
	 get(max_pet_num),
	 get(buy_pet_slot),
	 get(present_pet_slot),
	 get(pets_info),
	 get(gm_pets_info),
	 get(last_pet_switch_time),
	 get(pet_can_buy_goods),		%%在宠物商店可以买的物品列表
	 get(pet_refresh_used),		%%已用刷新次数
	 get(pet_account),				%%宠物商店积分
	 get(pet_luck_high),
	 get(pet_hostel),
	 get(active_room),
	 pet_skill_op:export_for_copy() 
	 % pet_talent_op:export_for_copy()
	}.

%%true/false
pet_rename(PetId,NewName)->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			slogger:msg("pet_rename error PetId ~p Roleid ~p ~n",[PetId,get(roleid)]),
			false;
		GmPetInfo->
			NewGmPetInfo = set_name_to_petinfo(GmPetInfo,NewName),
			update_gm_pet_info_all(NewGmPetInfo),
			PetInfo = get_pet_info(PetId),
			NewPetInfo = set_changenameflag_to_mypetinfo(PetInfo,?PET_CHANGE_NAME),
			update_pet_info_all(NewPetInfo),
			game_rank_manager:updata_pet_rank_info(PetId,NewName),
			case get_state_from_petinfo(NewGmPetInfo) of
				?PET_STATE_BATTLE->
					pet_attr:self_update_and_broad(PetId, [{name,NewName}]);
				_->
					pet_attr:only_self_update(PetId, [{name,NewName}])
			end,
			true
	end.

pet_move(PetId,{PosX,PosY},Path,Time)->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			nothing;
		GmPetInfo->
			State = get_state_from_petinfo(GmPetInfo),
			if
				State =:= ?PET_STATE_BATTLE->
					NewGmInfo = GmPetInfo#gm_pet_info{posx = PosX,posy = PosY,path = Path},
					update_gm_pet_info_all(NewGmInfo),
					pet_attr:move_notify_aoi_roles(PetId,{PosX,PosY},Path,Time);
				true->
					nothing
			end
	end.

car_move(CarId,{PosX,PosY},Path,Time)->
	pet_attr:move_notify_aoi_roles(CarId,{PosX,PosY},Path,Time).

pet_stop_move(PetId,{PosX,PosY},_Time)->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			nothing;
		GmPetInfo->
			State = get_state_from_petinfo(GmPetInfo),
			if
				State =:= ?PET_STATE_BATTLE->
					NewGmPetInfo = GmPetInfo#gm_pet_info{posx = PosX,posy = PosY,path = []},	
					update_gm_pet_info_all(NewGmPetInfo),
					StopMsg = role_packet:encode_move_stop_s2c(PetId,{PosX,PosY}),
					role_op:broadcast_message_to_aoi_client(StopMsg);
				true->
					nothing
			end
	end.
					
pet_attack(PetId,OriSkillID1,OriTargetID)->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			nothing;
		PetInfo->
			case get_state_from_petinfo(PetInfo) of
				?PET_STATE_BATTLE->
					SelfInfo = get(creature_info),
					SelfId = get(roleid),
					PetClass = get_class_from_petinfo(PetInfo),
					OriTargetInfo = creature_op:get_creature_info(OriTargetID),
					%case pet_skill_op:check_common_skill(PetClass,OriSkillID) of
                    OriSkillID = 700000002,
					Ff = true,
					case Ff of
						true->
							OriSkillLevel = 1,	%%common skill level	
							OriSkillInfo = skill_db:get_skill_info(OriSkillID, OriSkillLevel),
							case role_op:attack_check(SelfId,OriTargetID,OriTargetInfo,OriSkillInfo) of
								false ->
									nothing;
				 				_->		 	
									Now = timer_center:get_correct_now(),
									CoolCheck = pet_skill_op:check_common_cool(Now),
									JudgeResult = pet_combat_op:pet_judge(PetInfo,SelfInfo, OriTargetInfo,OriSkillInfo),
									if
										JudgeResult and CoolCheck ->			
										%%maybe cast passive skill
										{SkillID,SkillLevel,TargetId} = pet_combat_op:get_passive_skill_on_attack(OriSkillID, OriSkillLevel,PetInfo,SelfId,OriTargetID),
										SkillInfo = skill_db:get_skill_info(SkillID, SkillLevel),
										MyPos = creature_op:get_pos_from_creature_info(SelfInfo),
										if
											TargetId =:= SelfId->
												TargetInfo = SelfInfo;
											true->
												TargetInfo = OriTargetInfo
										end,
										MyTarget = creature_op:get_pos_from_creature_info(TargetInfo),
										Speed = skill_db:get_flyspeed(SkillInfo),
										FlyTime = Speed*util:get_distance(MyPos,MyTarget),	
										case skill_db:get_cast_time(SkillInfo) of
											0 ->
												{ChangedAttr, CastResult} =

													pet_combat_op:process_pet_instant_attack(PetInfo,SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo),
													role_op:process_damage_list(PetId,SelfInfo,SkillID,SkillLevel, FlyTime, CastResult),
													creature_op:combat_bufflist_proc(SelfInfo,CastResult,FlyTime),
													NewInfo2 = role_op:apply_skill_attr_changed(get(creature_info),ChangedAttr),
													put(creature_info, NewInfo2),								
													role_op:update_role_info(SelfId,NewInfo2);
											_->					%%not support not now
											
												nothing
										end;
									true->
										nothing
								end
						end;
					_->
						nothing
				end;
			_->
				nothing
		end		
	end.

call_out(PetId)->
	case get_out_pet_id() =/=0  of
		true->
			% a;
			ErrorMsg = pet_packet:encode_pet_opt_error_s2c(?ERRNO_CAN_NOT_DO_IN_BANQUET),
			role_op:send_data_to_gate(ErrorMsg);
		_->
			
			Now = timer_center:get_correct_now(),
			case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
				false->
					slogger:msg("roleid ~p call out PetId ~p error ~n",[get(roleid),PetId]);
				GmPetInfo->
					case pet_hostel:check_pet_in_room(PetId) of
						false ->
							ErrorMsg = pet_packet:encode_pet_opt_error_s2c(?ERR_IN_HOTEL),
							role_op:send_data_to_gate(ErrorMsg);
						true ->
							case get_heart_from_petinfo(GmPetInfo) of
								0 ->
									ErrorMsg = pet_packet:encode_pet_opt_error_s2c(?ERR_PET_HEART_LOW),
									role_op:send_data_to_gate(ErrorMsg);
								_ ->
									case timer:now_diff(timer_center:get_correct_now(),get(last_pet_switch_time)) >= ?PET_SWITCH_COOLTIME*1000 of
										true->
											put(last_pet_switch_time,Now),
											case get_state_from_petinfo(GmPetInfo) of
												?PET_STATE_IDLE->
													Proto = get_proto_from_petinfo(GmPetInfo),
													ProtoInfo = pet_proto_db:get_info(Proto),
													MinTakeLevel =pet_proto_db:get_min_take_level(ProtoInfo),
													case MinTakeLevel > get(level) of
														true->
															Msg = pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_MASTER_LESS_LEVEL),
															role_op:send_data_to_gate(Msg);
														_->
															case lists:keyfind(?PET_STATE_BATTLE, #gm_pet_info.state, get(gm_pets_info)) of
																false->
																	OldGmPetInfo = [],
																	NewGmPetInfo = change_pet_state(GmPetInfo,?PET_STATE_BATTLE),
																	switch_pet_to_battle(OldGmPetInfo,NewGmPetInfo),
																	role_fighting_force:hook_on_change_role_fight_force();
																OldGmPetInfo->
																	case get_id_from_petinfo(OldGmPetInfo) =/= PetId of
																		true->
																			NewInfo1 = change_pet_state(OldGmPetInfo,?PET_STATE_IDLE),
																			NewInfo2 = change_pet_state(GmPetInfo,?PET_STATE_BATTLE),
																			switch_pet_to_battle(NewInfo1,NewInfo2),	
																			role_fighting_force:hook_on_change_role_fight_force();
																		_->
																			nothing
																	end
															end
													end;
												OtherState->
													slogger:msg("call_out()PetId ~p State ~p roleid ~p ~n",[PetId,OtherState,get(roleid)])
											end;
										_->
											nothing
									end
							end	

					end			
			end
			
	end.

call_back(PetId)->
	case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
		false->
			slogger:msg("roleid ~p call out PetId ~p error ~n",[get(roleid),PetId]);
		PetInfo->
			call_back_by_info(PetInfo)
	end.

%%
%%return true|false|full
buy_pet_slot()->
	CurNum = get(buy_pet_slot),
	NewNum = CurNum + 1,
	case pet_slot_db:get_info(NewNum) of
		[]->
			nothing;
		SlotInfo->
			{MoneyType, MoneyCount} = pet_slot_db:get_price(SlotInfo),
			case role_op:check_money(MoneyType, MoneyCount) of
				true->
					role_op:money_change( MoneyType, -MoneyCount,buy_pet_slot),
					put(buy_pet_slot,NewNum),
					put(max_pet_num,get(max_pet_num)+1),
					MessageBin = pet_packet:encode_update_pet_slot_num_s2c(get(max_pet_num)),
					role_op:send_data_to_gate(MessageBin);
				_->
					MessageBin = pet_packet:encode_pet_opt_error_s2c(?ERROR_LESS_GOLD),
					role_op:send_data_to_gate(MessageBin)
			end
	end.
	
dismount_pet(PetId)->
%%	role_sitdown_op:hook_on_action_async_interrupt(timer_center:get_correct_now(),dismount_pet),
	case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
		false->
			nothing;
		PetInfo->
			dismount_by_info(PetInfo)
	end.

call_back()->
	case get_out_pet() of
		[]->
			nothing;
		GmPetInfo->
			call_back_by_info(GmPetInfo)
	end.
			
call_back_by_info(GmPetInfo)->
	case get_state_from_petinfo(GmPetInfo) of
		?PET_STATE_BATTLE->
			NewInfo = change_pet_state(GmPetInfo,?PET_STATE_IDLE),
			switch_pet_to_battle(NewInfo,[]),
			role_fighting_force:hook_on_change_role_fight_force();
		_->
			nothing
	end.

dismount_by_info(PetInfo)->
	nothing.

change_pet_state(GmPetInfo,Type)->
	PetId = get_id_from_petinfo(GmPetInfo),
	case Type of
		?PET_STATE_BATTLE->
					compute_heart_start(PetId),
					{PosX,PosY} = get_pos_from_roleinfo(get(creature_info)),
					NewGmInfo = GmPetInfo#gm_pet_info{state = Type,posx =PosX + 2,posy = PosY,path=[]};
		_->
			NewGmInfo0 = compute_heart_end(PetId, GmPetInfo),
			NewGmInfo = NewGmInfo0#gm_pet_info{state = Type,path=[]}
	end,
	put(gm_pets_info,lists:keyreplace(PetId, #gm_pet_info.id,  get(gm_pets_info), NewGmInfo)),
	UpdateAttr = [{state, Type}],
	pet_attr:only_self_update(PetId,UpdateAttr),
	NewGmInfo.

compute_heart_start(PetId) ->
	% slogger:msg("pet out start: ~p~n",[PetId]),
	TimeRef = erlang:send_after(?CHECK_TIME,self(),{check_pet_heart,PetId}),
	put(pet_out,{PetId,now(),TimeRef}).

compute_heart_end(PetId, GmPetInfo) ->
	compute_heart(PetId, GmPetInfo,call_back).
check_pet_heart(PetId) ->
	GmPetInfo = lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)),
	NewGmInfo = compute_heart(PetId, GmPetInfo,check),
	put(gm_pets_info,lists:keyreplace(PetId, #gm_pet_info.id,  get(gm_pets_info), NewGmInfo)).

compute_heart(PetId, GmPetInfo,Type) ->
	case get(pet_out) of
		undefined ->
			% slogger:msg("pet not found: ~p :~p~n",[PetId ,Type]),
			GmPetInfo;
		{PetId, Battle_time,Check_TimeRef} ->
			erlang:cancel_timer(Check_TimeRef),
			Current_heart = get_heart_from_petinfo(GmPetInfo),
			% slogger:msg("Current_hert is : ~p~n",[Current_heart]),
			case Type of
				call_back ->
					NewPetInfo = GmPetInfo,
					Out_Time = timer:now_diff(now(),Battle_time)/1000,
					LostHeart_point = trunc(Out_Time/(?TIMT_RULE))+1,
					% slogger:msg("LostHeart_point is : ~p call_back~n",[LostHeart_point]),
					Now_hert0 = Current_heart - LostHeart_point,
					Now_hert = case Now_hert0 of
							_ when Now_hert0 > 0 ->
							Now_hert0;
							_ ->
								0 
					end;
				check ->
					LostHeart_point = trunc((?CHECK_TIME)/(?TIMT_RULE)),
					% slogger:msg("LostHeart_point is : ~p check~n",[LostHeart_point]),
					Now_hert0 = Current_heart - LostHeart_point,
					Now_hert = case Now_hert0 of
							_ when Now_hert0 > 0 ->
								NewPetInfo = GmPetInfo,
								compute_heart_start(PetId),
								Now_hert0;
							_ ->
								NewPetInfo = change_pet_state(GmPetInfo,?PET_STATE_IDLE),
								switch_pet_to_battle(NewPetInfo,[]),
								0 
					end
				end,
			MessageBin = pet_packet:encode_pet_cur_heart_s2c(PetId,Now_hert),
			role_op:send_data_to_gate(MessageBin),
			set_heart_to_petinfo(NewPetInfo,Now_hert);
		_ ->
			% slogger:msg("pet not found: ~p :~p~n",[PetId ,Type]),
			GmPetInfo
	end.
%%no buffer 
switch_pet_to_battle(OldGmPetInfo,GmPetInfo)->
	case OldGmPetInfo of
		[]->	
			OutPetId = 0,
			OldPetProto = 0,
			nothing;
		_->			
			OutPetId = get_id_from_petinfo(OldGmPetInfo),
			OldPetProto = get_proto_from_petinfo(OldGmPetInfo),
			pet_manager:unregist_pet_info(OutPetId),
			pet_attr:pet_out_view_broad(OutPetId)
	end,
	case GmPetInfo of
		[]->
			PetProto = 0,
			PetId = 0;
		_->
			PetId = get_id_from_petinfo(GmPetInfo),
			pet_manager:regist_pet_info(PetId, GmPetInfo),
			% Sex = get_gender_from_petinfo(GmPetInfo),
			PetProto = get_proto_from_petinfo(GmPetInfo),
			% TemGmPetInfo = case Sex of
			% 				2 ->
			% 					set_proto_to_petinfo(GmPetInfo, PetProto + 100);
			% 				_ ->
			% 					GmPetInfo
			% 			end,
			pet_attr:pet_into_view_broad(GmPetInfo)
	end,
	gm_logger_role:pet_change(get(roleid),OldPetProto,OutPetId,PetProto,PetId),
	put(creature_info, set_pet_id_to_roleinfo(get(creature_info), PetId)),
	%% 转化属性给role
	%% 重新计算玩家的其他属性
	role_op:recompute_pet_attr().     

update_gm_pet_info_all(NewGmPetInfo)->
	PetId = get_id_from_petinfo(NewGmPetInfo),
	put(gm_pets_info,lists:keyreplace(PetId, #gm_pet_info.id,  get(gm_pets_info), NewGmPetInfo)),
	case get_state_from_petinfo(NewGmPetInfo) of
		?PET_STATE_BATTLE->
			pet_manager:regist_pet_info(PetId , NewGmPetInfo);
		_->
			nothing
	end.

update_pet_info_all(NewInfo)->
	PetId = get_id_from_mypetinfo(NewInfo),
	put(pets_info,lists:keyreplace(PetId, #my_pet_info.petid,  get(pets_info), NewInfo)).

%%returen :true / false
apply_create_pet(ProtoId,Growth,Quality)->
	case pet_proto_db:get_info(ProtoId) of
		[]->
			% slogger:msg("apply_create_pet error ProtoId ~p Quality ~p ~n",[ProtoId,Quality]),
			false;
		PetProtoInfo->
			case pet_proto_db:get_min_take_level(PetProtoInfo) =< get(level) of
				true->
					case get_empty_pet_slot() of
						false->
							PetId = "000000",
							Errno = ?ERROR_BATTLEPET_GOT_SLOT;
						_->
							Errno  = [],
							PetId = create_pet(ProtoId, Growth, Quality, PetProtoInfo)
					end;
				_->
					PetId = "000000",
					Errno = ?ERROR_PET_GOT_LEVEL
			end,
			if
				Errno=:=[]->
					{true,PetId};
				true->
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno)),
					false
			end
	end.


create_pet(ProtoId, Growth, Quality, PetProtoInfo)->
	PetId = petid_generator:gen_newid(),
	{PetInfo,GmPetInfo} = apply_info_with_args(PetProtoInfo, ProtoId, Growth, Quality, PetId),
	add_pet_by_petinfo(PetInfo,GmPetInfo,PetProtoInfo).

add_pet_by_petinfo(PetInfo,GmPetInfo,PetProtoInfo)->	
	PetId = get_id_from_mypetinfo(PetInfo),
	put(pets_info,[PetInfo|get(pets_info)]),
	put(gm_pets_info,[GmPetInfo|get(gm_pets_info)]),
	Gm_pets_info = get(gm_pets_info),
	% update_role_title(Gm_pets_info),
	PetEquipInfo = get_equipinfo_from_mypetinfo(PetInfo),
	CreatePet = pet_packet:make_pet(PetInfo,GmPetInfo,pet_equip_op:get_body_items_info(PetEquipInfo)),
	Msg = pet_packet:encode_create_pet_s2c(CreatePet),
	role_op:send_data_to_gate(Msg),
	pet_skill_op:send_init_data(PetId),
	pet_util:recompute_attr(create_delate,PetId),
	pet_hostel:add_common_room(),
	save_pet_to_db(PetId),
	PetId.

update_role_title(Gm_pets_info)->
	Gm_pets_info1 = lists:ukeysort(4,Gm_pets_info),
	Num = length(Gm_pets_info1),
	case Num of
		3 ->
			role_pos_util:send_to_role(get(roleid),{title_condition_change,?TITLE_TYPE_PETNUM, 3});
		5 ->
			role_pos_util:send_to_role(get(roleid),{title_condition_change,?TITLE_TYPE_PETNUM, 5});
		10 ->
			role_pos_util:send_to_role(get(roleid),{title_condition_change,?TITLE_TYPE_PETNUM, 10});
		15 ->
			role_pos_util:send_to_role(get(roleid),{title_condition_change,?TITLE_TYPE_PETNUM, 15});
		_ ->
			nothing
	end.

apply_info_with_args(PetProtoInfo, ProtoId, Growth, Quality, PetId)->
	Level = 1,
	PetLevelInfo = pet_level_db:get_info(Level),
	TotalExp = pet_level_db:get_exp(PetLevelInfo),
	Mana = pet_level_db:get_maxmp(PetLevelInfo),
	Exp = pet_level_db:get_exp(PetLevelInfo),
	Mpmax = 0,
	% Hpmax = pet_level_db:get_maxmp(PetLevelInfo),
	Icon = [],
	RandomV0 = random:uniform(100),
	Gender = 
		case pet_proto_db:get_femina_rate(PetProtoInfo) >= RandomV0 of
			true->
				?GENDER_FEMALE;
			_->
				?GENDER_MALE
		end,
	Name = pet_proto_db:get_name(PetProtoInfo),
	Class = random:uniform(pet_proto_db:get_class(PetProtoInfo)),
	% Is_ride = 0, % pet_proto_db:get_is_ride(PetProtoInfo),	
	Pos = get_pos_from_roleinfo(get(creature_info)),
	State = ?PET_STATE_IDLE,
	Info = pet_quality_proto_db:get_info(Quality),

	% 获取宠物成长的加成
	{PetGrowHp, PetGrowPower, PetGrowHitRate, PetGrowDodge, PetGrowCriticalRate, PetGrowCriticalDamage, _GrowToughness} = pet_growth_proto_db:get_growth_pet_attr(Growth),
	% 获取宠物模型基础值
	% {生命，攻击，命中，闪避，暴击，暴伤，韧性, 魔防, 远防, 近防, 魔免疫，远免疫，近免疫}
	{PetProtoHp, PetProtoPower, PetProtoHitRate, PetProtoDodge, PetProtoCriticalRate, PetProtoCriticalDamage, ProtoToughness, ProtoMagicDefense, ProtoFarDefense, ProtoNearDefense, ProtoMagicImmunity, ProtoFarImmunity, ProtoNearImmunity} = pet_proto_db:get_born_abilities(PetProtoInfo),
	% 获取级别加成
	{PetLvlHp, PetLvlPower, PetLvlHitRate, PetLvlDodge, PetLvlCriticalRate, PetLvlCriticalDamage, _LvlToughness, PetLvl_MagicDefense, PetLvl_FarDefense, PetLvl_NearDefense} = pet_level_db:get_sysaddattr(PetLevelInfo),

    %%宠物基础值
	Base_Power = PetGrowPower + trunc(PetProtoPower*PetLvlPower/100),
	Base_HitRate = PetGrowHitRate + trunc(PetProtoHitRate*PetLvlHitRate/100),
    Base_Dodge = PetGrowDodge + trunc(PetProtoDodge*PetLvlDodge/100),
	Base_CriticalRate = PetGrowCriticalRate + trunc(PetProtoCriticalRate*PetLvlCriticalRate/100),
    Base_CriticalDamage = PetGrowCriticalDamage + trunc(PetProtoCriticalDamage*PetLvlCriticalDamage/100),
    Base_Life = PetGrowHp + trunc(PetProtoHp*PetLvlHp/100),
    BaseMagicDefense = trunc(ProtoMagicDefense*PetLvl_MagicDefense/100),
    BaseFarDefense = trunc(ProtoFarDefense*PetLvl_FarDefense/100),
    BaseNearDefense = trunc(ProtoNearDefense*PetLvl_NearDefense/100),
	BaseMagicImmunity = ProtoMagicImmunity,
	BaseFarImmunity = ProtoFarImmunity,
	BaseNearImmunity = ProtoNearImmunity,
	Defense = 0,
	Quality_Value_Info = 0,
	Quality_Value_Up_Info = 0,
    Grade_Riseup_Retries = 0,
    Grade_Riseup_Lucky = 0,
	% 品阶
    Quality_Riseup_Retries = 1,
    % {失败次数,幸运值}
    Quality_Riseup_Lucky = {0, 0},
    %宠物的悟性
    Savvy = random:uniform(100),
	TradeLock = ?PET_TRADE_UNLOCK,
	%%skill
	% RandomV2 = random:uniform(100),
	% SkillRandList = lists:foldl(fun({SkillId,Rate},Tmp)->
	% 			if 
	% 				Rate>=RandomV2->
	% 					Tmp++[{SkillId,1,{0,0,0}}];
	% 				true->
	% 					Tmp
	% 			end end,[], pet_proto_db:get_born_skills(PetProtoInfo)),
	pet_skill_op:create_pet_skill(PetId),
	PetEquipInfo = pet_equip_op:init_pet_equipinfo(),
    %宠物最终属性由以下内容组成
    %级别和资质所带来的属性＋装备带来的属性＋技能带来的属性
    Pet_heart = 100,
    Can_buy_goods = [],
    Used_refresh = [],
    Account = 0,
    Luck_num = 0,
	{Power, HitRate, Dodge, CriticalRate, CriticalDamage, Life,_Toughness2,MagicDefense2,FarDefense2,NearDefense2} = pet_util:compute_attr(Class, {Base_Power, Base_HitRate, Base_Dodge, Base_CriticalRate, Base_CriticalDamage, Base_Life,0,0,0,0}, pet_util:get_skill_attr_self(PetId),pet_equip_op:get_attr_by_equipinfo(PetEquipInfo)),
	Fighting_Force = pet_fighting_force:computter_fight_force(Power, HitRate, Dodge, CriticalRate, CriticalDamage, Life, BaseMagicDefense, BaseFarDefense, BaseNearDefense, BaseMagicImmunity, BaseFarImmunity, BaseNearImmunity),
	GmPetInfo = create_petinfo(PetId, get(roleid), ProtoId,Level, Name, Gender, Life, Mana, Quality, Life, Mpmax, Class, State, Pos, Exp, TotalExp, Power, HitRate, CriticalRate, CriticalDamage, Fighting_Force, Icon, Dodge, Defense, Growth, Savvy, BaseMagicDefense, BaseFarDefense, BaseNearDefense, BaseMagicImmunity, BaseFarImmunity, BaseNearImmunity,Pet_heart,Can_buy_goods,Used_refresh,Account,Luck_num,{0,0,0}),
	PetInfo = create_mypetinfo(PetId,Quality_Value_Info,Quality_Value_Up_Info,
	          {Power,HitRate,Dodge,CriticalRate,CriticalDamage,Life,ProtoToughness,BaseMagicDefense,BaseFarDefense,BaseNearDefense}, 
			  TradeLock,PetEquipInfo,(not ?PET_CHANGE_NAME),
              Grade_Riseup_Retries,Grade_Riseup_Lucky,Quality_Riseup_Retries,Quality_Riseup_Lucky),
	{PetInfo,GmPetInfo}.

delete_pet(PetId,NeedCheck)->
	case get_pet_gminfo(PetId) of
		[]->
			slogger:msg("delete_pet error PetId [] ~p ~n",[PetId]);
		GmPetInfo->
			case get_state_from_petinfo(GmPetInfo) of
				?PET_STATE_IDLE->
					Proto = get_proto_from_petinfo(GmPetInfo),
					CanDelete = pet_proto_db:get_can_delete(pet_proto_db:get_info(Proto)),
					case NeedCheck and (CanDelete =/= ?PET_CAN_DELETE) of
						true->
							nothing;
						_->
							PetInfo = get_pet_info(PetId), 
							put(pets_info,lists:keydelete(PetId, #my_pet_info.petid, get(pets_info))),
							put(gm_pets_info,lists:keydelete(PetId, #gm_pet_info.id, get(gm_pets_info))),
							pet_equip_op:hook_on_pet_destroy(PetInfo),
							pet_skill_op:delete_pet(PetId),
							pets_db:del_pet(PetId,get(roleid)),	
							game_rank_manager:pet_lose_rank(PetId),	
							pet_util:recompute_attr(create_delate,PetId),			
							Msg = pet_packet:encode_pet_delete_s2c(PetId),
							role_op:send_data_to_gate(Msg),
							gm_logger_role:pet_delete(get(roleid),PetId,NeedCheck,Proto)
					end;
				State->
					slogger:msg("delete_pet error PetId  ~p State ~p ~n",[PetId,State])
			end
	end.		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Base op%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

has_out_pet()->
	lists:keymember(fight,#gm_pet_info.state, get(gm_pets_info)).

is_out_pet(PetId)->
	case lists:keyfind(?PET_STATE_BATTLE,#gm_pet_info.state, get(gm_pets_info)) of
		false->
			false;
		PetInfo->
			PetId=:= get_id_from_petinfo(PetInfo)
	end.

get_pet_info(PetId)->
	case lists:keyfind(PetId, #my_pet_info.petid, get(pets_info)) of
		false->
			[];
		PetInfo->
			PetInfo
	end.

get_pet_gminfo(PetId)->
	case lists:keyfind(PetId, #gm_pet_info.id, get(gm_pets_info)) of
		false->
			[];
		PetInfo->
			PetInfo
	end.

get_out_pet_id()->
	case lists:keyfind(?PET_STATE_BATTLE,#gm_pet_info.state, get(gm_pets_info)) of
		false->
			0;
		Info->
			get_id_from_petinfo(Info)
	end.

get_out_pet()->
	case lists:keyfind(?PET_STATE_BATTLE,#gm_pet_info.state, get(gm_pets_info)) of
		false->
			[];
		Info->
			Info
	end.

make_dbinfo_from_petinfo(PetInfo,GmPetInfo)->
	#my_pet_info{			
				quality_value_info = Quality_Value_Info,
				quality_value_up_info = Quality_Value_Up_Info,
				trade_lock = TradeLock,
				changenameflag = ChangeNameFlag,
                grade_riseup_retries = Grade_Riseup_Retries,
                grade_riseup_lucky = Grade_Riseup_Lucky,
                quality_riseup_retries = Quality_Riseup_Retries,
                quality_riseup_lucky = Quality_Riseup_Lucky
				} = PetInfo,
	#gm_pet_info{level = Level,
				name = Name,
				gender = Gender,
				life = Life,
				mana = Mana,
				exp = Exp,
				class = Class,
				state = State,
				proto = Proto,
                quality = Quality,
                grade = Grade,
                savvy = Savvy,
				magic_defense = MagicDefense,
				far_defense = FarDefense,
				near_defense = NearDefense,
				magic_immunity = MagicImmunity,
				far_immunity = FarImmunity,
				near_immunity = NearImmunity,
				current_heart = Heart,
				can_buy_goods = Can_buy_goods,		
				refresh_used = Refresh_used,	
				account = Account,				
				luck_high =  Luck_high,
				refresh_defense = Refresh_defense
				}=GmPetInfo,
	ProtoInfo = pet_proto_db:get_info(Proto),	
	{Level,Name,Gender,Life,Mana,Exp,Quality_Value_Info,Quality_Value_Up_Info,State,TradeLock,ChangeNameFlag,Grade,Quality,Savvy,Grade_Riseup_Retries,Grade_Riseup_Lucky,Quality_Riseup_Retries,Quality_Riseup_Lucky, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Class, Heart, Can_buy_goods, Refresh_used, Account ,Luck_high, Refresh_defense}.

get_pet_add_attr()->
 	get_add_attr().

%%
%%出战宠物体质对主人血量上限的加成
%% hpmax = pet_stamina * PET_STAMINA_FACTOR
%%

% get_add_attr([])->
% 	[];
get_add_attr()->
	% PetId = get_id_from_petinfo(GmPetInfo),
	%Stamina = get_stamina_from_petinfo(GmPetInfo),
	%[{hpmax,Stamina*?PET_STAMINA_FACTOR}]	++ pet_util:get_skill_attr_master(PetId). 
	case  pet_util:compute_attr_to_role() of
		{error, Code} -> 
			slogger:msg(" ERROR !! no found pet info~n");
		AttrList ->
			AttrList
	end.


create_petinfo_bydbinfo(PetId,Proto,PetDBInfo,PetDbSkillInfo,EquipInfo)->
	case PetDBInfo of
		{Level, Name, Gender,Life, Mana, Exp, Quality_Value_Info, Quality_Value_Up_Info, State, TradeLock, ChangeNameFlag, Grade, Quality, Savvy, Grade_Riseup_Retries, Grade_Riseup_Lucky, Quality_Riseup_Retries, Quality_Riseup_Lucky, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Class, Heart_point, Can_buy_goods, Refresh_used, Account, Luck_high,Refresh_defense} ->

		% {Level, Name, Gender, Mana, Exp, Quality_Value_Info, Quality_Value_Up_Info, State, TradeLock, ChangeNameFlag, Grade, Quality, Savvy, Grade_Riseup_Retries, Grade_Riseup_Lucky, Quality_Riseup_Retries, Quality_Riseup_Lucky, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Class, Heart_point} ->
			Pos = {0,0},
			PetLevelInfo = pet_level_db:get_info(Level),
			MpMax = pet_level_db:get_maxmp(PetLevelInfo),
			% HpMax = 0,
			Icon = [],
			TotalExp = pet_level_db:get_exp(PetLevelInfo)+Exp,
			ProtoInfo = pet_proto_db:get_info(Proto),
			% Is_ride = 0,
			Attr = pet_util:get_system_attr_add(Level,Grade,Proto),
			{Base_Power,Base_HitRate,Base_Dodge,Base_CriticalRate,Base_CritialDamage,Base_Life,Base_Toughness,Base_MagicDefense,Base_FarDefense,Base_NearDefense} = Attr,
			PetEquipInfo = pet_equip_op:get_equipinfo_by_db(EquipInfo),
			pet_skill_op:init_pet_skill(PetId,PetDbSkillInfo),		
			{Power,Hitrate,Dodge,CriticalRate,CriticalDamage,Life2,Toughness2,MagicDefense2,FarDefense2,NearDefense2} = pet_util:compute_attr(Class,Attr, pet_util:get_skill_attr_self(PetId),pet_equip_op:get_attr_by_equipinfo(PetEquipInfo)),
			{Add_MagicDefense,Add_FarDefense,Add_NearDefense} = Refresh_defense,
			% slogger:msg("ffffffffffffffffffffffffffffffffffffCriticalDamage:~p~n",[CriticalDamage]),
			Fighting_Force = pet_fighting_force:computter_fight_force(Power, Hitrate, Dodge, CriticalRate, CriticalDamage, Life, MagicDefense + Add_MagicDefense, Add_FarDefense + FarDefense, Add_NearDefense + NearDefense, MagicImmunity, FarImmunity, NearImmunity),
			% GmPetInfo = create_petinfo(PetId,get(roleid),Proto,Level,Name,Gender,Life,Mana,Quality, Base_Life,MpMax,Class,State,Pos,Exp,TotalExp,Power,HitRate,CriticalRate,CriticalDamage,Fighting_Force, Icon, Dodge, Defense, Grade, Savvy, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Heart_point, [], [], 0, 0),
			GmPetInfo = create_petinfo(PetId,get(roleid),Proto,Level,Name,Gender,Life2,Mana,Quality, Life2,MpMax,Class,State,Pos,Exp,TotalExp,Power,Hitrate,CriticalRate,CriticalDamage,Fighting_Force, Icon, Dodge, 0, Grade, Savvy, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Heart_point, Can_buy_goods, Refresh_used, Account, Luck_high,Refresh_defense),
			
			PetInfo = create_mypetinfo(PetId,Quality_Value_Info,Quality_Value_Up_Info,
                Attr,TradeLock,PetEquipInfo,ChangeNameFlag,
                Grade_Riseup_Retries,Grade_Riseup_Lucky,Quality_Riseup_Retries,Quality_Riseup_Lucky),
			{GmPetInfo,PetInfo};
		{Level, Name, Gender, Mana, Exp, Quality_Value_Info, Quality_Value_Up_Info, State, TradeLock, ChangeNameFlag, Grade, Quality, Savvy, Grade_Riseup_Retries, Grade_Riseup_Lucky, Quality_Riseup_Retries, Quality_Riseup_Lucky, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Class, Heart_point, Can_buy_goods, Refresh_used, Account, Luck_high,Refresh_defense} ->

		% {Level, Name, Gender, Mana, Exp, Quality_Value_Info, Quality_Value_Up_Info, State, TradeLock, ChangeNameFlag, Grade, Quality, Savvy, Grade_Riseup_Retries, Grade_Riseup_Lucky, Quality_Riseup_Retries, Quality_Riseup_Lucky, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Class, Heart_point} ->
			Pos = {0,0},
			PetLevelInfo = pet_level_db:get_info(Level),
			MpMax = pet_level_db:get_maxmp(PetLevelInfo),
			% HpMax = 0,
			Icon = [],
			TotalExp = pet_level_db:get_exp(PetLevelInfo)+Exp,
			ProtoInfo = pet_proto_db:get_info(Proto),
			% Is_ride = 0,
			Attr = pet_util:get_system_attr_add(Level,Grade,Proto),
			{Base_Power,Base_HitRate,Base_Dodge,Base_CriticalRate,Base_CritialDamage,Base_Life,Base_Toughness,Base_MagicDefense,Base_FarDefense,Base_NearDefense} = Attr,
			PetEquipInfo = pet_equip_op:get_equipinfo_by_db(EquipInfo),
			pet_skill_op:init_pet_skill(PetId,PetDbSkillInfo),		
			{Power,Hitrate,Dodge,CriticalRate,CriticalDamage,Life,Toughness2,MagicDefense2,FarDefense2,NearDefense2} = pet_util:compute_attr(Class,Attr, pet_util:get_skill_attr_self(PetId),pet_equip_op:get_attr_by_equipinfo(PetEquipInfo)),
			{Add_MagicDefense,Add_FarDefense,Add_NearDefense} = Refresh_defense,
			Fighting_Force = pet_fighting_force:computter_fight_force(Power, Hitrate, Dodge, CriticalRate, CriticalDamage, Life, MagicDefense + Add_MagicDefense, Add_FarDefense + FarDefense, Add_NearDefense + NearDefense, MagicImmunity, FarImmunity, NearImmunity),
			% GmPetInfo = create_petinfo(PetId,get(roleid),Proto,Level,Name,Gender,Life,Mana,Quality, Base_Life,MpMax,Class,State,Pos,Exp,TotalExp,Power,HitRate,CriticalRate,CriticalDamage,Fighting_Force, Icon, Dodge, Defense, Grade, Savvy, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Heart_point, [], [], 0, 0),
			GmPetInfo = create_petinfo(PetId,get(roleid),Proto,Level,Name,Gender,Life,Mana,Quality, Life,MpMax,Class,State,Pos,Exp,TotalExp,Power,Hitrate,CriticalRate,CriticalDamage,Fighting_Force, Icon, Dodge, 0, Grade, Savvy, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Heart_point, Can_buy_goods, Refresh_used, Account, Luck_high,Refresh_defense),
			
			PetInfo = create_mypetinfo(PetId,Quality_Value_Info,Quality_Value_Up_Info,
                Attr,TradeLock,PetEquipInfo,ChangeNameFlag,
                Grade_Riseup_Retries,Grade_Riseup_Lucky,Quality_Riseup_Retries,Quality_Riseup_Lucky),
			{GmPetInfo,PetInfo};
		_->
			slogger:msg("load pet_from_db error format PetDBInfo ~p ~n ",[PetDBInfo]),
			{[],[]}
	end.
			
create_petinfo_byproto()->
	todo.
create_petinfo_bybaseinfo()->
	todo.

proc_pet_item_equip(equip,PetId,Slot)->
	case get_pet_info(PetId) of
		[]->
			nothing;
		MyPetInfo->
			case pet_equip_op:proc_equip_pet_item(PetId,MyPetInfo,Slot) of
				[]->
					nothing;
				NewEquipInfo->
					NewPetInfo = set_equipinfo_to_mypetinfo(MyPetInfo,NewEquipInfo),
					put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
					pet_util:recompute_attr(equip,PetId)
			end
	end;
proc_pet_item_equip(unequip,PetId,Slot)->
	case get_pet_info(PetId) of
		[]->
			nothing;
		MyPetInfo->
			case pet_equip_op:proc_unequip_pet_item(PetId,MyPetInfo,Slot) of
				[]->
					nothing;
				NewEquipInfo->
					NewPetInfo = set_equipinfo_to_mypetinfo(MyPetInfo,NewEquipInfo),
					put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
					pet_util:recompute_attr(equip,PetId)
			end
	end.

hook_item_destroy_on_pet(ItemInfo)->
	ItemId = get_id_from_iteminfo(ItemInfo),
	case lists:filter(fun(MyPetInfo)-> pet_equip_op:is_in_pet_body(MyPetInfo,ItemId) end,get(pets_info)) of
		[]->
			nothing;
		[MyPetInfo]->
			PetId = get_id_from_mypetinfo(MyPetInfo),
			NewEquipInfo = pet_equip_op:proc_item_destroy_on_pet(MyPetInfo,ItemId),
			NewPetInfo = set_equipinfo_to_mypetinfo(MyPetInfo,NewEquipInfo),
			put(pets_info,lists:keyreplace(PetId,#my_pet_info.petid,get(pets_info),NewPetInfo)),
			pet_util:recompute_attr(equip,PetId)
	end.
	
hook_item_attr_changed(ItemId)->
	case lists:filter(fun(MyPetInfo)-> pet_equip_op:is_in_pet_body(MyPetInfo,ItemId) end,get(pets_info)) of
		[]->
			nothing;
		[MyPetInfo]->
			PetId = get_id_from_mypetinfo(MyPetInfo),
			pet_util:recompute_attr(equip,PetId)
	end.

%% for [{{X1,Y2},Rate1},{{X2,Y2},Rate2}] list.
apply_ran_list(RandomList)->
	MaxRate = lists:foldl(fun(ItemRate,LastRate)->
						LastRate +element(2,ItemRate)
				end, 0, RandomList),
	RandomV = random:uniform(MaxRate),
	{Value,_} = lists:foldl(fun({{X1,X2},RateTmp},{Value,LastRate})->
						if
							Value=/= []->
								{Value,0};
							true->
								if
									LastRate+RateTmp >= RandomV->
										{X1 + (RandomV rem (X2-X1+1)),0};
									true->
										{[],LastRate+RateTmp}
								end
						end
				end, {[],0}, RandomList),
	Value.

% 宠物类型转换
pet_type_change(PetId, ChangeType, Flag, RoleState) ->
	% 该宠物是否存在
	case get_pet_gminfo(PetId) of
		[] ->
			{error, ?ERROR_PET_NOEXIST};
		PetInfo ->
			#gm_pet_info{class = OldType} = PetInfo,
			% 原类型与即将转换类型是否一致
			case OldType =:= ChangeType of
				true ->
					{error, ?ERROR_PET_TYPE_SAME};
				false ->
					case Flag =/= ?TYPR_CHANGE_GOLD andalso Flag =/= ?TYPR_CHANGE_PROP of
						true ->
							{error, ?ERROR_SYSTEM};
						false ->
							% 类型转换配置信息
							PetTypeChange = pet_type_change:get_type_change(ChangeType),
							if
								Flag =:= ?TYPR_CHANGE_GOLD ->
									% 元宝是否充足
									Gold = PetTypeChange#pet_type_change_config.gold,
									case role_op:check_money(?MONEY_GOLD, Gold) of
										false ->
											{error, ?ERROR_LESS_GOLD};
										true ->
											NewPetInfo = PetInfo#gm_pet_info{class = ChangeType},
											% 更新内存数据
											update_gm_pet_info_all(NewPetInfo),
											% 扣钱
											role_op:money_change(?MONEY_GOLD, -Gold, pet_type_change),
											% 计算、保存
											pet_util:recompute_attr(type_change, PetId),
											Msg = pet_packet:encode_pet_type_change_s2c(PetId, ChangeType),
											role_op:send_data_to_gate(Msg),

											{ok, RoleState}
									end;
								Flag =:= ?TYPR_CHANGE_PROP ->
									% 道具是否充足
									PropNumList = PetTypeChange#pet_type_change_config.prop_list,
									case equipment_move:prop_enough(PropNumList) of
										false ->
											{error, ?ERROR_PET_TYPE_CHANGE_PROP_NOT_ENOUGH};
										true ->
											NewPetInfo = PetInfo#gm_pet_info{class = ChangeType},
											% 更新内存数据
											update_gm_pet_info_all(NewPetInfo),
											% 扣除道具
											ok = equipment_move:delete_prop(PropNumList),
											% 计算、保存
											pet_util:recompute_attr(type_change, PetId),
											Msg = pet_packet:encode_pet_type_change_s2c(PetId, ChangeType),
											role_op:send_data_to_gate(Msg),

											{ok, RoleState}
									end
							end
					end
			end
	end.
% pet_swank(PetId) ->
% case get_pet_gminfo(PetId) of
% 	[] ->
% 		{error, ?ERROR_PET_NOEXIST};
% 	PetInfo ->
% 		% #gm_pet_info{class = OldType} = PetInfo,
% 		do_swank();
% end.
