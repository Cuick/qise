-module (top_bar_manager_op).

-include ("top_bar_item_def.hrl").
-include ("game_rank_define.hrl").
-include ("string_define.hrl").
-include ("item_define.hrl").
-include ("error_msg.hrl").
-include ("mnesia_table_def.hrl").
-include ("npc_define.hrl").
-include ("travel_match_def.hrl").
-include ("common_define.hrl").

-export ([init/0, load_from_db/0, hook_account_charge/0, hook_get_jackaroo_card/0, next_activity_check/0, role_login/1,
	check_activity_awards/1, update_activity_count_offline/3, update_activity_count_online/3, check_jackaroo_card/1,
	check_first_charge/1, check_repeat_charge/1, update_by_gm/0, get_temp_activity_contents/2,
	get_activity_awards/1,check_double_exp/0, check_travel_match_type_1/1, hook_on_travel_match_start/0, 
	hook_on_travel_match_stop/0, hook_on_travel_battle_start/1, hook_on_travel_battle_stop/0, check_travel_battle/1,
	load_by_copy/1, export_for_copy/0, hook_on_dead_valley_start/1, hook_on_dead_valley_stop/0,
	check_dead_valley/1,activity_reward_arm_send/2,check_open_server_activities/0,check_combine_server_activities/0]).

-include ("item_struct.hrl").

init() ->
	AllTempActivityInfo = top_bar_item_db:get_all_activity_info(),
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{TimeList, IdList, DelayList} = lists:foldl(fun({ActivityId, ActivityInfo}, {TimeAcc, IdAcc, DelayAcc}) ->
		StartTime = top_bar_item_db:get_activity_start_time(ActivityInfo),
		EndTime = top_bar_item_db:get_activity_end_time(ActivityInfo),
		LeftTime = timer_util:time_delta(Now, EndTime),
		if
			LeftTime > 0 ->
				LeftTime2 = timer_util:time_delta(StartTime, Now),
				if
					 LeftTime2 >= 0 ->
					 	%% have started
						TimeList2 = case lists:keyfind(EndTime, 1, TimeAcc) of
							false ->
								[{EndTime, [ActivityId]} | TimeAcc];
							{EndTime, R} ->
								lists:keyreplace(EndTime, 1, TimeAcc, {EndTime, [ActivityId | R]})
						end,
						{TimeList2, [{ActivityId, ?ACTIVITY_STATE_OPEN} | IdAcc], DelayAcc};
					true ->
						%% not start
						TimeList2 = case lists:keyfind(StartTime, 1, TimeAcc) of
							false ->
								[{StartTime, [ActivityId]} | TimeAcc];
							{StartTime, R} ->
								lists:keyreplace(StartTime, 1, TimeAcc, {StartTime, [ActivityId | R]})
						end,
						TimeList3 = case lists:keyfind(EndTime, 1, TimeList2) of
							false ->
								[{EndTime, [ActivityId]} | TimeList2];
							{EndTime, R2} ->
								lists:keyreplace(EndTime, 1, TimeList2, {EndTime, [ActivityId | R2]})
						end,
						{TimeList3, [{ActivityId, ?ACTIVITY_STATE_WAIT} | IdAcc], DelayAcc}
				end;
			true ->
				AwardsTime = top_bar_item_db:get_activity_awards_time(ActivityInfo),
				DelayAcc2 = if
					AwardsTime =:= ?ACTIVITY_AWARD_LOGIN_OR_DELAY; 
					AwardsTime =:= ?ACTIVITY_AWARD_DEADLINE_OR_DELAY ->
						[ActivityId | DelayAcc];
					true ->
						DelayAcc
				end,
				{TimeAcc, IdAcc, DelayAcc2}
		end
	end, {[], [], []}, AllTempActivityInfo),
	if
		TimeList =/= [] ->
			TimeList2 = lists:sort(fun(A, B) ->
				TimeA = element(1, A),
				TimeB = element(1, B),
				timer_util:time_delta(TimeA, TimeB) > 0
			end, TimeList),
			[{NextActivityTime, _} | _] = TimeList2,
			Duration = timer_util:time_delta(Now, NextActivityTime),
			{ok, TimerRef} = timer:send_after(Duration * 1000, {top_bar_next_activity}),
			put(temp_activitys, {TimeList2, IdList, DelayList, TimerRef});
		true ->
			put(temp_activitys, {TimeList, IdList, DelayList, undefined})
	end.

