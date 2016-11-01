-module (dead_valley_zone_manager).

-behaviour (gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include ("error_msg.hrl").
-include ("travel_match_def.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------

-export ([start_link/0, start_instance/5, boss_init/2, boss_update/2, role_come/1]).

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

start_instance(MapNode, InstanceProc, MapId, CreatorTag, Duration) ->
	gen_server:call({?MODULE, MapNode}, {start_instance, InstanceProc, 
		MapId, CreatorTag, Duration}).

boss_init(NpcId, HpMax) ->
	gen_server:cast(?MODULE, {boss_init, NpcId, HpMax}).

boss_update(NpcId, Hp) ->
	gen_server:cast(?MODULE, {boss_update, NpcId, Hp}).

role_come(RoleId) ->
	gen_server:cast(?MODULE, {role_come, RoleId}).

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
	dead_valley_zone_manager_op:init(),
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
handle_call({start_instance, InstanceProc, MapId, CreatorTag, 
	Duration}, _, State) ->
	Result = dead_valley_zone_manager_op:start_instance(
		InstanceProc, MapId, CreatorTag, Duration),
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

handle_cast({boss_init, NpcId, HpMax}, State) ->
	dead_valley_zone_manager_op:boss_init(NpcId, HpMax),
	{noreply, State};

handle_cast({boss_update, NpcId, Hp}, State) ->
	dead_valley_zone_manager_op:boss_update(NpcId, Hp),
	{noreply, State};

handle_cast({role_come, RoleId}, State) ->
	dead_valley_zone_manager_op:role_come(RoleId),
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