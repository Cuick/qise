-module (travel_battle_zone_manager_op).

-include ("travel_battle_def.hrl").
-include ("error_msg.hrl").
-include ("npc_define.hrl").
-include ("common_define.hrl").

-export ([init/0, query_role_rank/1, register/8, overload_check/0, join_next_section/2, quit_from_stage/2,
	role_offline/1, cancel_match/1, recompute_rank/0, show_rank_page/1, update_role_rank_info/5, 
	month_awards_check/0]).


init() ->
	case travel_battle_util:is_travel_battle_db_map_node(node()) of
		true ->
			db_init();
		false ->
			normal_init()
	end.

query_role_rank(RoleId) ->
	{RankList, _, _, _} = get(travel_battle_rank_data),
	case lists:keyfind(RoleId, 1, RankList) of
		false ->
			?TRAVEL_BATTLE_ROLE_NOT_IN_RANK;
		_ ->
			{_, Idx} = lists:foldl(fun({RoleId2, _, _, _, _}, {Flag, IdxTmp}) ->
				if
					Flag; RoleId2 =:= RoleId ->
						{true, IdxTmp};
					true ->
						{false, IdxTmp + 1}
				end
			end, {false, 1}, RankList),
			Idx
	end.

register(RoleId, FightForce, RoleNode, RolePid, MapId, MapProc, LineId, Pos) ->
	{ZoneId, StageId, PersonNum, GroupMax} = get(zone_info),
	GroupList = get(group_list),
	GroupLength = length(GroupList),
	if
		GroupLength < GroupMax ->
			GroupId = case get(current_group) of
				undefined ->
					GroupId2 = generate_group_id(),
					put(current_group, GroupId2),
					put(GroupId2, []),
					GroupId2;
				GroupId3 ->
					GroupId3
			end,
			GroupRoleList = get(GroupId),
			GroupRoleListLength = length(GroupRoleList),
			put(GroupId, [{RoleId, ?TRAVEL_BATTLE_ROLE_MATCH, 0} | GroupRoleList]),
			GroupRoleListLengthNow = GroupRoleListLength + 1,
			role_travel_battle_zone_db:save_role_info(RoleId, FightForce, RoleNode, RolePid, 
				MapId, MapProc, LineId, Pos, GroupId),
			notify_group_member_change(GroupRoleList, GroupRoleListLengthNow),
			if
				GroupRoleListLengthNow =:= PersonNum ->
					put(group_list, [GroupId | get(group_list)]),
					put(current_group, undefined),
					start_group_battle(GroupId);
				true ->
					nothing
			end,
			{ok, {?TRAVEL_BATTLE_REGISTER_SUCESS, GroupRoleListLengthNow}};
		true ->
			{WaitList, TimerRef} = get(wait_list),
			if
				TimerRef =/= undefined ->
					erlang:cancel_timer(TimerRef);
				true ->
					nothing
			end,
			TimerRef2 = erlang:send_after(?TRAVEL_BATTLE_OVERLOAD_CHECK_INTERVAL, self(), {travel_battle_overload_check}),
			put(wait_list, {[RoleId | WaitList], TimerRef2}),
			role_travel_battle_zone_db:save_role_info(RoleId, FightForce, RoleNode, RolePid, 
				MapId, MapProc, LineId, Pos, undefined),
			{ok, {?TRAVEL_BATTLE_REGISTER_WAIT, length(WaitList) + 1}}
	end.

overload_check() ->
	{ZoneId, StageId, PersonNum, GroupMax} = get(zone_info),
	GroupList = get(group_list),
	{WaitList, TimerRef} = get(wait_list),
	GroupLength = length(GroupList),
	WaitList2 = if
		GroupLength < GroupMax ->
			GroupNum = erlang:min((length(WaitList) div PersonNum), (GroupMax - GroupLength)),
			{GroupList2, WaitList3} = lists:foldl(fun(_, {GroupListTmp, WaitListTmp}) ->
				GroupId = generate_group_id(),
				Length = length(WaitListTmp),
				{WaitListTmp2, GroupRoleList} = lists:split(Length - PersonNum, WaitListTmp),
				put(GroupId, [{RoleId, ?TRAVEL_BATTLE_ROLE_MATCH, 0} || RoleId <- GroupRoleList]),
				[role_travel_battle_zone_db:update_role_group_id(RoleId, GroupId) || RoleId <- GroupRoleList],
				start_group_battle(GroupId),
				{[GroupId | GroupListTmp], WaitListTmp2}
			end, {[], WaitList}, lists:seq(1, GroupNum)),
			put(group_list, GroupList2 ++ GroupList),
			WaitList3;
		true ->
			WaitList
	end,
	if
		WaitList2 =:= [] ->
			put(wait_list, {[], undefined});
		true ->
			notify_wait_member(WaitList2),
			TimerRef2 = erlang:send_after(?TRAVEL_BATTLE_OVERLOAD_CHECK_INTERVAL, self(), {travel_battle_overload_check}),
			put(wait_list, {WaitList2, TimerRef2})
	end.

