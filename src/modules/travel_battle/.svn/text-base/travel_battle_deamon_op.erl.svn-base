-module(travel_battle_deamon_op).

-compile(export_all).

-define(CHECK_MAP_INTERVAL,10000).
-define(TRAVEL_BATTLE_MAP_NODES,'$tavel_battle_map_nodes$').		

init()->
	put(connect_map_nodes,[]),
	ets:new(?TRAVEL_BATTLE_MAP_NODES,[set,named_table]),
	timer:send_after(60000, check_interval).	
	
do_check_interval()->	
	timer:send_after(?CHECK_MAP_INTERVAL, check_interval).

do_check()->
	AllShareNodes = env:get(travel_battle_map_node, []),
	CantConNodes = 
	lists:filter(fun({ZoneId,MapNode,Cookie})->
		erlang:set_cookie(node(), Cookie),				 
	  	net_adm:ping(MapNode) =/= pong		
	end,AllShareNodes),
	ConnNodes = AllShareNodes -- CantConNodes,
	case lists:filter(fun({ZoneIdTmp,_})-> lists:keymember(ZoneIdTmp,1,CantConNodes) end,get(connect_map_nodes)) of
		[]->
			nothing;
		LostConNodes->
			delete_connect_nodes(LostConNodes)
	end,
	lists:foreach(fun({ZoneIdTmp,MapNode2,_})-> 
		case lists:keymember(ZoneIdTmp,1,get(connect_map_nodes)) of
			false->			%%new node
				erlang:monitor_node(MapNode2, true),
				put(connect_map_nodes,[{ZoneIdTmp,MapNode2}|get(connect_map_nodes)]),
				add_tavel_battle_map_node({ZoneIdTmp,MapNode2});
			_->
				nothing
		end,
		case node_util:check_snode_match(line, node()) of
			true ->
				ServerId = env:get(serverid, undefined),
				% slogger:msg("travel_battle_deamon_op connect apply_regist_server Server ~p ~n",[{ServerId,node()}]),
				travel_battle_map_travel:apply_regist_server(MapNode2, {ServerId, node()});
			_ ->
				nothing
		end
	end, ConnNodes),
	erlang:set_cookie(node(),env:get(cookie,undefined)),
	do_check_interval().

add_tavel_battle_map_node({ZoneId,MapNode})->
	ets:insert(?TRAVEL_BATTLE_MAP_NODES,{ZoneId,MapNode}).

delete_connect_nodes(LostConNodes)->
	lists:foreach(fun({ZoneId, _})->delete_from_connect_servers(ZoneId) end, LostConNodes),
	slogger:msg("lost connect share map ~p ~n",[LostConNodes]),
	put(connect_map_nodes,get(connect_map_nodes) -- LostConNodes).

delete_from_connect_servers(ZoneId)->
	ets:delete(?TRAVEL_BATTLE_MAP_NODES, ZoneId).

get_connect_map_nodes() ->
	ets:tab2list(?TRAVEL_BATTLE_MAP_NODES).

get_one_connect_map_node() ->
	case get_connect_map_nodes() of
		[] ->
			[];
		[{_, MapNode} | _] ->
			MapNode
	end.

delete_disconnect_node(Node) ->
	ConnectNodes = get(connect_map_nodes),
	{ZoneId, _} = lists:keyfind(Node, 2, ConnectNodes),
	put(connect_map_nodes, lists:keydelete(ZoneId, 1, ConnectNodes)),
	delete_from_connect_servers(ZoneId).

is_travel_battle_data_available() ->
	case travel_battle_util:get_travel_battle_db_map_node() of
		[] ->
			false;
		Node ->
			lists:keymember(Node, 2, get_connect_map_nodes())
	end.