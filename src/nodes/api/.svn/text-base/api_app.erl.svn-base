%% Author: adrian
%% Created: 2010-4-2
%% Description: TODO: Add description to gate_network
-module(api_app).

-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("reloader.hrl").

%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 start/2,
	 stop/1
        ]).

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start/0,api_listener_started/2,api_listener_stopped/2,start_client/2]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------


%% ====================================================================!
%% External functions
%% ====================================================================!
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, _StartArgs) ->
	case util:get_argument('-line') of
		[]->  slogger:msg("Missing --line argument input the nodename");
		[CenterNode|_]->
			filelib:ensure_dir("../log/"),
			error_logger:logfile({open,"../log/api_node.log"}),
			?RELOADER_RUN,
			ping_center:wait_all_nodes_connect(),
			db_operater_mod:start(),
			global_util:global_proc_wait(),
			timer_center:start_at_app(),
			applicationex:wait_ets_init(),
			case travel_battle_util:is_travel_battle_server() of
				false->
					travel_battle_deamon_sup:start_link();
				true->
					nothing
			end,
			boot_client_sup(),
			boot_listener_sup(),
			{ok, self()}
	end.

start()->
	applicationex:start(?MODULE).


boot_listener_sup() ->	
	%%SName = node_util:get_node_sname(node()),
	SName = node_util:get_match_snode(api,node()),
	Port = env:get2(apiport, SName, 0),
	case Port of
		0-> slogger:msg("start api error ,can not find listen port~n"),error;
		Port->
			AcceptorCount = env:get2(api,acceptor_count,1),
			OnStartup = {?MODULE,api_listener_started,[]},
			OnShutdown = {?MODULE,api_listener_stopped,[]},
			AcceptCallback={?MODULE,start_client,[]},
			case api_listener_sup:start_link(Port ,OnStartup, OnShutdown, AcceptCallback,AcceptorCount) of
				{ok, Pid} ->
					{ok, Pid};
				Error ->
					Error
			end
	end.

boot_client_sup() ->
	api_client_sup:start_link().

%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
	ok.
%% --------------------------------------------------------------------
%% Func: api_listen_start/2
%% Returns: any
%% --------------------------------------------------------------------
api_listener_started(IPAddress, Port) ->
	slogger:msg("API Started at ~p : ~p\n", [IPAddress, Port]).


api_listener_stopped(IPAddress, Port) ->
	slogger:msg("API Stopped at ~p : ~p\n", [IPAddress, Port]).

start_client(Sock,Pid)->
	slogger:msg("start one apiclient process pid = ~p sock = ~p\n",[Pid,Sock]).

%% ====================================================================
%% Internal functions
%% ====================================================================
