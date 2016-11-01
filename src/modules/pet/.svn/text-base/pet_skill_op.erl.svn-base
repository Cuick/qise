-module(pet_skill_op).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("skill_define.hrl").
-include("item_define.hrl").
-include("little_garden.hrl").
-include("error_msg.hrl").
-include("pet_struct.hrl").
-include("pet_def.hrl").

-define(OPEN_SLOT, 100).

-define(SKILL_COVER_RATE, 99).


% -record(pet_skill_buy_slot_c2s, {msgid=23002,petid,slot}).
% -record(pet_skill_buy_slot_s2c, {msgid=23003,petid,slot}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%pet_skillinfo [{PetId,[{Slot,{SkillId,SkillLevel,CastTime},SlotState}]}]

init_pet_skill_info() ->
	put(pets_skill_info,[]).

check_slot_state(Slot_num) ->
	Newpets_skill_info = lists:foldl(fun(Pet_skillinfo,AccPet_skillinfo) ->
			case Pet_skillinfo of
				{PetId,Pet_slots} ->
					[{PetId,lists:foldl(fun(Pet_slot,Pet_slotAcc)->
							case Pet_slot of
								 {SlotId,{_SkillId,_SkillLevel,_CastTime},SlotState}->
									if
										SlotId =< Slot_num ->
											if SlotState =:= ?PET_SKILL_SLOT_NOT_OPEN ->
													[{SlotId,{_SkillId,_SkillLevel,_CastTime},?PET_SKILL_SLOT_INACTIVE}] ++ Pet_slotAcc;
												true ->
													[{SlotId,{_SkillId,_SkillLevel,_CastTime},SlotState}] ++ Pet_slotAcc
											end;
										true ->
											[{SlotId,{_SkillId,_SkillLevel,_CastTime},SlotState}] ++ Pet_slotAcc
									end;
								_ ->
										Pet_slotAcc
							end
					end,[],Pet_slots)}]++AccPet_skillinfo;
				_  ->
					AccPet_skillinfo
			end
	end,[],get(pets_skill_info)),
	put(pets_skill_info,Newpets_skill_info).

save_to_db()->
	todo.
	
async_save_to_db()->
	todo.

% initskillinfo()->
% 	BornSkillInfo1 = [{1,{0,0,0},?PET_SKILL_SLOT_INACTIVE}],
% 	BornSkillInfo = lists:map(fun(SlotId)-> {SlotId,{0,0,0},?PET_SKILL_SLOT_NOT_OPEN} end,lists:seq(2,?PET_TOTAL_SKILL_SLOT)),
% 	% OtherSkillInfo = lists:map(fun(SlotId)-> {SlotId,{0,0,0},?PET_SKILL_SLOT_INACTIVE} end,lists:seq(?PET_BORN_SKILL_SLOT+1,?PET_TOTAL_SKILL_SLOT)),
% 	TotleBornSkillInfo = BornSkillInfo1++BornSkillInfo.

initskillinfo()->
	BornSkillInfo = lists:map(fun(SlotId)-> {SlotId,{0,0,0},?PET_SKILL_SLOT_NOT_OPEN} end,lists:seq(1,?PET_TOTAL_SKILL_SLOT)).


init_pet_skill(PetId,SkillInfos)->
	case SkillInfos of
		[] ->
			NewSkillInfo = initskillinfo();
		_ ->
			NewSkillInfo = lists:foldl(fun(SkillInfo,Acc)->
							case SkillInfo of
								 {SlotId,{_SkillId,_SkillLevel,_CastTime},_SlotState}->
								 	case lists:keyfind(SlotId,1,initskillinfo()) of 
								 		false ->
								 			Acc;
								 		_ ->
								 			[{SlotId,{_SkillId,_SkillLevel,_CastTime},_SlotState}|Acc]
								 	end;
								 _ ->
								 	Acc		
							end	
			end,[],SkillInfos)
	end,
	put(pets_skill_info,[{PetId,NewSkillInfo}|get(pets_skill_info)]).

send_up_data() ->
	lists:foreach(fun({PetId,SkillInfo})->
				%% slot info 
				SlotInfo = lists:map(fun({Slot,_,SlotState})-> pet_packet:make_psll(Slot,SlotState) end,SkillInfo),
				SlotInitMsg = pet_packet:encode_init_pet_skill_slots_s2c(pet_packet:make_psl(PetId,SlotInfo)),
				role_op:send_data_to_gate(SlotInitMsg),
				%%skill info
				Skills = lists:map(fun({Slot,{SkillId,Level,CastTime},_})-> pet_packet:make_psk(Slot,SkillId,Level) end,SkillInfo),
				SendSkillInfo = pet_packet:encode_learned_pet_skill_s2c(pet_packet:make_ps(PetId,Skills)),
				role_op:send_data_to_gate(SendSkillInfo)		  
			end, get(pets_skill_info)).
	
send_init_data()->
	Skillid = case get_pet_skill_from_roleinfo(get(creature_info)) of
				[] ->
					0;
				[Val] ->
					Val
				end,
	% slogger:msg("aaaaaaaaaaaaaaaaaaaaaaaaaa~p~ncreature_info:~p~n",[Skillid,get(creature_info)]),
	Msg = pet_packet:encode_pet_skill_fuse_s2c(Skillid),
	role_op:send_data_to_gate(Msg),
	lists:foreach(fun({PetId,SkillInfo})->
				%% slot info 
				SlotInfo = lists:map(fun({Slot,_,SlotState})-> pet_packet:make_psll(Slot,SlotState) end,SkillInfo),
				SlotInitMsg = pet_packet:encode_init_pet_skill_slots_s2c(pet_packet:make_psl(PetId,SlotInfo)),
				role_op:send_data_to_gate(SlotInitMsg),
				%%skill info
				Skills = lists:map(fun({Slot,{SkillId,Level,CastTime},_})-> pet_packet:make_psk(Slot,SkillId,Level) end,SkillInfo),
				SendSkillInfo = pet_packet:encode_learned_pet_skill_s2c(pet_packet:make_ps(PetId,Skills)),
				role_op:send_data_to_gate(SendSkillInfo)		  
			end, get(pets_skill_info)).

send_init_data(PetId)->
	case lists:keyfind(PetId,1,get(pets_skill_info)) of
		false->
			nothing;
		{_,SkillInfo}->
			%% slot info 
			SlotInfo = lists:map(fun({Slot,_,SlotState})-> pet_packet:make_psll(Slot,SlotState) end,SkillInfo),
			SlotInitMsg = pet_packet:encode_init_pet_skill_slots_s2c(pet_packet:make_psl(PetId,SlotInfo)),
			role_op:send_data_to_gate(SlotInitMsg),
			%%skill info
			Skills = lists:map(fun({Slot,{SkillId,Level,CastTime},_})-> pet_packet:make_psk(Slot,SkillId,Level) end,SkillInfo),
			SendSkillInfo = pet_packet:encode_learned_pet_skill_s2c(pet_packet:make_ps(PetId,Skills)),
			role_op:send_data_to_gate(SendSkillInfo)
	end.
%%
%%
%%
create_pet_skill(PetId)->
	SkillList = initskillinfo(),
	add_pet(PetId,SkillList),
	Level = get(level),
	LevelInfo = role_petnum_db:get_info(Level),
	Level_skill_slot = role_petnum_db:get_skill_slot(LevelInfo),
	check_slot_state(Level_skill_slot).
	
add_pet(PetId,SkillInfo)->
	put(pets_skill_info,[{PetId,SkillInfo}|get(pets_skill_info)]).

delete_pet(PetId)->
	put(pets_skill_info,lists:keydelete(PetId, 1, get(pets_skill_info))).

%%
%%return true|false
%%
learn_skill(PetId,SkillId,SkillLevel,Lock_slot_list) ->
	quest_op:pet_skill_check(),
	case lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			ErrorMsg = pet_packet:encode_pet_opt_error_s2c(17001),
			role_op:send_data_to_gate(ErrorMsg),
			false;
		{PetId,OriSkillsInfo}->
			{ActiveSlot,InActiviveSlot,SameSkillSlot} 
				= lists:foldl(fun({Slot,{CurSlotSkill,_,_},Status},{ActiveAcc,InActiveAcc,SameSkillSlotAcc})->
								if
									SameSkillSlotAcc =/= 0->
										{ActiveAcc,InActiveAcc,SameSkillSlotAcc};
									CurSlotSkill =:= SkillId->
									  	{ActiveAcc,InActiveAcc,Slot};
									true->
										case lists:member(Slot,Lock_slot_list) of
											false ->
												case Status of
													?PET_SKILL_SLOT_ACTIVE ->
														{[Slot|ActiveAcc],InActiveAcc,SameSkillSlotAcc};
													?PET_SKILL_SLOT_INACTIVE ->
														{ActiveAcc,[Slot|InActiveAcc],SameSkillSlotAcc};
													_ ->
														{ActiveAcc,InActiveAcc,SameSkillSlotAcc}
												end;
											_ ->
												{ActiveAcc,InActiveAcc,SameSkillSlotAcc}

										end
								end
							end,{[],[],0},OriSkillsInfo),
			if
				SameSkillSlot =/= 0->	%%find same skill 
					{_,{_,OldLevel,_},SameSkillSlotStatus} = lists:keyfind(SameSkillSlot,1,OriSkillsInfo),
					case SkillLevel - OldLevel of
						1 ->
							NewSkillInfo = lists:keyreplace(SameSkillSlot,1,OriSkillsInfo,{SameSkillSlot,{SkillId,SkillLevel,0},SameSkillSlotStatus}),
							put(pets_skill_info,lists:keyreplace(PetId, 1, get(pets_skill_info), {PetId,NewSkillInfo})),
							SkillMsgBin = pet_packet:encode_update_pet_skill_s2c(PetId,pet_packet:make_psk(SameSkillSlot,SkillId,SkillLevel)),
							role_op:send_data_to_gate(SkillMsgBin),
							pet_util:recompute_attr(skill,{PetId,SkillId,OldLevel,SkillLevel,same}),
							true;
						_ ->
							role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_LEARN_SKILL_SAME_SKILL_LOCK)),
							false
					end;
				true->
					case SkillLevel of
						1 ->
							case length(ActiveSlot) of
								0 ->
									case length(InActiviveSlot) of
										0 ->
											ErrorMsg = pet_packet:encode_pet_opt_error_s2c(?HANENOT_SLOT),
											role_op:send_data_to_gate(ErrorMsg),
											false;
										_ ->
											FindSlot = lists:foldl(fun(ActSlot,Acc) ->
														{Num,_Time} = random:uniform_s(100,now()),
														if Num < ?SKILL_COVER_RATE ->
																ActSlot;
															true ->
																Acc
														end
												end,hd(InActiviveSlot),InActiviveSlot),
											{_,{OldSkillId,OldSkillLevel,_},_FindSlotStatus} = lists:keyfind(FindSlot,1,OriSkillsInfo),
											FindSlotInfo = {FindSlot,{SkillId,SkillLevel,0},?PET_SKILL_SLOT_ACTIVE},
											SkillsInfo = lists:keyreplace(FindSlot,1,OriSkillsInfo,FindSlotInfo),					
											put(pets_skill_info,lists:keyreplace(PetId, 1, get(pets_skill_info), {PetId,SkillsInfo})),	
											item_util:consume_items_by_classid(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,length(Lock_slot_list)),
											SkillMsgBin = pet_packet:encode_update_pet_skill_s2c(PetId,pet_packet:make_psk(FindSlot,SkillId,SkillLevel)),
											role_op:send_data_to_gate(SkillMsgBin),
											pet_util:recompute_attr(skill,{PetId,SkillId,0,SkillLevel,diff}),
											true
									end;
								_Length ->
									FindSlot = lists:foldl(fun(ActSlot,Acc) ->
														{Num,_Time} = random:uniform_s(100,now()),
														if Num < ?SKILL_COVER_RATE ->
																ActSlot;
															true ->
																Acc
														end
												end,hd(ActiveSlot),ActiveSlot),
									{_,{OldSkillId,OldSkillLevel,_},_FindSlotStatus} = lists:keyfind(FindSlot,1,OriSkillsInfo),
									FindSlotInfo = {FindSlot,{SkillId,SkillLevel,0},?PET_SKILL_SLOT_ACTIVE},
									SkillsInfo = lists:keyreplace(FindSlot,1,OriSkillsInfo,FindSlotInfo),					
									put(pets_skill_info,lists:keyreplace(PetId, 1, get(pets_skill_info), {PetId,SkillsInfo})),	
									item_util:consume_items_by_classid(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,length(Lock_slot_list)),
									SkillMsgBin = pet_packet:encode_update_pet_skill_s2c(PetId,pet_packet:make_psk(FindSlot,SkillId,SkillLevel)),
									role_op:send_data_to_gate(SkillMsgBin),
									pet_util:recompute_attr(skill,{PetId,OldSkillId,OldSkillLevel,0,forget}),
									pet_util:recompute_attr(skill,{PetId,SkillId,0,SkillLevel,diff}),
									true
							end;
					 _ ->
					 	ErrorMsg = pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_CANNOT_LEARN_THIS_SKILL),
						role_op:send_data_to_gate(ErrorMsg),
					 	false
					end
			end							
	end.
	
