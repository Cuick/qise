-module (travel_tangle_manager).

-behaviour (gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include ("error_msg.hrl").
-include ("travel_match_def.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------

-compile(export_all).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================

start_link()->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).


apply_for_battle(Info) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:cast({?MODULE, MapNode}, {apply_for_battle, Info})
		% gen_server:call({?MODULE, MapNode}, {apply_for_battle,Info}, 5000)
	catch
		E : R ->
		slogger:msg("travel_tangle_manager:apply_for_battle, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?DEAD_VALLEY_SYSTEM_ERROR}
	end.

notify_manager_battle_start(Info)->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:cast({?MODULE, MapNode}, {notify_manager_battle_start, Info})
		% gen_server:call({?MODULE, MapNode}, {notify_manager_battle_start,Info}, 5000)
	catch
		E : R ->
		slogger:msg("travel_tangle_manager:notify_manager_battle_start, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?DEAD_VALLEY_SYSTEM_ERROR}
	end.

get_tangle_records(RoleId)->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		% global_util:send(?MODULE,{get_tangle_records,RoleId})
		gen_server:cast({?MODULE, MapNode}, {get_tangle_records, RoleId})
	catch
		E:R->
			slogger:msg("get_my_battle_ground error ~p ~p ~n ",[E,R]),
			error
	end.

get_reward_by_manager(RoleId,Node)->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		% global_util:send(?MODULE,{get_reward_by_manager,{Type,RoleId}})
		gen_server:cast({?MODULE, MapNode}, {get_reward_by_manager, {RoleId,Node}})
	catch
		E:R->
			slogger:msg("get_reward_by_manager error ~p ~p ~n ",[E,R]),
			error
	end.

get_tangle_kill_info(Info)->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		% global_util:send(?MODULE,{get_tangle_kill_info,Info})
		gen_server:cast({?MODULE, MapNode}, {get_tangle_kill_info, Info})
	catch
		E:R->
			slogger:msg("get_tangle_kill_info error ~p ~p ~n ",[E,R]),
			error
	end.

get_battle_start()->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		% global_util:call(?MODULE,{check_battle_time})
		gen_server:call({?MODULE, MapNode}, {check_battle_time}, 5000)
	catch
		E:R->
			slogger:msg("tangle_battle,get_battle_start error ~p ~p ~n ",[E,R]),
			{0,0,0}
	end.

get_tangle_battle_curenum()->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		% global_util:call(?MODULE,{get_tangle_battle_curenum})
		gen_server:call({?MODULE, MapNode}, {get_tangle_battle_curenum}, 5000)
	catch
		E:R->
			slogger:msg("get_tangle_battle_curenum error ~p ~p ~n ",[E,R]),
			{0,[]}
	end.

get_reward_error(RoleId)->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		% global_util:send(?MODULE,{get_reward_error,RoleId})
		gen_server:cast({?MODULE, MapNode}, {get_reward_error, RoleId})
	catch
		E:R->
			slogger:msg("get_reward_error error ~p ~p ~n ",[E,R]),
			error
	end.
notify_manager_role_leave(Info)->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		% global_util:send(?MODULE,{notify_manager_role_leave,{BattleType,Info}})
		gen_server:cast({?MODULE, MapNode}, {notify_manager_role_leave, Info})
	catch
		E:R->
			slogger:msg("notify_manager_role_leave error ~p ~p ~n ",[E,R]),
			error
	end.

%%
%%取消加入战场
%%
cancel_apply_battle(Info)->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		% global_util:send(?MODULE,{cancel_apply_battle,Info})
		gen_server:cast({?MODULE, MapNode}, {cancel_apply_battle, Info})
	catch
		E:R->
			slogger:msg("cancel_apply_battle error ~p ~p ~n ",[E,R]),
			error
	end.

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	timer_center:start_at_process(),
	travel_tangle_manager_op:init(),
    {ok, #state{}}.

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
handle_call({join}, _, State) ->
	Result = travel_tangle_manager_op:join(),
	{reply, Result, State};
handle_call({get_battle_info}, _, State) ->
	Result = travel_tangle_manager_op:get_battle_info(),
	{reply, Result, State};

handle_call({check_battle_time}, _From, State) ->
	Reply = 
	try
		 travel_tangle_manager_op:check_battle_time()
	catch
		E:R->
			slogger:msg("get_battle_start error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			{0,0,0}
	end,
    {reply, Reply, State};
handle_call({get_tangle_battle_curenum}, _From, State) ->
	Reply = travel_tangle_manager_op:get_tangle_battle_curenum(), 
    {reply, Reply, State};

handle_call(_, _, State) ->		
    {reply, ok, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({apply_for_battle,Info},State) ->
	travel_tangle_manager_op:apply_for_battle(Info),
	{noreply, State};
handle_cast({notify_manager_battle_start,Info},State) ->
	travel_tangle_manager_op:notify_manager_battle_start(Info),
	{noreply, State};

handle_cast({get_tangle_records,RoleId}, State) ->
	try
		travel_tangle_manager_op:get_role_battle_info(RoleId)
	catch
		E:R->
			slogger:msg("get_tangle_records error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};
handle_cast({get_reward_by_manager,Info},State)->
	try
		travel_tangle_manager_op:get_reward_by_manager(Info)
	catch
		E:R->
			slogger:msg("get_reward_by_manager error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};
handle_cast({get_tangle_kill_info,Info},State)->
	try
		travel_tangle_manager_op:get_role_battle_kill_info(Info)
	catch
		E:R->
			slogger:msg("get_role_battle_kill_info error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_cast({get_reward_error,RoleId},State)->
	try
		travel_tangle_manager_op:get_reward_error(RoleId)
	catch
		E:R->
			slogger:msg("get_reward_error ~p error ~p ~p ~p ~n ",[RoleId,E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_cast({notify_manager_role_leave,Info},State)->
	try
		travel_tangle_manager_op:role_leave_battle(Info)
	catch
		E:R->
			slogger:msg("notify_manager_role_leave error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_cast({cancel_apply_battle,Info},State)->	
	try
		travel_tangle_manager_op:cancel_apply_battle(Info)
	catch
		E:R->
			slogger:msg("cancel_apply_battle error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};

handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


handle_info({start_notify,Duration}, State) ->
	travel_tangle_manager_op:start_notify(Duration),
	{noreply, State};
handle_info({battle_check}, State) ->
	try
		travel_tangle_manager_op:on_check()
	catch
		E:R->
			slogger:msg("battle_ground_check error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};
handle_info({battle_start_notify,Info}, State) ->
	try
		travel_tangle_manager_op:battle_start_notify(Info)
	catch
		E:R->
			slogger:msg("battle_start_notify error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};
handle_info({on_battle_end}, State) ->
	try
		travel_tangle_manager_op:on_battle_end()
	catch
		E:R->
			slogger:msg("on_battle_end error ~p ~p ~p ~n ",[E,R,erlang:get_stacktrace()]),
			error
	end,
	{noreply, State};
handle_info({on_destroy},State)->
	% my_apply(get(battle_type),on_destroy,[]),
	travel_tangle_manager_op:on_destroy(),
	{noreply,State};




handle_info(Info, State) ->
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% ====================================================================
%% Internal functions
%% ====================================================================


