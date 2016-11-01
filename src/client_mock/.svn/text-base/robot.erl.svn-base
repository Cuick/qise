%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%		机器人启动
%%% Created : 2013-5-6
%%% -------------------------------------------------------------------

-module(robot).

-export([start/7]).

%% erl -name robot@127.0.0.1
%       {N,_Time} = random:uniform_s(90000,now()),robot:start("127.0.0.1", 8001, "1", 5, 3, N, 1).

%% robot:start("127.0.0.1", 8001, 1, 5, 3, 423, 1).

start(ServerIp, ServerPort, ServerId, SpawnInterval, SpeakInterval, StartId, ClientMax) ->
	applicationex:force_start(),
	ping_center:wait_all_nodes_connect(),

	%% create configure ets
	configures:create_all_ets(),

	%% load all map data
	load_map_sup:start_link(),
	mock_client_sup:start_link(),
	mock_server:start_link(ServerIp, ServerPort, ServerId, SpawnInterval, SpeakInterval, StartId, ClientMax).