forget_skill(PetId,SkillId,Slot)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			nothing;
		{PetId,OriSkillsInfo}->
			case lists:keyfind(Slot,1,OriSkillsInfo) of
				false->
					nothing;
				{_,{0,_,_},_}->
					nothing;
				{_,_,Status}->
					if
						Status =:= ?PET_SKILL_SLOT_INACTIVE->
							nothing;
						true->
							if
								Status =:= ?PET_SKILL_SLOT_ACTIVE_AND_LOCK ->
									NewSlotInfo = {Slot,{0,0,0},?PET_SKILL_SLOT_ACTIVE},
									MsgBin = pet_packet:encode_update_pet_skill_slot_s2c(PetId,pet_packet:make_psll(Slot,?PET_SKILL_SLOT_ACTIVE)),
									role_op:send_data_to_gate(MsgBin);
								true->
									NewSlotInfo = {Slot,{0,0,0},Status}
							end,
							SkillsInfo = lists:keyreplace(Slot,1,OriSkillsInfo,NewSlotInfo),		
							put(pets_skill_info,lists:keyreplace(PetId, 1, get(pets_skill_info), {PetId,SkillsInfo})),
							SkillMsgBin = pet_packet:encode_update_pet_skill_s2c(PetId,pet_packet:make_psk(Slot,0,0)),
							role_op:send_data_to_gate(SkillMsgBin),
							pet_util:recompute_attr(skill,{PetId,SkillId,3,0,forget})
					end
			end		
	end.

