%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%        
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (travel_battle_manager_op).

-include ("travel_battle_def.hrl").

-export ([open_check/0, notify_forecast_end/0, notify_start/0, notify_forecast_begin/0, notify_end/0,
	do_notify_start/1, do_notify_forecast_end/0, do_notify_forecast_begin/0, do_notify_end/0]).

open_check() ->
	single_open_check().

single_open_check() ->
	BattleProto = travel_battle_db:get_battle_info(),
	{StartTime, EndTime} = travel_battle_db:get_battle_time_line(BattleProto),
	Now = timer_center:get_correct_now(),
	{Date, Time} = calendar:now_to_local_time(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
	EndSecs = calendar:datetime_to_gregorian_seconds({Date, EndTime}),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	case StartSecs =< NowSecs andalso NowSecs < EndSecs of
		true ->
			self() ! {travel_battle_start};
		false ->
			ForecastBeginSecs = StartSecs - ?TRAVEL_BATTLE_FORECAST_BEGIN_TIME,
			case ForecastBeginSecs =< NowSecs andalso NowSecs < StartSecs of
				true ->
					self() ! {travel_battle_forecast_bigin};
				false ->
					if
						NowSecs < ForecastBeginSecs ->
							erlang:send_after((ForecastBeginSecs - NowSecs) * 1000, self(), {travel_battle_forecast_bigin});
						EndSecs =< NowSecs ->
							erlang:send_after((ForecastBeginSecs + 24 * 60 * 60 - NowSecs) * 1000, self(), {travel_battle_forecast_bigin});
						true ->
							nothing
					end
			end
	end.

do_notify_start(Duration) ->
	slogger:msg("yanzengyan, in travel_battle_manager_op:do_notify_start~n"),
	top_bar_manager:hook_on_travel_battle_start(Duration),
	Message = travel_battle_packet:encode_travel_battle_open_notice_s2c(),
	role_pos_util:send_to_all_online_clinet(Message).

notify_start() ->
	slogger:msg("yanzengyan, in travel_battle_manager_op:notify_start~n"),
	BattleProto = travel_battle_db:get_battle_info(),
	{_, EndTime} = travel_battle_db:get_battle_time_line(BattleProto),
	Now = timer_center:get_correct_now(),
	{Date, Time} = calendar:now_to_local_time(Now),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	EndSecs = calendar:datetime_to_gregorian_seconds({Date, EndTime}),
	travel_battle_util:cast_for_all_server(?MODULE, do_notify_start, [(EndSecs - NowSecs) * 1000]),
	ForecastEndSecs = EndSecs - ?TRAVEL_BATTLE_FORECAST_END_TIME,
	case ForecastEndSecs =< NowSecs andalso NowSecs < EndSecs of
		true ->
			self() ! {travel_battle_forecast_end};
		false ->
			erlang:send_after((ForecastEndSecs - NowSecs) * 1000, self(), {travel_battle_forecast_end})
	end.

do_notify_forecast_begin() ->
	Message = travel_battle_packet:encode_travel_battle_forecast_begin_notice_s2c(),
	role_pos_util:send_to_all_online_clinet(Message).

notify_forecast_begin() ->
	travel_battle_util:cast_for_all_server(?MODULE, do_notify_forecast_begin, []),
	BattleProto = travel_battle_db:get_battle_info(),
	{StartTime, _} = travel_battle_db:get_battle_time_line(BattleProto),
	Now = timer_center:get_correct_now(),
	{Date, Time} = calendar:now_to_local_time(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	erlang:send_after((StartSecs - NowSecs) * 1000, self(), {travel_battle_start}).

do_notify_forecast_end() ->
	Message = travel_battle_packet:encode_travel_battle_forecast_end_notice_s2c(),
	role_pos_util:send_to_all_online_clinet(Message).

notify_forecast_end() ->
	travel_battle_util:cast_for_all_server(?MODULE, do_notify_forecast_end, []),
	BattleProto = travel_battle_db:get_battle_info(),
	{_, EndTime} = travel_battle_db:get_battle_time_line(BattleProto),
	Now = timer_center:get_correct_now(),
	{Date, Time} = calendar:now_to_local_time(Now),
	EndSecs = calendar:datetime_to_gregorian_seconds({Date, EndTime}),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	erlang:send_after((EndSecs - NowSecs) * 1000, self(), {travel_battle_end}).

do_notify_end() ->
	top_bar_manager:hook_on_travel_battle_stop(),
	Message = travel_battle_packet:encode_travel_battle_close_notice_s2c(),
	role_pos_util:send_to_all_online_clinet(Message).

notify_end() ->
	travel_battle_util:cast_for_all_server(?MODULE, do_notify_end, []),
	BattleProto = travel_battle_db:get_battle_info(),
	{StartTime, _} = travel_battle_db:get_battle_time_line(BattleProto),
	Now = timer_center:get_correct_now(),
	{Date, Time} = calendar:now_to_local_time(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	ForecastBeginSecs = StartSecs - ?TRAVEL_BATTLE_FORECAST_BEGIN_TIME,
	erlang:send_after((ForecastBeginSecs + 24 * 60 * 60 - NowSecs) * 1000, self(), {travel_battle_forecast_bigin}).





