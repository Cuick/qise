-module (travel_match_single_manager_op).

-include ("travel_match_def.hrl").
-include ("error_msg.hrl").
-include ("string_define.hrl").

-export ([init/0, stage_start/1, stage_forecast_end/1, stage_end/1, stage_forecast_start/1,
	broadcast_register_start/0, broadcast_register_forecast_end/0, broadcast_register_end/0,
	broadcast_battle_start/1, broadcast_enter_wait_map_start/1, notify_enter_wait_map_forecast_end/1,
	notify_match_end/0, register/6, do_return_back_register_cost/2, notify_register_success/3,
	query_wait_map_info/1, broadcast_wait_map_forecast_end/1, query_role_info/1, 
	update_match_result/2, do_send_participation_awards/4, do_send_final_awards/5,
	do_send_promotion/4, do_send_loss/4, query_unit_player_list/1, query_session_data/2]).


-record (single_match_stage_info, {stage,state,total,level_stat}).

init() ->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{RegisterStartTime, RegisterEndTime} = get_register_datetime(Now),
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds(RegisterStartTime),
	EndSecs = calendar:datetime_to_gregorian_seconds(RegisterEndTime),
	check_stage_start(register, NowSecs, StartSecs),
	check_stage_forecast_end(register, NowSecs, EndSecs),
	check_stage_end(register, NowSecs, EndSecs),
	put(single_match_stage_info, #single_match_stage_info{stage = register,
		state = ?TRAVEL_MATCH_STATE_NOT_START, total = 0, level_stat = []}).

stage_start(register) ->
	travel_battle_util:cast_for_all_server(?MODULE, broadcast_register_start, []),
	clear_last_session_data(),
	update_stage_and_state(register, ?TRAVEL_MATCH_STATE_GOING);
stage_start(Stage) when Stage =:= audition; Stage =:= trial; Stage =:= replay; 
	Stage =:= semifinal; Stage =:= final ->
	travel_battle_util:cast_for_all_server(?MODULE, broadcast_battle_start, 
		[get_stage_num(Stage)]),
	transfer_all_user_to_battle(),
	update_stage_and_state(Stage, ?TRAVEL_MATCH_STATE_GOING);
stage_start(_) ->
	nothing.

stage_forecast_start(Stage) when Stage =:= audition; Stage =:= trial; Stage =:= replay; 
	Stage =:= semifinal; Stage =:= final ->
	% %% 为每个小组建立等待地图
	create_all_wait_maps(Stage),
	travel_battle_util:cast_for_all_server(?MODULE, broadcast_enter_wait_map_start, 
		[get_stage_num(Stage)]),
	update_stage_and_state(Stage, ?TRAVEL_MATCH_STATE_READY),
	erlang:send_after(5 * 60 * 1000, self(), {single_match_enter_wait_map_forecast_end, 
		get_stage_num(Stage)});
stage_forecast_start(_) ->
	nothing.

stage_end(register) ->
	travel_battle_util:cast_for_all_server(?MODULE, broadcast_register_end, []),
	update_stage_and_state(register, ?TRAVEL_MATCH_STATE_END),
	%% 分组并邮件通知，计算奖金数值
	divide_into_units_and_compute_awards(),
	case check_next_stage() of
		true ->
			wait_next_stage(register);
		false ->
			init()
	end;
stage_end(Stage) when Stage =:= audition; Stage =:= trial; Stage =:= replay; 
	Stage =:= semifinal; Stage =:= final ->
	update_stage_and_state(Stage, ?TRAVEL_MATCH_STATE_END),
	%% 销毁等待地图进程
	stop_all_wait_maps(),
	%% 每场结算
	summary_on_stage_end(Stage),
	wait_next_stage(Stage);
stage_end(_) ->
	nothing.

stage_forecast_end(register) ->
	travel_battle_util:cast_for_all_server(?MODULE, broadcast_register_forecast_end, []);
stage_forecast_end(_) ->
	nothing.

broadcast_register_start() ->
	top_bar_manager:hook_on_travel_match_start(),
	Msg = travel_match_packet:encode_travel_match_register_start_s2c(?TRAVEL_MATCH_TYPE_SINGLE),
    role_pos_util:send_to_all_online_clinet(Msg).

broadcast_register_forecast_end() ->
	Msg = travel_match_packet:encode_travel_match_register_forecast_end_s2c(?TRAVEL_MATCH_TYPE_SINGLE),
    role_pos_util:send_to_all_online_clinet(Msg).

broadcast_register_end() ->
	Msg = travel_match_packet:encode_travel_match_register_end_s2c(?TRAVEL_MATCH_TYPE_SINGLE),
    role_pos_util:send_to_all_online_clinet(Msg).

broadcast_battle_start(Stage) ->
	Msg = travel_match_packet:encode_travel_match_battle_start_s2c(?TRAVEL_MATCH_TYPE_SINGLE, Stage),
    role_pos_util:send_to_all_online_clinet(Msg).

broadcast_enter_wait_map_start(Stage) ->
	Msg = travel_match_packet:encode_travel_match_enter_wait_map_start_s2c(?TRAVEL_MATCH_TYPE_SINGLE, Stage),
    role_pos_util:send_to_all_online_clinet(Msg).

notify_enter_wait_map_forecast_end(Stage) ->
	travel_battle_util:cast_for_all_server(?MODULE, broadcast_wait_map_forecast_end, [Stage]).

