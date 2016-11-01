-module (mock_processor_sup_type_6).

-behaviour(supervisor).

%% API
-export([start_link/0, start_mock_type_6/7, stop_mock/1]).

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
			
start_mock_type_6(MockProc, MockId, ProtoId, Name, Gender, Class, LineId) ->
	try 
		supervisor:start_child(?MODULE, [MockProc, MockId, ProtoId, Name, Gender, Class, LineId])
	catch
		E:R-> slogger:msg("can not start mock, MockId: ~p, MockProtoId: ~p~n", [MockId, ProtoId]),
			  {error,R}
	end.

stop_mock(MockProc) ->
	supervisor:terminate_child(?MODULE, MockProc),
	supervisor:delete_child(?MODULE, MockProc).

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
    {ok,{{simple_one_for_one,10,10}, [{mock_processor_type_6,{mock_processor_type_6,
    start_link,[]},transient,2000,worker,[mock_processor_type_6]}]}}.

%% ====================================================================
%% Internal functions
%% ====================================================================