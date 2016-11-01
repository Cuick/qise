-module (mock_processor_sup_type_2).

-behaviour(supervisor).

-export ([start_link/0, start_mock_type_2/7, stop_child/1]).

-export ([init/1]).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->	
	supervisor:start_link({local,?MODULE}, ?MODULE, []).

start_mock_type_2(MockProc, MockId, ProtoId, Name, Gender, Class, Level) ->
	try
		AChild = {MockProc,{mock_processor_type_2,start_link,[MockProc, MockId, ProtoId, Name, Gender, Class, Level]},
				  	      		temporary,2000,worker,[mock_processor_type_2]},
		supervisor:start_child(?MODULE, AChild)
	catch
		E:R-> slogger:msg("mock_processor_sup_type_2 cannot start child, E: ~p, R: ~p~n", [E, R])
 	end.

 stop_child(MockProc)->
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
    {ok,{{one_for_one,10,10}, []}}.