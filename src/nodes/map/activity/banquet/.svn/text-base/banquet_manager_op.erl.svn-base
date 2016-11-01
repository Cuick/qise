%% Author: MacX
%% Created: 2011-9-27
%% Description: TODO: Add description to banquet_manager_op
-module(banquet_manager_op).

%%
%% Include files
%%
-define(BANQUET_BUFFER_TIME_S,70).
-define(BANQUET_BUFFER_END_TIME_S,120).
-define(BANQUET_SEND_NOTICE_BUFFER_TIME_S,60).
-define(BANQUET_MANAGER_STATE,banquet_manager_state).
%%banquet_info {BanquetId,Node,MapProc,JoinCount,InstanceLimit}
-define(BANQUET_INFO,banquet_info).
%%banquet_role_info {RoleId,RoleName,BanquetId,JoinState,
%%OtherInfo={dancinginfo,cheeringinfo}}
-define(BANQUET_ROLE_INFO,banquet_role_info).
-define(BANQUET_TIME,banquet_time).
-define(BANQUET_MAX_MAP_NUM,5).


-include("activity_define.hrl").
-include("error_msg.hrl").
-include("npc_define.hrl").
%%
%% Exported Functions
%%
-export([init/0,on_check/0,
		 apply_stop_me/1,
		 get_activity_state/0,
		 apply_join_activity/1,
		 apply_leave_activity/1,
		 banquet_start_notify/1,
		 request_banquetlist/1,
		 banquet_touch_other_role/2,
		 banquet_add_vip_count/2,
		 send_ground_role/1,
		 send_ground_role_client/1,
		 banquet_pet_swanking/2]).

%%
%% API Functions
%%
init()->
	put(?BANQUET_MANAGER_STATE,?ACTIVITY_STATE_STOP),
	put(?BANQUET_INFO,[]),
	put(?BANQUET_ROLE_INFO,[]),
	put(?BANQUET_TIME,{0,0,0}).

on_check()->
	InfoList = answer_db:get_activity_info(?BANQUET_ACTIVITY),
	CheckFun = fun(Info)->
				{Type,StartLines} = answer_db:get_activity_start(Info),
				activity_manager_op:activity_forecast_check(?BANQUET_ACTIVITY,Type,StartLines),
				Duration = answer_db:get_activity_duration(Info),
				SpecInfo = [?BANQUET_MAX_MAP_NUM],
				case activity_manager_op:check_is_time_line(Type,StartLines,?BANQUET_BUFFER_TIME_S,?BANQUET_BUFFER_END_TIME_S) of
					{true,_}->
						on_start_activity(Duration,SpecInfo),
						true;
					_->
						false
				end
	end,
	States = lists:map(CheckFun, InfoList),

	case lists:member(true,States) of
		true->
			nothing;
		_->
			on_stop_activity()
	end.

get_nodecount_by_onlinecount(OnlineCount,Limit)->
	if
		OnlineCount rem Limit > 0->
			OnlineCount div Limit + 1;
		true->
			OnlineCount div Limit
	end.

