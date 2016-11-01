%% Author: MacX
%% Created: 2011-9-29
%% Description: TODO: Add description to banquet_op
-module(banquet_op).

%%
%% Include files

%%
%% Exported Functions
%%
-export([init/0,load_from_db/1,export_for_copy/0,load_by_copy/1,write_to_db/0,
		 banquet_join_c2s/1,hook_on_online/0,hook_on_offline/0,
		 banquet_request_banquetlist_c2s/0,banquet_leave_c2s/0,get_map_proc_name/0,
		 banquet_cheering_c2s/1,banquet_dancing_c2s/1,check_cooltime/1,
		 handle_banquet_touch/2,handle_be_banquet_touch/2,is_in_banquet/0,
		 banquet_dancing_with_gold/1,hook_on_role_levelup/1,
		 banquet_apply_stop_player/0,hook_on_vip_up/2, companion_dancing_apply/1,
		 companion_dancing_start/1, companion_dancing_reject/1, handle_other_role_msg/2,
		 stop_dancing/0, can_companion_dancing/0, pet_swank/0,handle_pet_swanking/1]).

-define(BANQUET_BUFFER_TIME_S,60).
-define(BANQUET_BUFFER_END_TIME_S,0).
-define(BANQUET_DANCING_GOLD,8).
-define(ROLE_BANQUET_INFO,role_banquet_info).
-define(ROLE_BANQUET_STATE,role_banquet_state).
-define(ROLE_BANQUET_ACTIVITY,role_banquet_activity).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("instance_define.hrl").
-include("little_garden.hrl").
-include("activity_define.hrl").
-include("error_msg.hrl").
-include("game_map_define.hrl").
-include("map_info_struct.hrl").
-include("item_define.hrl").
-include("common_define.hrl").
-include("creature_define.hrl").
-include("pet_struct.hrl").

