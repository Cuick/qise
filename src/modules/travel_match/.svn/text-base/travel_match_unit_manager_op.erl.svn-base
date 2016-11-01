-module (travel_match_unit_manager_op).

-include ("travel_match_def.hrl").
-include ("error_msg.hrl").
-include ("npc_define.hrl").
-include ("travel_battle_def.hrl").
-include ("common_define.hrl").

-export ([init/4, enter_wait_map/1, battle_start/0, leave_wait_map/1, battle_end/0]).

-record (travel_match_unit, {section_total,duration,interval,map_id,pos_list,
	section_count,members,exclude,unit}).

init(Unit, Type, LevelZone, Stage) ->
	MatchTypeInfo = travel_match_db:get_type_info(Type),
	Duration = travel_match_db:get_type_duration(MatchTypeInfo),
	Interval = travel_match_db:get_type_interval(MatchTypeInfo),
	MatchBattleInfo = travel_match_db:get_level_stage_info(Type, LevelZone, Stage),
	SectionTotal = travel_match_db:get_level_stage_sections(MatchBattleInfo),
	MapId = travel_match_db:get_level_stage_map_id(MatchBattleInfo),
	PosList = travel_match_db:get_level_stage_pos_list(MatchBattleInfo),
	put(travel_match_unit, #travel_match_unit{section_total = SectionTotal,
		duration = Duration, interval = Interval, map_id = MapId,
		pos_list = PosList, section_count = 0, members = [],
		exclude = [], unit = Unit}),
	put(map_idx, 1).

enter_wait_map(RoleId) ->
	MatchUnit = get(travel_match_unit),
	Exclude = MatchUnit#travel_match_unit.exclude,
	Exclude2 = [RoleId | Exclude],
	MatchUnit2 = MatchUnit#travel_match_unit{exclude = Exclude2},
	put(travel_match_unit, MatchUnit2),
	ok.

battle_start() ->
	slogger:msg("yanzengyan, in travel_match_unit_manager_op:battle_start~n"),
	start_new_battle().

leave_wait_map(RoleId) ->
	MatchUnit = get(travel_match_unit),
	Exclude = MatchUnit#travel_match_unit.exclude,
	Members = MatchUnit#travel_match_unit.members,
	Exclude2 = lists:delete(RoleId, Exclude),
	Members2 = lists:delete(RoleId, Members),
	MatchUnit2 = MatchUnit#travel_match_unit{exclude = Exclude2,
		members = Members2},
	put(travel_match_unit, MatchUnit2),
	ok.

battle_end() ->
	MatchUnit = get(travel_match_unit),
	Members = MatchUnit#travel_match_unit.members,
	lists:foreach(fun(RoleId) ->
		role_pos_util:send_to_role(RoleId, {travel_match_battle_end})
	end, Members),
	Exclude = MatchUnit#travel_match_unit.exclude,
	SectionTotal = MatchUnit#travel_match_unit.section_total,
	SectionCount = MatchUnit#travel_match_unit.section_count,
	if
		SectionCount < SectionTotal ->
			%% 启动新的一局战斗
			Interval = MatchUnit#travel_match_unit.interval,
			erlang:send_after(Interval, self(), {travel_match_battle_start});
		true ->
			%% 本场次结束
			notify_members_stage_end(Members ++ Exclude)
	end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% local functions
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_new_battle() ->
	MatchUnit = get(travel_match_unit),
	Exclude = MatchUnit#travel_match_unit.exclude,
	Members = MatchUnit#travel_match_unit.members,
	SectionCount = MatchUnit#travel_match_unit.section_count,
	Duration = MatchUnit#travel_match_unit.duration,
	Unit = MatchUnit#travel_match_unit.unit,
	MapId = MatchUnit#travel_match_unit.map_id,
	PosList = MatchUnit#travel_match_unit.pos_list,
	slogger:msg("yanzengyan, in travel_match_unit_manager_op:start_new_battle~n"),
	{Members2, Exclude2} = do_start_new_battle(Exclude ++ Members, Unit, 
		Duration, MapId, PosList),
	MatchUnit2 = MatchUnit#travel_match_unit{members = Members2,
		exclude = Exclude2, section_count = SectionCount + 1},
	put(travel_match_unit, MatchUnit2),
	erlang:send_after(Duration, self(), {travel_match_battle_end}).

do_start_new_battle(Members, Unit, Duration, MapId, PosList) ->
	Length = erlang:length(Members),
	OldMapIdx = get(map_idx),
	LeftNum = Length rem 3,
	{Members2, Exclude2} = lists:split((Length - LeftNum), Members),
	notify_members_luck_win(Exclude2),
	MapIdx = lists:foldl(fun(Id, Acc) ->
		InstanceProc = make_instance_proc_name(Unit, Acc),
		map_sup:stop_child(InstanceProc),
		CreatorTag = {?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM},
		map_sup:start_child(InstanceProc, {?TRAVEL_BATTLE_LINE_ID, MapId},
			travel_match_battle,CreatorTag,Duration),
		RoleList = lists:sublist(Members2, (Id - 1) * 3 + 1, 3),
		slogger:msg("yanzengyan, in travel_match_unit_manager_op:do_start_new_battle, 
			Id: ~p, InstanceProc: ~p~n", [Id, InstanceProc]),
		RolePosList = lists:zip(RoleList, PosList),
		lists:foreach(fun({RoleId, Pos}) ->
			role_pos_util:send_to_role(RoleId, 
				{travel_match_join_instance, InstanceProc, 
				?TRAVEL_BATTLE_LINE_ID, MapId, Pos})	
		end, RolePosList),
		Acc + 1
	end, OldMapIdx, lists:seq(1, Length div 3)),
	put(map_idx, MapIdx),
	{Members2, Exclude2}.

make_instance_proc_name(Unit, Id) ->
	list_to_atom("travel_match_battle_" ++ integer_to_list(Unit) ++
		"_" ++ integer_to_list(Id)).

notify_members_luck_win(Exclude) ->
	lists:foreach(fun(RoleId) ->
		role_pos_util:send_to_role(RoleId, {travel_match_luck_win})
	end, Exclude).

notify_members_stage_end(Members) ->
	lists:foreach(fun(RoleId) ->
		role_pos_util:send_to_role(RoleId, {travel_match_stage_end})
	end, Members).