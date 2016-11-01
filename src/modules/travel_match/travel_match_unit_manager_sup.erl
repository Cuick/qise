%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (travel_match_unit_manager_sup).

-behaviour(supervisor).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0, start_child/5, stop_child/1]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([init/1]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	supervisor:start_link({local,?MODULE},?MODULE,[]).

start_child(InstanceProc, Unit, Type, LevelZone, Stage) ->
	AChild = {InstanceProc,{travel_match_unit_manager,start_link,[InstanceProc,
		Unit, Type, LevelZone, Stage]},transient,2000,worker,
		[travel_match_unit_manager]},
	case supervisor:start_child(?MODULE, AChild) of
			{ok, _} ->
				InstanceProc;
			{error, Reason} ->
				slogger:msg("travel_match_unit_manager ~p start failed, error: ~p~n", 
					[InstanceProc, Reason])
		end
	.

stop_child(InstanceProc) ->
	supervisor:terminate_child(?MODULE, InstanceProc),
	supervisor:delete_child(?MODULE, InstanceProc).

%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init([]) ->
    {ok,{{one_for_one,10,10}, []}}.

%% ====================================================================
%% Internal functions
%% ====================================================================