%%
%% API Functions
%%
init()->
	%%role_banquet_info={roleid,node,mapproc,banquetid,banquettime,
	%%{{dancing,bedancing,cool},{cheering,becheering,cool},{swanking}}
	put(?ROLE_BANQUET_INFO,[]),
	put(?ROLE_BANQUET_STATE,?BANQUET_ROLE_STATE_LEAVE),
	put(?ROLE_BANQUET_ACTIVITY,?ACTIVITY_STATE_STOP),
	hook_on_online().

load_from_db(_RoleId)->
	todo.

export_for_copy()->
	{get(?ROLE_BANQUET_STATE),get(?ROLE_BANQUET_INFO),get(?ROLE_BANQUET_ACTIVITY)}.
	
write_to_db()->
	nothing.

load_by_copy({RoleBanquetState,RoleBanquetInfo,RoleBanquetActivity})->
	put(?ROLE_BANQUET_STATE,RoleBanquetState),
	put(?ROLE_BANQUET_INFO,RoleBanquetInfo),
	put(?ROLE_BANQUET_ACTIVITY,RoleBanquetActivity).

is_in_banquet()->
	case get(?ROLE_BANQUET_STATE) of
		?BANQUET_ROLE_STATE_JOIN->
			true;
		_->
			false
	end.

banquet_request_banquetlist_c2s()->
	activity_manager:request_banquetlist(get(roleid)).

get_map_proc_name()->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			[];
		{_,_,MapProc,_,_,_}->
			MapProc
	end.

banquet_join_c2s(BanquetId)->
	Errno = 
	case get(?ROLE_BANQUET_STATE) of
		?BANQUET_ROLE_STATE_LEAVE->
			banquet_join_request(BanquetId);
		_->
			?ERRNO_NPC_EXCEPTION
	end,
	if 
		Errno =/= []->
			Message_failed = banquet_packet:encode_banquet_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

banquet_join_request(BanquetId)->
	BanquetOption = banquet_db:get_option_info(?BANQUET_DEFAULT_ID),
	Duration = banquet_db:get_banquet_duration(BanquetOption),
	InstanceId = banquet_db:get_banquet_instance_proto(BanquetOption),
	RoleVipExt = vip_op:get_role_vip_ext(vip_op:get_role_vip()),
	case lists:keyfind(RoleVipExt, 1, banquet_db:get_banquet_vip_op_addition(BanquetOption)) of
		false->
			VipOp = 0;
		{_,Op}->
			VipOp = Op
	end,
	Dancing = banquet_db:get_banquet_dancing(BanquetOption)+VipOp,
	Cheering = banquet_db:get_banquet_cheering(BanquetOption)+VipOp,
	PetSwanking = banquet_db:get_banquet_pet_swanking(BanquetOption)+VipOp,
	InstanceInfo = instance_proto_db:get_info(InstanceId),
	{LevelStart,LevelEnd} = instance_proto_db:get_level(InstanceInfo),
	case  transport_op:can_directly_telesport() and (not role_op:is_dead()) of
		true->
			case activity_op:handle_join_without_instance(
		   		?BANQUET_ACTIVITY,
		   		LevelStart,
		   		LevelEnd,
		   		[BanquetId,Dancing,Cheering,PetSwanking]) of
				{ok,Node,MapProc,BanquetTime,Info}->
					{{RealDancing,_,LastDancingTime},{RealCheering,_,LastCheeringTime},{RealPetSwanking,LastPetSwankingTime}} = Info,
					put(?ROLE_BANQUET_STATE,?BANQUET_ROLE_STATE_JOIN),
					put(?ROLE_BANQUET_INFO,{get(roleid),Node,MapProc,BanquetId,BanquetTime,Info}),
					Now = timer_center:get_correct_now(),
					LeftTime = trunc((Duration - timer:now_diff(Now,BanquetTime)/1000)/1000),
					LeftDancing = trunc(timer:now_diff(Now,LastDancingTime)/1000000),
					LeftCheering = trunc(timer:now_diff(Now,LastCheeringTime)/1000000),
					LeftPetSwankingTime = trunc(timer:now_diff(Now,LastPetSwankingTime)/1000000),
					Message = banquet_packet:encode_banquet_join_s2c(BanquetId, RealCheering, RealDancing, RealPetSwanking, 
						LeftTime, LeftCheering, LeftDancing, LeftPetSwankingTime),
					role_op:send_data_to_gate(Message),
					Errno=[],
					do_join_instance(InstanceId);
				joined->
					Errno=?ERROR_ACTIVITY_IS_JOINED;
				state_error->
					Errno=?ERROR_ACTIVITY_STATE_ERR;
				level_error->
					Errno=?ERROR_ACTIVITY_LEVEL_ERR;
				instance_error->
					Errno=?ERROR_ACTIVITY_INSTANCE_ERR;
				no_activity->
					Errno=?ERROR_ACTIVITY_NOT_EXSIT;
				full->
					Errno=?ERROR_ACTIVITY_IS_FULL;
				_->
					Errno=[]
			end;
		_->
			Errno=?ERROR_ACTIVITY_INSTANCE_ERR
	end,
	Errno.

do_join_instance(InstanceId)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			false;
		{_RoleId,_Node,MapProc,_BanquetId,_BanquetTime,_Info}->
			case instance_pos_db:get_instance_pos_from_mnesia(
				   instance_op:make_id_by_creationtag(atom_to_list(MapProc), InstanceId)) of			
				[]->
					false;
				{_Id,_Creation,_StartTime,CanJoin,InstanceNode ,_Pid,MapId,ProtoId,_Members}->
					ProtoInfo = instance_proto_db:get_info(ProtoId),
					if
						CanJoin->
							role_ride_op:hook_on_join_spar(),
							gm_logger_role:banquet_log(get(roleid),get_level_from_roleinfo(get(creature_info)),1,0),
							activity_value_op:update({join_activity,?BANQUET_ACTIVITY}),
							Pos = lists:nth(random:uniform(erlang:length(?BANQUET_SPAWN_POS)),?BANQUET_SPAWN_POS),
							instance_op:trans_to_dungeon(false,MapProc,get(map_info),Pos ,
														 ?INSTANCE_TYPE_BANQUET,ProtoInfo,InstanceNode,MapId,[]);
							true;
						true->
							false
					end	
			end
	end.

hook_on_online()->
	InfoList = answer_db:get_activity_info(?BANQUET_ACTIVITY),
	CheckFun = fun(Info)->
				{Type,StartLines} = answer_db:get_activity_start(Info),
				case activity_manager_op:check_is_time_line(Type,StartLines) of
					{true,_}->
						true;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, InfoList),
	case lists:member(true,States) of
		true->
			case activity_manager:get_activity_state(?BANQUET_ACTIVITY) of
				?ACTIVITY_STATE_START->
					put(?ROLE_BANQUET_ACTIVITY,?ACTIVITY_STATE_START),
					BanquetInfo = banquet_db:get_option_info(?BANQUET_DEFAULT_ID),
					InstanceId = banquet_db:get_banquet_instance_proto(BanquetInfo),
					InstanceInfo = instance_proto_db:get_info(InstanceId),
					{LevelStart,_LevelEnd} = instance_proto_db:get_level(InstanceInfo),
					Message = banquet_packet:encode_banquet_start_notice_s2c(LevelStart),
					role_op:send_data_to_gate(Message);
				_->
					nothing
			end;
		_->
			nothing
	end.

