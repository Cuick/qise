-module (travel_match_handle).

-include ("login_pb.hrl").

-export ([process_msg/1]).

process_msg(#travel_match_query_role_info_c2s{type = Type})->
	travel_match_op:query_role_info(Type);

process_msg(#travel_match_register_c2s{type = Type})->
	travel_match_op:regiser(Type);

process_msg(#travel_match_enter_wait_map_c2s{type = Type}) ->
	travel_match_op:enter_wait_map(Type);

process_msg(#travel_match_leave_wait_map_c2s{}) ->
	travel_match_op:leave_wait_map();

process_msg(#travel_match_query_unit_player_list_c2s{type = Type}) ->
	travel_match_op:query_unit_player_list(Type);

process_msg(#travel_match_query_session_data_c2s{type = Type, session = Session, 
	min_level = MinLevel, max_level = MaxLevel}) ->
	travel_match_op:query_session_data(Type, Session, {MinLevel, MaxLevel});

process_msg(_) ->
	nothing.