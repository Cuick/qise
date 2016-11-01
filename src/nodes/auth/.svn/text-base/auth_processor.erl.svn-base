%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-15
%%% -------------------------------------------------------------------
-module(auth_processor).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,auth/9]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).
-define(AUTH_FAILED,-1).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
    gen_server:start_link({local,?MODULE},?MODULE,[],[]).

auth(FromNode,FromProc,Account,ServerId,Adult,Pf,Time,Sign,Flag)->
    global_util:send(?MODULE, {auth_player,FromNode,FromProc,Account,ServerId,Adult,Pf,Time,Sign,Flag}).


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
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%user_auth_c2s
handle_info({auth_player,FromNode,FromProc,Account,ServerId,Adult,Pf,Time,Sign,Flag},State)->
    PlatformKey = env:get2(platform_key, Pf, []),
    AuthStr = "account=" ++ Account ++ "&adult=" ++ Adult ++ 
        "&key=" ++ PlatformKey ++ "&pf=" ++ Pf ++ "&timestamp=" ++ Time,
    case auth_util:platform_check(AuthStr, Sign) of
        true ->
                tcp_client:auth_ok(FromNode,FromProc,ServerId,Account,Time,Adult,Pf,Flag);
        false ->
                tcp_client:auth_failed(FromNode, FromProc, -1)
    end,
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.
%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