on_start_activity(Duration,Args)->
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_STOP->
			BanquetInfo = banquet_db:get_option_info(?BANQUET_DEFAULT_ID),
			InstanceId = banquet_db:get_banquet_instance_proto(BanquetInfo),
			InstanceInfo = instance_proto_db:get_info(InstanceId),
			{LevelStart,_LevelEnd} = instance_proto_db:get_level(InstanceInfo),
			{_,InstanceLimit} = instance_proto_db:get_membernum(InstanceInfo),
			MapId = instance_proto_db:get_level_mapid(InstanceInfo),
			case Args of
				[]->
					%%todo ccu config
					OnlineCount = role_pos_db:get_online_count(),
					Need_NodeCount = get_nodecount_by_onlinecount(OnlineCount,InstanceLimit) + 1;
				[NeedCount]->
					Need_NodeCount = NeedCount
			end,
			Nodes = node_util:get_low_load_node(Need_NodeCount),
			Fun = fun(Seq,Acc)->
					Node = lists:nth(Seq, Nodes),
					MapProc = make_map_proc_name(Seq),
					CreatorTag = {?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM},
					case rpc:call(Node,map_manager,start_instance, 
								  [MapProc,MapId,instance,CreatorTag,{atom_to_list(MapProc),InstanceId}]) of
						ok->
							Acc ++ [{Seq,Node,MapProc,0,InstanceLimit}];
						error->
							Acc
					end
				  end,
			BANQUET_INFO = lists:foldl(Fun, [], lists:seq(1, erlang:length(Nodes))),
			put(?BANQUET_INFO,BANQUET_INFO),
			put(?BANQUET_MANAGER_STATE,?ACTIVITY_STATE_START),
			put(banquet_time,timer_center:get_correct_now()),
			LocalTime = calendar:now_to_local_time(timer_center:get_correct_now()),
			erlang:send_after(?BANQUET_SEND_NOTICE_BUFFER_TIME_S*1000,self(),{banquet_start_notify,LevelStart}),
			erlang:send_after(Duration + ?BANQUET_SEND_NOTICE_BUFFER_TIME_S*1000,self(),{apply_stop_me,{?BANQUET_ACTIVITY,[{send,Duration,LocalTime}]}});
		_->
			noting			
	end.

create_banquet_list()->
	case get(?BANQUET_INFO) of
		[]->
			[];
		BanquetInfo->
			lists:map(fun(Info)->
							  {BanquetId,_,_,JoinCount,InstanceLimit} = Info,
							  {banquet,BanquetId,JoinCount,InstanceLimit}
					  end, BanquetInfo)
	end.

banquet_start_notify(InstanceLevel)->
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			put(banquet_time,timer_center:get_correct_now()),
			Message = banquet_packet:encode_banquet_start_notice_s2c(InstanceLevel),
			role_pos_util:send_to_all_online_clinet(Message);
		_->
			nothing
	end.

request_banquetlist(RoleId)->
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			Message = banquet_packet:encode_banquet_request_banquetlist_s2c(create_banquet_list()),
			role_pos_util:send_to_role_clinet(RoleId, Message);
		_->
			nothing
	end.

banquet_add_vip_count(RoleId,AddCount)->
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			BanquetRole = get(?BANQUET_ROLE_INFO),
			case lists:keyfind(RoleId, 1, BanquetRole) of
				false->
					nothing;
				{_,Name,BanquetId,JoinState,
				{{Dancing,ChPassive,ChTime},{Cheering,SwPassive,SwTime},{Pet_swanking}}}->
					NewRoleInfo = {RoleId,Name,BanquetId,JoinState,
							{{Dancing+AddCount,ChPassive,ChTime},{Cheering+AddCount,SwPassive,SwTime},{Pet_swanking+AddCount}}},
					NewBanquetRole = lists:keyreplace(RoleId, 1, BanquetRole, NewRoleInfo),
					put(?BANQUET_ROLE_INFO,NewBanquetRole)
			end;
		_->
			nothing
	end.

banquet_touch_other_role(Type,Info)->
	case Type of
		?BANQUET_TOUCH_TYPE_DANCING->
			banquet_dancing(Info);
		?BANQUET_TOUCH_TYPE_CHEERING->
			banquet_cheering(Info);
		_->
			nothing
	end.
banquet_pet_swanking(_Type,Info) ->
	{_BanquetId,RoleId} = Info,
	Errno=
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			BanquetRole = get(?BANQUET_ROLE_INFO),
			case lists:keyfind(RoleId, 1, BanquetRole) of
				false->
					?ERROR_ACTIVITY_STATE_ERR;
				{_,MyName,MyBanquet,MyJoinState,{_MyDancingInfo,_MycheeerInfo,{PetSwanking,BeCoolTime}}}->
					if MyJoinState=:=?BANQUET_ROLE_STATE_JOIN, PetSwanking > 0 ->
							NowTime = timer_center:get_correct_now(),
							NewBe = {RoleId,MyName,MyBanquet,MyJoinState,
								 	{_MyDancingInfo,_MycheeerInfo,{PetSwanking-1,NowTime}}},
							NewBanquetRole = lists:keyreplace(RoleId, 1, BanquetRole, NewBe),
							put(?BANQUET_ROLE_INFO,NewBanquetRole),
							send_message(RoleId,{handle_pet_swanking,?BANQUET_TYPE_PET_SPAWNING,{PetSwanking-1, NowTime}}),
							[];
					true ->
							?ERROR_ACTIVITY_STATE_ERR
					end;
				_->
					[]
			end;
		_  ->
			?ERROR_ACTIVITY_STATE_ERR
	end,
	if
		Errno=/=[]->
			Message = banquet_packet:encode_banquet_error_s2c(Errno),
			send_message_client(RoleId,Message);
		true->
			nothing
	end.