export_for_copy()->	
	{get(pets_skill_info)}.

load_by_copy({Skill_info})->
	put(pets_skill_info,Skill_info).

get_pet_skillnum(PetId)->
	erlang:length(get_pet_skillinfo(PetId)).

get_active_skillnum(PetId)->
	lists:foldl(fun({SkillId,Level,_},AddTmp)->
		SkillInfo = skill_db:get_skill_info(SkillId,Level),
		SkillType = skill_db:get_type(SkillInfo),				
		case (SkillType =:= ?SKILL_TYPE_ACTIVE)  or (SkillType =:=?SKILL_TYPE_ACTIVE_WITHOUT_CHECK_SILENT) of
			true->
				AddTmp+1;
			false->
				AddTmp
		end
	end,0,get_pet_skillinfo(PetId)).

get_pet_skillallinfo(PetId)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			[];
		{PetId,SkillsInfo}->
			SkillsInfo
	end.

get_pet_skillinfo(PetId)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			[];
		{PetId,SkillsInfo}->
			NewSkillsInfo = lists:filter(fun({_,{SkillId,_,_},_})-> SkillId =/= 0 end,SkillsInfo),
			lists:map(fun({_,Skill,_})-> Skill end,NewSkillsInfo)
	end.

%%
%%
%%
get_pet_bestskillinfo(PetId)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			[];
		{PetId,SkillsInfo}->
			lists:foldl(fun({_,{SkillId,SkillLevel,CastTime},_},Acc)-> 
								if
									SkillId =:= 0->
										Acc;
									true-> 
										case lists:keyfind(SkillId,1,Acc) of 
											false->
												NewAcc = [{SkillId,SkillLevel,CastTime}|Acc];
											{_,OldLevel,OldCastTime}->
												if
													OldLevel >= SkillLevel->			
														NewAcc = Acc;
													true->
														NewAcc = lists:keyreplace(SkillId,1,Acc,{SkillId,SkillLevel,CastTime})
												end;
											_->
												NewAcc = Acc
										end,
										NewAcc
								end
							end,[],SkillsInfo);
		_->
			[]
	end.

