%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module (mock_manager_type_3).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([start_link/0, start_mocks/5, stop/0]).

%% for testing function.

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {}).

%%servers_index : [{serverid,curindex}]

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start({local,?MODULE}, ?MODULE, [], []).

start_mocks(SpawnMin, SpawnMax, SpeakMin, SpeakMax, BroadCastRate) when is_integer(SpawnMin), 
	is_integer(SpawnMax), is_integer(SpeakMin), is_integer(SpeakMax), is_integer(BroadCastRate),
	SpawnMin < SpawnMax, SpeakMin < SpeakMax, BroadCastRate =< 100 ->
	gen_server:cast(?MODULE, {start_mocks, SpawnMin, SpawnMax, SpeakMin, SpeakMax, BroadCastRate});
start_mocks(_, _, _, _, _) ->
	io:format("all parameters must be integer!!!~n").

stop() ->
	gen_server:cast(?MODULE, {stop_all_mocks}).

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
	mock_processor_sup_type_3:start_link(),
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
handle_cast({start_mocks, SpawnMin, SpawnMax, SpeakMin, SpeakMax, BroadCastRate}, State) ->
	case get(timer_ref) of
		undefined ->
			nothing;
		TimerRef ->
			erlang:cancel_timer(TimerRef)
	end,
	spawn_mock(SpeakMin, SpeakMax, BroadCastRate),
	Interval = SpawnMin + random:uniform(SpawnMax - SpawnMin),
	TimerRef2 = erlang:send_after(Interval, self(), {start_mocks, SpawnMin, SpawnMax, SpeakMin, SpeakMax, BroadCastRate}),
	put(timer_ref, TimerRef2),
	{noreply, State};

handle_cast({stop_all_mocks}, State) ->
	case get(timer_ref) of
		undefined ->
			nothing;
		TimerRef ->
			erlang:cancel_timer(TimerRef)
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

handle_info({start_mocks, SpawnMin, SpawnMax, SpeakMin, SpeakMax, BroadCastRate}, State) ->
	spawn_mock(SpeakMin, SpeakMax, BroadCastRate),
	Interval = SpawnMin + random:uniform(SpawnMax - SpawnMin),
	TimerRef = erlang:send_after(Interval, self(), {start_mocks, SpawnMin, SpawnMax, SpeakMin, SpeakMax, BroadCastRate}),
	put(timer_ref, TimerRef),
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
%% Local functions
%% ====================================================================
spawn_mock(SpeakMin, SpeakMax, BroadCastRate) ->
	Gender = mock_util:get_mock_gender(),
	MockId = mock_id_generator:gen_newid(),
	Name = mock_name_generator:gen_new_name(Gender),
	Class = mock_util:get_mock_class(),
	mock_processor_sup_type_3:start_mock_type_3(MockId, Name, Gender, Class, SpeakMin, SpeakMax, BroadCastRate).