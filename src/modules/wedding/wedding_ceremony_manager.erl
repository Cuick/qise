%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (wedding_ceremony_manager).

-behaviour (gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------

-export ([start_link/0, query_free_times/0, book_ceremony/4]).

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

query_free_times() ->
	global_util:call(?MODULE, {query_free_times}).

book_ceremony(Applicant, Spouse, Type, TimeId) ->
	global_util:call(?MODULE, {book_ceremony, Applicant, Spouse, Type, TimeId}).


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
	wedding_ceremony_manager_op:init(),
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

handle_call({query_free_times}, From, State) ->
	Reply = wedding_ceremony_manager_op:query_free_times(),
	{reply, Reply, State};

handle_call({book_ceremony, Applicant, Spouse, Type, TimeId}, From, State) ->
	Reply = wedding_ceremony_manager_op:book_ceremony(Applicant, Spouse, Type, TimeId),
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

handle_cast(_, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({wedding_notify}, State) ->
	wedding_ceremony_manager_op:do_send_notify(),
	{noreply, State};

handle_info({wedding_start}, State) ->
	wedding_ceremony_manager_op:do_send_start(),
	{noreply, State};

handle_info({wedding_end}, State) ->
	wedding_ceremony_manager_op:do_send_end(),
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