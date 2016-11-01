-module (travel_match_manager).

-behaviour (gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include ("error_msg.hrl").
-include ("travel_match_def.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------

-export ([start_link/0, register/7, query_wait_map_info/2, query_role_info/2, 
	update_role_match_result/3, query_unit_player_list/2, query_session_data/3]).

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

register(Type, RoleId, RoleName, Gender, Class, Level, FightForce) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {travel_match_register, 
			Type, RoleId, RoleName, Gender, Class, Level, FightForce}, 5000)
	catch
		E : R ->
		slogger:msg("travel_match_manager:register, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end.

query_wait_map_info(RoleId, Type) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {travel_match_query_wait_map_info,
		    RoleId, Type}, 5000)
	catch
		E : R ->
		slogger:msg("travel_match_manager:query_wait_map_info, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end.

query_role_info(RoleId, Type) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {travel_match_query_role_info,
		    RoleId, Type}, 5000)
	catch
		E : R ->
		slogger:msg("travel_match_manager:query_role_info, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end.

update_role_match_result(RoleId, Type, Points) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {travel_match_update_result,
		    RoleId, Type,Points}, 5000)
	catch
		E : R ->
		slogger:msg("travel_match_manager:query_role_info, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end.

query_unit_player_list(RoleId, Type) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {travel_match_query_unit_player_list,
		    RoleId, Type}, 5000)
	catch
		E : R ->
		slogger:msg("travel_match_manager:query_role_info, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end.

query_session_data(Type, Session, LevelZone) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {travel_match_query_session_data, Type,
			Session, LevelZone}, 5000)
	catch
		E : R ->
		slogger:msg("travel_match_manager:query_role_info, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
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
	%% single mode
	travel_match_single_manager_op:init(),
	%% team mode ......
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
handle_call({travel_match_register, Type, RoleId, RoleName, Gender, 
	Class, Level, FightForce}, _, State) ->
	Result = if
		Type =:= ?TRAVEL_MATCH_TYPE_SINGLE ->
			travel_match_single_manager_op:register(RoleId, RoleName, 
				Gender, Class, Level, FightForce);
		true ->
			{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end,
	{reply, Result, State};

handle_call({travel_match_query_wait_map_info, RoleId, Type}, _, State) ->
	Result = if
		Type =:= ?TRAVEL_MATCH_TYPE_SINGLE ->
			travel_match_single_manager_op:query_wait_map_info(RoleId);
		true ->
			{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end,
	{reply, Result, State};

handle_call({travel_match_query_role_info, RoleId, Type}, _, State) ->
	Result = if
		Type =:= ?TRAVEL_MATCH_TYPE_SINGLE ->
			travel_match_single_manager_op:query_role_info(RoleId);
		true ->
			{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end,
	{reply, Result, State};

handle_call({travel_match_update_result, RoleId, Type, Points}, _, State) ->
	Result = if
		Type =:= ?TRAVEL_MATCH_TYPE_SINGLE ->
			travel_match_single_manager_op:update_match_result(RoleId, Points);
		true ->
			{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end,
	{reply, Result, State};

handle_call({travel_match_query_unit_player_list, RoleId, Type}, _, State) ->
	Result = if
		Type =:= ?TRAVEL_MATCH_TYPE_SINGLE ->
			travel_match_single_manager_op:query_unit_player_list(RoleId);
		true ->
			{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end,
	{reply, Result, State};

handle_call({travel_match_query_session_data, Type, Session, LevelZone}, _, State) ->
	Result = if
		Type =:= ?TRAVEL_MATCH_TYPE_SINGLE ->
			travel_match_single_manager_op:query_session_data(Session, LevelZone);
		true ->
			{error, ?TRAVEL_MATCH_SYSTEM_ERROR}
	end,
	{reply, Result, State};

handle_call(_, _, State) ->		
    {reply, ok, State}.

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
handle_info({single_match_stage_start, Stage}, State) ->
	travel_match_single_manager_op:stage_start(Stage),
	{noreply, State};	

handle_info({single_match_stage_forecast_end, Stage}, State) ->
	travel_match_single_manager_op:stage_forecast_end(Stage),
	{noreply, State};

handle_info({single_match_stage_end, Stage}, State) ->
	travel_match_single_manager_op:stage_end(Stage),
	{noreply, State};

handle_info({single_match_stage_forecast_start, Stage}, State) ->
	travel_match_single_manager_op:stage_forecast_start(Stage),
	{noreply, State};

handle_info({single_match_enter_wait_map_forecast_end, Stage}, State) ->
	travel_match_single_manager_op:notify_enter_wait_map_forecast_end(Stage),
	{noreply, State};

handle_info({single_match_stage_closed}, State) ->
	travel_match_single_manager_op:notify_match_end(),
	{noreply, State};

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