broadcast_wait_map_forecast_end(Stage) ->
	Msg = travel_match_packet:encode_travel_match_enter_wait_map_forecast_end_s2c(
		?TRAVEL_MATCH_TYPE_SINGLE, Stage),
    role_pos_util:send_to_all_online_clinet(Msg).

notify_match_end() ->
	%% 通知图标消失
	top_bar_manager:hook_on_travel_match_stop().

register(RoleId, RoleName, Gender, Class, Level, FightForce) ->
	MatchStageInfo = get(single_match_stage_info),
	LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
	[{LevelZone, Num, _} | _] = lists:filter(fun({{MinLevel, MaxLevel},
		_, _}) ->
		MinLevel =< Level andalso Level =< MaxLevel
	end, LevelStat),
	MatchLevel = travel_match_db:get_type_level_info2(?
		TRAVEL_MATCH_TYPE_SINGLE, LevelZone),
	Limit = travel_match_db:get_type_level_limit(MatchLevel),
	if
		Num =< Limit ->
			case role_travel_match_db:get_register_info(RoleId) of
				[] ->
					role_travel_match_db:save_register_info(RoleId, 
						RoleName, Gender, Class, Level, FightForce),
					update_register_stat(Level),
					ok;
				_->
					{error, ?TRAVEL_MATCH_REGISTER_TWICE}
			end;
		true ->
			{error, ?TRAVEL_MATCH_LEVEL_COUNT_LIMIT}
	end.

do_return_back_register_cost(RoleId, Level) ->
	RoleInfo = role_db:get_role_info(RoleId),
	RoleName = role_db:get_name(RoleInfo),
	MatchLevel = travel_match_db:get_type_level_info(?TRAVEL_MATCH_TYPE_SINGLE, Level),
	Cost = travel_match_db:get_type_level_cost(MatchLevel),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_TRAVEL_MATCH_RETUREN_BACK_REGISTER_COST_TITLE),
	Content = util:sprintf(language:get_string(?STR_TRAVEL_MATCH_RETUREN_BACK_REGISTER_COST_CONTENT), [Cost]),
	mail_op:gm_send_with_gold(FromName, RoleName, Title, Content, 0, 0, 0, Cost).

notify_register_success(RoleId, LevelZone, _) ->
	RoleInfo = role_db:get_role_info(RoleId),
	RoleName = role_db:get_name(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_TRAVEL_MATCH_REGISTER_SUCCESS_TITLE),
	{MinLevel, MaxLevel} = LevelZone,
	Content = util:sprintf(language:get_string(?STR_TRAVEL_MATCH_REGISTER_SUCCESS_CONTENT), [MinLevel, MaxLevel]),
	mail_op:gm_send(FromName, RoleName, Title, Content, 0, 0, 0).

query_wait_map_info(RoleId) ->
	case role_travel_match_db:get_match_result(RoleId) of
		[] -> 
			{error, ?TRAVEL_MATCH_NOT_REGISTER};
		MatchResult ->
			case can_enter_wait_map() of
				true ->
					do_query_wait_map_info(MatchResult);
				false ->
					{error, ?TRAVEL_MATCH_NOT_WAIT_MAP_TIME}
			end
	end.