quit_from_stage(RoleId, Score) ->
	case role_travel_battle_zone_db:get_role_info(RoleId) of
		[] ->
			nothing;
		RoleInfo ->
			GroupId = role_travel_battle_zone_db:get_role_group_id(RoleInfo),
			RoleList = get(GroupId),
			{RoleId, _, OldScore} = lists:keyfind(RoleId, 1, RoleList),
			put(GroupId, lists:keyreplace(RoleId, 1, RoleList, {RoleId, ?TRAVEL_BATTLE_ROLE_FAILED,
				OldScore + Score})),
			RoleNode = role_travel_battle_zone_db:get_role_node(RoleInfo),
			LineId = role_travel_battle_zone_db:get_role_line_id(RoleInfo),
			MapId = role_travel_battle_zone_db:get_role_map_id(RoleInfo),
			Pos = role_travel_battle_zone_db:get_role_pos(RoleInfo),
			MapProc = role_travel_battle_zone_db:get_role_map_proc(RoleInfo),
			role_pos_util:send_to_role(RoleId, {kick_from_travel_battle_stage, 
				RoleNode, MapId, MapProc, LineId, Pos, -1}),
			role_travel_battle_zone_db:delete_role(RoleId),
			check_match_result(GroupId)
	end.

join_next_section(RoleId, Score) ->
	case role_travel_battle_zone_db:get_role_info(RoleId) of
		[] ->
			nothing;
		RoleInfo ->
			GroupId = role_travel_battle_zone_db:get_role_group_id(RoleInfo),
			RoleList = get(GroupId),
			{RoleId, _, OldScore} = lists:keyfind(RoleId, 1, RoleList),
			put(GroupId, lists:keyreplace(RoleId, 1, RoleList, {RoleId, ?TRAVEL_BATTLE_ROLE_MATCH,
				OldScore + Score})),
			check_match_result(GroupId)
	end.

role_offline(RoleId) ->
	{WaitList, TimerRef} = get(wait_list),
	case lists:member(RoleId, WaitList) of
		true ->
			put(wait_list, WaitList -- [RoleId]);
		false ->
			case role_travel_battle_zone_db:get_role_info(RoleId) of
				[] ->
					nothing;
				RoleInfo ->
					GroupId = role_travel_battle_zone_db:get_role_group_id(RoleInfo),
					RoleList = get(GroupId),
					case lists:member(GroupId, get(group_list)) of
						true ->
							{RoleId, _, Score} = lists:keyfind(RoleId, 1, RoleList),
							put(GroupId, lists:keyreplace(RoleId, 1, RoleList, {RoleId, 
								?TRAVEL_BATTLE_ROLE_FAILED, Score})),
							check_match_result(GroupId);
						false ->
							CurrentGroupId = get(current_group),
							CurrentGroupRoles = get(CurrentGroupId),
							put(CurrentGroupId, lists:keydelete(RoleId, 1, 
								CurrentGroupRoles))
					end,
					role_travel_battle_zone_db:delete_role(RoleId)
			end
	end.

