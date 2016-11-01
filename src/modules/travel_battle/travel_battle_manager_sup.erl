%%%-------------------------------------------------------------------
%%% File    : travel_battle_manager_sup.erl
%%% Author  : yanzengyan
%%% Description : 
%%%
%%%-------------------------------------------------------------------
-module (travel_battle_manager_sup).

-behaviour(supervisor).

%% API
-export([
	 start_link/0
	]).

%% Supervisor callbacks
-export([init/1]).

%%====================================================================
%% API functions
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok,Pid} | ignore | {error,Error}
%% Description: Starts the supervisor
%%--------------------------------------------------------------------
start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).
			
%%====================================================================
%% Supervisor callbacks
%%====================================================================
%%--------------------------------------------------------------------
%% Func: init(Args) -> {ok,  {SupFlags,  [ChildSpec]}} |
%%                     ignore                          |
%%                     {error, Reason}
%% Description: Whenever a supervisor is started using 
%% supervisor:start_link/[2,3], this function is called by the new process 
%% to find out about restart strategy, maximum restart frequency and child 
%% specifications.
%%--------------------------------------------------------------------
init(_) ->
  AChild = {travel_battle_manager,{travel_battle_manager,start_link,[]},
	       transient,2000,worker,[travel_battle_manager]},
	{ok,{{one_for_one, 10, 10}, [AChild]}}.

%%====================================================================
%% Internal functions
%%====================================================================