hook_on_role_levelup(Level)->
	ActivityState = get(?ROLE_BANQUET_ACTIVITY),
	RoleBanquetState = get(?ROLE_BANQUET_STATE),
	if
		ActivityState=:=?ACTIVITY_STATE_START,
		RoleBanquetState=/=?BANQUET_ROLE_STATE_JOIN->
			BanquetInfo = banquet_db:get_option_info(?BANQUET_DEFAULT_ID),
			InstanceId = banquet_db:get_banquet_instance_proto(BanquetInfo),
			InstanceInfo = instance_proto_db:get_info(InstanceId),
			{LevelStart,_LevelEnd} = instance_proto_db:get_level(InstanceInfo),
			if
				Level >= LevelStart->
					Message = banquet_packet:encode_banquet_start_notice_s2c(LevelStart),
					role_op:send_data_to_gate(Message);
				true->
					nothing
			end;
		true->
			nothing
	end.

hook_on_vip_up(OriLevel,NewLevel)->
	if
		NewLevel>OriLevel->
			BanquetOption = banquet_db:get_option_info(?BANQUET_DEFAULT_ID),
			OriVipExt = vip_op:get_role_vip_ext(OriLevel),
			NewVipExt = vip_op:get_role_vip_ext(NewLevel),
			OriCount =
			case lists:keyfind(OriVipExt, 1, banquet_db:get_banquet_vip_op_addition(BanquetOption)) of
				false->
					0;
				{_,OriOp}->
					OriOp
			end,
			NewCount =
			case lists:keyfind(NewVipExt, 1, banquet_db:get_banquet_vip_op_addition(BanquetOption)) of
				false->
					0;
				{_,NewOp}->
					NewOp
			end,
			AddCount = NewCount - OriCount,
			if
				AddCount>0->
					case get(?ROLE_BANQUET_INFO) of
						[]->
							nothing;
						RoleBanquetInfo->
							{RoleId,Node,MapProc,BanquetId,BanquetTime,
							 {{Dancing,DcPassive,DcTime},{Cheering,ChPassive,ChTime},{PetSwanking,PsTime}}} = RoleBanquetInfo,
							NewRoleBanquetInfo = {RoleId,Node,MapProc,BanquetId,BanquetTime,
							{{Dancing+AddCount,DcPassive,DcTime},{Cheering+AddCount,ChPassive,ChTime},{PetSwanking+AddCount,PsTime}}},
							put(?ROLE_BANQUET_INFO,NewRoleBanquetInfo),
							activity_manager:banquet_add_vip_count(RoleId,AddCount),
							Message = banquet_packet:encode_banquet_update_count_s2c(Dancing+AddCount, Cheering+AddCount, PetSwanking+AddCount),
							role_op:send_data_to_gate(Message)
					end;
				true->
					nothing
			end;
		true->
			nothing
	end.

