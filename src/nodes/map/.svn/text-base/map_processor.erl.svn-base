%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-11
%%% -------------------------------------------------------------------
-module(map_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_define.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/5]).

-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("data_struct.hrl").
-include("instance_define.hrl").
-include("npc_define.hrl").

%%mapinfo: {LineId,MapId}
-record(state, {type, mapinfo, aoidb, mapproc}).

-define(ETS_POS_GRID,1).
-define(ETS_POS_UNITS,2).
-define(ETS_POS_ROLES,3).
-define(ETS_POS_STATE,4).
%% ====================================================================
%% External functions
%% ====================================================================
start_link(MapProcName,{LineId,MapId},Type,CreatorTag,Extra)->
	gen_server:start_link({local,MapProcName},?MODULE,[MapProcName,{LineId,MapId},Type,CreatorTag,Extra],[]).

join_grid(MapProcName,Grid,CreatureId)->
	gen_server:call(MapProcName,{join_grid,Grid,CreatureId},infinity).

leave_grid(MapProcName,Grid,CreatureId)->
	gen_server:call(MapProcName,{leave_grid,Grid,CreatureId}).

%%lefttime
get_map_details(MapProcName,Node)->
	try
		gen_server:call({MapProcName,Node},get_map_details)
	catch
		E:R->
			slogger:msg("get_map_details error E ~p: R ~p",[E,R]),
			[]
	end.

join_instance(RoleId,MapProcName,Node)->
	try
		gen_server:call({MapProcName,Node},{role_come,RoleId})
	catch
		E:R->
			slogger:msg("join_instance error E ~p: R ~p",[E,R]),
			error
	end.
	
leave_instance(RoleId,MapProcName)->
	try
		gen_server:call(MapProcName,{role_leave,RoleId})
	catch
		E:R->
			slogger:msg("leave_instance RoleId ~p MapProcName~p error ~p:~p ~n",[RoleId,MapProcName,E,R]),
			nothing
	end.
	
leave_instance(RoleId,MapProcName,offline)->
	try
		gen_server:call(MapProcName,{role_leave,RoleId,offline})
	catch
		E:R-> 
			slogger:msg("leave_instance offline RoleId ~p MapProcName~p error ~p:~p ~n",[RoleId,MapProcName,E,R]),
				nothing
	end.

destroy_instance(Node,Proc)->
	gs_rpc:cast(Node,Proc,{on_destroy}).

destroy_instance(Node,Proc,TimeMs)->
	gs_rpc:cast(Node,Proc,{on_destroy,TimeMs}).