query_role_info(RoleId) ->
	MatchStageInfo = get(single_match_stage_info),
	Stage = MatchStageInfo#single_match_stage_info.stage,
	State = MatchStageInfo#single_match_stage_info.state,
	Status = if
		State =:= ?TRAVEL_MATCH_STATE_READY ->
			Now = calendar:now_to_local_time(timer_center:get_correct_now()),
			{{Y, M, D}, _} = Now,
			MatchStage = travel_match_db:get_match_stage_info(
				?TRAVEL_MATCH_TYPE_SINGLE, Stage),
			{Day, StartTime, _} = travel_match_db:get_stage_time_line(MatchStage),
			NowSecs = calendar:datetime_to_gregorian_seconds(Now),
			StartSecs = calendar:datetime_to_gregorian_seconds({{Y, M, Day}, StartTime}),
			StartSecs - NowSecs;
		true ->
			State
	end,
	{RegisterStatus, Rank, Details, Awards} = 
		case role_travel_match_db:get_register_info(RoleId) of
		[] ->
			{?TRAVEL_MATCH_NOT_REGISTERED, ?TRAVEL_MATCH_RANK_WAIT,
				[], #level_awards{}};
		_ ->
			{Rank2, LevelZone, Details2} = get_match_result_info(
				RoleId, Stage, Status),
			LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
			Awards2 = case lists:keyfind(LevelZone, 1, LevelStat) of
				false ->
					#level_awards{};
				{_, _, Awards3} ->
					Awards3
			end,
			{?TRAVEL_MATCH_REGITSER_OK, Rank2, Details2, Awards2}
	end,
	{ok, get_stage_num(Stage), Status, Rank, Awards, Details, RegisterStatus}.

update_match_result(RoleId, Points) ->
	MatchStageInfo = get(single_match_stage_info),
	Stage = MatchStageInfo#single_match_stage_info.stage,
	MatchResult = role_travel_match_db:get_match_result(RoleId),
	LevelZone = role_travel_match_db:get_match_result_level(MatchResult),
	MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
	{_, Unit, _, Rank} = lists:keyfind(Stage, 1, MatchInfo),
	MatchInfo2 = lists:keyreplace(Stage, 1, MatchInfo, {Stage, Unit, Points, Rank}),
	role_travel_match_db:save_match_result(RoleId, LevelZone, MatchInfo2).

do_send_participation_awards(RoleId, Stage, LevelZone, Awards) ->
	RoleInfo = role_db:get_role_info(RoleId),
	RoleName = role_db:get_name(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_TRAVEL_MATCH_PARTICIPATION_AWARDS_TITLE),
	{MinLevel, MaxLevel} = LevelZone,
	StageName = get_stage_name(Stage),
	Content = util:sprintf(language:get_string(?STR_TRAVEL_MATCH_PARTICIPATION_AWARDS_CONTENT), 
		[MinLevel, MaxLevel, StageName]),
	mail_op:gm_send_multi_2(FromName, RoleName, Title, Content, Awards, 0).

do_send_final_awards(RoleId, LevelZone, Rank, AwardsRank, Gold) ->
	RoleInfo = role_db:get_role_info(RoleId),
	RoleName = role_db:get_name(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_TRAVEL_MATCH_FINAL_RANK_AWARDS_TITLE),
	{MinLevel, MaxLevel} = LevelZone,
	Content = util:sprintf(language:get_string(?STR_TRAVEL_MATCH_FINAL_RANK_AWARDS_CONTENT), 
		[MinLevel, MaxLevel, Rank, Gold]),
	mail_op:gm_send_multi_2_with_gold(FromName,RoleName,Title,Content,AwardsRank,0,Gold).

do_send_promotion(RoleId, LevelZone, NextStage, UnitNo) ->
	RoleInfo = role_db:get_role_info(RoleId),
	RoleName = role_db:get_name(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_TRAVEL_MATCH_STAGE_PROMOTION_TITLE),
	{MinLevel, MaxLevel} = LevelZone,
	StageName = get_stage_name(NextStage),
	Content = util:sprintf(language:get_string(?STR_TRAVEL_MATCH_STAGE_PROMOTION_CONTENT), 
		[MinLevel, MaxLevel, StageName]),
	mail_op:gm_send(FromName, RoleName, Title, Content, 0, 0, 0).

do_send_loss(RoleId, Stage, LevelZone, Rank) ->
	RoleInfo = role_db:get_role_info(RoleId),
	RoleName = role_db:get_name(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_TRAVEL_MATCH_STAGE_LOSS_TITLE),
	{MinLevel, MaxLevel} = LevelZone,
	StageName = get_stage_name(Stage),
	Content = util:sprintf(language:get_string(?STR_TRAVEL_MATCH_STAGE_LOSS_CONTENT), 
		[MinLevel, MaxLevel, StageName, Rank]),
	mail_op:gm_send(FromName, RoleName, Title, Content, 0, 0, 0).

query_unit_player_list(RoleId) ->
	case role_travel_match_db:get_register_info(RoleId) of
		[] ->
			{error, ?TRAVEL_MATCH_NOT_REGISTER};
		_ ->
			MatchStageInfo = get(single_match_stage_info),
			Stage = MatchStageInfo#single_match_stage_info.stage,
			State = MatchStageInfo#single_match_stage_info.state,
			if
				Stage =:= register, State =/= ?TRAVEL_MATCH_STATE_END ->
					{error, ?TRAVEL_MATCH_PLAYER_LIST_NOT_AVAILIABLE};
				Stage =:= final, Stage =:= ?TRAVEL_MATCH_STATE_END ->
					{error, ?TRAVEL_MATCH_PLAYER_LIST_NOT_AVAILIABLE};
				true ->
					Stage2 = if
						State =:= ?TRAVEL_MATCH_STATE_END ->
							get_next_stage(Stage);
						true ->
							Stage
					end,
					do_query_unit_player_list(RoleId, Stage2)
			end
	end.

query_session_data(Session, LevelZone) ->
	case role_travel_match_db:get_session_data(
		?TRAVEL_MATCH_TYPE_SINGLE,Session, LevelZone) of
		[] ->
			{error, ?TRAVEL_MATCH_RANK_DATA_NOT_AVAILIABLE};
		RankList ->
			RankData = lists:map(fun(SessionData) ->
				RoleId = role_travel_match_db:get_session_role_id(SessionData),
				RoleName = role_travel_match_db:get_session_role_name(SessionData),
				Gender = role_travel_match_db:get_session_role_gender(SessionData),
				Class = role_travel_match_db:get_session_role_class(SessionData),
				Level = role_travel_match_db:get_session_role_level(SessionData),
				FightForce = role_travel_match_db:get_session_role_fight_force(SessionData),
				Rank = role_travel_match_db:get_session_role_rank(SessionData),
				Gold = role_travel_match_db:get_session_role_gold(SessionData),
				#travel_match_rank{role_id = RoleId, role_name = RoleName, gender = Gender, 
				class = Class, level = LevelZone, fight_force = FightForce, rank = Rank, 
				gold = Gold}
			end, RankList),
			{ok, RankData}
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% local functions
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_register_datetime(Now) ->
	{{Y, M, D}, Time} = Now,
	MatchStage = travel_match_db:get_match_stage_info(
		?TRAVEL_MATCH_TYPE_SINGLE, register),
	{Day, StartTime, EndTime} = travel_match_db:get_stage_time_line(MatchStage),
	case timer_util:compare_datatime(Now, {{Y, M, Day}, StartTime}) of
		true ->
			%% not start
			StartDateTime = {{Y, M, Day}, StartTime},
			EndDateTime = {{Y, M, Day}, EndTime};
		_ ->
			%% have passed
			NextStartDate = timer_util:get_the_same_day_next_month({Y, M, Day}),
			StartDateTime = {NextStartDate, StartTime},
			EndDateTime = {NextStartDate, EndTime}
	end,
	{StartDateTime, EndDateTime}.