banquet_cheering(Info)->
	{_BanquetId,MyRoleId,RoleId} = Info,
	Errno=
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			BanquetRole = get(?BANQUET_ROLE_INFO),
			case lists:keyfind(MyRoleId, 1, BanquetRole) of
				false->
					?ERROR_ACTIVITY_STATE_ERR;
				{_,MyName,MyBanquet,MyJoinState,{MyDancingInfo,{MyCheering,MyPassive,MyCoolTime},_Petinfo}}->
					CheckCoolTime = banquet_op:check_cooltime(MyCoolTime),
					if
						MyJoinState=:=?BANQUET_ROLE_STATE_JOIN,CheckCoolTime->
							case lists:keyfind(RoleId, 1, BanquetRole) of
								false->
									?ERROR_ACTIVITY_STATE_ERR;
								{_,BeName,BeBanquet,BeJoinState,
								 {BeDancingInfo,{BeCheering,BePassive,BeCoolTime},_Petinfo2}}->
									if
										BeJoinState=:=?BANQUET_ROLE_STATE_JOIN,BePassive>0->
											NowTime = timer_center:get_correct_now(),
											NewMy = {MyRoleId,MyName,MyBanquet,MyJoinState,
													{MyDancingInfo,{MyCheering-1,MyPassive,NowTime},_Petinfo}},
											NewBe = {RoleId,BeName,BeBanquet,BeJoinState,
								 					{BeDancingInfo,{BeCheering,BePassive-1,BeCoolTime},_Petinfo2}},
											NewBanquetRole = lists:keyreplace(MyRoleId, 1, BanquetRole, NewMy),
											NewBanquetRole2 = lists:keyreplace(RoleId, 1, NewBanquetRole, NewBe),
											put(?BANQUET_ROLE_INFO,NewBanquetRole2),
											send_message(MyRoleId,{handle_banquet_touch,
																   ?BANQUET_TOUCH_TYPE_CHEERING,
																   {BeName,MyCheering-1,NowTime}}),
											send_message(RoleId,{handle_be_banquet_touch,
																 ?BANQUET_TOUCH_TYPE_CHEERING,
																 {MyName,BePassive-1}}),
											[];
										true->
											?ERROR_BANQUET_CAN_NOT_TOUCH_CHEERING_ERR
									end
							end;
						true->
							?ERROR_ACTIVITY_COOLTIME_CHEERING_ERR
					end;
				_->
					?ERROR_ACTIVITY_STATE_ERR
			end;
		_->
			[]
	end,
	if
		Errno=/=[]->
			Message = banquet_packet:encode_banquet_error_s2c(Errno),
			send_message_client(MyRoleId,Message);
		true->
			nothing
	end.

