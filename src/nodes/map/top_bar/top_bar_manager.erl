%%% -------------------------------------------------------------------
%%% Author  : MacX
%%% Description :
%%%
%%% Created : 2011-3-28
%%% -------------------------------------------------------------------

-module (top_bar_manager).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export ([start_link/0, load_from_db/0,hook_account_charge/0,hook_get_jackaroo_card/0,check_activity_awards/1,
    hook_activity_count/2,hook_activity_count/3, update_by_gm/0, get_temp_activity_contents/2,
    check_double_exp/0, hook_on_travel_match_start/0, hook_on_travel_match_stop/0,
    hook_on_travel_battle_start/1, hook_on_travel_battle_stop/0, load_by_copy/1, export_for_copy/0,
    hook_on_dead_valley_start/1, hook_on_dead_valley_stop/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link() ->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).

load_from_db() ->
	top_bar_manager_op:load_from_db(),
    global_util:send(?MODULE, {notify_role_login, get(roleid)}).

export_for_copy() ->
    top_bar_manager_op:export_for_copy().

load_by_copy(TopBarItemInfo) ->
    top_bar_manager_op:load_by_copy(TopBarItemInfo).

check_double_exp() ->
    top_bar_manager_op:check_double_exp().

hook_account_charge() ->
    top_bar_manager_op:hook_account_charge().

hook_get_jackaroo_card() ->
    top_bar_manager_op:hook_get_jackaroo_card().

check_activity_awards(ActivityId) ->
    top_bar_manager_op:check_activity_awards(ActivityId).

hook_on_travel_match_start() ->
    top_bar_manager_op:hook_on_travel_match_start().

hook_on_travel_match_stop() ->
    top_bar_manager_op:hook_on_travel_match_stop().
    
hook_on_travel_battle_start(Duration) ->
    top_bar_manager_op:hook_on_travel_battle_start(Duration).

hook_on_travel_battle_stop() ->
    top_bar_manager_op:hook_on_travel_battle_stop().

hook_on_dead_valley_start(Duration) ->
    top_bar_manager_op:hook_on_dead_valley_start(Duration).

hook_on_dead_valley_stop() ->
    top_bar_manager_op:hook_on_dead_valley_stop().

hook_activity_count(ActivityType, Count) ->
    global_util:send(?MODULE, {update_activity_count_online, get(roleid), ActivityType, Count}).

hook_activity_count(RoleId, ActivityType, Count) ->
    global_util:send(?MODULE, {update_activity_count_offline, RoleId, ActivityType, Count}).

get_temp_activity_contents(RoleId, ItemId) ->
    global_util:send(?MODULE, {temp_activity_contents, RoleId, ItemId}).

update_by_gm() ->
    global_util:call(?MODULE, {update_by_gm}).

%% ====================================================================
%% Server functions
%% ====================================================================
	
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
	top_bar_manager_op:init(),
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
handle_call({update_by_gm}, From, State) ->
    top_bar_manager_op:update_by_gm(),
    {reply, ok, State};

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

handle_info({top_bar_next_activity}, State) ->
    top_bar_manager_op:next_activity_check(),
    {noreply, State};

handle_info({notify_role_login, RoleId}, State) ->
    top_bar_manager_op:role_login(RoleId),
    {noreply, State};

handle_info({update_activity_count_offline, RoleId, ActivityType, Count}, State) ->
    top_bar_manager_op:update_activity_count_offline(RoleId, ActivityType, Count),
    {noreply, State};

handle_info({update_activity_count_online, RoleId, ActivityType, Count}, State) ->
    top_bar_manager_op:update_activity_count_online(RoleId, ActivityType, Count),
    {noreply, State};

handle_info({temp_activity_contents, RoleId, ItemId}, State) ->
    top_bar_manager_op:get_temp_activity_contents(RoleId, ItemId),
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

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