check_stage_forecast_start(register, _, _) ->
	nothing;
check_stage_forecast_start(Stage, NowSecs, StartSecs) ->
	erlang:send_after((StartSecs - NowSecs - 10 * 60) * 1000, self(), {single_match_stage_forecast_start, 
		Stage}).

check_stage_start(Stage, NowSecs, StartSecs) ->
	erlang:send_after((StartSecs - NowSecs) * 1000, self(), {single_match_stage_start, Stage}).

check_stage_forecast_end(register, NowSecs, EndSecs) ->
	erlang:send_after((EndSecs - NowSecs - 5 * 60) * 1000, self(), {single_match_stage_forecast_end, 
		register});
check_stage_forecast_end(_, _, _) ->
	todo.

check_stage_end(Stage, NowSecs, EndSecs) ->
	erlang:send_after((EndSecs - NowSecs) * 1000, self(), {single_match_stage_end, Stage}).

update_stage_and_state(Stage, State) ->
	MatchStageInfo = get(single_match_stage_info),
	MatchStageInfo2 = MatchStageInfo#single_match_stage_info{stage = Stage, 
		state = State},
	put(single_match_stage_info, MatchStageInfo2).

wait_next_stage(final) ->
	erlang:send_after(3 * 60 * 1000, self(), {single_match_stage_closed}),
	init();
wait_next_stage(Stage) ->
	NextStage = get_next_stage(Stage),
	MatchStage = travel_match_db:get_match_stage_info(
		?TRAVEL_MATCH_TYPE_SINGLE, NextStage),
	{Day, StartTime, EndTime} = travel_match_db:get_stage_time_line(MatchStage),
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{{Y, M, D}, Time} = Now,
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds({{Y, M, Day}, StartTime}),
	EndSecs = calendar:datetime_to_gregorian_seconds({{Y, M, Day}, EndTime}),
	check_stage_forecast_start(NextStage, NowSecs, StartSecs),
	check_stage_start(NextStage, NowSecs, StartSecs),
	check_stage_end(NextStage, NowSecs, EndSecs).

get_next_stage(Stage) ->
	case Stage of
		register ->
			audition;
		audition ->
			trial;
		trial ->
			replay;
		replay ->
			semifinal;
		semifinal ->
			final
	end.
	
get_stage_num(Stage) ->
	case Stage of
		register ->
			?TRAVEL_MATCH_STAGE_REGISTER;
		audition ->
			?TRAVEL_MATCH_STAGE_AUDITION;
		trial ->
			?TRAVEL_MATCH_STAGE_TRIAL;
		replay ->
			?TRAVEL_MATCH_STAGE_REPLAY;
		semifinal ->
			?TRAVEL_MATCH_STAGE_SEMIFINAL;
		final ->
			?TRAVEL_MATCH_STAGE_FINAL
	end.

update_register_stat(Level) ->
	MatchStageInfo = get(single_match_stage_info),
	Total = MatchStageInfo#single_match_stage_info.total,
	LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
	MatchLevel = travel_match_db:get_type_level_info(?TRAVEL_MATCH_TYPE_SINGLE, Level),
	LevelZone = travel_match_db:get_type_level(MatchLevel),
	LevelStat2 = case lists:keyfind(LevelZone, 1, LevelStat) of
		false ->
			[{LevelZone, 1, 0} | LevelStat];
		{LevelZone, Num, 0} ->
			lists:keyreplace(LevelZone, 1, LevelStat, {LevelZone, Num + 1, 0})
	end,
	MatchStageInfo2 = MatchStageInfo#single_match_stage_info{total = Total + 1, 
		level_stat = LevelStat2},
	put(single_match_stage_info, MatchStageInfo2).

divide_into_units_and_compute_awards() ->
	MatchStageInfo = get(single_match_stage_info),
	LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
	LevelStat2 = lists:foldl(fun({LevelZone, Num, _}, Acc) ->
		MatchLevel = travel_match_db:get_type_level_info2(?TRAVEL_MATCH_TYPE_SINGLE, LevelZone),
		MinNum = travel_match_db:get_type_level_min_num(MatchLevel),
		if
			Num < MinNum ->
				return_back_register_cost(LevelZone),
				lists:keydelete(LevelZone, 1, Acc);
			true ->
				divide_into_units(LevelZone),
				Acc
		end
	end, LevelStat, LevelStat),
	compute_awards_gold(MatchStageInfo, LevelStat2).

