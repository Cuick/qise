-module (travel_match_packet).

-include ("login_pb.hrl").

-export ([handle/2, encode_travel_match_register_start_s2c/1,
	encode_travel_match_register_forecast_end_s2c/1,
	encode_travel_match_register_end_s2c/1,
	encode_travel_match_register_s2c/0,
	encode_travel_match_enter_wait_map_start_s2c/2,
	encode_travel_match_enter_wait_map_forecast_end_s2c/2,
	encode_travel_match_battle_start_s2c/2,
	encode_travel_match_query_role_info_s2c/6,
	encode_travel_match_section_result_s2c/2,
	encode_travel_match_stage_result_s2c/2,
	encode_travel_match_query_unit_player_list_s2c/1,
	encode_travel_match_query_session_data_s2c/1
	]).

handle(Message = #travel_match_query_role_info_c2s{}, RolePid) ->
	RolePid ! {travel_match, Message};

handle(Message = #travel_match_register_c2s{}, RolePid) ->
	RolePid ! {travel_match, Message};

handle(Message = #travel_match_enter_wait_map_c2s{}, RolePid) ->
	RolePid ! {travel_match, Message};

handle(Message = #travel_match_leave_wait_map_c2s{}, RolePid) ->
	RolePid ! {travel_match, Message};

handle(Message = #travel_match_query_unit_player_list_c2s{}, RolePid) ->
	RolePid ! {travel_match, Message};

handle(Message = #travel_match_query_session_data_c2s{}, RolePid) ->
	RolePid ! {travel_match, Message};

handle(_, _) ->
	nothing.

encode_travel_match_register_start_s2c(Type) ->
	login_pb:encode_travel_match_register_start_s2c(
		#travel_match_register_start_s2c{type = Type}
		).

encode_travel_match_register_forecast_end_s2c(Type) ->
	login_pb:encode_travel_match_register_forecast_end_s2c(
		#travel_match_register_forecast_end_s2c{type = Type}
		).

encode_travel_match_register_end_s2c(Type) ->
	login_pb:encode_travel_match_register_end_s2c(
		#travel_match_register_end_s2c{type = Type}
		).

encode_travel_match_register_s2c() ->
	login_pb:encode_travel_match_register_s2c(
		#travel_match_register_s2c{}
		).

encode_travel_match_enter_wait_map_start_s2c(Type, Stage) ->
	login_pb:encode_travel_match_enter_wait_map_start_s2c(
		#travel_match_enter_wait_map_start_s2c{type = Type, stage = Stage}
		).

encode_travel_match_enter_wait_map_forecast_end_s2c(Type, Stage) ->
	login_pb:encode_travel_match_enter_wait_map_forecast_end_s2c(
		#travel_match_enter_wait_map_forecast_end_s2c{type = Type, stage = Stage}
		).

encode_travel_match_battle_start_s2c(Type, Stage) ->
	login_pb:encode_travel_match_battle_start_s2c(
		#travel_match_battle_start_s2c{type = Type, stage = Stage}
		).

encode_travel_match_section_result_s2c(Result, Points) ->
	login_pb:encode_travel_match_section_result_s2c(
		#travel_match_section_result_s2c{result = Result,
			points = Points}
		).

encode_travel_match_stage_result_s2c(Result, Points) ->
	login_pb:encode_travel_match_stage_result_s2c(
		#travel_match_stage_result_s2c{result = Result,
			points = Points}
		).

encode_travel_match_battle_awards_s2c(Type, Awards) ->
	login_pb:encode_travel_match_battle_awards_s2c(
		#travel_match_battle_awards_s2c{type = Type,
			awards = Awards}
		).

encode_travel_match_query_role_info_s2c(Stage, Status, 
	Rank, Details, Awards, RegisterStatus) ->
	login_pb:encode_travel_match_query_role_info_s2c(
		#travel_match_query_role_info_s2c{stage = Stage,
		status = Status, rank = Rank, details = Details,
		awards_gold = Awards, register_status = RegisterStatus}
		).

encode_travel_match_query_unit_player_list_s2c(PlayerList) ->
	login_pb:encode_travel_match_query_unit_player_list_s2c(
		#travel_match_query_unit_player_list_s2c{players = PlayerList
		}
		).

encode_travel_match_query_session_data_s2c(RankData) ->
	login_pb:encode_travel_match_query_session_data_s2c(
		#travel_match_query_session_data_s2c{rank_data = RankData
		}
		).