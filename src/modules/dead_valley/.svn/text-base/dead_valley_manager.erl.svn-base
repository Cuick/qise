-module (dead_valley_manager).

-behaviour (gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include ("error_msg.hrl").
-include ("travel_match_def.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------

-export ([start_link/0, join/1, leave/1, query_zone_info/0]).

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

join(ZoneId) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {join, ZoneId}, 5000)
	catch
		E : R ->
		slogger:msg("dead_valley_manager:join, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?DEAD_VALLEY_SYSTEM_ERROR}
	end.

leave(ZoneId) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {leave, ZoneId}, 5000)
	catch
		E : R ->
		slogger:msg("dead_valley_manager:leave, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?DEAD_VALLEY_SYSTEM_ERROR}
	end.

query_zone_info() ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {query_zone_info}, 5000)
	catch
		E : R ->
		slogger:msg("dead_valley_manager:query_zone_info, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?DEAD_VALLEY_SYSTEM_ERROR}
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
	dead_valley_manager_op:init(),
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
handle_call({join, ZoneId}, _, State) ->
	Result = dead_valley_manager_op:join(ZoneId),
	{reply, Result, State};

handle_call({leave, ZoneId}, _, State) ->
	Result = dead_valley_manager_op:leave(ZoneId),
	{reply, Result, State};

handle_call({query_zone_info}, _, State) ->
	Result = dead_valley_manager_op:query_zone_info(),
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

handle_info({start_forecast}, State) ->
	dead_valley_manager_op:start_forecast(),
	{noreply, State};

handle_info({start_notify, Duration}, State) ->
	dead_valley_manager_op:start_notify(Duration),
	{noreply, State};

handle_info({start_instance, Duration}, State) ->
	dead_valley_manager_op:start_instance(Duration),
	{noreply, State};

handle_info({end_forecast}, State) ->
	dead_valley_manager_op:end_forecast(),
	{noreply, State};

handle_info({end_notify}, State) ->
	dead_valley_manager_op:end_notify(),
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