compute_awards_gold(MatchStageInfo, LevelStat) ->
	LevelStat2 = lists:foldl(fun({LevelZone, Num, _}, Acc) ->
		Awards = compute_awards_gold_level(LevelZone, Num),
		lists:keyreplace(LevelZone, 1, Acc, {LevelZone, Num, Awards})
	end, LevelStat, LevelStat),
	put(single_match_stage_info, MatchStageInfo#single_match_stage_info{level_stat = LevelStat2}).

check_next_stage() ->
	MatchStageInfo = get(single_match_stage_info),
	MatchStageInfo#single_match_stage_info.level_stat =/= [].

return_back_register_cost(LevelZone) ->
	RoleList = role_travel_match_db:get_register_info_by_level(LevelZone),
	lists:foreach(fun(RegisterInfo) ->
		RoleId = role_travel_match_db:get_register_role_id(RegisterInfo),
		Level = role_travel_match_db:get_register_level(RegisterInfo),
		travel_battle_util:cast_to_role_server(RoleId, ?MODULE, 
			do_return_back_register_cost, [RoleId, Level]),
		role_travel_match_db:delete_role_register_info(RoleId)
	end, RoleList).

divide_into_units(LevelZone) ->
	MatchStageInfo = get(single_match_stage_info),
	LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
	{_, Num, _} = lists:keyfind(LevelZone, 1, LevelStat),
	Units = get_level_units_count(LevelZone, Num),
	RoleList = role_travel_match_db:get_register_info_by_level(LevelZone),
	lists:foldl(fun(RegisterInfo, Idx) ->
		RoleId = role_travel_match_db:get_register_role_id(RegisterInfo),
		UnitNo = Idx rem Units + 1,
		role_travel_match_db:save_match_result(RoleId, LevelZone, [{audition, UnitNo, 0, 0}]),
		travel_battle_util:cast_to_role_server(RoleId, ?MODULE, 
			notify_register_success, [RoleId, LevelZone, UnitNo]),
		Idx + 1
	end, 0, RoleList).

get_level_units_count(LevelZone, Num) ->
	MatchLevel = travel_match_db:get_type_level_info2(?TRAVEL_MATCH_TYPE_SINGLE, LevelZone),
	UnitPersonNum = travel_match_db:get_type_level_unit(MatchLevel),
	if
		Num rem UnitPersonNum =:= 0 ->
			Num div UnitPersonNum;
		true ->
			Num div UnitPersonNum + 1
	end.

create_all_wait_maps(Stage) ->
	MatchStageInfo = get(single_match_stage_info),
	LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
	lists:foreach(fun({LevelZone, Num, _}) ->
		Units = get_level_units_count(LevelZone, Num),
		ZoneList = travel_battle_util:get_all_zone_ids() -- [1],
		ZoneUsed = role_travel_match_db:get_zone_used(),
		do_create_wait_maps(LevelZone, Stage, lists:seq(1, Units), ZoneList -- ZoneUsed)
	end, LevelStat).

do_create_wait_maps(_, _, [], _) ->
	nothing;
do_create_wait_maps(LevelZone, Stage, UnitList, [ZoneId | ZoneUnused]) ->
	ZoneCntInfo = travel_match_db:get_zone_count_info(ZoneId, 
		?TRAVEL_MATCH_TYPE_SINGLE, LevelZone),
	MaxCount = travel_match_db:get_zone_max_count(ZoneCntInfo),
	{ZoneUnits, LeftUnits} = case length(UnitList) > MaxCount of
		true ->
			lists:split(MaxCount, UnitList);
		false ->
			{UnitList, []}
	end,
	lists:foreach(fun(Unit) ->
		role_travel_match_db:save_wait_map_zone(?TRAVEL_MATCH_TYPE_SINGLE, 
			LevelZone, Unit, ZoneId),
		MatchLevel = travel_match_db:get_type_level_info2(
			?TRAVEL_MATCH_TYPE_SINGLE, LevelZone),
		WaitMapId = travel_match_db:get_type_level_wait_map(MatchLevel),
		start_travel_match_unit_manager(?TRAVEL_MATCH_TYPE_SINGLE, LevelZone, 
			Stage, Unit, ZoneId, WaitMapId)
	end, ZoneUnits),
	do_create_wait_maps(LevelZone, Stage, LeftUnits, ZoneUnused).

start_travel_match_unit_manager(Type, LevelZone, Stage, 
	Unit, ZoneId, WaitMapId) ->
	MapNode = travel_battle_util:get_zone_map_node(ZoneId),
	MapProc = travel_match_unit_manager:make_wait_map_proc_name(
		Type, ZoneId, Unit),
	travel_match_zone_manager:start_travel_match_unit_manager(MapNode, MapProc, 
		Type, LevelZone, Stage, WaitMapId, Unit).	

stop_all_wait_maps() ->
	AllWaitMapInfo = role_travel_match_db:get_all_wait_map_info_by_type(
		?TRAVEL_MATCH_TYPE_SINGLE),
	lists:foreach(fun(WaitMapInfo) ->
		ZoneId = role_travel_match_db:get_wait_map_zone_id(WaitMapInfo),
		Unit = role_travel_match_db:get_wait_map_unit(WaitMapInfo),
		stop_travel_match_unit_manager(?TRAVEL_MATCH_TYPE_SINGLE, Unit, ZoneId)
	end, AllWaitMapInfo).

stop_travel_match_unit_manager(Type, Unit, ZoneId) ->
	MapNode = travel_battle_util:get_zone_map_node(ZoneId),
	MapProc = travel_match_unit_manager:make_wait_map_proc_name(
		Type, ZoneId, Unit),
	travel_match_zone_manager:stop_travel_match_unit_manager(MapNode, MapProc, Unit),
	role_travel_match_db:clear_wait_map_zone().

can_enter_wait_map() ->
	MatchStageInfo = get(single_match_stage_info),
	Stage = MatchStageInfo#single_match_stage_info.stage,
	State = MatchStageInfo#single_match_stage_info.state,
	Stage =/= register andalso (State =:= ?TRAVEL_MATCH_STATE_READY orelse
		State =:= ?TRAVEL_MATCH_STATE_GOING).

do_query_wait_map_info(MatchResult) ->
	LevelZone = role_travel_match_db:get_match_result_level(MatchResult),
	MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
	MatchStageInfo = get(single_match_stage_info),
	Stage = MatchStageInfo#single_match_stage_info.stage,
	case lists:keyfind(Stage, 1, MatchInfo) of
		false ->
			{error, ?TRAVEL_MATCH_STAGE_FAILED};
		{_, Unit, Points, _} ->
			[WaitMapInfo | _] = role_travel_match_db:get_wait_map_info(
				?TRAVEL_MATCH_TYPE_SINGLE, LevelZone, Unit),
			ZoneId = role_travel_match_db:get_wait_map_zone_id(WaitMapInfo),
			{ok, LevelZone, Stage, ZoneId, Unit, Points}
	end.

get_match_result_info(RoleId, Stage, Status) ->
	if
		Stage =:= register ->
			{?TRAVEL_MATCH_RANK_WAIT, {0, 0}, []};
		true ->
			MatchResult = role_travel_match_db:get_match_result(RoleId),
			LevelZone = role_travel_match_db:get_match_result_level(MatchResult),
			MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
			Rank = get_rank_from_match_info(Stage, MatchInfo),
			MatchInfo2 = lists:filter(fun({_, _, _, Rank4}) ->
				Rank4 =/= 0
			end, MatchInfo),
			MatchInfo3 = [#stage_rank_info{stage = get_stage_num(Stage2), 
			rank = Rank5, points = Points} || {Stage2, _, Rank5, Points} <- MatchInfo],
			{Rank, LevelZone, MatchInfo3}
	end.