cancel_match(RoleId) ->
	{WaitList, TimerRef} = get(wait_list),
	case lists:member(RoleId, WaitList) of
		true ->
			put(wait_list, WaitList -- [RoleId]),
			role_travel_battle_zone_db:delete_role(RoleId),
			ok;
		false ->
			case get(current_group) of
				undefined ->
					{error, ?TRAVEL_BATTLE_MATCH_OK};
				CurrentGroupId ->
					CurrentGroupRoles = get(CurrentGroupId),
					GroupRoleListLengthNow = length(CurrentGroupRoles) - 1,
					case lists:keyfind(RoleId, 1, CurrentGroupRoles) of
						false ->
							{error, ?TRAVEL_BATTLE_MATCH_OK};
						_ ->
							put(CurrentGroupId, lists:keydelete(RoleId, 
								1, CurrentGroupRoles)),
							role_travel_battle_zone_db:delete_role(RoleId),
							notify_group_member_change(CurrentGroupRoles, GroupRoleListLengthNow),
							ok
					end
			end
	end.

recompute_rank() ->
	{RankList, CollectList, RefreshList, _} = get(travel_battle_rank_data),
	do_recompute_rank(RankList, CollectList, RefreshList).

show_rank_page(Page) ->
	EntryStart = (Page - 1) * ?TRAVEL_BATTLE_PAGE_SHOW_COUNT + 1,
	{RankList, _, _, _} = get(travel_battle_rank_data),
	Length = length(RankList),
	if 
		Length < EntryStart ->
			{error, ?TRAVEL_BATTLE_RANK_DATA_NOT_AVAILABLE};
		true ->
			[lists:sublist(RankList, EntryStart, ?TRAVEL_BATTLE_PAGE_SHOW_COUNT),Length]
	end.

update_role_rank_info(RoleId, RoleName, Gender, Class, Scores) ->
	rank_collect(RoleId, RoleName, Gender, Class, Scores).

month_awards_check() ->
	{RankList, _, _, TimerRef} = get(travel_battle_rank_data),
	send_month_awards(RankList),
	erlang:cancel_timer(TimerRef),
	{{_, Month, _}, _} = calendar:now_to_local_time(timer_center:get_correct_now()),
	role_travel_battle_zone_db:clear_role_rank_info(),
	role_travel_battle_zone_db:update_rank_clear_month(Month),
	init_rank_list([]),
	do_next_month_awards_check().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

normal_init() ->
	put(wait_list, {[], undefined}),
	put(group_list, []),
	put(current_group, undefined),
	ZoneId = travel_battle_util:get_zone_id(),
	StageInfo = travel_battle_db:get_stage_info_by_zone_id(ZoneId),
	StageId = travel_battle_db:get_stage_id(StageInfo),
	PersonNum = travel_battle_db:get_stage_person_num(StageInfo),
	ZoneCntInfo = travel_battle_db:get_zone_count_info(ZoneId),
	ZoneCount = travel_battle_db:get_zone_count(ZoneCntInfo),
	GroupMax = ZoneCount div PersonNum,
	put(zone_info, {ZoneId, StageId, PersonNum, GroupMax}),
	put(group_idx, 1),
	put(instance_idx, 1).

db_init() ->
	RankData = role_travel_battle_zone_db:load_rank_data(),
	{{_, Month, _}, _} = calendar:now_to_local_time(timer_center:get_correct_now()),
	RankData2 = case role_travel_battle_zone_db:get_rank_clear_month() of
		Month ->
			RankData;
		_ ->
			role_travel_battle_zone_db:clear_role_rank_info(),
			role_travel_battle_zone_db:update_rank_clear_month(Month),
			send_month_awards(RankData),
			[]
	end,
	init_rank_list(RankData2),
	do_next_month_awards_check().

generate_group_id() ->
	Idx = get(group_idx),
	put(group_idx, Idx + 1),
	"travel_battle_group_" ++ integer_to_list(Idx).

generate_instance_id() ->
	Idx = get(instance_idx),
	put(instance_idx, Idx + 1),
	list_to_atom("travel_battle_instance_" ++ integer_to_list(Idx)).

notify_group_member_change(RoleList, Length) ->
	lists:foreach(fun({RoleId, _, _}) ->
		case role_travel_battle_zone_db:get_role_info(RoleId) of
			[] ->
				nothing;
			RoleInfo ->
				RoleNode = role_travel_battle_zone_db:get_role_node(RoleInfo),
				RolePid = role_travel_battle_zone_db:get_role_pid(RoleInfo),
				try
					{RolePid, RoleNode} ! {travel_battle_register_wait, ?TRAVEL_BATTLE_REGISTER_SUCESS, Length}
				catch
					E:R->slogger:msg("notify_group_member_change ~p~p ~p ~n",[E,R,erlang:get_stacktrace()])
				end
		end
	end, RoleList).