hook_on_offline()->
	case get(?ROLE_BANQUET_STATE) of
		?BANQUET_ROLE_STATE_LEAVE->
			nothing;
		_->
			case get(?ROLE_BANQUET_INFO) of
				[]->
					nothing;
				RoleBanquetInfo->
					{RoleId,_,_,BanquetId,_,_} = RoleBanquetInfo,
					activity_manager:apply_leave_activity(?BANQUET_ACTIVITY,
														  {RoleId,BanquetId,?BANQUET_ROLE_STATE_LEAVE})
			end
	end.

banquet_apply_stop_player()->
	case get(?ROLE_BANQUET_STATE) of
		?BANQUET_ROLE_STATE_LEAVE->
			nothing;
		_->
			case get(?ROLE_BANQUET_INFO) of
				[]->
					nothing;
				RoleBanquetInfo->
					{RoleId,Node,MapProc,BanquetId,_BanquetTime,Info} = RoleBanquetInfo,
					activity_manager:apply_leave_activity(?BANQUET_ACTIVITY,{RoleId,BanquetId,?BANQUET_ROLE_STATE_LEAVE}),
					put(?ROLE_BANQUET_STATE,?BANQUET_ROLE_STATE_LEAVE),
					put(?ROLE_BANQUET_ACTIVITY,?ACTIVITY_STATE_STOP),
					put(?ROLE_BANQUET_INFO,{RoleId,Node,MapProc,BanquetId,{0,0,0},Info}),
					Message = banquet_packet:encode_banquet_leave_s2c(),
					role_op:send_data_to_gate(Message),
					instance_op:kick_instance_by_reason({?INSTANCE_TYPE_BANQUET,MapProc})
			end
	end.

banquet_leave_c2s()->
	case get(?ROLE_BANQUET_STATE) of
		?BANQUET_ROLE_STATE_LEAVE->
			nothing;
		_->
			case get(?ROLE_BANQUET_INFO) of
				[]->
					nothing;
				RoleBanquetInfo->
					{RoleId,Node,MapProc,BanquetId,_BanquetTime,Info} = RoleBanquetInfo,
					activity_manager:apply_leave_activity(?BANQUET_ACTIVITY,{RoleId,BanquetId,?BANQUET_ROLE_STATE_LEAVE}),
					put(?ROLE_BANQUET_STATE,?BANQUET_ROLE_STATE_LEAVE),
					put(?ROLE_BANQUET_INFO,{RoleId,Node,MapProc,BanquetId,{0,0,0},Info}),
					Message = banquet_packet:encode_banquet_leave_s2c(),
					role_op:send_data_to_gate(Message),
					instance_op:kick_instance_by_reason({?INSTANCE_TYPE_BANQUET,MapProc})
			end
	end.

banquet_cheering_c2s(RoleId)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{MyRoleId,_Node,_MapProc,BanquetId,_BanquetTime,OpInfo}->
			{_,{Cheering,_,CoolTime},_} = OpInfo,
			CheckCoolTime = check_cooltime(CoolTime),
			if RoleId=/=0-> 
				if Cheering>0->
					if CheckCoolTime->
						Errno=[],
						activity_manager:banquet_touch_other_role(?BANQUET_TOUCH_TYPE_CHEERING,{BanquetId, MyRoleId, RoleId});
					   true->
						Errno=?ERROR_ACTIVITY_COOLTIME_CHEERING_ERR
			    	end;
				   true->
					   Errno=?ERROR_BANQUET_TOUCH_LIMIT_ERR
				end;
			   true->
				   Errno=[]
			end,
			if Errno=/=[]->
				Message = banquet_packet:encode_banquet_error_s2c(Errno),
				role_op:send_data_to_gate(Message);
			   true->
				nothing
			end
	end.

banquet_dancing_c2s(RoleId)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{MyRoleId,_Node,_MapProc,BanquetId,_BanquetTime,OpInfo}->
			{{Dancing,_,CoolTime},_} = OpInfo,
			CheckCoolTime = check_cooltime(CoolTime),
			if RoleId=/=0-> 
				if Dancing>0->
					if CheckCoolTime->
						Errno=[],
						activity_manager:banquet_touch_other_role(?BANQUET_TOUCH_TYPE_DANCING,{BanquetId, MyRoleId, RoleId,false});
					   true->
						Errno=?ERROR_ACTIVITY_COOLTIME_DANCING_ERR
			    	end;
				   true->
					   Errno=?ERROR_BANQUET_TOUCH_LIMIT_ERR
				end;
			   true->
				   Errno=[]
			end,
			if Errno=/=[]->
				Message = banquet_packet:encode_banquet_error_s2c(Errno),
				role_op:send_data_to_gate(Message);
			   true->
				nothing
			end
	end.

