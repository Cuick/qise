%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-5-21
%%% -------------------------------------------------------------------
-module(npc_processor).

-behaviour(gen_fsm).
%% --------------------------------------------------------------------
%% External exports
-define(NPCID_DB,npcid_db).
-define(NPCID_MEM,npcid_mem).

-include("ai_define.hrl").
-include("skill_define.hrl").

%% gen_fsm callbacks
-export([init/1, handle_event/3,
	 handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-record(state, {}).

%% state:init_npc,
%%      enter_map,
%%      aliving,
%%      dead,
%%      corpsedisappears,

-export([enter_map/2,gaming/2,deading/2,hiden/2,attack/2,reseting/2,singing/2]).

-export([start_link/5]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("map_info_struct.hrl").
-include("common_define.hrl").

-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================

start_link(MapProc,NpcId,NpcManager,NpcInfo,CreateArg)->
	gen_fsm:start_link(?MODULE,[NpcId, NpcManager, MapProc,NpcInfo,CreateArg],[]).

forced_leave_map(NpcPId)->
	try
		gen_fsm:sync_send_all_state_event(NpcPId, {forced_leave_map})
	catch
		E:R->slogger:msg("forced_leave_map Error ~p : ~p ~n",[E,R]),error
	end.
let_other_say(NpcPid,Dialogues)->
	NpcPid ! {let_other_say,Dialogues}.
	
%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok, StateName, StateData}          |
%%          {ok, StateName, StateData, Timeout} |
%%          ignore                              |
%%          {stop, StopReason}
%% --------------------------------------------------------------------
init([NpcId,NpcManager,MapProc,NpcSpwanInfo,CreateArg]) ->
	timer_center:start_at_process(),
	%%设置初始化信息
	npc_op:init(NpcSpwanInfo, MapProc,NpcManager,CreateArg),
	%%这个地方不能直接进地图.因为是地图进把npc同步启动的
	util:send_state_event(self(), {position}),
	{ok, enter_map, #state{}}.

enter_map({position},StateData)->
	%%向地图的Grid注册
	NpcInfo = get(creature_info),
	MapInfo = get(map_info),
	npc_op:join(NpcInfo, MapInfo),
	npc_op:perform_creature_duty(),
	{next_state, gaming, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态：站立
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 事件：开始移动;
%%      由于是NPC移动，所以我们不用CheckPath，只需要通知相应的玩家即可
gaming({start_idle_walk}, StateData) ->
	npc_movement:proc_idle_walk(),
	{next_state, gaming, StateData};

gaming({perform_creature_duty}, StateData)->
	npc_op:perform_creature_duty(),
	{next_state, gaming, StateData};

%%激活
gaming({activate}, StateData)->
	npc_op:activate(),
	{next_state, gaming, StateData};	
	
gaming({hibernate}, StateData)->
	npc_op:hibernate(),
	{next_state, gaming, StateData};
	
gaming({provoke,ProvokerId}, StateData) ->
	npc_op:provoke(ProvokerId),
	{next_state, attack, StateData};

gaming({alert_heartbeat}, StateData) ->
	npc_op:alert_heartbeat(),
	{next_state, gaming, StateData};

gaming({do_idle_action},StateData) ->
	npc_ai:do_idle_action(),
	{next_state, gaming, StateData};
	
gaming({enemy_found,_InrangeEnemy},StateData)->
	npc_op:update_attack(),
	{next_state,attack,StateData};
	
gaming({follow_heartbeat},StateData)->	
	npc_op:follow_target(),
	{next_state,gaming,StateData};
	
gaming({call_ai_event,AiEvent,RoleId},StateData)->
	npc_ai:call_function(AiEvent,RoleId),
	{next_state,gaming,StateData};

gaming({call_you_help,CreatureId,TargetId},StateData)->
	npc_ai:do_help(CreatureId,TargetId),
	{next_state,attack,StateData};
	
gaming(_Event, StateData) ->
	{next_state, gaming, StateData}.

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态：战斗状态
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
attack({attack_heartbeat},StateData)-> %%攻击一下
	npc_op:attack(get(targetid)),
	{next_state, attack, StateData};

attack({singing},StateData)-> %%开始吟唱技能,转向singing状态
	{next_state, singing, StateData};	

attack({reset},StateData)-> %%reset
	npc_op:npc_reset(), 
	{next_state, reseting, StateData}; 

attack(_Event, StateData) ->
	{next_state, attack, StateData}.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态：吟唱状态，与atack来回切换
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
singing({reset},StateData)-> 
	npc_op:process_cancel_attack(get(id),move),
	npc_op:npc_reset(),
	{next_state, reseting, StateData}; 
 
singing({sing_complete, TargetID, SkillID, SkillInfo, FlyTime}, State) ->
	NpcInfo = get(creature_info),
	npc_op:process_sing_complete(NpcInfo, TargetID, SkillID, SkillInfo, FlyTime),  %%sing_complete后会继续触发attackheartbeat
	{next_state, attack, State};
 
singing({interrupt_by_buff},State) ->
	SelfId = get(id),
	npc_op:process_cancel_attack(SelfId, interrupt_by_buff),
	npc_op:update_attack(),
	{next_state, attack, State};	 
  
singing(_Event, StateData) ->
	{next_state, singing, StateData}.
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态：reseting,不接收任何挑衅
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
reseting({reset_fin},StateData)->
	npc_action:on_reset_finish(),
	{next_state, gaming , StateData};	

reseting(_Event, StateData) ->
	{next_state, reseting, StateData}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态: 死亡(城中的NPC是否有这个状态呢)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deading({leavemap},StateData)->
	npc_op:proc_leave_map(),
	{next_state, deading, StateData};

%%被喊出来的.
deading({respawn_by_call},StateData)->
	case get(is_in_world) of
		true->
			case get(respawn_timer) of
				 undefined->
				 	nothing;
				 Timer->
				 	gen_fsm:cancel_timer(Timer)
			end,
			creature_op:leave_map(get(creature_info),get(map_info));
		false->
			nothing
	end,			
	npc_op:npc_respawn(),
	npc_op:join(get(creature_info), get(map_info)),
	npc_op:call_duty(),
	{next_state, gaming, StateData};

%%respawn,
deading({respawn},StateData)->
	put(respawn_timer,undefined),
	npc_op:npc_respawn(),
	npc_op:join(get(creature_info), get(map_info)),
	npc_op:call_duty(),
	{next_state, gaming, StateData};
	
deading(_Msg,StateData)->
	{next_state, deading, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态: 隐身状态
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hiden(_Msg,StateData)->
	{next_state, enter_map, StateData}.

%% --------------------------------------------------------------------
%% Func: handle_event/3
%% Returns: {next_state, NextStateName, NextStateData}          |
%%          {next_state, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}
%% --------------------------------------------------------------------
handle_event(_Event, StateName, StateData) ->
    {next_state, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: handle_sync_event/4
%% Returns: {next_state, NextStateName, NextStateData}            |
%%          {next_state, NextStateName, NextStateData, Timeout}   |
%%          {reply, Reply, NextStateName, NextStateData}          |
%%          {reply, Reply, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}                          |
%%          {stop, Reason, Reply, NewStateData}
%% --------------------------------------------------------------------

handle_sync_event({get_state}, _From, StateName, StateData) ->
    Reply = StateName,
    {reply, Reply, StateName, StateData};	

handle_sync_event({forced_leave_map},_From, StateName, StateData) ->
	npc_op:proc_force_leave_map(),
    {reply, ok, StateName, StateData};  
	
handle_sync_event(Info, _From, StateName, StateData) ->
	Reply = npc_script:run_script(proc_special_msg,[Info]),
    {reply, Reply, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: handle_info/3
%% Returns: {next_state, NextStateName, NextStateData}          |
%%          {next_state, NextStateName, NextStateData, Timeout} |
%%          {stop, Reason, NewStateData}
%% --------------------------------------------------------------------
handle_info({follow_me,RoleId}, StateName, StateData) ->
	npc_op:start_follow_creature(RoleId),
	{next_state,StateName, StateData}; 

handle_info({call_ai_event,Event}, StateName, StateData) ->
	npc_ai:call_function_no_state(Event),	
	{next_state,StateName, StateData}; 
	
handle_info({move_heartbeat, NewPos}, StateName, StateData) ->
	case (StateName =:= gaming) or (StateName =:= reseting) or (StateName =:= attack) of
		true->
			NpcInfo = get(creature_info),
			MapInfo = get(map_info),	
			npc_movement:move_heartbeat(NpcInfo, MapInfo, NewPos);
		_->
			nothing
	end,		
    {next_state,StateName, StateData}; 
    
handle_info({run_away_to_pos,Pos}, StateName, StateData) ->
	case (StateName =:= gaming) or (StateName =:= attack) of
		true->
			npc_op:run_away_to_pos(Pos);
		_->
			nothing
	end,		
    {next_state,gaming, StateData};    

handle_info({forced_leave_map}, StateName, StateData) ->
	npc_op:proc_force_leave_map(),
    {next_state,StateName, StateData}; 

handle_info({leave_map}, _StateName, StateData) ->	
	npc_op:proc_leave_map(),
	{next_state,deading, StateData};
	
handle_info({other_into_view, OtherId}, StateName, StateData) ->
	case creature_op:get_creature_info(OtherId) of
		undefined ->
			nothing;
		OtherInfo->			
			creature_op:handle_other_into_view(OtherInfo)
	end,	
	{next_state, StateName, StateData};

handle_info({other_outof_view, OtherId}, StateName, StateData) ->
	case npc_op:other_outof_view(OtherId) of 
		out_of_view ->
			if
				( StateName =:= attack) or (StateName=:= singing)->
					HatredOp = get(hatred_fun),
					case npc_hatred_op:HatredOp(other_outof_bound,OtherId) of 
						reset ->
								npc_op:npc_reset(),
								{next_state, reseting, StateData}; 
						nothing_todo ->
								{next_state, attack, StateData};
						update_attack ->
								npc_op:update_attack(),
								{next_state,attack, StateData}
					end;
				true->
					{next_state, StateName, StateData}
			end;
		_->		 
			{next_state, StateName, StateData}
	end;
	


handle_info({respawn}, StateName, StateData) ->
	util:send_state_event(self(),{respawn}),
	{next_state, StateName, StateData};

handle_info({other_be_killed,{PlayerId, _,_,_,Pos}}, StateName, StateData) ->
	npc_op:other_be_killed(PlayerId,Pos),
	if
		(StateName =:= singing) or (StateName =:= attack)->
			HatredOp = get(hatred_fun),
			case npc_hatred_op:HatredOp(other_dead,PlayerId) of 
				reset ->
						case (StateName=:=singing)of
							true->  
								npc_op:process_cancel_attack(get(id),move);
							_->
								nothing
						end,
						npc_op:npc_reset(),
						{next_state, reseting, StateData}; 
				nothing_todo ->							 
						{next_state, StateName, StateData};
				update_attack ->
						case (StateName=:=singing)of
							true->  
								npc_op:process_cancel_attack(get(id),move);
							_->
								nothing
						end,
						npc_op:update_attack(),
						{next_state,attack, StateData}
			end;
		true->
			nothing,
			{next_state, StateName, StateData}	
	end;

%%在区域被冷却时,会收到hibernate
handle_info({hibernate}, StateName, StateData) ->
	if 		%%其他状态的会依靠perform_creature_duty里去hibernate
		StateName =:= gaming->	
			util:send_state_event(self(), {hibernate});
		true->
			nothing
	end,
	{next_state, StateName, StateData}; 		
	
handle_info({other_be_attacked, AttackInfo}, StateName, State) ->
	{EnemyId, _, _, _, SkillId, SkillLevel} = AttackInfo,
	if 
		(StateName =:= gaming) or (StateName =:= attack) or (StateName =:= singing)->
			SelfInfo = get(creature_info),
			case npc_op:other_be_attacked(AttackInfo, SelfInfo) of
				deading -> %%Npc死了
						Status = deading;				
				{be_attacked,Hatred} ->
						case (EnemyId =/= get_id_from_npcinfo(SelfInfo)) and (Hatred=/=0) of
							 true ->						
								HatredOp = get(hatred_fun),
								case  npc_hatred_op:HatredOp(is_attacked,{EnemyId,Hatred}) of
									update_attack ->
										if
											(StateName =:= singing)->
												Status = singing;
											true->
												Status = attack,
												SkillInfo = skill_db:get_skill_info(SkillId, SkillLevel),
												SkillType = skill_db:get_type(SkillInfo),
												if
													SkillType =/= ?SKILL_TYPE_PUSH,
													SkillType =/= ?SKILL_TYPE_PULL ->
														npc_op:update_attack();
													true ->
														nothing
												end
										end;
									nothing_todo -> 
										Status = StateName
								end;
							_->
								Status = StateName
						end,
						npc_ai:handle_event(?EVENT_BE_ATTACK);
				_ -> 
					slogger:msg("attack:other_be_attacked error~n"),Status = attack
			end;
		true->
			Status = StateName,
			nothing
	end,
	{next_state, Status, State};

handle_info({pull_or_push, Pos}, StateName, State) ->
	npc_op:shift_pos(Pos),
	timer:sleep(?PULL_OR_PUSH_DELAY),
	npc_op:update_attack(),
	{next_state, StateName, State};
	
%% 事件：用于进行buffer的计算TODO:交给各个状态处理?
handle_info( {buffer_interval, BufferInfo}, StateName, State) ->
	if 
		(StateName =:= gaming) or (StateName =:= attack) or (StateName =:= singing)->
			case buffer_op:do_interval(BufferInfo) of
				{remove,{BufferId,BufferLevel}}-> 
					NextState = StateName,
					npc_op:remove_buffer({BufferId,BufferLevel});
				{changattr,{BufferId,_Level},BuffChangeAttrs}->
					%%处理变化属性
					NextState = 
					case effect:proc_buffer_function_effects(BuffChangeAttrs) of
						[]->
							StateName;
						ChangedAttrs->
							NpcId = get(id),
							npc_op:update_npc_info(NpcId,get(creature_info)),
							npc_op:broad_attr_changed(ChangedAttrs),
							%%广播当前buff影响
							BuffChangesForSend = lists:map(fun({AttrTmp,ValueTmp})-> role_attr:to_role_attribute({AttrTmp,ValueTmp}) end,BuffChangeAttrs),
							Message = role_packet:encode_buff_affect_attr_s2c(NpcId,BuffChangesForSend),
							npc_op:broadcast_message_to_aoi_client(Message),
							%%检查一下有没有影响到血量,如果有的话,看是否导致死掉
							case lists:keyfind(hp,1,ChangedAttrs) of
								{_,HPNew}->
									if
										HPNew =< 0 ->
											{EnemyId,_EnemyName} = buffer_op:get_buff_casterinfo(BufferId),
											%% 被杀害了	
											case creature_op:get_creature_info(EnemyId) of
												undefined->				%%凶手已经不在了?
													npc_op:on_dead(get(creature_info));
												KillerInfo->
													npc_op:on_dead(KillerInfo)
											end,		
											deading;																				
										true->					
											StateName					
									end;
								false ->
									StateName
							end
					end;
				_Any -> 
					NextState = StateName
			end;
		true->
			NextState = StateName
	end,
	{next_state, NextState, State};

%%CasterInfo:{Id,Name}
handle_info({be_add_buffer, Buffers,CasterInfo}, StateName, StateData) ->
	if 
		(StateName =:= gaming) or (StateName =:= attack) or (StateName =:= singing)->
			npc_op:be_add_buffer(Buffers,CasterInfo);
		true->
			nothing
	end,
	{next_state, StateName, StateData};	

handle_info({let_other_say,Dialogues},StateName, StateData) ->
	normal_ai:say(Dialogues),
	{next_state, StateName, StateData};

handle_info({get_state}, StateName, StateData) ->	
	io:format("get_state ~p~n",[StateName]),	
	{next_state, StateName, StateData};
	
handle_info({provoke,ProvokerId}, StateName,StateData) ->
	gen_fsm:send_event(self(),{provoke,ProvokerId}),
	{next_state, StateName, StateData};
	
handle_info({apply_next_ai,NextAi},StateName,StateData) ->
	npc_ai:handle_apply_next_ai(NextAi),
	{next_state, StateName, StateData};
	
handle_info({christmas_activity,Msg},StateName,StateData) ->
	npc_christmas_tree:proc_msg(Msg),
    {next_state, StateName, StateData};

handle_info(Info, StateName, StateData) ->
	npc_script:run_script(proc_special_msg,[Info]),
    {next_state, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% --------------------------------------------------------------------
terminate(Reason, _StateName, _StatData) ->
	slogger:msg("npc_processor terminate Reason~p Id ~p CreatureInfo ~p ~n",[Reason,get(id),get(creature_info)]),
	NpcInfo = get(creature_info),
	MapInfo = get(map_info),
	creature_op:leave_map(NpcInfo,MapInfo),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% --------------------------------------------------------------------
code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}.


get_option_value(Key,Options)->
	case lists:keyfind(Key, 1, Options) of
		false-> error;
		{_,OptValue}->OptValue
	end.

make_dialog_beam(NpcId)->
	list_to_atom(lists:append(["npc_dialog_",util:make_int_str4(NpcId)])).

has_type(Type)->
	lists:member(Type,get(type)).