notify_wait_member(WaitList) ->
	Length = length(WaitList),
	lists:foreach(fun(RoleId) ->
		case role_travel_battle_zone_db:get_role_info(RoleId) of
			[] ->
				nothing;
			RoleInfo ->
				RoleNode = role_travel_battle_zone_db:get_role_node(RoleInfo),
				RolePid = role_travel_battle_zone_db:get_role_pid(RoleInfo),
				try
					{RolePid, RoleNode} ! {travel_battle_register_wait, ?TRAVEL_BATTLE_REGISTER_WAIT, Length}
				catch
					E:R->slogger:msg("notify_wait_member ~p~p ~p ~n",[E,R,erlang:get_stacktrace()])
				end
		end
	end, WaitList).

start_group_battle(GroupId) ->
	RoleList = get(GroupId),
	RoleList2 = lists:map(fun({RoleId, _, Score}) ->
		case role_travel_battle_zone_db:get_role_info(RoleId) of
			[] ->
				{RoleId, ?TRAVEL_BATTLE_ROLE_FAILED, Score, 0};
			RoleInfo ->
				FightForce = role_travel_battle_zone_db:get_role_fight_force(RoleInfo),
				{RoleId, ?TRAVEL_BATTLE_ROLE_MATCH, Score, FightForce}
		end
	end, RoleList),
	RoleList3 = lists:sort(fun(A, B) ->
		{_, _, _, FightForceA} = A,
		{_, _, _, FightForceB} = B,
		FightForceA < FightForceB
	end, RoleList2),
	RoleList4 = [{RoleId, State, Score} || {RoleId, State, Score, _} <- RoleList3],
	put(GroupId, RoleList4),
	check_match_result(GroupId).

check_match_result(GroupId) ->
	RoleList = get(GroupId),
	RoleLeftNum = lists:foldl(fun({RoleId, State, _}, Acc) ->
		if
			State =:= ?TRAVEL_BATTLE_ROLE_FAILED ->
				Acc;
			true ->
			    Acc + 1
		end
	end, 0, RoleList),
	if 
		RoleLeftNum =< 3 ->
			StageEndCheck = lists:any(fun({_, State, _}) ->
				State =:= ?TRAVEL_BATTLE_ROLE_BATTLE
			end, RoleList),
			if
				StageEndCheck ->
					nothing;
				true ->
					do_stage_end(GroupId, RoleList)
			end;
		true ->
			do_check_match_result(GroupId, RoleList)
	end.

notify_join_instance(InstanceId, RoleList) ->
	{_, StageId, _, _} = get(zone_info),
	StageInfo = travel_battle_db:get_stage_info(StageId),
	MapId = travel_battle_db:get_stage_map_id(StageInfo),
	PosList = travel_battle_db:get_stage_pos_list(StageInfo),
	CreatorTag = {?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM},
	map_sup:start_child(InstanceId, {?TRAVEL_BATTLE_LINE_ID, MapId},
		travel_battle,CreatorTag,StageId),
	RolePosList = lists:zip(RoleList, PosList),
	lists:foreach(fun(RoleId) ->
		{_, Pos} = lists:keyfind(RoleId, 1, RolePosList),
		send_to_role(RoleId, {travel_battle_join_instance, InstanceId, Pos})	
	end, RoleList).

do_check_match_result(GroupId, RoleList) ->
	RoleList2 = [{RoleId, State, Score} || {RoleId, State, Score} <- RoleList,
		State =:= ?TRAVEL_BATTLE_ROLE_MATCH],
	Length = length(RoleList2),
	{RoleList3, _} = lists:foldl(fun(_, {RoleListTmp, RoleLeftTmp}) ->
		{InstanceRoleList, RoleLeftTmp2} = lists:split(?TRAVEL_BATTLE_INSTANCE_ROLE_NUM, 
			RoleLeftTmp),
		RoleListTmp2 = lists:foldl(fun({RoleId2, _, Score2}, Acc2) ->
			lists:keyreplace(RoleId2, 1, Acc2, {RoleId2, ?TRAVEL_BATTLE_ROLE_BATTLE, 
				Score2})
		end, RoleListTmp, InstanceRoleList),
		RoleIds = [RoleId3 || {RoleId3, _, _} <- InstanceRoleList],
		InstanceId = generate_instance_id(),
		notify_join_instance(InstanceId, RoleIds),
		{RoleListTmp2, RoleLeftTmp2}
	end, {RoleList, RoleList2}, lists:seq(1, Length div ?TRAVEL_BATTLE_INSTANCE_ROLE_NUM)),
	put(GroupId, RoleList3).