get_instance_id(MapProcName)->
	try
		gen_server:call(MapProcName,{get_instance_id})
	catch
		E:R-> 
			slogger:msg("get_instance_id MapProcName~p error ~p:~p ~n",[MapProcName,E,R]),
			[]
	end.
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([MapProcName,{LineId,MapId},Type,CreatorTag,Extra])->
	process_flag(trap_exit, true),
	AOIdb = ets:new(MapProcName, [set, public, named_table]),
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProcName),
	ets:new(NpcInfoDB, [set,public,named_table]),
	put(npcinfo_db,NpcInfoDB),	
	npc_sup:start_link(MapId,MapProcName,NpcInfoDB),
	NpcManagerProc = npc_manager:make_npc_manager_proc(MapProcName),
	NpcInfos = npc_db:get_creature_spawns_info(MapId) ++
	%%special line monster for map	   
	npc_db:get_creature_spawns_info({LineId,MapId}),
	lists:foreach(fun(NpcInfo)->
        NpcId = npc_db:get_spawn_id(NpcInfo),
	    case npc_db:get_born_with_map(NpcInfo) of
		    1 ->
	 		    npc_manager:add_npc_by_option(NpcManagerProc,NpcId,
	 		    	LineId,MapId,NpcInfo,CreatorTag);
		    0->
			    nothing
	    end
	end,NpcInfos),
	MapDb = mapdb_processor:make_db_name(MapId),
	case ets:info(MapDb) of
		undefined->
			%% first new the database, and then register proc
			ets:new(MapDb, [set,named_table]),
			case map_info_db:get_map_info(MapId) of
				[]->
					nothing;
				MapInfo_->
					MapDataId = map_info_db:get_serverdataname(MapInfo_),
					map_db:load_map_ext_file(MapDataId,MapDb),
					map_db:load_map_file(MapDataId,MapDb)
			end;
		_->
			nothing
	end,
	init_by_type(Type, MapProcName, MapId, Extra),
	{ok, #state{type=Type, mapinfo={LineId,MapId}, aoidb=AOIdb, mapproc=MapProcName}}.

%%lefttime
handle_call(get_map_details,_From,#state{type=Type}=State) ->
	Reply = get_map_details_by_type(Type),
	{reply, Reply,State};
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({get_instance_id}, _From,ProcState) ->
	Reply = get(instanceid),
	{reply, Reply,ProcState};

handle_call({role_come,RoleId}, _From,#state{type=Type}=ProcState) ->	
	Reply = do_role_come_by_type(Type, RoleId),
	{reply, Reply,ProcState};

handle_call({role_leave,RoleId}, _From,#state{type=Type}=ProcState) ->
	Reply = do_role_leave_by_type(Type, RoleId),
	{reply, Reply, ProcState};

%%if last one is offline ,not delete the instance
handle_call({role_leave,RoleId,offline}, _From,#state{type=Type}=ProcState) ->
	Reply = do_role_offline_by_type(Type, RoleId),
	{reply, Reply,ProcState};
  
handle_call({join_grid,Grid,CreatureId}, _From,#state{mapproc=MapProcName}=ProcState) ->
	case creature_op:what_creature(CreatureId) of
		role->
			case ets:lookup(MapProcName, Grid) of
				[] ->										
					ets:insert(MapProcName, {Grid, [],[CreatureId],true});			
				[{_, _,Roles,_}] ->			
					case lists:member(CreatureId,Roles) of
						false-> 
							ets:update_element(MapProcName,Grid,{?ETS_POS_ROLES,[CreatureId]++Roles});
						_->
							nothing
					end												
			end;
		npc->
			case ets:lookup(MapProcName, Grid) of
				[] ->						
					ets:insert(MapProcName, {Grid, [CreatureId],[],false});			
				[{_, Units,_,_}] ->	
					case lists:member(CreatureId,Units) of
						false-> 
							ets:update_element(MapProcName,Grid,{?ETS_POS_UNITS,[CreatureId]++Units});
						_->
							nothing
					end															
			end
	end,	
  	Reply = ok,
	{reply, Reply,ProcState}; 

handle_call({leave_grid,Grid,CreatureId}, _From,#state{mapproc=MapProcName}=ProcState) ->
  	case ets:lookup(MapProcName, Grid) of
		[] ->
			nothing;			
		[{_,Units,Roles,_}] ->
			case creature_op:what_creature(CreatureId) of
				role ->																												
					ets:update_element(MapProcName,Grid,{?ETS_POS_ROLES,lists:delete(CreatureId,Roles)});
				npc->
					ets:update_element(MapProcName,Grid,{?ETS_POS_UNITS,lists:delete(CreatureId,Units)})
			end					
	end,
	Reply = ok,
	{reply, Reply, ProcState};
  
handle_call(Request, From, State) ->
	Reply = ok,
	{reply, Reply, State}.


%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({on_destroy,WaitTime},#state{type=Type}=ProcState)->
	erlang:send_after(WaitTime,self(),{on_destroy}),
	on_destroy_delay_by_type(Type, WaitTime),
	{noreply,ProcState};

handle_info({on_destroy},#state{type=Type,mapproc=MapProcName}=ProcState)->
	on_destroy_by_type(Type,MapProcName),
	{noreply,ProcState};

handle_info({destory_self},#state{type=Type,mapproc=MapProcName}=ProcState)->
	destory_self_by_type(Type, MapProcName),
	{stop,normal,ProcState};

handle_info(Info, State) ->
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason,#state{type=Type,mapproc=MapProcName}=ProcState) ->
	terminate_by_type(Type, MapProcName),
	ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
	{ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
init_by_type(instance, MapProcName, MapId, {Creation,ProtoId}) ->
	ProtoInfo = instance_proto_db:get_info(ProtoId),
	case instance_proto_db:get_type(ProtoInfo) of
		?INSTANCE_TYPE_TANGLE_BATTLE->
			InstanceId = atom_to_list(MapProcName);
		 ?INSTANCE_TYPE_CAMP_BATTLE->
		    InstanceId = atom_to_list(MapProcName);
		?INSTANCE_TYPE_YHZQ->
			InstanceId = atom_to_list(MapProcName);
		?INSTANCE_TYPE_GUILDBATTLE->
			InstanceId = atom_to_list(MapProcName);
		?INSTANCE_TYPE_JSZD->
			InstanceId = atom_to_list(MapProcName);
		?INSTANCE_TYPE_GUILD->
			InstanceId = atom_to_list(MapProcName);
		?INSTANCE_TYPE_LOOP_INSTANCE->
			InstanceId = atom_to_list(MapProcName);
		_->
			InstanceId = instance_op:make_id_by_creationtag(Creation,ProtoId)
	end,
	if
		InstanceId =/=[]->
			instance_pos_db:reg_instance_pos_to_mnesia(InstanceId,Creation,now(),true,node(),MapProcName,MapId,ProtoId,[]),
			put(instanceid,InstanceId),
			case ProtoInfo of
				[]->
					slogger:msg("error instance proto info ProtoId ~p,Del_Time default:60000 ~n",[ProtoId]),
					DurationTime = 60000;
				_->
					DurationTime =	instance_proto_db:get_duration_time(ProtoInfo)
			end;
		true->
			DurationTime = 0,
			put(instanceid,[])
	end,
	put(map_start_time,timer_center:get_correct_now()),
	if
		DurationTime =/= 0->
			erlang:send_after(DurationTime,self(),{on_destroy});
		true->
			nothing
	end;
init_by_type(travel_battle, _, _, StageId) ->
	put(members, []),
	StageInfo = travel_battle_db:get_stage_info(StageId),
	Duration = travel_battle_db:get_stage_duration(StageInfo),
	erlang:send_after(Duration,self(),{on_destroy});
init_by_type(travel_match_battle, _, _, Duration) ->
	self() ! {on_destroy, Duration};
init_by_type(dead_valley, _, _, Duration) ->
	self() ! {on_destroy, Duration};
init_by_type(_, _, _, _) ->
	nothing.


get_map_details_by_type(instance) ->
	StartTime = get(map_start_time),
	trunc(timer:now_diff(timer_center:get_correct_now(),StartTime)/1000000);
get_map_details_by_type(_) ->
	{0,0}.

do_role_come_by_type(instance, RoleId) ->
	InstanceId = get(instanceid),
	case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of			
		[]->
			error;
		{Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
			if
				not CanJoin->
					error;
				true->
					case lists:member(RoleId,Members) of
						true->
							nothing;
						false->
							instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,
								StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,
								[RoleId|Members])
					end,
					{ok,StartTime}
			end
	end;
do_role_come_by_type(travel_battle,RoleId) ->
	put(members, [RoleId | get(members)]),
	ok;
do_role_come_by_type(_, _) ->
	error.

do_role_leave_by_type(instance, RoleId) ->
	InstanceId = get(instanceid),
	case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of			
		[]->
			error;
		{Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
			NewMemerbList = lists:delete(RoleId, Members),
			instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,CanJoin,
				InstanceNode ,Pid,MapId,Protoid,NewMemerbList),
			case NewMemerbList of
				[]->
					ProtoInfo = instance_proto_db:get_info(Protoid),
					case ProtoInfo of
						[]->
							self() ! {on_destroy};
						_->
							InsType = instance_proto_db:get_type(ProtoInfo),
							if
								(InsType=:= ?INSTANCE_TYPE_SINGLE) or (InsType=:=?INSTANCE_TYPE_GROUP) or 
								(InsType=:=?INSTANCE_TYPE_LOOP_TOWER) or (InsType =:= ?INSTANCE_TYPE_BDYY) ->
									self() ! {on_destroy};
								true->
									nothing
							end
					end;
				_->
					nothing
			end,
			ok
	end;
do_role_leave_by_type(travel_battle, RoleId) ->
	Members = get(members),
	CheckResult = lists:member(RoleId, Members),
	Members1 = if
		CheckResult ->
			Members2 = Members -- [RoleId],
			Length = length(Members2),
			if
				Length =:= 1 ->
					[RoleWin | _] = Members2,
					send_role_winner(RoleWin),
					timer:send_after(10000, {on_destroy}),
					[];
				true ->
					Members2
			end;
		true ->
			Members
	end,
	put(members, Members1),
	ok;
do_role_leave_by_type(_, _) ->
	error.

on_destroy_delay_by_type(instance, WaitTime) ->
	InstanceId = get(instanceid),
	case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of
		[]->
			nothing;
		{Id,Creation,StartTime,_CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
			instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,false,
				InstanceNode ,Pid,MapId,Protoid,Members),
			Msg = role_packet:encode_instance_end_seconds_s2c(trunc(WaitTime/1000)), 
			role_pos_util:send_to_clinet_list(Msg, Members)
	end;
on_destroy_delay_by_type(_, _) ->
	nothing.

on_destroy_by_type(instance, MapProcName) ->
	InstanceId = get(instanceid),
	case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of
		[]->
			nothing;
		{Id,Creation,StartTime,CanJoin,InstanceNode,Pid,MapId,Protoid,Members}->
			lists:foreach(fun(MemberId)->
				RoleProc = role_op:make_role_proc_name(MemberId),
				send_kick_out(instance,RoleProc,MapProcName)
			end,Members),
			if
				CanJoin->
					instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,
						false,InstanceNode ,Pid,MapId,Protoid,[]);
				true->
					nothing
			end,
			erlang:send_after(10000,self(),{destory_self})
	end;
on_destroy_by_type(travel_battle, _) ->
	Members = get(members),
	send_roles_losser(Members);
on_destroy_by_type(dead_valley, MapProcName) ->
	RoleList = mapop:get_map_roles_id_by_proc(MapProcName),
	lists:foreach(fun(RoleId) ->
		RoleProc = role_op:make_role_proc_name(RoleId),
		send_kick_out(dead_valley,RoleProc, MapProcName)
	end, RoleList),
	erlang:send_after(10000,self(),{destory_self});
on_destroy_by_type(_, _) ->
	erlang:send_after(10000,self(),{destory_self}).

destory_self_by_type(instance, MapProcName) ->
	InstanceId = get(instanceid),
	instance_pos_db:unreg_instance_pos_to_mnesia(InstanceId),
	npc_manager:remove_all_npc(npc_manager:make_npc_manager_proc(MapProcName)),
	map_manager:stop_instance(node(),MapProcName),
	instanceid_generator:safe_turnback_proc(MapProcName);
destory_self_by_type(dead_valley, MapProcName) ->
	npc_manager:remove_all_npc(npc_manager:make_npc_manager_proc(MapProcName)),
	map_manager:stop_instance(node(),MapProcName);
destory_self_by_type(_, _) ->
	nothing.

terminate_by_type(instance, MapProcName) ->
	InstanceId = get(instanceid),
	case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of
		[]->
			nothing;
		_->
			instance_pos_db:unreg_instance_pos_to_mnesia(MapProcName),
			instanceid_generator:safe_turnback_proc(MapProcName)
	end;
terminate_by_type(_, _) ->
	nothing.

do_role_offline_by_type(instance, RoleId) ->
	InstanceId = get(instanceid),
	case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of			
		[]->
			error;
		{Id,Creation,StartTime,CanJoin,InstanceNode ,Pid,MapId,Protoid,Members}->
			NewMemerbList = lists:delete(RoleId, Members),
			instance_pos_db:reg_instance_pos_to_mnesia(Id,Creation,StartTime,CanJoin,
				InstanceNode ,Pid,MapId,Protoid,NewMemerbList),
			case NewMemerbList of
				[]->
					ProtoInfo = instance_proto_db:get_info(Protoid),
					case ProtoInfo of
						[]->
							self() ! {on_destroy};
						_->
							InsType = instance_proto_db:get_type(ProtoInfo),
							if
								(InsType=:= ?INSTANCE_TYPE_LOOP_TOWER )->
									self() ! {on_destroy};
								true->
									nothing
							end
					end;
				_->
					nothing
			end,
			ok
	end;
do_role_offline_by_type(_, _) ->
	nothing.

send_role_winner(RoleWin) ->
	WinnerProc = role_op:make_role_proc_name(RoleWin),
	send_kick_out(travel_battle, WinnerProc, winner).

send_kick_out(travel_battle, RoleProc, Result) ->
	try
		RoleProc ! {kick_from_travel_battle_section, Result}
	catch
		E:R->slogger:msg("send_kick_out ~p~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end;
send_kick_out(instance, Proc, MapProcName)->
	try
		Proc ! {kick_from_instance,MapProcName}
	catch
		E:R->slogger:msg("MapProcName~p send_kick_out Proc ~p ~p~p ~p ~n",[MapProcName,Proc,E,R,erlang:get_stacktrace()])
	end;
send_kick_out(dead_valley, RoleProc, _) ->
	try
		RoleProc ! {kick_from_dead_valley}
	catch
		E:R->slogger:msg("send_kick_out ~p~p ~p ~n",[E,R,erlang:get_stacktrace()])
	end;
send_kick_out(_, _, _) ->
	nothing.

send_roles_losser(RoleList) ->
	lists:foreach(fun(RoleId) ->
		RoleProc = role_op:make_role_proc_name(RoleId),
		send_kick_out(travel_battle, RoleProc, losser)
	end, RoleList).