get_skill_level(PetId,SkillID)->
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			0;
		{PetId,SkillsInfo}->
			lists:foldl(fun({_,{SkillId,Level,_},_},Acc)->
							if
								SkillID =:= SkillId->
									erlang:max(Acc,Level);
								true->
									Acc
							end
						end,0,SkillsInfo)
	end.

check_common_cool(Now)->
	case get(last_pet_cast_time) of
		undefined->
			true;
		Time->
			% timer:now_diff(Now ,Time) >= ?PET_ATTACK_TIME*1000
			true
	end.

set_common_cool(Now)->
	put(last_pet_cast_time,Now).

%% 目前宠物使用的技能是一个固定技能(落雷术)，时间比较长，临时减少时间间隔
is_cooldown_ok(PetId,SkillID) ->
	Now = timer_center:get_correct_now(),
	BaseCheck = check_common_cool(Now),
	if
		BaseCheck->
			case get_pet_bestskillinfo(PetId) of
				[]->
					false;
				SkillsInfo->
					case lists:keyfind(SkillID, 1,SkillsInfo ) of
						false->
							false;
						{SkillID,SkillLevel,0}->
							true;
						{SkillID,SkillLevel,LastCastTime}->
							SkillInfo =  skill_db:get_skill_info(SkillID,SkillLevel),
							true
							% timer:now_diff(Now ,LastCastTime) >= 800 * 1000
							% timer:now_diff(Now ,LastCastTime) >= skill_db:get_cooldown(SkillInfo) * 1000					
					end
			end;
		true->
			false
	end.

