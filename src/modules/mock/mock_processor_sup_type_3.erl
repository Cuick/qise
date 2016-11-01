-module (mock_processor_sup_type_3).

-behaviour(supervisor).

-export ([start_link/0, start_mock_type_3/7]).

-export ([init/1]).

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->	
	supervisor:start_link({local,?MODULE}, ?MODULE, []).

start_mock_type_3(MockId, Name, Gender, Class, SpeakMin, SpeakMax, BroadCastRate) ->
	supervisor:start_child(?MODULE, [MockId, Name, Gender, Class, SpeakMin, SpeakMax, BroadCastRate]).

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
	{ok,{{simple_one_for_one,10,10}, [{mock_processor_type_3, {mock_processor_type_3, start_link, []},
            temporary, brutal_kill, worker, [mock_processor_type_3]}]}}.

%% ====================================================================
%% Internal functions
%% ====================================================================