get_rank_from_match_info(Stage, MatchInfo) ->
	if
		Stage =:= final ->
			case lists:keyfind(final, 1, MatchInfo) of
				false ->
					get_last_rank_from_match_info(MatchInfo);
				{_, _, _, Rank2} ->
					if
						Rank2 > 0 ->
							Rank2;
						true ->
							?TRAVEL_MATCH_RANK_WAIT
					end
			end;
		true ->
			NextStage = get_next_stage(Stage),
			case lists:keyfind(NextStage, 1, MatchInfo) of
				false ->
					?TRAVEL_MATCH_RANK_PROMOTION;
				_ ->
					case lists:keyfind(Stage, 1, MatchInfo) of
						false ->
							get_last_rank_from_match_info(MatchInfo);
						{_, _, _, Rank3} ->
							Rank3
					end
			end
	end.

get_last_rank_from_match_info(MatchInfo) ->
	{_, _, _, Rank} = lists:keyfind(audition, 1, MatchInfo),
	do_get_last_rank_from_match_info(Rank, trial, MatchInfo).

do_get_last_rank_from_match_info(Rank, Stage, MatchInfo) ->
	case lists:keyfind(Stage, 1, MatchInfo) of
		false ->
			Rank;
		{_, _, _, Rank2} ->
			NextStage = get_next_stage(Stage),
			do_get_last_rank_from_match_info(Rank2, NextStage, MatchInfo)
	end.

compute_awards_gold_level(LevelZone, Num) ->
	MatchLevel = travel_match_db:get_type_level_info2(?TRAVEL_MATCH_TYPE_SINGLE, LevelZone),
	Cost = travel_match_db:get_type_level_cost(MatchLevel),
	AwardsRate = travel_match_db:get_type_level_awards_rate(MatchLevel),
	Awards = Cost * Num * AwardsRate / 100,
	{R1, R2, R3} = travel_match_db:get_type_level_distribution(MatchLevel),
	#level_awards{champion = trunc(Awards * R1 / 100), 
		second_place = trunc(Awards * R2/ 100), 
		third_place = trunc(Awards * R3/ 100)
	}.

transfer_all_user_to_battle() ->
	AllWaitMapInfo = role_travel_match_db:get_all_wait_map_info_by_type(
		?TRAVEL_MATCH_TYPE_SINGLE),
	lists:foreach(fun(WaitMapInfo) ->
		ZoneId = role_travel_match_db:get_wait_map_zone_id(WaitMapInfo),
		Unit = role_travel_match_db:get_wait_map_unit(WaitMapInfo),
		MapNode = travel_battle_util:get_zone_map_node(ZoneId),
		UnitManagerProc = travel_match_unit_manager:make_unit_manager_proc_name(Unit),
		travel_match_unit_manager:battle_start(MapNode, UnitManagerProc)
	end, AllWaitMapInfo).

summary_on_stage_end(Stage) ->
	MatchStageInfo = get(single_match_stage_info),
	LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
	lists:foreach(fun({LevelZone, _, _}) ->
		send_participation_awards(Stage, LevelZone),
		update_role_rank_info(Stage, LevelZone),
		if
			Stage =:= final ->
				send_final_awards(LevelZone),
				copy_rank_data_to_session_table(LevelZone);
			true ->
				divide_into_units_next_stage(Stage, LevelZone),
				notify_loss(Stage, LevelZone)
		end
	end, LevelStat).

send_participation_awards(Stage, LevelZone) ->
	MatchResultLevel = role_travel_match_db:get_match_result_by_level(LevelZone),
	MatchResultLevel2 = lists:filter(fun(MatchResult) ->
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		lists:keyfind(Stage, 1, MatchInfo) =/= false
	end, MatchResultLevel),
	AwardsInfo = travel_match_db:get_level_stage_info(
		?TRAVEL_MATCH_TYPE_SINGLE, LevelZone, Stage),
	Awards = travel_match_db:get_level_stage_awards(AwardsInfo),
	lists:foreach(fun(MatchResult) ->
		RoleId = role_travel_match_db:get_match_result_role_id(MatchResult),
		travel_battle_util:cast_to_role_server(RoleId, ?MODULE, 
			do_send_participation_awards, [RoleId, Stage, LevelZone, Awards])
	end, MatchResultLevel2).

