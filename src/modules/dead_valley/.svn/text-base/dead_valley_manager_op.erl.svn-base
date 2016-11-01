-module (dead_valley_manager_op).

-include ("travel_battle_def.hrl").
-include ("npc_define.hrl").
-include ("dead_valley_def.hrl").
-include ("error_msg.hrl").

-export ([init/0, join/1, leave/1, start_forecast/0, start_instance/1, end_forecast/0,
	end_notify/0, do_start_forecast/0, do_start_notify/1, do_end_forecast/0, do_end_notify/0,
	query_zone_info/0, start_notify/1]).


%% ====================================================================
%% External functions
%% ====================================================================

init() ->
	put(dead_valley_zone_instance, []),
	time_check().

join(ZoneId) ->
	ZoneInstance = get(dead_valley_zone_instance),
	case lists:keyfind(ZoneId, 1, ZoneInstance) of
		false ->
			{error, ?DEAD_VALLEY_SYSTEM_ERROR};
		{ZoneId, InstanceProc, ZoneCount} ->
			ZoneCntInfo = dead_valley_db:get_zone_count_info(ZoneId),
			ZoneMaxCnt = dead_valley_db:get_zone_max_count(ZoneCntInfo),
			if 
				ZoneCount >= ZoneMaxCnt ->
					{error, ?DEAD_VALLEY_ALL_ZONE_OVERLOAD};
				true ->
					ZoneInstance2 = lists:keyreplace(ZoneId, 1, 
						ZoneInstance, {ZoneId, InstanceProc, ZoneCount + 1}),
					put(dead_valley_zone_instance, ZoneInstance2),
					{ok, InstanceProc}
			end
	end.

leave(ZoneId) ->
	ZoneInstance = get(dead_valley_zone_instance),
	{ZoneId, InstanceProc, Count} = lists:keyfind(ZoneId, 1, ZoneInstance),
	ZoneInstance2 = lists:keyreplace(ZoneId, 1, ZoneInstance, {ZoneId, InstanceProc, Count - 1}),
	put(dead_valley_zone_instance, ZoneInstance2),
	ok.

start_forecast() ->
	travel_battle_util:cast_for_all_server(?MODULE, do_start_forecast, []).

start_instance(Duration) ->
	ProtoInfo = dead_valley_db:get_proto_info(),
	MapId = dead_valley_db:get_map_id(ProtoInfo),
	CreatorTag = {?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM},
	ZoneInstance = lists:foldl(fun(ZoneId, Acc) ->
		InstanceProc = make_instance_proc(ZoneId),
		MapNode = travel_battle_util:get_zone_map_node(ZoneId),
		case dead_valley_zone_manager:start_instance(MapNode, InstanceProc, 
			MapId, CreatorTag, Duration) of
			ok ->
				[{ZoneId, InstanceProc, 0} | Acc];
			error ->
				Acc
		end
	end, [], travel_battle_util:get_all_zone_ids() -- [1]),
	put(dead_valley_zone_instance, ZoneInstance).

start_notify(Duration) ->
	slogger:msg("yanzengyan, in dead_valley_manager_op:start_notify~n"),
	travel_battle_util:cast_for_all_server(?MODULE, do_start_notify, [Duration]).

end_forecast() ->
	travel_battle_util:cast_for_all_server(?MODULE, do_end_forecast, []).

end_notify() ->
	travel_battle_util:cast_for_all_server(?MODULE, do_end_notify, []),
	time_check().

do_start_forecast() ->
	slogger:msg("yanzengyan, in dead_valley_manager_op:do_start_forecast~n"),
	Message = dead_valley_packet:encode_dead_valley_start_forecast_s2c(),
	role_pos_util:send_to_all_online_clinet(Message).

do_start_notify(Duration) ->
	top_bar_manager:hook_on_dead_valley_start(Duration),
	Message = dead_valley_packet:encode_dead_valley_start_nofity_s2c(),
	role_pos_util:send_to_all_online_clinet(Message).

do_end_forecast() ->
	Message = dead_valley_packet:encode_dead_valley_end_forecast_s2c(),
	role_pos_util:send_to_all_online_clinet(Message).

do_end_notify() ->
	top_bar_manager:hook_on_dead_valley_stop().

query_zone_info() ->
	{ok, [{ZoneId, ZoneCount} || {ZoneId, _, ZoneCount} <- get(dead_valley_zone_instance)]}.

%% ====================================================================
%% Internal functions
%% ====================================================================

time_check() ->
	ProtoInfo = dead_valley_db:get_proto_info(),
	TimeLines = dead_valley_db:get_time_lines(ProtoInfo),
	{Date, Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
	Week = calendar:day_of_the_week(Date),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	StartLines = lists:map(fun(TimeLine) ->
		case TimeLine of
			{Week2, Time2, Duration} ->
				Secs = if
					Week2 =:= Week ->
						generate_datetime_secs_day(Time2, Date, NowSecs);
					true ->
						generate_datetime_secs_week(Week2, Time2, Date, Week)
				end,
				{Secs, Duration};
			{Time2, Duration} ->
				Secs = generate_datetime_secs_day(Time2, Date, NowSecs),
				{Secs, Duration}
		end
	end, TimeLines),
	[{StartSecs, Duration} | _] = lists:sort(fun(A, B) ->
		{StartSecsA, _} = A,
		{StartSecsB, _} = B,
		StartSecsA =< StartSecsB
	end, StartLines),
	StartForecastSecs = StartSecs - ?DEAD_VALLEY_START_FORECAST,
	if
		NowSecs < StartForecastSecs ->
			erlang:send_after((StartForecastSecs - NowSecs) * 1000, self(), {start_forecast});
		true ->
			self() ! {start_forecast}
	end,
	TimeDelta = (StartSecs - NowSecs) * 1000,
	if
		TimeDelta > ?DEAD_VALLEY_BUFF_TIME * 1000 ->	
			erlang:send_after(TimeDelta - ?DEAD_VALLEY_BUFF_TIME * 1000, self(), 
				{start_instance, Duration + ?DEAD_VALLEY_BUFF_TIME * 1000 * 2});
		true ->
			self() ! {start_instance, Duration + ?DEAD_VALLEY_BUFF_TIME * 1000 * 2}
	end,
	erlang:send_after(TimeDelta, self(), {start_notify, Duration}),
	erlang:send_after(TimeDelta + Duration - ?DEAD_VALLEY_END_FORECAST, self(), {end_forecast}),
	erlang:send_after(TimeDelta + Duration, self(), {end_notify}).

generate_datetime_secs_week(Week2, Time, Date, Week) ->
	Days = (7 + Week2 - Week) rem 7,
	calendar:datetime_to_gregorian_seconds({Date, Time}) + Days * 24 * 3600.


generate_datetime_secs_day(Time, Date, NowSecs) ->
	Secs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	if
		Secs =< NowSecs ->
			Secs + 24 * 3600;
		true ->
			Secs
	end.

make_instance_proc(ZoneId) ->
	list_to_atom("dead_valley_" ++ integer_to_list(ZoneId)).