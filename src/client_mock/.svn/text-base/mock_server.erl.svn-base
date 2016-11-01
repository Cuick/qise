%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%		机器人管理
%%% Created : 2013-5-6
%%% -------------------------------------------------------------------
-module(mock_server).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/7, change_spawn_interval/1, change_speak_interval/1, change_client_max/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


-record(state, {server_ip, server_port, server_id, spawn_interval, speak_interval, client_id, client_count, client_max}).


%% ====================================================================
%% External functions
%% ====================================================================
start_link(ServerIp, ServerPort, ServerId, SpawnInterval, SpeakInterval, StartId, ClientMax) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, 
		[ServerIp, ServerPort, ServerId, SpawnInterval, SpeakInterval, StartId, ClientMax], []).

change_spawn_interval(NewSpawnInterval) ->
	gen_server:call(?MODULE, {spawn_interval_change, NewSpawnInterval}).

change_speak_interval(NewSpeakInterval) ->
	gen_server:call(?MODULE, {speak_interval_change, NewSpeakInterval}).

change_client_max(NewClientMax) ->
	gen_server:call(?MODULE, {client_max_change, NewClientMax}).

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
init([ServerIp, ServerPort, ServerId, SpawnInterval, SpeakInterval, StartId, ClientMax]) ->
	erlang:send_after(SpawnInterval * 1000, self(), {new_client_create}),
    {ok, #state{server_ip = ServerIp, server_port = ServerPort, server_id = ServerId, spawn_interval = SpawnInterval,
  		speak_interval = SpawnInterval, client_id = StartId, client_count = 0, client_max = ClientMax}}.

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
handle_call({spawn_interval_change, NewSpawnInterval}, _From, State) ->
	{reply, ok, State#state{spawn_interval = NewSpawnInterval}};

handle_call({speak_interval_change, NewSpeakInterval}, _From, State) ->
	{reply, ok, State#state{speak_interval = NewSpeakInterval}};

handle_call({client_max_change, NewClientMax}, _From, State) ->
	{reply, ok, State#state{client_max = NewClientMax}};

handle_call(Request, _From, State) ->
    {reply, {unknown_call, Request}, State}.

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

handle_info({new_client_create}, State) ->
	#state{server_ip = ServerIp, server_port = ServerPort, server_id = ServerId, 
		spawn_interval = SpawnInterval, speak_interval = SpeakInterval,
		client_count = ClientCount, client_id = ClientId, client_max = ClientMax} = State,
	mock_client_sup:create_new_client(ServerIp, ServerPort, ServerId, SpeakInterval, ClientId),
	if 
		ClientCount + 1 < ClientMax ->
			erlang:send_after(SpawnInterval * 1000, self(), {new_client_create});
		true ->
			nothing
	end,
	{noreply, State#state{client_id = ClientId + 1, client_count = ClientCount + 1}};

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, State) ->
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