update_role_rank_info(Stage, LevelZone) ->
	MatchResultLevel = role_travel_match_db:get_match_result_by_level(LevelZone),
	MatchResultLevel2 = lists:filter(fun(MatchResult) ->
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		lists:keyfind(Stage, 1, MatchInfo) =/= false
	end, MatchResultLevel),
	MatchResultLevel3 = lists:sort(fun(A, B) ->
		MatchInfoA = role_travel_match_db:get_match_result_info(A),
		{_, _, PointsA, _} = lists:keyfind(Stage, 1, MatchInfoA),
		MatchInfoB = role_travel_match_db:get_match_result_info(B),
		{_, _, PointsB, _} = lists:keyfind(Stage, 1, MatchInfoB),
		PointsA >= PointsB
	end, MatchResultLevel2),
	lists:foldl(fun(MatchResult, Rank) ->
		RoleId = role_travel_match_db:get_match_result_role_id(MatchResult),
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		{_, Unit, Points, _} = lists:keyfind(Stage, 1, MatchInfo),
		MatchInfo2 = lists:keyreplace(Stage, 1, MatchInfo, {Stage, Unit, Points, Rank}),
		role_travel_match_db:save_match_result(RoleId, LevelZone, MatchInfo2),
		Rank + 1
	end, 1, MatchResultLevel3).

send_final_awards(LevelZone) ->
	MatchResultLevel = role_travel_match_db:get_match_result_by_level(LevelZone),
	MatchResultLevel2 = lists:filter(fun(MatchResult) ->
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		case lists:keyfind(final, 1, MatchInfo) of
			false ->
				false;
			{_, _, _, Rank} ->
				Rank =:= 1 orelse Rank =:= 2 orelse Rank =:= 3
		end
	end, MatchResultLevel),
	MatchStageInfo = get(single_match_stage_info),
	LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
	{_, _, AwardsGold} = lists:keyfind(LevelZone, 1, LevelStat),
	lists:foreach(fun(MatchResult) ->
		RoleId = role_travel_match_db:get_match_result_role_id(MatchResult),
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		{_, _, _, Rank} = lists:keyfind(final, 1, MatchInfo),
		AwardsRankInfo = travel_match_db:get_rank_awards_info(?TRAVEL_MATCH_TYPE_SINGLE,
			LevelZone, Rank),
		Awards = travel_match_db:get_type_rank_awards(AwardsRankInfo),
		Gold = if
			Rank =:= 1 ->
				AwardsGold#level_awards.champion;
			Rank =:= 2 ->
				AwardsGold#level_awards.second_place;
			true ->
				AwardsGold#level_awards.third_place
		end,
		travel_battle_util:cast_to_role_server(RoleId, ?MODULE, 
			do_send_final_awards, [RoleId, LevelZone, Rank, Awards, Gold])
	end, MatchResultLevel2).


divide_into_units_next_stage(Stage, LevelZone) ->
	MatchResultLevel = role_travel_match_db:get_match_result_by_level(LevelZone),
	LevelStageInfo = travel_match_db:get_level_stage_info(
		?TRAVEL_MATCH_TYPE_SINGLE, LevelZone, Stage),
	Qualified = travel_match_db:get_level_stage_qualified(LevelStageInfo),
	MatchResultLevel2 = lists:filter(fun(MatchResult) ->
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		case lists:keyfind(Stage, 1, MatchInfo) of
			false ->
				false;
			{_, _, _, Rank} ->
				Rank =< Qualified
		end
	end, MatchResultLevel),
	Num = length(MatchResultLevel2),
	Units = get_level_units_count(LevelZone, Num),
	NextStage = get_next_stage(Stage),
	lists:foldl(fun(MatchResult, Idx) ->
		RoleId = role_travel_match_db:get_match_result_role_id(MatchResult),
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		UnitNo = Idx rem Units + 1,
		role_travel_match_db:save_match_result(RoleId, LevelZone, 
			[{NextStage, UnitNo, 0, 0} | MatchInfo]),
		travel_battle_util:cast_to_role_server(RoleId, ?MODULE, 
			do_send_promotion, [RoleId, LevelZone, NextStage, UnitNo]),
		Idx + 1
	end, 0, MatchResultLevel2).


notify_loss(Stage, LevelZone) ->
	MatchResultLevel = role_travel_match_db:get_match_result_by_level(LevelZone),
	MatchResultLevel2 = lists:filter(fun(MatchResult) ->
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		lists:keyfind(Stage, 1, MatchInfo) =/= false
	end, MatchResultLevel),
	LevelStageInfo = travel_match_db:get_level_stage_info(
		?TRAVEL_MATCH_TYPE_SINGLE, LevelZone, Stage),
	Qualified = travel_match_db:get_level_stage_qualified(LevelStageInfo),
	lists:foreach(fun(MatchResult) ->
		RoleId = role_travel_match_db:get_match_result_role_id(MatchResult),
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		{_, _, _, Rank} = lists:keyfind(Stage, 1, MatchInfo),
		Result = if
			Rank > Qualified ->
				travel_battle_util:cast_to_role_server(RoleId, ?MODULE, 
					do_send_loss, [RoleId, Stage, LevelZone, Rank]);
			true ->
				nothing
		end
	end, MatchResultLevel2).

