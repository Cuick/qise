-module (dead_valley_packet).

-include ("login_pb.hrl").

-export ([handle/2, encode_dead_valley_start_forecast_s2c/0, encode_dead_valley_start_nofity_s2c/0,
	encode_dead_valley_end_forecast_s2c/0, encode_dead_valley_end_notify_s2c/0,
	encode_dead_valley_points_update_s2c/1, encode_dead_valley_boss_hp_update_s2c/3,
	encode_dead_valley_force_leave_s2c/0, encode_dead_valley_exp_update_s2c/1,
	encode_dead_valley_query_zone_info_s2c/1]).

handle(Message, RolePid) ->
	RolePid ! {dead_valley, Message}.

encode_dead_valley_start_forecast_s2c() ->
	login_pb:encode_dead_valley_start_forecast_s2c(
		#dead_valley_start_forecast_s2c{}
		).

encode_dead_valley_start_nofity_s2c() ->
	login_pb:encode_dead_valley_start_nofity_s2c(
		#dead_valley_start_nofity_s2c{}
		).

encode_dead_valley_end_forecast_s2c() ->
	login_pb:encode_dead_valley_end_forecast_s2c(
		#dead_valley_end_forecast_s2c{}
		).

encode_dead_valley_end_notify_s2c() ->
	login_pb:encode_dead_valley_end_notify_s2c(
		#dead_valley_end_notify_s2c{}
		).

encode_dead_valley_points_update_s2c(Points) ->
	login_pb:encode_dead_valley_points_update_s2c(
		#dead_valley_points_update_s2c{points = Points}
		).

encode_dead_valley_boss_hp_update_s2c(NpcId, HpMax, Hp) ->
	login_pb:encode_dead_valley_boss_hp_update_s2c(
		#dead_valley_boss_hp_update_s2c{npcid = NpcId, hpmax = HpMax, hp = Hp}
		).

encode_dead_valley_force_leave_s2c() ->
	login_pb:encode_dead_valley_force_leave_s2c(
		#dead_valley_force_leave_s2c{}
		).

encode_dead_valley_exp_update_s2c(Exp) ->
	login_pb:encode_dead_valley_exp_update_s2c(
		#dead_valley_exp_update_s2c{exp = Exp}).

encode_dead_valley_query_zone_info_s2c(ZoneInfo) ->
	login_pb:encode_dead_valley_query_zone_info_s2c(
		#dead_valley_query_zone_info_s2c{info = ZoneInfo}).