-module (travel_battle_util).

-compile(export_all).

-include("common_define.hrl").
-include("travel_battle_def.hrl").

get_zone_id() ->
	AllShareNodes = env:get(travel_battle_map_node, []),
	{ZoneId, _, _} = lists:keyfind(node(), 2, AllShareNodes),
	ZoneId.

is_travel_battle_server()->
	env:get(travel_battle_server,0)=:=1.

is_has_travel_battle_map_node()->
	env:get(travel_battle_map_node,[])=/=[].

is_tavel_battle_map_node(MapNode)->
	lists:member(MapNode,get_travel_battle_map_node()).

is_travel_battle_db_map_node(MapNode) ->
	env:get(travel_battle_db_map_node, []) =:= MapNode.

get_travel_battle_db_map_node() ->
	env:get(travel_battle_db_map_node, []).

is_travel_battle_map(MapId) ->
	lists:member(MapId, env:get(travel_battle_map, [])).
	
ping_tavel_battle_map_nodes()->
	nothing.

get_travel_battle_map_node()->
	lists:map(fun({ZoneId, MapNode, _Cookie})->MapNode end ,env:get(travel_battle_map_node,[])).

get_all_zone_ids() ->
	[ZoneId || {ZoneId, _, _} <- env:get(travel_battle_map_node,[])].

get_zone_map_node(ZoneId) ->
	case lists:keyfind(ZoneId, 1, env:get(travel_battle_map_node, [])) of
		false ->
			[];
		{ZoneId, MapNode, _} ->
			MapNode
	end.

get_serverid_by_roleid(RoleId)->
	trunc(RoleId / ?SERVER_MAX_ROLE_NUMBER).
	
%%do in every server
cast_for_all_server(Module,Function,Args)->
	case is_travel_battle_server() of
		true->
			travel_battle_map_travel_op:multicast_all_in_travel(Module,Function,Args);
		_->	
			case travel_battle_map_travel_op:multicast_all_not_in_travel(Module,Function,Args) of
				false->
					erlang:apply(Module, Function, Args);
				_->
					nothing
			end	
	end.

%%do in self only and do in every server if is share node 
cast_for_all_server_with_self_if_share_node(Module,Function,Args)->
	erlang:apply(Module, Function, Args),
	case is_travel_battle_server() of
		true->
			travel_battle_map_travel_op:multicast_all_in_travel(Module,Function,Args);
		_->
			nothing
	end.

send_msg_to_all_server(Msg)->
	cast_for_all_server(role_pos_util,send_to_all_online_clinet,[Msg]).

%%apply in share_node.if not,apply self
do_in_share_node_if_has_travel(Module,Function,Args)->
	case travel_battle_util:is_travel_battle_server() of
		true->			%%is share_node
			erlang:apply(Module, Function, Args);
		_->	
			case travel_battle_util:is_has_travel_battle_map_node() of
				false->			%%if not has share_node,apply		
					erlang:apply(Module, Function, Args);
				_->
					nothing
			end
	end.

do_in_not_share_node(Module,Function,Args)->
	case travel_battle_util:is_travel_battle_server() of
		true->			%%is share_node
			nothing;
		_->
			erlang:apply(Module, Function, Args)
	end.

cast_to_role_server(RoleId, Module, Function, Args) ->
	ServerId = get_serverid_by_roleid(RoleId),
	case is_travel_battle_server() of
		true->
			travel_battle_map_travel_op:cast_to_server_in_travel(ServerId,Module,Function,Args);
		_->	
			case travel_battle_map_travel_op:cast_to_server_not_in_travel(ServerId,Module,Function,Args) of
				false->
					erlang:apply(Module, Function, Args);
				_->
					nothing
			end	
	end.