banquet_dancing(Info)->
	{_BanquetId,MyRoleId,RoleId,IsGold} = Info,
	Errno=
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			BanquetRole = get(?BANQUET_ROLE_INFO),
			case lists:keyfind(MyRoleId, 1, BanquetRole) of
				false->
					?ERROR_ACTIVITY_STATE_ERR;
				{_,MyName,MyBanquet,MyJoinState,{{MyDancing,MyPassive,_MyCoolTime},MyCheeringInfo,_Pet}}->
					case MyJoinState of
						?BANQUET_ROLE_STATE_JOIN->
							case lists:keyfind(RoleId, 1, BanquetRole) of
								false->
									?ERROR_ACTIVITY_STATE_ERR;
								{_,BeName,BeBanquet,BeJoinState,
								 {{BeDancing,BePassive,BeCoolTime},BeCheeringInfo,Pet}}->
									if
										BeJoinState=:=?BANQUET_ROLE_STATE_JOIN,BePassive>0->
											NowTime = timer_center:get_correct_now(),
											NewMy = {MyRoleId,MyName,MyBanquet,MyJoinState,
													{{MyDancing-1,MyPassive,NowTime},MyCheeringInfo,_Pet}},
											NewBe = {RoleId,BeName,BeBanquet,BeJoinState,
								 					{{BeDancing,BePassive-1,BeCoolTime},BeCheeringInfo,Pet}},
											NewBanquetRole = lists:keyreplace(MyRoleId, 1, BanquetRole, NewMy),
											NewBanquetRole2 = lists:keyreplace(RoleId, 1, NewBanquetRole, NewBe),
											put(?BANQUET_ROLE_INFO,NewBanquetRole2),
											send_message(MyRoleId,{handle_banquet_touch,
																   ?BANQUET_TOUCH_TYPE_DANCING,
																   {BeName,MyDancing-1,NowTime,IsGold}}),
											send_message(RoleId,{handle_be_banquet_touch,
																 ?BANQUET_TOUCH_TYPE_DANCING,
																 {MyName,BePassive-1}}),
											[];
										true->
											?ERROR_BANQUET_CAN_NOT_TOUCH_DANCING_ERR
									end
							end;
						_->
							?ERROR_ACTIVITY_COOLTIME_DANCING_ERR
					end;
				_->
					?ERROR_ACTIVITY_STATE_ERR
			end;
		_->
			[]
	end,
	if
		Errno=/=[]->
			Message = banquet_packet:encode_banquet_error_s2c(Errno),
			send_message_client(MyRoleId,Message);
		true->
			nothing
	end.

send_message(RoleId,Message)->
	role_pos_util:send_to_role(RoleId,Message).

send_message_client(RoleId,Message)->
	role_pos_util:send_to_role_clinet(RoleId, Message).

apply_stop_me(_Info)->
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			put(?BANQUET_MANAGER_STATE,?ACTIVITY_STATE_END),
			apply_stop_player();
		_->
			nothing
	end.

on_stop_activity()->
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_STOP->
			nothing;
		_->
			on_destroy_instance(),
			apply_stop_player(),
			init()
	end.

on_destroy_instance()->
	case get(?BANQUET_INFO) of
		[]->
			nothing;
		BanquetInfos->
			lists:foreach(fun(Info)->
								  {_,Node,MapProc,_,_} = Info,
								  rpc:call(Node,erlang,send_after,[?BANQUET_BUFFER_TIME_S*1000,MapProc, {on_destroy}])
						  end, BanquetInfos)
	end.

apply_stop_player()->
	case get(?BANQUET_ROLE_INFO) of
		[]->
			nothing;
		RoleInfos->
			Message = banquet_packet:encode_banquet_stop_s2c(),
			role_pos_util:send_to_all_online_clinet(Message),
			lists:foreach(fun(RoleInfo)->
								  {RoleId,_,_,JoinState,_} = RoleInfo,
%% 								  Message = banquet_packet:encode_banquet_stop_s2c(),
%% 								  send_message_client(RoleId, Message),
								  if
									  JoinState=:=?BANQUET_ROLE_STATE_JOIN->
								  		send_message(RoleId,{banquet_apply_stop_player});
									  true->
										  nothing
								  end
						  end, RoleInfos)
	end.

send_ground_role(Message)->
	case get(?BANQUET_ROLE_INFO) of
		[]->
			nothing;
		RoleInfos->
			lists:foreach(fun(RoleInfo)->
								  {RoleId,_,_,_,_} = RoleInfo,
								  send_message(RoleId,Message)
						  end, RoleInfos)
	end.

send_ground_role_client(Message)->
	case get(?BANQUET_ROLE_INFO) of
		[]->
			nothing;
		RoleInfos->
			lists:foreach(fun(RoleInfo)->
								  {RoleId,_,_,_,_} = RoleInfo,
								  send_message_client(RoleId, Message)
						  end, RoleInfos)
	end.