do_stage_end(GroupId, RoleList) ->
	LeftRoleList = lists:filter(fun({_, State, _}) ->
		State =:= ?TRAVEL_BATTLE_ROLE_MATCH
	end, RoleList),
	LeftRoleList2 = lists:sort(fun(A, B) ->
		{_, _, ScoreA} = A,
		{_, _, ScoreB} = B,
		ScoreA > ScoreB
	end, LeftRoleList),
	lists:foldl(fun({RoleId, _, _}, Acc) ->
		RoleInfo = role_travel_battle_zone_db:get_role_info(RoleId),
		RoleNode = role_travel_battle_zone_db:get_role_node(RoleInfo),
		LineId = role_travel_battle_zone_db:get_role_line_id(RoleInfo),
		MapId = role_travel_battle_zone_db:get_role_map_id(RoleInfo),
		Pos = role_travel_battle_zone_db:get_role_pos(RoleInfo),
		MapProc = role_travel_battle_zone_db:get_role_map_proc(RoleInfo),
		Acc2 = if 
			Acc > 3 ->
				send_to_role(RoleId, {kick_from_travel_battle_stage, 
					RoleNode, MapId, MapProc, LineId, Pos, -1}),
				Acc;
			true ->
				send_to_role(RoleId, {kick_from_travel_battle_stage, 
					RoleNode, MapId, MapProc, LineId, Pos, Acc}),
				Acc + 1
		end,
		role_travel_battle_zone_db:delete_role(RoleId),
		Acc2
	end, 1, LeftRoleList2),
	erase(GroupId),
	put(group_list, get(group_list) -- [GroupId]).

init_rank_list(RankData) ->
	RankList = lists:sort(fun(A, B) ->
		{_, _, _, _, ScoresA} = A,
		{_, _, _, _, ScoresB} = B,
		ScoresA > ScoresB
	end, RankData),
	RankListLength = erlang:length(RankList),
	{RankList2, LeftList} = if
		RankListLength > ?TRAVEL_BATTLE_RANK_LENGTH ->
			lists:split(?TRAVEL_BATTLE_RANK_LENGTH, RankList);
		true ->
			{RankList, []}
	end,
	lists:foreach(fun({RoleId, _, _, _, _}) ->
		role_travel_battle_zone_db:delete_role_from_rank(RoleId)
	end, LeftList),
	TimerRef = erlang:send_after(?TRAVEL_BATTLE_RANK_INTERVAL, self(), {travel_battle_rank_check}),
	put(travel_battle_rank_data, {RankList2, [], [], TimerRef}).

rank_collect(RoleId, Name, Gender, Class, Scores) ->
	role_travel_battle_zone_db:add_role_to_rank(RoleId, Name, Gender, Class, Scores),
	{RankList, CollectList, RefreshList, TimerRef} = get(travel_battle_rank_data),
	{NewCollectList, NewRefreshList} = case lists:keymember(RoleId, 1, CollectList) of
		true ->
			CollectList2 = lists:keyreplace(RoleId, 1, CollectList, {RoleId, Name, Gender, 
				Class, Scores}),
			{CollectList2, RefreshList};
		false ->
			RefreshList2 = case lists:keymember(RoleId, 1, RankList) of
				true ->
					[RoleId | RefreshList];
				false ->
					RefreshList
			end,
			CollectList2 = [{RoleId, Name, Gender, Class, Scores} | CollectList],
			{CollectList2, RefreshList2}
	end,
	Length = erlang:length(NewCollectList),
	if 
		Length > ?TRAVEL_BATTLE_RANK_RECOMPUTE_NUM ->
			erlang:cancel_timer(TimerRef),
			do_recompute_rank2(RankList, NewCollectList, NewRefreshList);
		true ->
			put(travel_battle_rank_data, {RankList, NewCollectList, NewRefreshList, TimerRef})
	end.

