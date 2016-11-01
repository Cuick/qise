%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module (mock_id_generator).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include ("common_define.hrl").
-include ("mock_def.hrl").

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,gen_newid/0]).

%% for testing function.

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {index}).

%%servers_index : [{serverid,curindex}]

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start({local,?MODULE}, ?MODULE, [], []).


%% ====================================================================
%% Server functions
%% ====================================================================
gen_newid()->
	gen_server:call(?MODULE, {gen_newid}).
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	LineId = mock_util:get_line_id(node()),
	LineCount = length(env:get(lines, [])),
	ServerId = env:get(serverid, 1),
	put(base, {ServerId, LineCount, LineId}),
    {ok, #state{index = 0}}.

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
handle_call({gen_newid}, _, #state{index = Idx} = State) ->
	{ServerId, LineCount, LineId} = get(base),
	Reply = ServerId * ?SERVER_MAX_ROLE_NUMBER + ?BASE_ROLE_ID + Idx * LineCount + LineId,
    {reply, Reply, #state{index = Idx + 1}};

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