is_cooldown_ok(SkillID,SkillLevel,LastCastTime) ->
	Now = timer_center:get_correct_now(),
	BaseCheck = check_common_cool(Now),
	if
		BaseCheck->
			SkillInfo =  skill_db:get_skill_info(SkillID,SkillLevel),
			% timer:now_diff(Now ,LastCastTime) >= skill_db:get_cooldown(SkillInfo)*1000;
			true;					
		true->
			false
	end.

set_casttime(PetId,SkillId,SkillLevel)->
	Now = timer_center:get_correct_now(),
	set_common_cool(Now),
	case  lists:keyfind(PetId, 1, get(pets_skill_info)) of
		false->
			nothing;
		{PetId,SkillList}->
			lists:foldl(fun({Slot,{FindSkillId,FindLevel,CastTime},Status},Acc)->
							if
								Acc->
									Acc;
								true->
									case {FindSkillId,FindLevel} of
										{SkillId,SkillLevel}->
											NewPetSkill = lists:keyreplace(Slot,1,SkillList,{Slot,{FindSkillId,FindLevel,Now},Status}),
											put(pets_skill_info,lists:keyreplace(PetId,1,get(pets_skill_info),{PetId,NewPetSkill})),
											true;
										_->
											Acc
									end
							end
						end,false,SkillList)
	end.

get_attack_module(Skill) ->
	case Skill of
		1 ->
			normal_point_attack;
		2 ->
			normal_scope_attack;
		3 ->
			complex_scope_attack;
		_ ->
			undefined
	end.

do_learn_for_pet(PetId,Skillid)->
	todo.