check_role_joined(RoleId)->
	case lists:keyfind(RoleId, 1, get(?BANQUET_ROLE_INFO)) of
		false->
			true;
		{_,_,_,JoinState,_}->
			if
				JoinState =:= ?BANQUET_ROLE_STATE_JOIN->
					false;
				true->
					true
			end
	end.

apply_join_activity(Args)->
	case get(?BANQUET_MANAGER_STATE) of
		?ACTIVITY_STATE_START->
			{RoleId,RoleName,[BanquetId,Dancing,Cheering,PetSwanking]} = Args,
			case get(?BANQUET_INFO) of
				[]->
					sys_error;
				BanquetInfo->
					case lists:keyfind(BanquetId, 1, BanquetInfo) of
						false->
							no_Banquetid;
						{_,Node,MapProc,JoinCount,InstanceLimit}->
							case check_role_joined(RoleId) of
								false->
									joined;
								true->
									if JoinCount+1 =< InstanceLimit->
										put(?BANQUET_INFO,lists:keyreplace(BanquetId, 1, BanquetInfo, 
										{BanquetId,Node,MapProc,JoinCount+1,InstanceLimit})),
										case lists:keyfind(RoleId, 1, get(?BANQUET_ROLE_INFO)) of
											false->
												DancingInfo = {Dancing,?BANQUET_PASSIVE_COUNT,{0,0,0}},
												CheeringInfo = {Cheering,?BANQUET_PASSIVE_COUNT,{0,0,0}},
												PetSwankingInfo = {PetSwanking,{0,0,0}},
												put(?BANQUET_ROLE_INFO,get(?BANQUET_ROLE_INFO)++
												[{RoleId,RoleName,BanquetId,?BANQUET_ROLE_STATE_JOIN,
												  {DancingInfo,CheeringInfo,PetSwankingInfo}}]),
												Info = {DancingInfo,CheeringInfo,PetSwankingInfo};
											{_,_,_,_,Info}->
												put(?BANQUET_ROLE_INFO,lists:keyreplace(RoleId, 1, get(?BANQUET_ROLE_INFO), 
													{RoleId,RoleName,BanquetId,?BANQUET_ROLE_STATE_JOIN,Info}))
										end,
										{ok,Node,MapProc,get(?BANQUET_TIME),Info};
									   true->
										full
									end
							end
					end
			end;
		_->
			state_error
	end.

apply_leave_activity(Info)->
	case get(?BANQUET_MANAGER_STATE) of
		State when State=:=?ACTIVITY_STATE_START;State=:=?ACTIVITY_STATE_END->
			case get(?BANQUET_INFO) of
				[]->
					nothing;
				BanquetInfo->
					{RoleId,BanquetId,LeaveState} = Info,
					case lists:keyfind(RoleId, 1, get(?BANQUET_ROLE_INFO)) of
						false->
							nothing;
						RoleInfo->
							{_,RoleName,_,JoinState,OpInfo} = RoleInfo,
							case JoinState of
								?BANQUET_ROLE_STATE_JOIN->
									case lists:keyfind(BanquetId, 1, BanquetInfo) of
										false->
											nothing;
										{_,Node,MapProc,JoinCount,InstanceLimit}->
											if
												JoinCount>=1->
													put(?BANQUET_INFO,lists:keyreplace(BanquetId, 1, BanquetInfo, 
													{BanquetId,Node,MapProc,JoinCount-1,InstanceLimit}));
												true->
													nothing
											end
									end,
									NewRoleInfo = lists:keyreplace(RoleId, 1, get(?BANQUET_ROLE_INFO), 
														   {RoleId,RoleName,BanquetId,LeaveState,OpInfo}),
									put(?BANQUET_ROLE_INFO,NewRoleInfo);
								_->
									nothing
							end
					end
			end;
		_->
			nothing
	end.

get_activity_state()->
	get(?BANQUET_MANAGER_STATE).

%%
%% Local Functions
%%
make_map_proc_name(BanquetId)->
	MapProc = lists:append(["map_banquet_",integer_to_list(BanquetId)]),
	list_to_atom(MapProc).