banquet_dancing_with_gold(RoleId)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{MyRoleId,_Node,_MapProc,BanquetId,_BanquetTime,OpInfo}->
			{{Dancing,_,CoolTime},_} = OpInfo,
			CheckCoolTime = check_cooltime(CoolTime),
			if RoleId=/=0-> 
				if Dancing>0->
					if CheckCoolTime->
						case role_op:check_money(?MONEY_GOLD, ?BANQUET_DANCING_GOLD) of
							true->
								Errno=[],
								activity_manager:banquet_touch_other_role(?BANQUET_TOUCH_TYPE_DANCING,{BanquetId, MyRoleId, RoleId,true});
							false->
								Errno=?ERROR_LESS_MONEY
						end;
					   true->
						Errno=?ERROR_ACTIVITY_COOLTIME_DANCING_ERR
			    	end;
				   true->
					   Errno=?ERROR_BANQUET_TOUCH_LIMIT_ERR
				end;
			   true->
				   Errno=[]
			end,
			if Errno=/=[]->
				Message = banquet_packet:encode_banquet_error_s2c(Errno),
				role_op:send_data_to_gate(Message);
			   true->
				nothing
			end
	end.

check_cooltime(CoolTime)->
	case CoolTime of
		{0,0,0}->
			true;
		_->
			timer:now_diff(timer_center:get_correct_now(),CoolTime) >= ?BANQUET_COOL_TIME*1000
	end.
%%
%% Local Functions
%%
handle_banquet_touch(Type,Message)->
	case Type of
		?BANQUET_TOUCH_TYPE_DANCING->
			handle_banquet_dancing(Message);
		?BANQUET_TOUCH_TYPE_CHEERING->
			handle_banquet_cheering(Message);
		_->
			nothing
	end.