get_skill_addition_for_pet(PetId)->
	SkillInfos = get_pet_bestskillinfo(PetId),
	lists:foldl(fun({SkillId,Level,_},AddAttrTmp)->
			SkillInfo = skill_db:get_skill_info(SkillId, Level),
			% slogger:msg("aaaaaaaaaaaaaaaaaapetid and info:~p~n",[{SkillId, Level,PetId,SkillInfo,SkillInfos}]),
			case skill_db:get_type(SkillInfo) of
				?SKILL_TYPE_PASSIVE_ATTREXT->
					% slogger:msg("12 ~p~n",[{skill_db:get_caster_buff(SkillInfo),skill_db:get_type(SkillInfo)}]),
					AddBuffs = skill_db:get_caster_buff(SkillInfo),
					AddAttrTmp ++
					lists:foldl(fun({{BufferId,BuffLevel},_Rate},AttrTmp)-> 
									AttrTmp ++ buffer_op:get_buffer_attr_effect(BufferId,BuffLevel)
								end, [], AddBuffs);
				_->
					slogger:msg("13 ~p~n",[{?SKILL_TYPE_PASSIVE_ATTREXT,skill_db:get_type(SkillInfo)}]),
					AddAttrTmp
			end end, [], SkillInfos).
get_skill_add_buff(SkillId, Level) ->
	case skill_db:get_skill_info(SkillId, Level) of
				[] ->
					[];
				SkillInfo ->
					case skill_db:get_type(SkillInfo) of
						?SKILL_TYPE_PASSIVE_ATTREXT->
							AddBuffs = skill_db:get_caster_buff(SkillInfo),
							lists:foldl(fun({{BufferId,BuffLevel},_Rate},AttrTmp)-> 
											AttrTmp ++ buffer_op:get_buffer_attr_effect(BufferId,BuffLevel)
										end, [], AddBuffs);
						_->
							slogger:msg("13 ~p~n",[{?SKILL_TYPE_PASSIVE_ATTREXT,skill_db:get_type(SkillInfo)}]),
							[]
					end
	end.

get_skill_addition_for_role(PetId)->
	SkillInfos = get_pet_bestskillinfo(PetId),
	lists:foldl(fun({SkillId,Level,_},AddAttrTmp)->
			SkillInfo = skill_db:get_skill_info(SkillId, Level),
			case skill_db:get_type(SkillInfo) of
				?SKILL_TYPE_PASSIVE_ATTREXT->
					% logger:msg("1 ~p~n",[?SKILL_TYPE_PASSIVE_ATTREXT]),
					AddBuffs = skill_db:get_target_buff(SkillInfo),
					AddAttrTmp ++
					lists:foldl(fun({{BufferId,BuffLevel},_Rate},AttrTmp)-> 
									AttrTmp ++ buffer_op:get_buffer_attr_effect(BufferId,BuffLevel)
								end, [], AddBuffs);
				_->
					AddAttrTmp
			end end, [], SkillInfos).

