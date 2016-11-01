-module (wedding_ceremony_manager_op).

-include ("wedding_def.hrl").
-include ("error_msg.hrl").

-export ([init/0, query_free_times/0, book_ceremony/4, do_send_notify/0, do_send_start/0, do_send_end/0]).

init() ->
	AllCeremonyInfos = wedding_db:get_all_ceremony_infos(),
	{Date, Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
	CeremonyInfosOK = lists:filter(fun({_, CeremonyInfo}) ->
		{StartTime, _} = wedding_db:get_ceremony_time_time(CeremonyInfo),
		case time_util:compare_time(Time, StartTime) of
			true ->
				true;
			_ ->
				false
		end
	end, AllCeremonyInfos),
	AllBookInfo = role_wedding_db:get_all_role_ceremony_info(),
	CeremonyInfosOK2 = lists:filter(fun({{CeremonyId, _}}) ->
		case lists:keyfind(CeremonyId, 2, AllBookInfo) of
			false ->
				true;
			BookInfo ->
				BookDate = role_wedding_db:get_ceremony_book_date(BookInfo),
				case time_util:compare_time(Date, BookDate) of
					equal ->
						false;
					_ ->
						true
				end
		end
	end, CeremonyInfosOK),
	CeremonyInfosOK3 = lists:sort(fun({_, CeremonyInfoA}, {_, CeremonyInfoB}) ->
		{StartTimeA, _} = wedding_db:get_ceremony_time_time(CeremonyInfoA),
		{StartTimeB, _} = wedding_db:get_ceremony_time_time(CeremonyInfoB),
		case time_util:compare_time(StartTimeA, StartTimeB) of
			true ->
				true;
			_ ->
				false
		end
	end, CeremonyInfosOK2),
	CeremonyIdsOK = [CeremonyId || {CeremonyId, _} <- CeremonyInfosOK3],
	[NextCeremonyId | _] = CeremonyIdsOK,
	put(free_times, CeremonyIdsOK),
	{_, NextCeremonyInfo} = lists:keyfind(NextCeremonyId, 1, AllCeremonyInfos),
	{StartTime2, _} = wedding_db:get_ceremony_time_time(NextCeremonyInfo),
	NowSeconds = calendar:datetime_to_gregorian_seconds({Date, Time}),
	StartSeconds = calendar:datetime_to_gregorian_seconds({Date, StartTime2}),
	NotifyInterval = StartSeconds - NowSeconds - ?WEDDING_CEREMONY_NOTIFY_DURATION,
	NotifyInterval2 = if
		NotifyInterval > 0 ->
			NotifyInterval;
		true ->
			0
	end,
	put(ceremony_info, {Date, NextCeremonyId}),
	send_notify(NotifyInterval2).
	
query_free_times() ->
	get(free_times).

book_ceremony(Applicant, Spouse, Type, CeremonyId) ->
	FreeTimes = get(free_times),
	case lists:member(CeremonyId, FreeTimes) of
		true ->
			put(free_times, lists:delete(CeremonyId, FreeTimes)),
			{Date, Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
			role_wedding_db:save_role_ceremony_info(Applicant, Spouse, Type, Date),
			%% check to notify
			CeremonyInfo = wedding_db:get_ceremony_time_time_info(CeremonyId),
			{StartTime, _} = wedding_db:get_ceremony_time_time(CeremonyInfo),
			NowSeconds = calendar:datetime_to_gregorian_seconds({Date, Time}),
			StartSeconds = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
			NotifyInterval = StartSeconds - NowSeconds - ?WEDDING_CEREMONY_NOTIFY_DURATION,
			if
				NotifyInterval =< 0 ->
					Msg = wedding_packet:encode_wedding_ceremony_notify_s2c(Applicant, Spouse),
					role_pos_util:send_to_all_online_clinet(Msg);
				true ->
					nothing
			end,
			ok;
		false ->
			{error, ?ERROR_WEDDING_WRONG_CEREMONY_TIME}
	end.



send_start(Interval) ->
	if
		Interval =:= 0 ->
			erlang:send(self(), {wedding_start});
		true ->
			erlang:send_after(Interval * 1000, self(), {wedding_start})
	end.

send_notify(Interval) ->
	if
		Interval =:= 0 ->
			erlang:send(self(), {wedding_notify});
		true ->
			erlang:send_after(Interval * 1000, self(), {wedding_notify})
	end.

send_end(Interval) ->
	erlang:send_after(Interval * 1000, self(), {wedding_end}).

do_send_notify() ->
	%% check if send notify message to someone
	{Date, CeremonyId, _} = get(ceremony_info),
	case role_wedding_db:get_role_ceremony_info(CeremonyId) of
		[] ->
			nothing;
		RoleCeremonyInfo ->
			case role_wedding_db:get_role_ceremony_date(RoleCeremonyInfo) of
				Date ->
					%% send notify message to someone
					Applicant = role_wedding_db:get_role_ceremony_applicant(RoleCeremonyInfo),
					Spouse = role_wedding_db:get_role_ceremony_spouse(RoleCeremonyInfo),
					Msg = wedding_packet:encode_wedding_ceremony_notify_s2c(Applicant, Spouse),
					role_pos_util:send_to_all_online_clinet(Msg);
				_ ->
					nothing
			end
	end,
	%% send start message to self() process.
	{_, Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
	CeremonyInfo = wedding_db:get_ceremony_time_time_info(CeremonyId),
	{StartTime, _} = wedding_db:get_ceremony_time_time(CeremonyInfo),
	NowSeconds = calendar:datetime_to_gregorian_seconds({Date, Time}),
	StartSeconds = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
	send_start(StartSeconds - NowSeconds).

do_send_start() ->
	{Date, CeremonyId, _} = get(ceremony_info),
	{_, Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
	CeremonyInfo = wedding_db:get_ceremony_time_time_info(CeremonyId),
	case role_wedding_db:get_role_ceremony_info(CeremonyId) of
		[] ->
			NextCeremonyId = wedding_db:get_ceremony_next(CeremonyInfo),
			NextCeremonyInfo = wedding_db:get_ceremony_time_time_info(NextCeremonyId),
			if
				NextCeremonyInfo =/= [] ->
					{StartTime, _} = wedding_db:get_ceremony_time_time(NextCeremonyInfo),
					NowSeconds = calendar:datetime_to_gregorian_seconds({Date, Time}),
					StartSeconds = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
					NotifyInterval = StartSeconds - NowSeconds - ?WEDDING_CEREMONY_NOTIFY_DURATION,
					send_notify(NotifyInterval),
					put(free_times, lists:delete(CeremonyId, get(free_times))),
					put(ceremony_info, {Date, NextCeremonyId});
				true ->
					wedding_ceremony_manager_op:init()
			end;	
		RoleCeremonyInfo ->
			case role_wedding_db:get_role_ceremony_date(RoleCeremonyInfo) of
				Date ->
					Applicant = role_wedding_db:get_role_ceremony_applicant(RoleCeremonyInfo),
					Spouse = role_wedding_db:get_role_ceremony_spouse(RoleCeremonyInfo),
					Msg = wedding_packet:encode_wedding_ceremony_start_s2c(Applicant, Spouse),
					role_pos_util:send_to_all_online_clinet(Msg),
					{StartTime, EndTime} = wedding_db:get_ceremony_time_time(CeremonyInfo),
					StartSeconds = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
					EndSeconds = calendar:datetime_to_gregorian_seconds({Date, EndTime}),
					send_end(EndSeconds - StartSeconds),
					put(ceremony_info, {Date, CeremonyId});
				_ ->
					NextCeremonyId = wedding_db:get_ceremony_next(CeremonyInfo),
					NextCeremonyInfo = wedding_db:get_ceremony_time_time_info(NextCeremonyId),
					if
						NextCeremonyInfo =/= [] ->
							{StartTime, _} = wedding_db:get_ceremony_time_time(NextCeremonyInfo),
							NowSeconds = calendar:datetime_to_gregorian_seconds({Date, Time}),
							StartSeconds = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
							NotifyInterval = StartSeconds - NowSeconds - ?WEDDING_CEREMONY_NOTIFY_DURATION,
							send_notify(NotifyInterval),
							put(free_times, lists:delete(CeremonyId, get(free_times))),
							put(ceremony_info, {Date, NextCeremonyId});
						true ->
							wedding_ceremony_manager_op:init()
					end
			end
	end.

do_send_end() ->
	{Date, CeremonyId, _} = get(ceremony_info),
	RoleCeremonyInfo = role_wedding_db:get_role_ceremony_info(CeremonyId),
	Applicant = role_wedding_db:get_role_ceremony_applicant(RoleCeremonyInfo),
	Spouse = role_wedding_db:get_role_ceremony_spouse(RoleCeremonyInfo),
	Msg = wedding_packet:encode_wedding_ceremony_end_s2c(Applicant, Spouse),
	role_pos_util:send_to_all_online_clinet(Msg),

	{_, Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
	CeremonyInfo = wedding_db:get_ceremony_time_time_info(CeremonyId),
	NextCeremonyId = wedding_db:get_ceremony_next(CeremonyInfo),
	NextCeremonyInfo = wedding_db:get_ceremony_time_time_info(NextCeremonyId),
	if
		NextCeremonyInfo =/= [] ->
			{StartTime, _} = wedding_db:get_ceremony_time_time(NextCeremonyInfo),
			NowSeconds = calendar:datetime_to_gregorian_seconds({Date, Time}),
			StartSeconds = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
			NotifyInterval = StartSeconds - NowSeconds - ?WEDDING_CEREMONY_NOTIFY_DURATION,
			send_notify(NotifyInterval),
			put(free_times, lists:delete(CeremonyId, get(free_times))),
			put(ceremony_info, {Date, NextCeremonyId});
		true ->
			wedding_ceremony_manager_op:init()
	end.