do_recompute_rank(RankList, CollectList, RefreshList) ->
	
	case erlang:length(CollectList) > 0 of
		true ->
			do_recompute_rank2(RankList, CollectList, RefreshList);
		_ ->
			TimerRef = erlang:send_after(?TRAVEL_BATTLE_RANK_INTERVAL, 
				self(), {travel_battle_rank_check}),
			put(travel_battle_rank_data, {RankList, [], [], TimerRef})
	end.

do_recompute_rank2(RankList, CollectList, RefreshList) ->
	NoRefreshList = lists:filter(fun({RoleId, _, _, _, _}) ->
		not lists:member(RoleId, RefreshList)
	end, RankList),
	ResultList = lists:sort(fun(A, B) ->
		{_, _, _, _, ScoresA} = A,
		{_, _, _, _, ScoresB} = B,
		ScoresA > ScoresB
	end, NoRefreshList ++ CollectList),
	ResultListLength = erlang:length(ResultList),
	RankList2 = if
		ResultListLength > ?TRAVEL_BATTLE_RANK_LENGTH ->
			{RankListTmp, _} = lists:split(?TRAVEL_BATTLE_RANK_LENGTH, ResultList),
			RankListTmp;
		true ->
			ResultList
	end,
	% lists:foreach(fun({RoleId, Name, Gender, Class, Scores}) ->
	% 	case lists:keymember(RoleId, 1, RankList) of
	% 		false ->
	% 			role_travel_battle_zone_db:add_role_to_rank(RoleId, Name, Gender, Class, Scores);
	% 		true ->
	% 			nothing
	% 	end
	% end, RankList2),
	lists:foreach(fun({RoleId, _, _, _, _}) ->
		case lists:keymember(RoleId, 1, RankList2) of
			false ->
				role_travel_battle_zone_db:delete_role_from_rank(RoleId);
			true ->
				nothing
		end
	end, RankList),
	TimerRef = erlang:send_after(?TRAVEL_BATTLE_RANK_INTERVAL, 
		self(), {travel_battle_rank_check}),
	put(travel_battle_rank_data, {RankList2, [], [], TimerRef}).

send_to_role(RoleId, Msg) ->
	case role_pos_util:where_is_role(RoleId) of
		[] ->
			RoleInfo = role_travel_battle_zone_db:get_role_info(RoleId),
			RoleNode = role_travel_battle_zone_db:get_role_node(RoleInfo),
			RolePid = role_travel_battle_zone_db:get_role_pid(RoleInfo),
			{RolePid, RoleNode} ! Msg;
		RolePos ->
			role_pos_util:send_to_role_by_pos(RolePos, Msg)
	end.	

do_next_month_awards_check() ->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{{Year, Month, Day}, _} = Now,
	NextMonthAwarsDate = if
		Month < 12 ->
			{Year, Month + 1, 1};
		true ->
			{Year + 1, 1, 1}
	end,
	NowSecs = calendar:datetime_to_gregorian_seconds(Now),
	NextMonthAwardsSecs = calendar:datetime_to_gregorian_seconds({NextMonthAwarsDate, {0, 0, 0}}),
	erlang:send_after((NextMonthAwardsSecs - NowSecs) * 1000, self(), {next_month_awards_check}).

send_month_awards([]) ->
	nothing;
send_month_awards(RankData) ->
	ResultList = lists:sort(fun(A, B) ->
		{_, _, _, _, ScoresA} = A,
		{_, _, _, _, ScoresB} = B,
		ScoresA > ScoresB
	end, RankData),
	ResultListLength = erlang:length(ResultList),
	ResultList2 = if
		ResultListLength > 3 ->
			{RankListTmp, _} = lists:split(3, ResultList),
			RankListTmp;
		true ->
			ResultList
	end,
	lists:foldl(fun({RoleId, _, _, _, _}, Rank) ->
		slogger:msg("travel_battle, send month awards, RoleId: ~p, ServerId: ~p, Rank: ~p~n", [RoleId, travel_battle_util:get_serverid_by_roleid(RoleId), Rank]),
		travel_battle_util:cast_to_role_server(RoleId, travel_battle_op, 
			send_month_awards, [RoleId, Rank]),
		Rank + 1
	end, 1, ResultList2).