change_skill_slot_status(PetId,Slot,Status)->
	SkillInfos = get_pet_skillallinfo(PetId),
	{_,Skills,SlotState} = lists:keyfind(Slot,1,SkillInfos),
	if
		SlotState =:= Status->
			slogger:msg("change_skill_slot_status error same status ~p ~n",[{PetId,Slot,Status}]),
			nothing;
		SlotState =:= ?PET_SKILL_SLOT_INACTIVE->
			slogger:msg("change_skill_slot_status error slot not active ~p ~n",[{PetId,Slot,Status}]),
			nothing;
		Status =:= ?PET_SKILL_SLOT_ACTIVE->			%%unlock
			%%check item
			case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,1) of
				false->
					Errno = ?ERROR_PET_SKILL_SLOT_LOCK_ITEM_NOT_ENOUGN,
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
				true->				
					%%consume
					item_util:consume_items_by_classid(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,1),
					NewSkillInfos = lists:keyreplace(Slot,1,SkillInfos,{Slot,Skills,Status}),
					put(pets_skill_info,lists:keyreplace(PetId,1,get(pets_skill_info),{PetId,NewSkillInfos})),
					%%notify client
					MsgBin = pet_packet:encode_update_pet_skill_slot_s2c(PetId,pet_packet:make_psll(Slot,Status)),
					role_op:send_data_to_gate(MsgBin)
			end;
		true->
			%%check lock solt num
			LockNum = lists:foldl(fun({_,_,FindStatus},Acc)->
										if
											FindStatus =:= ?PET_SKILL_SLOT_ACTIVE_AND_LOCK->
												Acc+1;
											true->
												Acc
										end
									end,0,SkillInfos),
			CanLockNum = ?PET_SKILL_SLOT_LOCK_NUM + vip_op:get_addition_with_vip(pet_slot_lock),
			CheckLockSolt = lists:member(Slot,?PET_SKILL_SLOTLIST_CAN_LOCK),
			{SkillId,_,_} = Skills,
			CheckSoltSkill = (SkillId =:= 0),
			if
				CheckSoltSkill->
					Errno = ?ERROR_PET_SKILL_SLOT_CANNOT_BELOCKED,
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
				CanLockNum =< LockNum  ->
					Errno = ?ERROR_PET_SKILL_SLOT_LOCKER_LIMITED,
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
				not CheckLockSolt->
					Errno = ?ERROR_PET_SKILL_SLOT_CANNOT_BELOCKED,
					role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
				true->
					%%check item
					case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,1) of
						false->
							Errno = ?ERROR_PET_SKILL_SLOT_LOCK_ITEM_NOT_ENOUGN,
							role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno));
						true->				
							%%consume
							item_util:consume_items_by_classid(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,1),
							%%change
							NewSkillInfos = lists:keyreplace(Slot,1,SkillInfos,{Slot,Skills,Status}),
							put(pets_skill_info,lists:keyreplace(PetId,1,get(pets_skill_info),{PetId,NewSkillInfos})),
							%%notify client
							MsgBin = pet_packet:encode_update_pet_skill_slot_s2c(PetId,pet_packet:make_psll(Slot,Status)),
							role_op:send_data_to_gate(MsgBin)
					end
			end
	end.

%%
%%find useful slot	
%%
check_useful_slot(PetId,Lock_slot_list)->
	SkillsInfo = get_pet_skillallinfo(PetId),
	lists:foldl(fun({Slotid,{SkillId,_,_},Status},Acc)->
						if
							Acc->
								Acc;
							true->
								Lock = lists:any(fun(SlotID)->
										Slotid =:= SlotID
										end,Lock_slot_list),
								(not Lock) and (Status =/= ?PET_SKILL_SLOT_NOT_OPEN)
						end
					end,false,SkillsInfo).

%%
%%return true | false
%%
check_common_skill(Class,SkillId)->
	case Class of
		?CLASS_MAGIC->
			SkillId =:= ?NARMAL_MAGIC_ATTACK_PET;
		?CLASS_RANGE->
			SkillId =:= ?NARMAL_RANGE_ATTACK_PET;
		?CLASS_MELEE->
			SkillId =:= ?NARMAL_MELEE_ATTACK_PET
	end.

%%
%%return true | false
%%
check_same_skill(PetId,SkillId,SkillLevel)->
	SkillsInfo = get_pet_skillallinfo(PetId),
	lists:foldl(fun({_,{SkillId0,SkillLevel0,_},_},Acc)->
						if
							Acc->
								Acc;
							true->
								(SkillId0 =:= SkillId) and (SkillLevel0 >= SkillLevel) 
						end
					end,false,SkillsInfo).

%%
%%return {true,oldlevel}|false
%%
check_best_skill(PetId,SkillId,SkillLevel)->
	SkillsInfo = get_pet_skillallinfo(PetId),
	lists:foldl(fun({_,{_SkillId,_SkillLevel,_},_},Acc)->
						case Acc of
							{true,_}->
								Acc;
							_->
								case (_SkillId =:= SkillId) and (_SkillLevel > SkillLevel) of
									true->
										{true,_SkillLevel};
									_->
										Acc
								end
						end
					end,false,SkillsInfo).
	


skill_fuse(Types) ->
	case travel_battle_op:is_in_zone() of
		false ->
			do_skill_fuse(Types);
		true ->
			Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_INVALID_OPERATION),
			role_op:send_data_to_gate(Msg)
	end.

