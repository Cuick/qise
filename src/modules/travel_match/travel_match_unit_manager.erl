%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (travel_match_unit_manager).

-include ("travel_match_def.hrl").
-include ("error_msg.hrl").

-behaviour (gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------

-export ([start_link/5, make_wait_map_proc_name/3, make_unit_manager_proc_name/1, 
	enter_wait_map/3, battle_start/2, leave_wait_map/3]).

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

start_link(InstanceProc, Unit, Type, LevelZone, Stage)->
	gen_server:start_link({local,InstanceProc},?MODULE,[Unit, Type, LevelZone, Stage],[]).

make_wait_map_proc_name(Type, ZoneId, Unit) ->
	list_to_atom("travel_match_wait_map_" ++ 
		integer_to_list(Type) ++ "_" ++
		integer_to_list(ZoneId) ++ "_" ++
		integer_to_list(Unit)).

make_unit_manager_proc_name(Unit) ->
	list_to_atom("travel_match_unit_manager_" ++ integer_to_list(Unit)).

enter_wait_map(MapNode, UnitManagerProc, RoleId) ->
	gen_server:call({UnitManagerProc, MapNode}, 
		{travel_match_enter_wait_map, RoleId}, 5000).

leave_wait_map(MapNode, UnitManagerProc, RoleId) ->
	gen_server:call({UnitManagerProc, MapNode}, 
		{travel_match_leave_wait_map, RoleId}, 5000).

battle_start(MapNode, UnitManagerProc) ->
	gen_server:cast({UnitManagerProc, MapNode}, {travel_match_battle_start}).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([Unit, Type, LevelZone, Stage]) ->
	timer_center:start_at_process(),
	travel_match_unit_manager_op:init(Unit, Type, LevelZone, Stage),
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
handle_call({travel_match_enter_wait_map, RoleId}, From, State) ->	
	Reply = travel_match_unit_manager_op:enter_wait_map(RoleId),	
    {reply, Reply, State};

handle_call({travel_match_leave_wait_map, RoleId}, From, State) ->	
	Reply = travel_match_unit_manager_op:leave_wait_map(RoleId),	
    {reply, Reply, State};

handle_call(Request, From, State) ->		
    {reply, ok, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_cast({travel_match_battle_start}, State) ->
	travel_match_unit_manager_op:battle_start(),
	{noreply, State};

handle_cast(_, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({travel_match_battle_end}, State) ->
	travel_match_unit_manager_op:battle_end(),
	{noreply, State};

handle_info({travel_match_battle_start}, State) ->
	travel_match_unit_manager_op:battle_start(),
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