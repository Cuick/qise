-module(travel_battle_map_travel_op).

%%
%% Include files
%%
-compile(export_all).

-define(REGIST_CALLBACK_TIME,30000).		%%wait line_manager_start
-define(SHARE_MAP_CONNECTING_NODES,'$share_map_line_nodes$').		%%wait line_manager_start

%%wait_servers,connect_servers :[{serverid,line_node}]

init()->
	ets:new(?SHARE_MAP_CONNECTING_NODES,[set,named_table]).

regist_server({ServerId,LineNode})->
%%	slogger:msg("receive regist_server ServerId ~p LineNode ~p ~n ",[ServerId,LineNode]),
	add_connect_servers({ServerId,LineNode}),
	ok.

add_connect_servers(ServerRef)->
	ets:insert(?SHARE_MAP_CONNECTING_NODES,ServerRef).

delete_from_connect_servers({ServerId,_})->
	ets:delete(?SHARE_MAP_CONNECTING_NODES, ServerId).

%%call in not share_map node %% return: true/false
multicast_all_not_in_travel(Module,Fun,Args)->
	case travel_battle_deamon_op:is_travel_battle_data_available() of
		true ->
			ShareNode = travel_battle_util:get_travel_battle_db_map_node(),
			cast_server(ShareNode,?MODULE,multicast_all_in_travel,[Module,Fun,Args]),
			true;
		false ->
			false
	end.

%%call in share_map node
multicast_all_in_travel(Module,Fun,Args)->
	ets:foldl(fun({_LineId,LineNode},_)->
		cast_server(LineNode,Module,Fun,Args)	  
	end ,[], ?SHARE_MAP_CONNECTING_NODES).

cast_server(Node,Module,Fun,Args)->
	try
		rpc:cast(Node, Module,Fun,Args)
	catch
		E:R->
			slogger:msg("cast_server ~p ~p  Module ~p Fun ~p ~n",[E,R,Module,Fun]),
			error
	end.

get_source_node_by_serverid(ServerId)->
	case ets:lookup(?SHARE_MAP_CONNECTING_NODES, ServerId) of
		[]->
			[];
		[{ServerId,Node}]->
			Node
	end.

get_all_server_online()->
	ets:foldl(fun({_LineId,LineNode},AccNum)->
			AccNum +
			try
				rpc:call(LineNode,role_pos_db,get_online_count,[])
			catch
				_:_->0
			end
		end,0, ?SHARE_MAP_CONNECTING_NODES).
	
cast_to_server_in_travel(ServerId,Module,Function,Args) ->
	case get_source_node_by_serverid(ServerId) of
		[] ->
			nothing;
		LineNode ->
			cast_server(LineNode,Module,Function,Args)
	end.

cast_to_server_not_in_travel(ServerId,Module,Function,Args) ->
	case travel_battle_deamon_op:is_travel_battle_data_available() of
		true ->
			ShareNode = travel_battle_util:get_travel_battle_db_map_node(),
			cast_server(ShareNode,?MODULE,cast_to_server_in_travel,[ServerId,Module,Function,Args]),
			true;
		false ->
			false
	end.