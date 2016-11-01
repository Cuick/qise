%% Author: adrian
%% Created: 2010-4-2
%% Description: TODO: Add description to gate_network
-module(gm_app).

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
-export([start/0,gm_listener_started/2,gm_listener_stopped/2,start_client/2]).

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
			error_logger:logfile({open,"../log/gm_node.log"}),
			?RELOADER_RUN,
			db_operater_mod:start(),
			ping_center:wait_all_nodes_connect(),
			case travel_battle_util:is_travel_battle_server() of
				false->
					travel_battle_deamon_sup:start_link();
				true->
					nothing
			end,
			timer_center:start_at_app(),
			global_util:global_proc_wait(),
			applicationex:wait_ets_init(),
			boot_client_sup(),
			boot_gm_msgwrite_sup(),
			boot_gm_msgwrite_mysql_sup(),
			boot_mysql_sup(),
			boot_listener_sup(),
			{ok, self()}
	end.

start()->
	applicationex:start(?MODULE).


boot_listener_sup() ->	
	%%SName = node_util:get_node_sname(node()),
	SName = node_util:get_match_snode(gm,node()),
	Port = env:get2(gmport, SName, 0),
	case Port of
		0-> slogger:msg("start gm error ,can not find listen port~n"),error;
		Port->
			AcceptorCount = env:get2(gm,acceptor_count,1),
			OnStartup = {?MODULE,gm_listener_started,[]},
			OnShutdown = {?MODULE,gm_listener_stopped,[]},
			AcceptCallback={?MODULE,start_client,[]},
			case gm_listener_sup:start_link(Port ,OnStartup, OnShutdown, AcceptCallback,AcceptorCount) of
				{ok, Pid} ->
					{ok, Pid};
				Error ->
					Error
			end
	end.

boot_client_sup() ->
	gm_client_sup:start_link().

boot_gm_msgwrite_sup()->
	gm_msgwrite_sup:start_link().

boot_gm_msgwrite_mysql_sup()->
	gm_msgwrite_mysql_sup:start_link().

boot_mysql_sup()->
	mysql_sup:start_link(),
	mysql_sup:start_mysql().
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
	ok.
%% --------------------------------------------------------------------
%% Func: gm_listen_start/2
%% Returns: any
%% --------------------------------------------------------------------
gm_listener_started(IPAddress, Port) ->
	slogger:msg("GM Started at ~p : ~p\n", [IPAddress, Port]).


gm_listener_stopped(IPAddress, Port) ->
	slogger:msg("GM Stopped at ~p : ~p\n", [IPAddress, Port]).

start_client(Sock,Pid)->
	slogger:msg("start one gmclient process pid = ~p sock = ~p\n",[Pid,Sock]).

%% ====================================================================
%% Internal functions
%% ====================================================================
