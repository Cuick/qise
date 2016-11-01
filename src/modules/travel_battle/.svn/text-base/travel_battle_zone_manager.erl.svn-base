%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (travel_battle_zone_manager).

-include ("travel_battle_def.hrl").
-include ("error_msg.hrl").

-behaviour (gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------

-export ([start_link/0, query_role_rank/1, register/9, role_offline/2, cancel_match/2, show_rank_page/1,
	join_next_section/3, quit_from_stage/3, update_role_rank_info/5]).

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


query_role_rank(RoleId) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {travel_battle_query_role_rank, RoleId}, 5000)
	catch
		E : R ->
		slogger:msg("travel_battle_zone_manager:get_role_rank error, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		?TRAVEL_BATTLE_ROLE_RANK_NOT_AVAILIABLE
	end.

register(MapNode, RoleId, FightForce, RoleNode, RolePid, MapId, MapProc, LineId, Pos) ->
	gen_server:call({?MODULE, MapNode}, {travel_battle_register, RoleId, FightForce, 
		RoleNode, RolePid, MapId, MapProc, LineId, Pos}, 5000).

join_next_section(MapNode, RoleId, Score) ->
	gen_server:cast({?MODULE, MapNode}, {travel_battle_join_next_section, RoleId, Score}).

quit_from_stage(MapNode, RoleId, Score) ->
	gen_server:cast({?MODULE, MapNode}, {travel_battle_quit_stage, RoleId, Score}).

role_offline(MapNode, RoleId) ->
	gen_server:cast({?MODULE, MapNode}, {travel_battle_role_offline, RoleId}).

cancel_match(MapNode, RoleId) ->
	gen_server:call({?MODULE, MapNode}, {travel_battle_cancel_match, RoleId}).

show_rank_page(Page) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	try
		gen_server:call({?MODULE, MapNode}, {travel_battle_show_rank_page, Page}, 5000)
	catch
		E : R ->
		slogger:msg("travel_battle_zone_manager:show_rank_page error, E: ~p, R: ~p, stacktrace: ~p~n", 
			[E, R, erlang:get_stacktrace()]),
		{error, ?TRAVEL_BATTLE_RANK_DATA_NOT_AVAILABLE}
	end.

update_role_rank_info(RoleId, RoleName, Gender, Class, Scores) ->
	MapNode = travel_battle_util:get_travel_battle_db_map_node(),
	gen_server:cast({?MODULE, MapNode}, {travel_battle_role_rank, RoleId, 
		RoleName, Gender, Class, Scores}).

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
	role_travel_battle_zone_db:create_travel_battle_zone_ets(),
	travel_battle_zone_manager_op:init(),
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

handle_call({travel_battle_query_role_rank, RoleId}, _, State) ->
	Rank = travel_battle_zone_manager_op:query_role_rank(RoleId),
	{reply, Rank, State};

handle_call({travel_battle_register, RoleId, FightForce, RoleNode, RolePid,
	MapId, MapProc, LineId, Pos}, _, State) ->
	Result = travel_battle_zone_manager_op:register(RoleId, FightForce,
		RoleNode, RolePid, MapId, MapProc, LineId, Pos),
	{reply, Result, State};

handle_call({travel_battle_cancel_match, RoleId}, _, State) ->
	Result = travel_battle_zone_manager_op:cancel_match(RoleId),
	{reply, Result, State};

handle_call({travel_battle_show_rank_page, Page}, _, State) ->
	Result = travel_battle_zone_manager_op:show_rank_page(Page),
	{reply, Result, State};

handle_call(Request, From, State) ->		
    {reply, ok, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_cast({travel_battle_join_next_section, RoleId, Score}, State) ->
	travel_battle_zone_manager_op:join_next_section(RoleId, Score),
	{noreply, State};

handle_cast({travel_battle_quit_stage, RoleId, Score}, State) ->
	travel_battle_zone_manager_op:quit_from_stage(RoleId, Score),
	{noreply, State};

handle_cast({travel_battle_role_offline, RoleId}, State) ->
	Rank = travel_battle_zone_manager_op:role_offline(RoleId),
	{noreply, State};

handle_cast({travel_battle_role_rank, RoleId, RoleName, Gender, 
	Class, Scores}, State) ->
	travel_battle_zone_manager_op:update_role_rank_info(RoleId, 
		RoleName, Gender, Class, Scores),
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

handle_info({travel_battle_overload_check}, State) ->
	travel_battle_zone_manager_op:overload_check(),
	{noreply, State};

handle_info({next_month_awards_check}, State) ->
	travel_battle_zone_manager_op:month_awards_check(),
	{noreply, State};

handle_info({travel_battle_rank_check}, State) ->
	travel_battle_zone_manager_op:recompute_rank(),
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