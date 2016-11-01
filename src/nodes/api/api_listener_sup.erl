%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-2
%%% -------------------------------------------------------------------
-module(api_listener_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/4,start_link/5]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================
start_link(Port, OnStartup, OnShutdown, AcceptCallback) ->
    start_link( Port, OnStartup, OnShutdown, AcceptCallback, 1).

start_link(Port, OnStartup, OnShutdown, AcceptCallback, AcceptorCount) ->
    supervisor:start_link({local,?MODULE},?MODULE, {Port, OnStartup, OnShutdown,
									AcceptCallback, AcceptorCount}).



%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init({ Port, OnStartup, OnShutdown, AcceptCallback, AcceptorCount}) ->
    %% This is gross. The api_listener needs to know about the
    %% api_acceptor_sup, and the only way I can think of accomplishing
    %% that without jumping through hoops is to register the
    %% api_acceptor_sup.
	
	
	{ok, {{one_for_all, 10, 10},
          [{api_acceptor_sup, 
				{api_acceptor_sup, start_link,
				 [AcceptCallback]},
			    transient, infinity, supervisor, [api_acceptor_sup]},
		   {api_listener, {api_listener, start_link,
				[Port,  AcceptorCount, OnStartup, OnShutdown]},
			    transient, 100, worker, [api_listener]}
		  ]}}.

%% ====================================================================
%% Internal functions
%% ====================================================================