get_stage_name(audition) ->
	language:get_string(?STR_TRAVEL_MATCH_STAGE_AUDITION);
get_stage_name(trial) ->
	language:get_string(?STR_TRAVEL_MATCH_STAGE_TRIAL);
get_stage_name(replay) ->
	language:get_string(?STR_TRAVEL_MATCH_STAGE_REPLAY);
get_stage_name(semifinal) ->
	language:get_string(?STR_TRAVEL_MATCH_STAGE_SEMIFINAL);
get_stage_name(final) ->
	language:get_string(?STR_TRAVEL_MATCH_STAGE_FINAL).

do_query_unit_player_list(RoleId, Stage) ->
	case role_travel_match_db:get_match_result(RoleId) of
		[] ->
			{error, ?TRAVEL_MATCH_PLAYER_LIST_NOT_AVAILIABLE};
		MatchResult ->
			LevelZone = role_travel_match_db:get_match_result_level(MatchResult),
			MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
			case lists:keyfind(Stage, 1, MatchInfo) of
				false ->
					{error, ?TRAVEL_MATCH_PLAYER_LIST_NOT_AVAILIABLE};
				{_, Unit, _, _} ->
					MatchResultLevel = role_travel_match_db:get_match_result_by_level(LevelZone),
					MatchResultLevel2 = lists:filter(fun(MatchResult2) ->
						MatchInfo2 = role_travel_match_db:get_match_result_info(MatchResult2),
						case lists:keyfind(Stage, 1, MatchInfo2) of
							false ->
								false;
							{_, Unit2, _, _} ->
								Unit2 =:= Unit
						end
					end, MatchResultLevel),
					RoleList = lists:map(fun(MatchResult3) ->
						role_travel_match_db:get_match_result_role_id(MatchResult3)
					end, MatchResultLevel2),
					Result = lists:map(fun(RoleId2) ->
						RegisterInfo = role_travel_match_db:get_register_info(RoleId2),
						RoleName = role_travel_match_db:get_register_name(RegisterInfo),
						Gender = role_travel_match_db:get_register_gender(RegisterInfo),
						Class = role_travel_match_db:get_register_class(RegisterInfo),
						Level = role_travel_match_db:get_register_level(RegisterInfo),
						FightForce = role_travel_match_db:get_register_fight_force(RegisterInfo),
						#travel_match_player{role_id = RoleId2, role_name = RoleName, 
							gender = Gender, class = Class, level = Level, 
							fight_force = FightForce}
					end, RoleList),
					{ok, Result}
			end
	end.

clear_last_session_data() ->
	role_travel_match_db:clear_register_info(),
	role_travel_match_db:clear_match_result(),
	role_travel_match_db:clear_wait_map_zone().

get_session_num() ->
	MatchProtoInfo = travel_match_db:get_type_info(?TRAVEL_MATCH_TYPE_SINGLE),
	{Y1, M1, _} = travel_match_db:get_type_start_date(MatchProtoInfo),
	{{Y2, M2}, _} = calendar:now_to_local_time(timer_center:get_correct_now()),
	(Y2 - Y1) * 12 + (M2 - M1) + 1.

copy_rank_data_to_session_table(LevelZone) ->
	%% 1. find first three rank data
	MatchResultLevel = role_travel_match_db:get_match_result_by_level(LevelZone),
	MatchResultLevel2 = lists:filter(fun(MatchResult) ->
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult),
		lists:keyfind(final, 1, MatchInfo) =/= false
	end, MatchResultLevel),
	MatchResultLevel3 = lists:filter(fun(MatchResult2) ->
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult2),
		{_, _, _, Rank} = lists:keyfind(final, 1, MatchInfo),
		Rank =:= 1 orelse Rank =:= 2 orelse Rank =:= 3
	end, MatchResultLevel),
	%%	2. copy to session table
	Session = get_session_num(),
	lists:foreach(fun(MatchResult3) ->
		RoleId = role_travel_match_db:get_match_result_role_id(MatchResult3),
		MatchInfo = role_travel_match_db:get_match_result_info(MatchResult3),
		{_, _, _, Rank} = lists:keyfind(final, 1, MatchInfo),
		RegisterInfo = role_travel_match_db:get_register_info(RoleId),
		RoleName = role_travel_match_db:get_register_name(RegisterInfo),
		Gender = role_travel_match_db:get_register_gender(RegisterInfo),
		Class = role_travel_match_db:get_register_class(RegisterInfo),
		FightForce = role_travel_match_db:get_register_fight_force(RegisterInfo),
		Level = role_travel_match_db:get_register_level(RegisterInfo),
		MatchStageInfo = get(single_match_stage_info),
		LevelStat = MatchStageInfo#single_match_stage_info.level_stat,
		{_, _, AwardsGold} = lists:keyfind(LevelZone, 1, LevelStat),
		Gold = if
			Rank =:= 1 ->
				AwardsGold#level_awards.champion;
			Rank =:= 2 ->
				AwardsGold#level_awards.second_place;
			true ->
				AwardsGold#level_awards.third_place
		end,
		role_travel_match_db:save_match_rank_info(?TRAVEL_MATCH_TYPE_SINGLE, 
			Session, LevelZone, RoleId, RoleName, Gender, Class, Rank, 
			FightForce, Gold, Level)
	end, MatchResultLevel3).