handle_pet_swanking(Message)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,BanquetId,BanquetTime,Info}->
			Name = get_name_from_roleinfo(get(creature_info)),
			{PetSwanking,NewTime} = Message,
			{_CheerInfo,_DancingInfo,_} = Info,
			NewInfo = {_CheerInfo,_DancingInfo,{PetSwanking,NewTime}},
			put(?ROLE_BANQUET_INFO,{RoleId,Node,MapProc,BanquetId,BanquetTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			BanquetExpInfo = banquet_db:get_banquet_exp_info(RoleLevel),
			AddExp = banquet_db:get_banquet_exp_pet_swanking(BanquetExpInfo),
			role_op:obtain_exp(AddExp),
			MessageData = banquet_packet:encode_banquet_pet_swanking_s2c(PetSwanking),
			F = fun(Gm_pet_info) ->
				Sex = get_gender_from_petinfo(Gm_pet_info),
				ProtoId = get_proto_from_petinfo(Gm_pet_info),
				case Sex of
					1 ->
						ProtoId;
					_ ->
						ProtoId + 100
				end
			end,
			Ptes = [F(Pet)||Pet<-get(gm_pets_info)],
			MessageBroadcast = banquet_packet:encode_banquet_pets_s2c(Name, Ptes),
			role_op:send_data_to_gate(MessageData),
			role_op:send_data_to_gate(MessageBroadcast),
			role_op:broadcast_message_to_aoi_client(MessageBroadcast)

	end.

		
handle_banquet_dancing(Message)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,BanquetId,BanquetTime,Info}->
			Name = get_name_from_roleinfo(get(creature_info)),
			{BeName,NewDancing,NewTime,IsGold} = Message,
			{{_,Passive,_},DancingInfo,_Swanking} = Info,
			NewInfo = {{NewDancing,Passive,NewTime},DancingInfo,_Swanking},
			put(?ROLE_BANQUET_INFO,{RoleId,Node,MapProc,BanquetId,BanquetTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			BanquetExpInfo = banquet_db:get_banquet_exp_info(RoleLevel),
			AddExp = banquet_db:get_banquet_exp_dancing_self(BanquetExpInfo),
			role_op:obtain_exp(AddExp),
			MessageData = banquet_packet:encode_banquet_dancing_s2c(Name, BeName, NewDancing),
			role_op:send_data_to_gate(MessageData),
			role_op:broadcast_message_to_aoi_client(MessageData)
	end.

handle_banquet_cheering(Message)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,BanquetId,BanquetTime,Info}->
			Name = get_name_from_roleinfo(get(creature_info)),
			{BeName,NewCheering,NewTime} = Message,
			{CheeringInfo,{_,Passive,_},_Swanking} = Info,
			NewInfo = {CheeringInfo,{NewCheering,Passive,NewTime},_Swanking},
			put(?ROLE_BANQUET_INFO,{RoleId,Node,MapProc,BanquetId,BanquetTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			BanquetExpInfo = banquet_db:get_banquet_exp_info(RoleLevel),
			AddExp = banquet_db:get_banquet_exp_cheering_self(BanquetExpInfo),
			role_op:obtain_exp(AddExp),
			MessageData = banquet_packet:encode_banquet_cheering_s2c(Name, BeName, NewCheering),
			role_op:send_data_to_gate(MessageData),
			role_op:broadcast_message_to_aoi_client(MessageData)
	end.


			
handle_be_banquet_touch(Type,Message)->
	case Type of
		?BANQUET_TOUCH_TYPE_DANCING->
			handle_be_banquet_dancing(Message);
		?BANQUET_TOUCH_TYPE_CHEERING->
			handle_be_banquet_cheering(Message);
		_->
			nothing
	end.
			
handle_be_banquet_dancing(Message)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,BanquetId,BanquetTime,Info}->
			_BeName = get_name_from_roleinfo(get(creature_info)),
			{_Name,NewPassive} = Message,
			{{Dancing,_Passive,CoolTime},DancingInfo,_Swanking} = Info,
			NewInfo = {{Dancing,NewPassive,CoolTime},DancingInfo,_Swanking},
			put(?ROLE_BANQUET_INFO,{RoleId,Node,MapProc,BanquetId,BanquetTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			BanquetExpInfo = banquet_db:get_banquet_exp_info(RoleLevel),
			AddExp = banquet_db:get_banquet_exp_dancing_be(BanquetExpInfo),
			role_op:obtain_exp(AddExp)
	end.

handle_be_banquet_cheering(Message)->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{RoleId,Node,MapProc,BanquetId,BanquetTime,Info}->
			_BeName = get_name_from_roleinfo(get(creature_info)),
			{_Name,NewPassive} = Message,
			{CheeringInfo,{Cheering,_Passive,CoolTime},_Swanking} = Info,
			NewInfo = {CheeringInfo,{Cheering,NewPassive,CoolTime},_Swanking},
			put(?ROLE_BANQUET_INFO,{RoleId,Node,MapProc,BanquetId,BanquetTime,NewInfo}),
			RoleLevel = get_level_from_roleinfo(get(creature_info)),
			BanquetExpInfo = banquet_db:get_banquet_exp_info(RoleLevel),
			AddExp = banquet_db:get_banquet_exp_cheering_be(BanquetExpInfo),
			role_op:obtain_exp(AddExp)
	end.

companion_dancing_apply(RoleId) ->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			nothing;
		{MyRoleId,_Node,_MapProc,BanquetId,_BanquetTime,OpInfo}->
			{{Dancing,_,CoolTime},_,_} = OpInfo,
			CheckCoolTime = check_cooltime(CoolTime),
			case get_state_from_roleinfo(get(creature_info)) of
				dancing ->
						nothing;
				_ ->
					case creature_op:is_in_aoi_list(RoleId) of
						true->
							Msg = banquet_packet:encode_companion_dancing_apply_s2c(get(roleid)),
							role_op:send_to_other_client(RoleId,Msg);
						_ ->
							Msg = banquet_packet:encode_companion_dancing_result_s2c(?DANCING_ERROR_NO_ROLE_INAOI),
							role_op:send_data_to_gate(Msg)
					end
			end
	end.


companion_dancing_start(RoleId) ->
	case creature_op:get_creature_info(RoleId) of
		undefined ->
			nothing;
		OtherRoleInfo ->
			case can_companion_dancing_with(OtherRoleInfo) of
				true ->
					case call_companion_dancing_with_me(OtherRoleInfo) of
						ok->
							nothing;
							% set_role_to_dancing(RoleId),
							% put(creature_info, set_state_to_roleinfo(get(creature_info), dancing)),
							% UpdateValues = [{state,?CREATURE_STATE_DANCING},{dancing_role,RoleId}],
							% role_op:self_update_and_broad(UpdateValues);
							%% erlang:send_after(10 * 1000, self(), {stop_dancing});
						_ ->
							nothing
					end;
				_ -> 
					nothing
			end
	end,
	ok.
% companion_dancing_start(RoleId) ->
% 	do_swank().



companion_dancing_reject(RoleId) ->
	Message = banquet_packet:encode_companion_dancing_reject_s2c(get_name_from_roleinfo(get(creature_info))),
	role_pos_util:send_to_role_clinet(RoleId, Message).

call_companion_dancing_with_me(RoleInfo) ->
	try
		Pid = get_pid_from_roleinfo(RoleInfo),
		role_processor:companion_dancing_with_me(Pid,get(roleid))
	catch
		_E:_R->
			error
	end.

handle_other_role_msg(add_companion_dancing,RoleId) ->

	{_,_,_,BanquetId,_,_} = get(?ROLE_BANQUET_INFO),
	activity_manager:banquet_touch_other_role(?BANQUET_TOUCH_TYPE_DANCING,{BanquetId, get(roleid), RoleId,true}),
	% set_role_to_dancing(RoleId),
	% put(creature_info, set_state_to_roleinfo(get(creature_info), dancing)),
	% UpdateValues = [{state,?CREATURE_STATE_DANCING},{dancing_role,RoleId}],
	% role_op:self_update_and_broad(UpdateValues),
	%% erlang:send_after(10 * 1000, self(), {stop_dancing}),
	ok;

handle_other_role_msg(_, _) ->
	error.

stop_dancing() ->
    put(creature_info, set_dancing_role_to_roleinfo(get(creature_info), 0)),
	put(creature_info, set_state_to_roleinfo(get(creature_info), gaming)),
	UpdateValues = [{state,?CREATURE_STATE_GAME}, {dancing_role, 0}],
	role_op:self_update_and_broad(UpdateValues).

set_role_to_dancing(RoleId)->
	put(creature_info, set_dancing_role_to_roleinfo(get(creature_info), RoleId)).


can_companion_dancing_with(OtherInfo)->
	(get_dancing_role_from_roleinfo(OtherInfo)=:=0) 
	and (get_state_from_roleinfo(OtherInfo) =/= dancing).

can_companion_dancing() ->
	CreatureInfo = get(creature_info),
	(get_dancing_role_from_roleinfo(CreatureInfo)=:=0) 
	and (get_state_from_roleinfo(CreatureInfo) =/= dancing).

pet_swank() ->
	case get(?ROLE_BANQUET_INFO) of
		[]->
			{error, ?ERROR_PET_NOEXIST};
		{RoleId,_Node,_MapProc,BanquetId,_BanquetTime,OpInfo}->
			{_,_,{Swanking,CoolTime}} = OpInfo,
			CheckCoolTime = check_cooltime(CoolTime),
			if RoleId=/=0-> 
				if Swanking>0->
					if CheckCoolTime->
						Errno=[],
						activity_manager:banquet_pet_swanking(?BANQUET_TYPE_PET_SPAWNING,{BanquetId, RoleId});
					   true->
						Errno=?ERROR_ACTIVITY_COOLTIME_SWANKING_ERR
			    	end;
				   true->
					   Errno=?ERROR_BANQUET_TOUCH_LIMIT_ERR
				end;
			   true->
				   Errno=[]
			end,
			if Errno=/=[]->
				Message = banquet_packet:encode_banquet_error_s2c(Errno),
				role_op:send_data_to_gate(Message);
			   true->
				nothing
			end
	end.