load_from_db() ->
	AllItems = top_bar_item_db:get_all_items_info(),
	{ItemsInfo, ItemList} = lists:foldl(fun({ItemId, ItemInfo}, {Acc0, Acc1}) ->
		case check_item_valid(ItemInfo) of
			{true, Duration} ->
				Pos = top_bar_item_db:get_pos(ItemInfo),
				{[#ac{id = ItemId, duration = Duration, pos = Pos} | Acc0], [ItemId | Acc1]};
			false ->
				{Acc0, Acc1}
		end
	end, {[], []}, AllItems),
	put(show_items, ItemList),
	if
		ItemsInfo =/= [] ->
			Msg = top_bar_item_packet:encode_top_bar_show_items_s2c(ItemsInfo),
			role_op:send_data_to_gate(Msg);
		true ->
			nothing
	end.

export_for_copy() ->
	get(show_items).

load_by_copy(TopBarItemInfo) ->
	put(show_items, TopBarItemInfo).

role_login(RoleId) ->
	{_, IdList, DelayList, _} = get(temp_activitys),
	ActivityIds = [ActivityId || {ActivityId, State} <- IdList, State =:= ?ACTIVITY_STATE_OPEN],
	TypeList = [?ACTIVITY_AWARD_LOGIN, ?ACTIVITY_AWARD_LOGIN_OR_DELAY, ?ACTIVITY_AWARD_LOGIN_OR_PROMPT],
	[check_awards_send(RoleId, ActivityId, TypeList) || ActivityId <- ActivityIds],
	show_activities(ActivityIds,RoleId),
	TypeList2 = [?ACTIVITY_AWARD_DEADLINE_OR_DELAY, ?ACTIVITY_AWARD_LOGIN_OR_DELAY],
	[check_awards_send(RoleId, ActivityId, TypeList) || ActivityId <- DelayList].

check_activity_awards(ActivityId) ->
	RoleId = get(roleid),
	ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
	ActivityType = top_bar_item_db:get_activity_type(ActivityInfo),
	do_check_activity_awards(RoleId, ActivityId, ActivityType, ActivityInfo).

update_activity_count_offline(RoleId, ActivityType, Count) ->
	{_, IdList, _, _} = get(temp_activitys),
	IdList2 = lists:foldl(fun({Id, State}, Acc) ->
		if
			State =:= ?ACTIVITY_STATE_OPEN ->
				ActivityInfo = top_bar_item_db:get_activity_info(Id),
				Type = top_bar_item_db:get_activity_type(ActivityInfo),
				if
					Type =:= ActivityType ->
						AwardsType = top_bar_item_db:get_activity_awards_type(ActivityInfo),
						[{Id, AwardsType} | Acc];
					true ->
						Acc
				end;
			true ->
				Acc
		end
	end, [], IdList),
	if 
		IdList2 =/= [] ->
			Now = timer_center:get_correct_now(),
			{Date, _} = calendar:now_to_local_time(Now),
			RoleCount = update_role_activity_count(RoleId, Count, IdList2, Now, Date),
			do_special_for_role_activity_count(RoleId, ActivityType, RoleCount, IdList2, Now, Date);
		true ->
			nothing
	end,
	IdList2.

update_activity_count_online(RoleId, ActivityType, Count) ->
	IdList = update_activity_count_offline(RoleId, ActivityType, Count),
	lists:foreach(fun({ActivityId, _}) ->
		check_awards_send(RoleId, ActivityId, [?ACTIVITY_AWARD_PROMPT, 
			?ACTIVITY_AWARD_LOGIN_OR_PROMPT])
	end, IdList).

hook_account_charge() ->
	ShowItems = get(show_items),
	ShowItems2 = case lists:member(?TOP_BAR_ITEM_FIRST_CHARGE, ShowItems) of
		true ->
			Msg = top_bar_item_packet:encode_top_bar_hide_items_s2c([?TOP_BAR_ITEM_FIRST_CHARGE]),
			role_op:send_data_to_gate(Msg),
			ShowItems -- [?TOP_BAR_ITEM_FIRST_CHARGE];
		false ->
			ShowItems
	end,
	ShowItems3 = case lists:member(?TOP_BAR_ITEM_REPEAT_CHARGE, ShowItems2) of
		false ->
			BarItemInfo = top_bar_item_db:get_item_info(?TOP_BAR_ITEM_REPEAT_CHARGE),
			Pos = top_bar_item_db:get_pos(BarItemInfo),
			Msg2 = top_bar_item_packet:encode_top_bar_show_items_s2c(
				[pb_util:key_value(?TOP_BAR_ITEM_REPEAT_CHARGE, Pos)]),
			role_op:send_data_to_gate(Msg2),
			[?TOP_BAR_ITEM_REPEAT_CHARGE | ShowItems2];
		true ->
			ShowItems2
	end,
	put(show_items, ShowItems3).

hook_get_jackaroo_card() ->
	ShowItems = get(show_items),
	ShowItems2 = case lists:member(?TOP_BAR_ITEM_JACKAROO, ShowItems) of
		true ->
			Msg = top_bar_item_packet:encode_top_bar_hide_items_s2c([?TOP_BAR_ITEM_JACKAROO]),
			role_op:send_data_to_gate(Msg),
			ShowItems -- [?TOP_BAR_ITEM_JACKAROO];
		false ->
			ShowItems
	end,
	put(show_items, ShowItems2).

next_activity_check() ->
	{TimeList, IdList, DelayList, TimerRef} = get(temp_activitys),
	if
		TimeList =/= [] ->
			[{_, Ids} | T] = TimeList,
			{IdList2, OpenActivities, CloseActivities} = lists:foldl(fun(ActivityId, {Acc, OpenAcc, CloseAcc}) ->
				{ActivityId, State} = lists:keyfind(ActivityId, 1, Acc),
				if
					State =:= ?ACTIVITY_STATE_WAIT ->
						check_awards_send(all, ActivityId, [?ACTIVITY_AWARD_LOGIN, ?ACTIVITY_AWARD_LOGIN_OR_DELAY]),
						duration_activity_start(ActivityId),
						Acc2 = lists:keyreplace(ActivityId, 1, Acc, {ActivityId, ?ACTIVITY_STATE_OPEN}),
						{Acc2, [ActivityId | OpenAcc], CloseAcc};
					true ->
						check_awards_send(all, ActivityId, [?ACTIVITY_AWARD_DEADLINE, ?ACTIVITY_AWARD_DEADLINE_OR_DELAY]),
						duration_activity_stop(ActivityId),
						Acc2 = lists:keydelete(ActivityId, 1, Acc),
						{Acc2, OpenAcc, [ActivityId | CloseAcc]}
				end
			end, {IdList, [], []}, Ids),
			show_activities(OpenActivities),
			hide_activities(CloseActivities),
			if 
				T =/= [] ->
					[{NextActivityTime, _} | _] = T,
					Now = calendar:now_to_local_time(timer_center:get_correct_now()),
					Duration = timer_util:time_delta(Now, NextActivityTime),
					{ok, TimerRef1} = timer:send_after(Duration * 1000, {top_bar_next_activity}),
					put(temp_activitys, {T, IdList2, DelayList, TimerRef1});
				true ->
					put(temp_activitys, {T, IdList2, DelayList, undefined})
			end;
		true ->
			nothing
	end.

check_jackaroo_card(_) ->
	case not giftcard_db:get_role_status(get(roleid)) of
		true ->
			{true, -1};
		false ->
			false
	end.

check_first_charge(_) ->
	Charge = vip_op:get_role_sum_gold(get(roleid)),
	case Charge =:= [] orelse Charge =:= 0 of
		true ->
			{true, -1};
		false ->
			false
	end.

check_repeat_charge(ItemInfo) ->
	case check_first_charge(ItemInfo) of
		{true, _} ->
			false;
		false ->
			{true, -1}
	end.

check_travel_match_type_1(_) ->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{{Y, M, _}, _} = Now,
	MatchStage = travel_match_db:get_match_stage_info(
		?TRAVEL_MATCH_TYPE_SINGLE, register),
	{Day, StartTime, _} = travel_match_db:get_stage_time_line(MatchStage),
	StartDateTime = {{Y, M, Day}, StartTime},
	MatchStage2 = travel_match_db:get_match_stage_info(
		?TRAVEL_MATCH_TYPE_SINGLE, final),
	{Day2, _, EndTime} = travel_match_db:get_stage_time_line(MatchStage2),
	EndDateTime = {{Y, M, Day2}, EndTime},
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds(StartDateTime),
	EndSecs = calendar:datetime_to_gregorian_seconds(EndDateTime) + 24 * 60 * 60,
	if
		StartSecs =< NowSecs, NowSecs =< EndSecs ->
			{true, (EndSecs - NowSecs) * 1000};
		true ->
			false
	end.

check_travel_battle(_) ->
	BattleProto = travel_battle_db:get_battle_info(),
	{StartTime, EndTime} = travel_battle_db:get_battle_time_line(BattleProto),
	Now = timer_center:get_correct_now(),
	{Date, Time} = calendar:now_to_local_time(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
	EndSecs = calendar:datetime_to_gregorian_seconds({Date, EndTime}),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	if
		StartSecs =< NowSecs, NowSecs =< EndSecs ->
			{true, (EndSecs - NowSecs) * 1000};
		true ->
			false
	end.

check_dead_valley(_) ->
	ProtoInfo = dead_valley_db:get_proto_info(),
	TimeLines = dead_valley_db:get_time_lines(ProtoInfo),
	{Date, Time} = calendar:now_to_local_time(timer_center:get_correct_now()),
	Week = calendar:day_of_the_week(Date),
	StartLines = lists:map(fun(TimeLine) ->
		case TimeLine of
			{Week2, Time2, Duration} ->
				Days = (7 + Week2 - Week) rem 7,
				Secs = calendar:datetime_to_gregorian_seconds({Date, Time2}) + Days * 24 * 3600,
				{Secs, Duration};
			{Time2, Duration} ->
				Secs = calendar:datetime_to_gregorian_seconds({Date, Time2}),
				{Secs, Duration}
		end
	end, TimeLines),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	RightLines = lists:filter(fun({Secs, Duration}) ->
		Secs =< NowSecs andalso NowSecs =< Secs + (Duration div 1000)
	end, StartLines),
	if
		RightLines =/= [] ->
			[{Secs, Duration} | _] = RightLines,
			{true, (Secs + Duration div 1000 - NowSecs) * 1000};
		true ->
			false
	end.

update_by_gm() ->
	{TimeList, IdList, DelayList, TimerRef} = get(temp_activitys),
	if
		TimerRef =/= undefined ->
			timer:cancel(TimerRef);
		true ->
		    nothing
	end,
	erase(temp_activitys),
	init().

get_temp_activity_contents(RoleId, ItemId) ->
	{_, IdList, _, _} = get(temp_activitys),
	Contents = lists:foldl(fun({ActivityId, State}, Acc) ->
		if 
			State =:= ?ACTIVITY_STATE_OPEN ->
				ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
				BarItem = top_bar_item_db:get_activity_bar_item(ActivityInfo),
				if 
					BarItem =:= ItemId ->
						Type = top_bar_item_db:get_activity_type(ActivityInfo),
						Awards = top_bar_item_db:get_activity_awards(ActivityInfo),
						SendType=top_bar_item_db:get_activity_awards_send_type(ActivityInfo),
						StartTime = top_bar_item_db:get_activity_start_time(ActivityInfo),
						EndTime = top_bar_item_db:get_activity_end_time(ActivityInfo),
						Sid = top_bar_item_db:get_activity_bar_sid(ActivityInfo),
						Condition = top_bar_item_db:get_activity_bar_condition(ActivityInfo),
						AwardsTime = top_bar_item_db:get_activity_awards_time(ActivityInfo),
						AwardsShowType = if
							Type =:= ?ACTIVITY_FIGHT_FORCE_RANK;
							Type =:= ?ACTIVITY_LEVEL_RANK;
							Type =:= ?ACTIVITY_GOLD_EQUIPMENTS;
							Type =:= ?ACTIVITY_CONSUMPTION ->
								?ACTIVITY_AWARD_SHOW_MULTI;
							true ->
								?ACTIVITY_AWARD_SHOW_NORMAL
						end,
						Awards2 = if
							AwardsTime =:= ?ACTIVITY_AWARD_DURATION ->
								[];
							true ->
								Awards
						end,
						[top_bar_item_packet:mk_activity_content(ActivityId, Type, StartTime, EndTime, 
							AwardsShowType, Awards2, SendType, Sid, Condition) | Acc];
					true ->
						Acc
				end;
			true ->
				Acc
		end
	end, [], IdList),
	Msg = top_bar_item_packet:encode_temp_activity_contents_s2c(ItemId, Contents),
	role_pos_util:send_to_role_clinet(RoleId, Msg).

get_activity_awards(ActivityId) ->
	ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
	AwardsSendType = top_bar_item_db:get_activity_awards_send_type(ActivityInfo),
	Result = if 
		AwardsSendType =:= ?ACTIVITY_AWARD_CLICK ->
			Now = calendar:now_to_local_time(timer_center:get_correct_now()),
			StartTime = top_bar_item_db:get_activity_start_time(ActivityInfo),
			EndTime = top_bar_item_db:get_activity_end_time(ActivityInfo),
			case timer_util:is_in_time_point(StartTime, EndTime, Now) of
				true ->
					do_get_activity_awards(ActivityId, ActivityInfo);
				false ->
					?ERROR_TEMP_ACTIVITY_OVERDUE
			end;
		true ->
			?ERROR_TEMP_ACTIVITY_AWARD_SEND_TYPE
	end,
	if
		Result =/= 0 ->
			Msg = top_bar_item_packet:encode_temp_activity_get_award_s2c(Result),
			role_op:send_data_to_gate(Msg);
		true ->
			nothing
	end.

add_config_to_ets(ItemList) ->
	lists:foreach(fun(Item) ->
		Table = element(1, Item),
		Key = element(2, Item),
		if
			Table =:= creature_spawns ->
				EtsName = list_to_existing_atom(atom_to_list(Table) ++ "_ets"),
				MapId = Item#creature_spawns.mapid,
				ets:insert(EtsName, {Key, MapId, Item});
			Table =:= ai_agents ->
				EtsName = list_to_existing_atom(atom_to_list(Table) ++ "_ets"),
				Entry = Item#ai_agents.entry,
				ets:insert(EtsName, {Entry, Item});
			Table =/= npc_sell_list ->
				EtsName = list_to_existing_atom(atom_to_list(Table) ++ "_ets"),
				ets:insert(EtsName, {Key, Item});
			true ->
				nothing
		end
	end, ItemList),
	lists:foreach(fun(Item) ->
		Table = element(1, Item),
		if
			Table =:= creature_spawns ->
				BornWithMap = Item#creature_spawns.born_with_map,
				if
					BornWithMap =:= 1 ->
						create_npc_now(Item);
					true ->
						nothing
				end;
			Table =:= npc_functions ->
				npc_function_frame:add_npc_function(Item);
			true ->
				nothing
		end
	end, ItemList).

delete_config_to_ets(ItemList) ->
	lists:foreach(fun(Item) ->
		Table = element(1, Item),
		Key = element(2, Item),
		if
			Table =/= npc_sell_list ->
				EtsName = list_to_existing_atom(atom_to_list(Table) ++ "_ets"),
				ets:delete(EtsName, Key);
			Table =:= ai_agents ->
				EtsName = list_to_existing_atom(atom_to_list(Table) ++ "_ets"),
				Entry = Item#ai_agents.entry,
				ets:delete(EtsName, Entry);
			true ->
				nothing
		end,
		if 
			Table =:= creature_spawns ->
				delete_npc_from_map(Item);
			Table =:= npc_functions ->
				npc_function_frame:delete_npc_function(Item);
			true ->
				nothing
		end
	end, ItemList).

check_double_exp() ->
	AllActivities = [X || {_, X} <- top_bar_item_db:get_all_activity_info()],
	DoubleExpActivities = lists:filter(fun(ActivityInfo) ->
		Type = top_bar_item_db:get_activity_type(ActivityInfo),
		Type =:= ?ACTIVITY_DOUBLE_EXP
	end, AllActivities),
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	lists:any(fun(ActivityInfo) ->
		StartTime = top_bar_item_db:get_activity_start_time(ActivityInfo),
		EndTime = top_bar_item_db:get_activity_end_time(ActivityInfo),
		timer_util:is_in_time_point(StartTime, EndTime, Now)
	end, DoubleExpActivities).

hook_on_travel_match_start() ->
	ItemInfo = top_bar_item_db:get_item_info(?TOP_BAR_ITEM_TRAVEL_MATCH_1),
	Pos = top_bar_item_db:get_pos(ItemInfo),
	Msg = top_bar_item_packet:encode_top_bar_show_items_s2c(
		[#ac{id = ?TOP_BAR_ITEM_TRAVEL_MATCH_1, duration = -1, pos = Pos}]),
	role_pos_util:send_to_all_online_clinet(Msg).

hook_on_travel_match_stop() ->
	Msg = top_bar_item_packet:encode_top_bar_hide_items_s2c([?TOP_BAR_ITEM_TRAVEL_MATCH_1]),
	role_pos_util:send_to_all_online_clinet(Msg).

hook_on_travel_battle_start(Duration) ->
	ItemInfo = top_bar_item_db:get_item_info(?TOP_BAR_ITEM_TRAVEL_BATTLE),
	Pos = top_bar_item_db:get_pos(ItemInfo),
	Msg = top_bar_item_packet:encode_top_bar_show_items_s2c(
		[#ac{id = ?TOP_BAR_ITEM_TRAVEL_BATTLE, duration = Duration, pos = Pos}]),
	role_pos_util:send_to_all_online_clinet(Msg).

hook_on_travel_battle_stop() ->
	Msg = top_bar_item_packet:encode_top_bar_hide_items_s2c([?TOP_BAR_ITEM_TRAVEL_BATTLE]),
	role_pos_util:send_to_all_online_clinet(Msg).

hook_on_dead_valley_start(Duration) ->
	ItemInfo = top_bar_item_db:get_item_info(?TOP_BAR_ITEM_DEAD_VALLEY),
	Pos = top_bar_item_db:get_pos(ItemInfo),
	Msg = top_bar_item_packet:encode_top_bar_show_items_s2c(
		[#ac{id = ?TOP_BAR_ITEM_DEAD_VALLEY, duration = Duration, pos = Pos}]),
	role_pos_util:send_to_all_online_clinet(Msg).

hook_on_dead_valley_stop() ->
	Msg = top_bar_item_packet:encode_top_bar_hide_items_s2c([?TOP_BAR_ITEM_DEAD_VALLEY]),
	role_pos_util:send_to_all_online_clinet(Msg).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

update_role_activity_count(RoleId, Count, ActivityList, Now, Date) ->
	RoleCount = role_top_bar_item_db:get_role_count(RoleId),
	RoleCount2 = lists:foldl(fun({Id, AwardsType}, Acc) ->
		case lists:keyfind(Id, 1, Acc) of
			false ->
				[{Id, Now, Count} | Acc];
			{Id, Time, Count2} ->
				{Time3, Count3} = if
					AwardsType =:= ?ACTIVITY_AWARD_ONE_TIME_PER_DAY ->
						{Date2, _} = calendar:now_to_local_time(Time),
						if
							Date =:= Date2 ->
								{Time, Count + Count2};
							true ->
								{Now, Count}
						end;
					true ->
						{Time, Count + Count2}
				end,
				lists:keyreplace(Id, 1, Acc, {Id, Time3, Count3})
		end
	end, RoleCount, ActivityList),
	role_top_bar_item_db:save_role_count(RoleId, RoleCount2),
	RoleCount2.

do_special_for_role_activity_count(RoleId, ?ACTIVITY_CONSUMPTION, RoleCount, IdList, Now, Date) ->
	lists:foreach(fun({ActivityId, AwardsType}) ->
		{_, _, Count} = lists:keyfind(ActivityId, 1, RoleCount),
		ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
		ActivityCount = top_bar_item_db:get_activity_condition(ActivityInfo),
		if
			Count >= ActivityCount ->
				update_consumption_rank_info(RoleId, Count, ActivityId, AwardsType, Now, Date);
			true ->
				nothing
		end
	end, IdList);
do_special_for_role_activity_count(_, _, _, _, _, _) ->
	nothing.

update_consumption_rank_info(RoleId, Count, ActivityId, AwardsType, Now, Date) ->
	Key = make_activity_key(ActivityId),
	RoleCount2 = case role_top_bar_item_db:get_rank_list(Key) of
		[] ->
			{Now, [{RoleId, Count}]};
		{Time, CountList} ->
			Length = length(CountList),
			UpdateFun = fun() ->
				case lists:keyfind(RoleId, 1, CountList) of
					false ->
						if
							Length > 3 ->
								CountList2 = lists:sort(fun({_, CountA}, {_, CountB}) ->
										CountA < CountB
									end, CountList),
									[{RoleIdTmp, CountTmp} | CountList3] = CountList2,
									if
										Count > CountTmp ->
											{Time, [{RoleId, Count} | CountList3]};
										true ->
											{Time, CountList2}
									end;
								true ->
									{Time, [{RoleId, Count} | CountList]}
						end;
					_ ->
						{Time, lists:keyreplace(RoleId, 1, CountList, {RoleId, Count})}
				end
			end,			
			if
				AwardsType =:= ?ACTIVITY_AWARD_ONE_TIME_PER_DAY ->
					{Date2, _} = calendar:now_to_local_time(Time),
					if
						Date =:= Date2 ->
							UpdateFun();
						true ->
							{Now, [{RoleId, Count}]}
					end;
				true ->
					UpdateFun()
			end
	end,
	role_top_bar_item_db:save_rank_list(Key, RoleCount2).

do_check_activity_awards(RoleId, ActivityId, ?ACTIVITY_GOLD_EQUIPMENTS, ActivityInfo) ->
	RoleAwards = role_top_bar_item_db:get_role_awards(RoleId),
	case lists:keyfind(ActivityId, 1, RoleAwards) of
		false ->
			GoldEquipments = get_body_gold_equipment(),
			AwardsTemplate = top_bar_item_db:get_activity_awards(ActivityInfo),
			AwardsResult = [Awards || {Min, Max, Awards} <- AwardsTemplate, Min =< GoldEquipments, GoldEquipments =< Max],
			if
				AwardsResult =:= [] ->
					nothing;
				true ->
					[Awards | _] = AwardsResult,
					AwardsSendType = top_bar_item_db:get_activity_awards_send_type(ActivityInfo),
					send_role_awards_mail_with_content_param(Awards, ?ACTIVITY_GOLD_EQUIPMENTS, [GoldEquipments]),
					RoleAwards2 = [{ActivityId, 1} | RoleAwards],
					role_top_bar_item_db:save_role_awards(RoleId, RoleAwards2)
			end;
		_ ->
			nothing
	end;
do_check_activity_awards(RoleId, ActivityId, ?ACTIVITY_ALL_USER, ActivityInfo) ->
	do_do_check_activity_awards(RoleId, ActivityId,?ACTIVITY_ALL_USER, ActivityInfo);
do_check_activity_awards(RoleId, ActivityId,?ACTIVITY_FESTIVAL_OF_LANTERNS, ActivityInfo) ->
	do_do_check_activity_awards(RoleId, ActivityId,?ACTIVITY_FESTIVAL_OF_LANTERNS, ActivityInfo);

do_check_activity_awards(RoleId, ActivityId, ActivityType, ActivityInfo) ->
	RoleCount = role_top_bar_item_db:get_role_count(RoleId),
	case lists:keyfind(ActivityId, 1, RoleCount) of
		false ->
			nothing;
		{ActivityId, Time, Count} ->
			AwardsType = top_bar_item_db:get_activity_awards_type(ActivityInfo),
			Condition = top_bar_item_db:get_activity_condition(ActivityInfo),
			RoleAwards = role_top_bar_item_db:get_role_awards(RoleId),
			{AwardsTimes, AwardsFlag, AwardsCount} = case lists:keyfind(ActivityId, 1, RoleAwards) of
				false ->
					CheckResult = condition_check(ActivityType, Time, Count, AwardsType, Condition, []),
					{CheckResult, false, 0};
				{_, AwardsTime, AwardsCount2} ->
					CheckResult = condition_check(ActivityType, Time, Count, AwardsType, Condition, {AwardsTime, AwardsCount2}),
					{CheckResult, true, AwardsCount2}
			end,
			if
				AwardsTimes > 0 ->
					AwardsTemplate = top_bar_item_db:get_activity_awards(ActivityInfo),
					Awards = [{ItemId, C * AwardsTimes} || {ItemId, C} <- AwardsTemplate],
					AwardsSendType = top_bar_item_db:get_activity_awards_send_type(ActivityInfo),
					send_role_awards(Awards, ActivityType, AwardsSendType),
					RoleAwards2 = if
						AwardsFlag =:= true ->
							lists:keyreplace(ActivityId, 1, RoleAwards, {ActivityId, Time, AwardsCount + AwardsTimes});
						true ->
							[{ActivityId, Time, AwardsTimes} | RoleAwards]
					end,
					role_top_bar_item_db:save_role_awards(RoleId, RoleAwards2);
				true ->
					nothing
			end
	end.
do_do_check_activity_awards(RoleId, ActivityId, Activity_type, ActivityInfo) ->
	RoleAwards = role_top_bar_item_db:get_role_awards(RoleId),
	case lists:keyfind(ActivityId, 1, RoleAwards) of
		false ->
			RoleInfo = role_db:get_role_info(RoleId),
			RoleLevel = role_db:get_level(RoleInfo),
			ActivityLevel = top_bar_item_db:get_activity_condition(ActivityInfo),
			if 
				RoleLevel >= ActivityLevel ->
					Awards = top_bar_item_db:get_activity_awards(ActivityInfo),
					AwardsSendType = top_bar_item_db:get_activity_awards_send_type(ActivityInfo),
					send_role_awards(Awards, Activity_type, AwardsSendType);
				true ->
					nothing
			end,
			RoleAwards2 = [{ActivityId, 1} | RoleAwards],
			role_top_bar_item_db:save_role_awards(RoleId, RoleAwards2);
		_ ->
			nothing
	end.
check_item_valid(ItemInfo) ->
	Type = top_bar_item_db:get_type(ItemInfo),
	check_item_valid2(Type, ItemInfo).

check_item_valid2(?HOT_BAR_ITEM_PERMANENT, _) ->
	{true, -1};
check_item_valid2(?HOT_BAR_ITEM_CONDITION, ItemInfo) ->
	case top_bar_item_db:get_script(ItemInfo) of
		0 ->
			NowTime = calendar:now_to_local_time(timer_center:get_correct_now()),
			StartTime = top_bar_item_db:get_start_time(ItemInfo),
			EndTime = top_bar_item_db:get_end_time(ItemInfo),
			case timer_util:is_in_time_point(StartTime,EndTime,NowTime) of
				true ->
					{true, -1};
				false ->
					false
			end;
		Script ->
			try
				erlang:apply(?MODULE, Script, [ItemInfo])
			catch
				E : R ->
					slogger:msg("check_item_valid2 failed, E: ~p, R: ~p, ~p~n", [E, R, erlang:get_stacktrace()]),
					false
			end
	end;
check_item_valid2(?HOT_BAR_ITEM_INSTANCE_NORMAL, ItemInfo) ->
	InstanceProtoId = top_bar_item_db:get_script(ItemInfo),
	ProtoInfo = instance_proto_db:get_info(InstanceProtoId),
	{LevelMin,LevelMax} = instance_proto_db:get_level(ProtoInfo),
	Level = get(level),
	if
		Level >= LevelMin, Level =< LevelMax ->
			{true, -1};
		true ->
			false
	end;
check_item_valid2(?HOT_BAR_ITEM_INSTANCE_LOOP, ItemInfo) ->
	InstanceProtoId = top_bar_item_db:get_script(ItemInfo),
	ProtoInfo = loop_instance_db:get_loop_instance_info(InstanceProtoId),
	LevelLimit = loop_instance_db:get_levellimit(ProtoInfo),
	Level = get(level),
	if
		Level >= LevelLimit ->
			{true, -1};
		true ->
			false
	end;
check_item_valid2(_, _) ->
	false.

check_awards_send(RoleId, ActivityId, TypeList) ->
	ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
	AwardsTime = top_bar_item_db:get_activity_awards_time(ActivityInfo),
	case lists:member(AwardsTime, TypeList) of
		true ->
			awards_send(RoleId, ActivityId, ActivityInfo);
		false ->
			nothing
	end.

awards_send(RoleId, ActivityId, ActivityInfo) ->
	Type = top_bar_item_db:get_activity_type(ActivityInfo),
	awards_send_type(RoleId, Type, ActivityId, ActivityInfo).

awards_send_type(_, ?ACTIVITY_REWARD_ARM, _, ActivityInfo) ->
	RankList = get_rank_list_by_type(?RANK_TYPE_FIGHTING_FORCE),
	activity_reward_arm_send(ActivityInfo, RankList);
awards_send_type(_, ?ACTIVITY_FIGHT_FORCE_RANK, _, ActivityInfo) ->
	RankList = get_rank_list_by_type(?RANK_TYPE_FIGHTING_FORCE),
	do_awards_send_type(?ACTIVITY_FIGHT_FORCE_RANK, RankList, ActivityInfo);
awards_send_type(_, ?ACTIVITY_LEVEL_RANK, _, ActivityInfo) ->
	RankList = get_rank_list_by_type(?RANK_TYPE_ROLE_LEVEL),
	do_awards_send_type(?ACTIVITY_LEVEL_RANK, RankList, ActivityInfo);
awards_send_type(_, ?ACTIVITY_CONSUMPTION, ActivityId, ActivityInfo) ->
	RankList = get_rank_list_by_type(?ACTIVITY_CONSUMPTION, ActivityId),
	do_awards_send_type(?ACTIVITY_CONSUMPTION, RankList, ActivityInfo);
awards_send_type(RoleId, _, ActivityId, ActivityInfo) ->
	%% mail or package
	AwardsSendType = top_bar_item_db:get_activity_awards_send_type(ActivityInfo),
	if
		AwardsSendType =:= ?ACTIVITY_AWARD_MAIL;
		AwardsSendType =:= ?ACTIVITY_AWARD_PACKAGE ->
			if
				RoleId =:= all ->
					role_pos_util:send_to_all_role({check_activity_awards, ActivityId});
				true ->
					role_pos_util:send_to_role(RoleId, {check_activity_awards, ActivityId})
			end;
		true ->
			nothing
	end.

do_awards_send_type(Type, RankList, ActivityInfo) ->
	RankList2 = lists:sort(fun({_, A, _}, {_, B, _}) ->
		A > B
	end, RankList),
	AwardsInfo = top_bar_item_db:get_activity_awards(ActivityInfo),
	lists:foldl(fun({{_, RoleId}, _, _}, Acc) ->
		RoleInfo = role_db:get_role_info(RoleId),
		RoleName = role_db:get_name(RoleInfo),
		FromName = language:get_string(?STR_SYSTEM),
		Title = get_mail_title(Type),
	    Content = get_mail_content(Type, [Acc]),
	    Info = [Awards || {Min, Max, Awards} <- AwardsInfo, Min =< Acc, Acc =< Max],
	    if
	    	Info =:= [] ->
	    		nothing;
	    	true ->
	    		[AwardsList | _] = Info,
	    		mail_op:gm_send_multi_2(FromName,RoleName,Title,Content,AwardsList,0)
	    end,
		Acc + 1
	end, 1, RankList2).

get_rank_list_by_type(_, ActivityId) ->
	Key = make_activity_key(ActivityId),
	case role_top_bar_item_db:get_rank_list(Key) of
		[] ->
			[];
		{Time, CountList} ->
			[{RoleId, Count, Time} || {RoleId, Count} <- CountList]
	end.

get_rank_list_by_type(Type1) ->
	DbData = game_rank_db:load_from_db(),
	lists:foldl(fun({{Type,_},_,_} = X, Acc) ->
		if
			Type =:= Type1 ->
				[X | Acc];
			true ->
				Acc
		end
	end, [], DbData).

get_mail_title(?ACTIVITY_REWARD_ARM) ->
	language:get_string(?STR_ACTIVITY_REWARD_ARM_TITLE);
get_mail_title(?ACTIVITY_FIGHT_FORCE_RANK) ->
	language:get_string(?STR_ACTIVITY_FIGHT_FORCE_RANK_TITLE);
get_mail_title(?ACTIVITY_LEVEL_RANK) ->
	language:get_string(?STR_ACTIVITY_LEVEL_RANK_TITLE);
get_mail_title(?ACTIVITY_CONSUMPTION) ->
	language:get_string(?STR_ACTIVITY_CONSUMPTION_TITLE);
get_mail_title(?ACTIVITY_CHARGE) ->
	language:get_string(?STR_ACTIVITY_CHARGE_TITLE);
get_mail_title(?ACTIVITY_LOTTERY) ->
	language:get_string(?STR_ACTIVITY_LOTTERY_TITLE);
get_mail_title(?ACTIVITY_ALL_USER) ->
	language:get_string(?STR_ACTIVITY_ALL_USER_TITLE);
get_mail_title(?ACTIVITY_FESTIVAL_OF_LANTERNS) ->
	language:get_string(?STR_ACTIVITY_FESTIVAL_OF_LANTERNS_TITLE);
get_mail_title(?ACTIVITY_GOLD_EQUIPMENTS) ->
	language:get_string(?STR_ACTIVITY_GOLD_EQUIPMENTS_TITLE).

get_mail_content(?ACTIVITY_REWARD_ARM,_) ->
	language:get_string(?STR_ACTIVITY_REWARD_ARM_CONTENT);
get_mail_content(?ACTIVITY_FIGHT_FORCE_RANK, Param) ->
	util:sprintf(language:get_string(?STR_ACTIVITY_FIGHT_FORCE_RANK_CONTENT), Param);
get_mail_content(?ACTIVITY_LEVEL_RANK, Param) ->
	util:sprintf(language:get_string(?STR_ACTIVITY_LEVEL_RANK_CONTENT), Param);
get_mail_content(?ACTIVITY_CONSUMPTION, _) ->
	language:get_string(?STR_ACTIVITY_CONSUMPTION_CONTENT);
get_mail_content(?ACTIVITY_CHARGE, _) ->
	language:get_string(?STR_ACTIVITY_CHARGE_CONTENT);
get_mail_content(?ACTIVITY_LOTTERY, _) ->
	language:get_string(?STR_ACTIVITY_LOTTERY_CONTENT);
get_mail_content(?ACTIVITY_ALL_USER, _) ->
	language:get_string(?STR_ACTIVITY_ALL_USER_CONTENT);
get_mail_content(?ACTIVITY_FESTIVAL_OF_LANTERNS, _) ->
	language:get_string(?STR_ACTIVITY_FESTIVAL_OF_LANTERNS_CONTENT);
get_mail_content(?ACTIVITY_GOLD_EQUIPMENTS, Param) ->
	util:sprintf(language:get_string(?STR_ACTIVITY_GOLD_EQUIPMENTS_CONTENT), Param).

condition_check(ActivityType, _, Count, AwardsType, Condition, []) ->
	case condition_check_detail(ActivityType, Count, Condition, 0) of
		LeftTimes when LeftTimes > 1 ->
			if 
				AwardsType =:= ?ACTIVITY_AWARD_MANY_TIMES ->
					LeftTimes;
				true ->
					1
			end;
		LeftTimes ->
			LeftTimes
	end;
condition_check(ActivityType, Time, Count, AwardsType, Condition, {AwardsTime, AwardsCount}) ->
	case AwardsType of
		?ACTIVITY_AWARD_ONE_TIME ->
			0;
		?ACTIVITY_AWARD_MANY_TIMES ->
			condition_check_detail(ActivityType, Count, Condition, AwardsCount);
		?ACTIVITY_AWARD_ONE_TIME_PER_DAY ->
			Now = timer_center:get_correct_now(),
			{Date, _} = calendar:now_to_local_time(Now),
			{Date2, _} = calendar:now_to_local_time(AwardsTime),
			TimeCheck = if
				Date =:= Date2 ->
					false;
				true ->
					{Date3, _} = calendar:now_to_local_time(Time),
					if
						Date =:= Date3 ->
							true;
						true ->
							false
					end
			end,
			if
				TimeCheck ->
					condition_check_detail(ActivityType, Count, Condition, 0);
				true ->
					0
			end;
		_ ->
			0
	end.

condition_check_detail(ActivityType, Count, Condition, Times) ->
	LeftTimes = Count div Condition - Times,
	if
		LeftTimes >= 0 ->
			LeftTimes;
		true ->
			0
	end.

send_role_awards(Awards, ActivityType, ?ACTIVITY_AWARD_MAIL) ->
	send_role_awards_mail_with_content_param(Awards, ActivityType, []);
send_role_awards(Awards, ActivityType, ?ACTIVITY_AWARD_PACKAGE) ->
	case package_op:can_added_to_package_template_list(Awards) of
        false ->
            send_role_awards(Awards, ActivityType, ?ACTIVITY_AWARD_MAIL);
        true ->
            lists:foreach(fun({Gift, Count}) ->
               role_op:auto_create_and_put(Gift, Count, activity_awards) end, Awards)
    end.

send_role_awards_mail_with_content_param(Awards, ActivityType, Param) ->
	RoleInfo = get(creature_info),
	RoleName = creature_op:get_name_from_creature_info(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = get_mail_title(ActivityType),
    Content = get_mail_content(ActivityType, Param),
    mail_op:gm_send_multi_2(FromName,RoleName,Title,Content,Awards,0).

get_body_gold_equipment()->
    BodyItemsId = package_op:get_body_items_id(),
    MatchFun = fun(ItemId,Acc)->
        case items_op:get_item_info(ItemId) of
            []->
                Acc;
            ItemInfo->
                ItemCless = get_class_from_iteminfo(ItemInfo),
                if ItemCless =:= ?ITEM_TYPE_RIDE ->
                       Acc;
                   true->
                       Quality = items_op:get_qualty_from_iteminfo(ItemInfo),
                       case Quality >= ?EQUIP_TYPE_GOLD of
                           true->
                               Acc + 1;
                           false->
                               Acc
                       end
                end
        end
	end,
    lists:foldl(MatchFun, 0, BodyItemsId).

show_activities([]) ->
	nothing;
show_activities(Activities) ->
	TopBarItems = lists:foldl(fun(ActivityId, Acc) ->
		ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
		ItemId = top_bar_item_db:get_activity_bar_item(ActivityInfo),
		case lists:keyfind(ItemId, 2, Acc) of
			false ->
				ItemInfo = top_bar_item_db:get_item_info(ItemId),
				Pos = top_bar_item_db:get_pos(ItemInfo),
				[#ac{id = ItemId, duration = -1, pos = Pos} | Acc];
			_ ->
				Acc
		end
	end, [], Activities),
	Msg = top_bar_item_packet:encode_top_bar_show_items_s2c(TopBarItems),
	role_pos_util:send_to_all_online_clinet(Msg).

show_activities([],RoleId) ->
	nothing;
show_activities(Activities,RoleId) ->
	TopBarItems = lists:foldl(fun(ActivityId, Acc) ->
		ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
		ItemId = top_bar_item_db:get_activity_bar_item(ActivityInfo),
		case lists:keyfind(ItemId, 2, Acc) of
			false ->
				ItemInfo = top_bar_item_db:get_item_info(ItemId),
				Pos = top_bar_item_db:get_pos(ItemInfo),
				[pb_util:key_value(ItemId, Pos) | Acc];
			_ ->
				Acc
		end
	end, [], Activities),
	Msg = top_bar_item_packet:encode_top_bar_show_items_s2c(TopBarItems),
	role_pos_util:send_to_role_clinet(RoleId, Msg).

hide_activities([]) ->
	nothing;
hide_activities(Activities) ->
	TopBarItems = lists:map(fun(ActivityId) ->
		ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
		top_bar_item_db:get_activity_bar_item(ActivityInfo)
	end, Activities),
	Msg = top_bar_item_packet:encode_top_bar_hide_items_s2c(sets:to_list(sets:from_list(TopBarItems))),
	role_pos_util:send_to_all_online_clinet(Msg).

make_activity_key(ActivityId) ->
	integer_to_list(env:get(serverid, 0)) ++ "_" ++ integer_to_list(ActivityId).

do_get_activity_awards(ActivityId, ActivityInfo) ->
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	RoleCount = role_top_bar_item_db:get_role_count(RoleId),
	case lists:keyfind(ActivityId, 1, RoleCount) of
		false ->
			?ERROR_TEMP_ACTIVITY_CONDITION_CHECK_FAILED;
		{ActivityId, Time, Count} ->
			AwardsType = top_bar_item_db:get_activity_awards_type(ActivityInfo),
			Condition = top_bar_item_db:get_activity_condition(ActivityInfo),
			ActivityType = top_bar_item_db:get_activity_type(ActivityInfo),
			RoleAwards = role_top_bar_item_db:get_role_awards(RoleId),
			{AwardsTimes, AwardsFlag, AwardsCount} = case lists:keyfind(ActivityId, 1, RoleAwards) of
				false ->
					CheckResult = condition_check(ActivityType, Time, Count, AwardsType, Condition, []),
					{CheckResult, false, 0};
				{_, AwardsTime, AwardsCount2} ->
					CheckResult = condition_check(ActivityType, Time, Count, AwardsType, Condition, {AwardsTime, AwardsCount2}),
					{CheckResult, true, AwardsCount2}
			end,
			if
				AwardsTimes > 0 ->
					AwardsTemplate = top_bar_item_db:get_activity_awards(ActivityInfo),
					Awards = [{ItemId, C * AwardsTimes} || {ItemId, C} <- AwardsTemplate],
					case package_op:can_added_to_package_template_list(Awards) of
				        false ->
				            ?ERROR_PACKAGE_FULL;
				        true ->
				        	RoleAwards2 = if
								AwardsFlag =:= true ->
									lists:keyreplace(ActivityId, 1, RoleAwards, {ActivityId, Time, AwardsCount + AwardsTimes});
								true ->
									[{ActivityId, Time, AwardsTimes} | RoleAwards]
							end,
							role_top_bar_item_db:save_role_awards(RoleId, RoleAwards2),
				            lists:foreach(fun({Gift, Num}) ->
				               role_op:auto_create_and_put(Gift, Num, temp_activity_awards) end, Awards)
				    end;
				true ->
					?ERROR_TEMP_ACTIVITY_CONDITION_CHECK_FAILED
			end
	end.

duration_activity_start(ActivityId) ->
	ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
	AwardsTime = top_bar_item_db:get_activity_awards_time(ActivityInfo),
	if
		AwardsTime =:= ?ACTIVITY_AWARD_DURATION	->
			ActivityType = top_bar_item_db:get_activity_type(ActivityInfo),
			duration_activity_type_start(ActivityType, ActivityInfo);
		true ->
			nothing
	end.

duration_activity_stop(ActivityId) ->
	ActivityInfo = top_bar_item_db:get_activity_info(ActivityId),
	AwardsTime = top_bar_item_db:get_activity_awards_time(ActivityInfo),
	if
		AwardsTime =:= ?ACTIVITY_AWARD_DURATION	->
			ActivityType = top_bar_item_db:get_activity_type(ActivityInfo),
			duration_activity_type_stop(ActivityType, ActivityInfo);
		true ->
			nothing
	end.

duration_activity_type_start(?ACTIVITY_MALL_UP_SALE, ActivityInfo) ->
	Awards = top_bar_item_db:get_activity_awards(ActivityInfo),
	gm_notice_checker:update_mall_sale_items(Awards);

duration_activity_type_start(?ACTIVITY_DOUBLE_EXP, _) ->
	role_pos_util:send_to_all_role({double_exp_start});
duration_activity_type_start(?ACTIVITY_GOD_TREE, ActivityInfo) ->
	god_tree_db:change_time(1),
	god_tree_db:save_to_db(),
	god_tree_op:init();
duration_activity_type_start(_, ActivityInfo) ->
	Awards = top_bar_item_db:get_activity_awards(ActivityInfo),
	add_config_to_db(Awards),
	OtherMapNode = node_util:get_mapnodes() -- [node()],
	lists:foreach(fun(MapNode) ->
		rpc:call(MapNode, ?MODULE, add_config_to_ets, [Awards])
	end, OtherMapNode),
	add_config_to_ets(Awards).

duration_activity_type_stop(?ACTIVITY_MALL_UP_SALE, _) ->
	gm_notice_checker:clear_mall_sale_items();

duration_activity_type_stop(?ACTIVITY_DOUBLE_EXP, _) ->
	role_pos_util:send_to_all_role({double_exp_end});
duration_activity_type_stop(?ACTIVITY_GOD_TREE, _) ->
	god_tree_db:change_time(0),
	god_tree_db:save_to_db(),
	god_tree_op:init(),
	god_tree_db:clear_storage();
duration_activity_type_stop(_, ActivityInfo) ->
	Awards = top_bar_item_db:get_activity_awards(ActivityInfo),
	delete_config_to_db(Awards),
	OtherMapNode = node_util:get_mapnodes() -- [node()],
	lists:foreach(fun(MapNode) ->
		rpc:call(MapNode, ?MODULE, delete_config_to_ets, [Awards])
	end, OtherMapNode),
	delete_config_to_ets(Awards).

add_config_to_db(ItemList) ->
	[dal:write_rpc(X) || X <- ItemList].

delete_config_to_db(ItemList) ->
	[begin Table = element(1, X), 
		Key = element(2, X), 
		dal:delete_rpc(Table, Key) end
		|| X <- ItemList].

create_npc_now(NpcInfo) ->
	LineId = get_match_line_id(),
	MapId = NpcInfo#creature_spawns.mapid,
	NpcId = NpcInfo#creature_spawns.id,
	MapName = map_manager:make_map_process_name(LineId, MapId),
	CreatorTag = {?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM},
	NpcManagerProc = npc_manager:make_npc_manager_proc(MapName),
	npc_manager:add_npc_by_option(NpcManagerProc,NpcId,LineId,MapId,NpcInfo,CreatorTag).

get_match_line_id() ->
	Node = node(),
	[LineId | _] = lists:filter(fun(Id) ->
		node_util:check_match_map_and_line(Node,Id)
	end, env:get(lines, [])),
	LineId.

delete_npc_from_map(NpcInfo) ->
	LineId = get_match_line_id(),
	MapId = NpcInfo#creature_spawns.mapid,
	NpcId = NpcInfo#creature_spawns.id,
	MapName = map_manager:make_map_process_name(LineId, MapId),
	NpcManagerProc = npc_op:make_npcinfo_db_name(MapName),
	CreatureInfo = npc_manager:get_npcinfo(NpcManagerProc, NpcId),
	Pid = creature_op:get_pid_from_creature_info(CreatureInfo),
	gs_rpc:cast(Pid,{forced_leave_map}).

activity_reward_arm_send(ActivityInfo, RankList) ->
	RankList2 = lists:sort(fun({_, A, _}, {_, B, _}) ->
		A > B
	end, RankList),
	[Award1,Award2,Award3] = top_bar_item_db:get_activity_awards(ActivityInfo),
	[D,E,F] = get_top(0,0,0,0,0,0,RankList2),
	Title = get_mail_title(?ACTIVITY_REWARD_ARM),
	Content = get_mail_content(?ACTIVITY_REWARD_ARM,[]),
	FromName = language:get_string(?STR_SYSTEM),
	lists:map(fun({Name,{Award,Count}}) ->
		if
			Name =:= 0 ->
				nothing;
			true ->
				mail_op:gm_send_multi_2(FromName,Name,Title,Content,[{Award,Count}],0)
		end
	end, [{D,Award1},{E,Award2},{F,Award3}]).

get_top(1,1,1,D,E,F,_) ->
	[D,E,F];
get_top(A,B,C,D,E,F,Rank) ->
	if
		length(Rank) =:= 0 ->
			get_top(1,1,1,D,E,F,nothing);
		true ->
			[{{_, RoleId}, FightingForce, _}|Rank1] = Rank,
			RoleInfo = role_db:get_role_info(RoleId),
			RoleName = role_db:get_name(RoleInfo),
			RoleClass = role_db:get_class(RoleInfo),
			case RoleClass of
				?CLASS_MAGIC ->
					if
						A =:= 0->
							if
								FightingForce >= 12000 ->
									D1 = RoleName;
								true ->
									D1 = 0
							end,
							get_top(1,B,C,D1,E,F,Rank1);
						true ->
							get_top(1,B,C,D,E,F,Rank1)
					end;
				?CLASS_RANGE ->
					if
						B =:= 0->
							if
								FightingForce >= 12000 ->
									E1 = RoleName;
								true ->
									E1 = 0
							end,
							get_top(A,1,C,D,E1,F,Rank1);
						true ->
							get_top(A,1,C,D,E,F,Rank1)
					end;
				?CLASS_MELEE ->
					if
						C =:= 0->
							if
								FightingForce >= 12000 ->
									F1 = RoleName;
								true ->
									F1 = 0
							end,
							get_top(A,B,1,D,E,F1,Rank1);
						true ->
							get_top(A,B,1,D,E,F,Rank1)
					end;
				_ ->
					nothing
			end

	end.
	
check_open_server_activities() ->
	ServerStartTime = util:get_server_start_time(),
	StartSecs = calendar:datetime_to_gregorian_seconds(ServerStartTime),
	ActivityStartSecs = StartSecs - 2 * 24 * 60 * 60,
	ActivityEndSecs = StartSecs + 3 * 24 * 60 * 60,
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	if
		ActivityStartSecs =< NowSecs, NowSecs =< ActivityEndSecs ->
			ActivityStartTime = calendar:gregorian_seconds_to_datetime(ActivityStartSecs),
			ActivityEndTime = calendar:gregorian_seconds_to_datetime(ActivityEndSecs),
			top_bar_item_db:load_open_or_combine_activities(?TOP_BAR_ITEM_OPEN_SERVER, ActivityStartTime, ActivityEndTime);
		true ->
			nothing
	end.

check_combine_server_activities() ->
	ServerCombineTime = util:get_server_combine_time(),
	StartSecs = calendar:datetime_to_gregorian_seconds(ServerCombineTime),
	ActivityStartSecs = StartSecs - 1 * 24 * 60 * 60,
	ActivityEndSecs = StartSecs + 3 * 24 * 60 * 60,
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	if
		ActivityStartSecs =< NowSecs, NowSecs =< ActivityEndSecs ->
			ActivityStartTime = calendar:gregorian_seconds_to_datetime(ActivityStartSecs),
			ActivityEndTime = calendar:gregorian_seconds_to_datetime(ActivityEndSecs),
			top_bar_item_db:load_open_or_combine_activities(?TOP_BAR_ITEM_COMBINE_SERVER, ActivityStartTime, ActivityEndTime),
			top_bar_item_db:load_open_or_combine_activities(?TOP_BAR_ITEM_LOTTERY, ActivityStartTime, ActivityEndTime);
		true ->
			nothing
	end.