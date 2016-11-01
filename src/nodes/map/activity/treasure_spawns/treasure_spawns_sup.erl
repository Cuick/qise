-module(treasure_spawns_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0,start_child/1,stop_child/0]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------
-define(SERVER, ?MODULE).

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	supervisor:start_link({local,?MODULE}, ?MODULE, []).


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

start_child(Id)->	
	try
		AChild = {treasure_spawns_processor ,{treasure_spawns_processor,start_link,[Id]},
				  	      		temporary,2000,worker,[treasure_spawns_processor]},
		supervisor:start_child(?MODULE, AChild)
	catch
		E:R-> io:format("can not start treasure_spawns_processor(~p:~p)~n",[E,R]),
			  {error,R}
 	end.

stop_child()->
	supervisor:terminate_child(?MODULE, treasure_spawns_processor),
	supervisor:delete_child(?MODULE, treasure_spawns_processor).
%% ====================================================================
%% Internal functions
%% ====================================================================
	

	
	