do_skill_fuse(Types) ->
	case check_type_diff(Types) of 
		false ->
			send_error(?ERROR_PET_SAME_TYPE);
		true ->
			case check_type(Types) of
				false ->
					send_error(?ERROR_PET_NOEXIST);
				true ->	
					F = fun(PetProto) ->
							PetProtoInfo = pet_proto_db:get_info(PetProto),
							PetSpecie = pet_proto_db:get_species(PetProtoInfo)
						end,
					Species = [F(Type)||Type<-Types],
					Total = lists:sum(Species),
					Skill_fuse_infos = pet_skill_slot_db:get_all_skill_fuse_info(),
					SkillInfo = lists:filter(fun({_Index,Skill_fuse_info})->
							{Min,Max} = Skill_fuse_info#pet_skill_fuse.index,
							Total >= Min andalso Total =< Max 
					end,Skill_fuse_infos),
					case SkillInfo of
						[] ->
							send_error(?ERROR_PET_CANNOT_FIND_SKILL);
						[{_,Skill}] ->
							npc_skill_study:learn_pet_skill_without_npc(Skill#pet_skill_fuse.skillid)
					end
					
			end
	end.

del_fuse_skill() ->
	put(creature_info, set_pet_skill_to_roleinfo(get(creature_info), [])).
open_slot(PetId0,Slot) ->
	PetId = list_to_integer(PetId0),
	% slogger:msg("aaaaaaaaaaaaaaaaaaaaaaa~p,~p,~n,~p",[PetId0,PetId,get(pets_skill_info)]),
	case lists:keyfind(PetId,1,get(pets_skill_info)) of
		false->
			send_error(?ERROR_PET_NOEXIST);
		{_,SkillInfos}->
			case lists:keyfind(Slot,1,SkillInfos) of
			 	false ->
			 		send_error(?ERR_PET_SLOT_FULL);
			 	{_,Skills,SlotState} ->
			 		case SlotState of
			 			?PET_SKILL_SLOT_NOT_OPEN ->
			 					case role_op:check_money(2, ?OPEN_SLOT) of
									true->
									 	case role_op:money_change(2, -?OPEN_SLOT,open_slot) of
											ok ->
												NewSkillInfos = lists:keyreplace(Slot,1,SkillInfos,{Slot,Skills,?PET_SKILL_SLOT_INACTIVE}),
												put(pets_skill_info,lists:keyreplace(PetId,1,get(pets_skill_info),{PetId,NewSkillInfos})),
												MsgBin = pet_packet:encode_update_pet_skill_slot_s2c(PetId,pet_packet:make_psll(Slot,?PET_SKILL_SLOT_INACTIVE)),
												role_op:send_data_to_gate(MsgBin);
											_ ->
												send_error(?ERROR_LESS_GOLD)
										end;
									false ->
										send_error(?ERROR_LESS_GOLD)
								end;
						_ ->
							send_error(?ERR_PET_SLOT_OPEND)
					end
			 end
	end.
check_type_diff(Types) ->
	lists:foldl(fun(Type,Acc)->
		case lists:member(Type,Types--[Type]) of
			true ->
				false;
			false ->
				Acc
		end
	end,true,Types).

check_type(Types) ->
	lists:foldl(fun(Type,Acc)-> 
			F = fun(PetInfo) ->
					PetProto = get_proto_from_petinfo(PetInfo),
					% PetProtoInfo = pet_proto_db:get_info(PetProto),
					% PetSpecies = pet_proto_db:get_species(PetProtoInfo),
					case PetProto of
						Type ->
							true;
						_ ->
							false
					end
				end,
			Flags = [F(Pet_info)||Pet_info<-get(gm_pets_info)],
			case lists:any(fun(Flag)-> Flag =:= true end,Flags) of
				false->
					false;
				true->
					Acc
			end
		end,true,Types).


send_error(ErrorCode) ->
	ErrorMsg = pet_packet:encode_pet_opt_error_s2c(ErrorCode),
	role_op:send_data_to_gate(ErrorMsg).
