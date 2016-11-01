-module (travel_match_op).

-include ("travel_match_def.hrl").
-include ("error_msg.hrl").
-include ("common_define.hrl").
-include ("travel_battle_def.hrl").
-include ("creature_define.hrl").

-export ([load_from_db/1, export_for_copy/0, load_by_copy/1, on_offline/0, 
	enter_wait_map/1, query_role_info/1, regiser/1, join_instance/4, luck_win/0,
	section_end/0, stage_end/0, leave_wait_map/0, query_unit_player_list/1,
	query_session_data/3, is_in_fight/0]).

-include ("map_info_struct.hrl").

-record (travel_match_info, {type,stage,level,points,node,line_id,map_proc,map_id,pos,zone_id,unit,battle_start}).

load_from_db(_) ->
	init().

export_for_copy() ->
	get(travel_match_info).

load_by_copy(Info) ->
	put(travel_match_info, Info).

init() ->
	put(travel_match_info, #travel_match_info{type = undefined}).

query_role_info(Type) ->
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	Msg = case travel_match_manager:query_role_info(RoleId, Type) of
		{ok, Stage, Status, Rank, Awards, Details, RegisterStatus} ->
			travel_match_packet:encode_travel_match_query_role_info_s2c(
				Stage, Status, Rank, Details, Awards, RegisterStatus);
		{error, ErrNo} ->
			pet_packet:encode_send_error_s2c(ErrNo)
	end,
	role_op:send_data_to_gate(Msg).

regiser(Type) ->
	Result = case check_register_time(Type) of
		true ->
			do_register(Type);
		false ->
			?TRAVEL_MATCH_NOT_REGISTER_TIME
	end,
	Msg = if
		Result =:= 0 ->
			travel_match_packet:encode_travel_match_register_s2c();
		true ->
			pet_packet:encode_send_error_s2c(Result)
	end,
	role_op:send_data_to_gate(Msg).

enter_wait_map(Type) ->
	case is_in_travel_match() of
		true ->
			nothing;
		false ->
			do_enter_wait_map(Type)
	end.

on_offline() ->
	case is_in_travel_match() of
		true ->
			case is_in_fight() of
				true ->
					TravelMatchInfo = get(travel_match_info),
					Points = TravelMatchInfo#travel_match_info.points,
					AddPoint = compute_section_points(),
					TravelMatchInfo2 = TravelMatchInfo#travel_match_info{
						points = Points + AddPoint},
					put(travel_match_info, TravelMatchInfo2);
				false ->
					nothing
			end,
			leave_wait_map();
		false ->
			nothing
	end.

join_instance(InstanceProc, LineId, MapId, {X, Y}) ->
	reset_role_data(),
	TravelMatchInfo = get(travel_match_info),
	TravelMatchInfo2 = TravelMatchInfo#travel_match_info{
		battle_start = timer_center:get_correct_now()
		},
	put(travel_match_info, TravelMatchInfo2),
	reset_points_compute(),
	role_op:enter_map_in_same_node(node(),InstanceProc,MapId,LineId,X,Y).

luck_win() ->
	TravelMatchInfo = get(travel_match_info),
	Points = TravelMatchInfo#travel_match_info.points,
	AddPoint = get_luck_win_points(),
	Points2 = Points + AddPoint,
	TravelMatchInfo2 = TravelMatchInfo#travel_match_info{points = Points2},
	put(travel_match_info, TravelMatchInfo2),
	Msg = travel_match_packet:encode_travel_match_section_result_s2c(
		?TRAVEL_MATCH_RESULT_WIN, Points2),
	role_op:send_data_to_gate(Msg).

section_end() ->
	TravelMatchInfo = get(travel_match_info),
	Points = TravelMatchInfo#travel_match_info.points,
	Status = check_win_or_loss(),
	AddPoint = compute_section_points(),
	Points2 = Points + AddPoint,
	TravelMatchInfo2 = TravelMatchInfo#travel_match_info{battle_start = undefined,
		points = Points2},
	put(travel_match_info, TravelMatchInfo2),
	Msg = travel_match_packet:encode_travel_match_section_result_s2c(
		Status, Points2),
	role_op:send_data_to_gate(Msg).

stage_end() ->
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	TravelMatchInfo = get(travel_match_info),
	Type = TravelMatchInfo#travel_match_info.type,
	Points = TravelMatchInfo#travel_match_info.points,
	Status = check_win_or_loss(),
	AddPoint = compute_section_points(),
	Points2 = Points + AddPoint,
	travel_match_manager:update_role_match_result(RoleId, Type, Points2),
	Msg = travel_match_packet:encode_travel_match_stage_result_s2c(
		Status, Points2),
	role_op:send_data_to_gate(Msg),
	MapNode = TravelMatchInfo#travel_match_info.node,
	LineId = TravelMatchInfo#travel_match_info.line_id,
	MapProc = TravelMatchInfo#travel_match_info.map_proc,
	MapId = TravelMatchInfo#travel_match_info.map_id,
	{X, Y} = TravelMatchInfo#travel_match_info.pos,
	reset_role_data(),
	init(),
	role_op:change_map_in_other_node_begin(get(map_info), MapNode, 
		MapProc, MapId, LineId, X, Y).

leave_wait_map() ->
	case is_in_travel_match() of
		true ->
			do_leave_wait_map();
		false ->
			nothing
	end.

query_unit_player_list(Type) ->
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	Msg = case travel_match_manager:query_unit_player_list(RoleId, Type) of
		{ok, PlayerList} ->
			travel_match_packet:encode_travel_match_query_unit_player_list_s2c(PlayerList);
		{error, ErrNo} ->
			pet_packet:encode_send_error_s2c(ErrNo)
	end,
	role_op:send_data_to_gate(Msg).

query_session_data(Type, Session, LevelZone) ->
	Msg = case travel_match_manager:query_session_data(Type, Session, LevelZone) of
		{ok, RankData} ->
			travel_match_packet:encode_travel_match_query_session_data_s2c(RankData);
		{error, ErrNo} ->
			pet_packet:encode_send_error_s2c(ErrNo)
	end,
	role_op:send_data_to_gate(Msg).

is_in_fight() ->
	MatchInfo = get(travel_match_info),
	BattleStart = MatchInfo#travel_match_info.battle_start,
	BattleStart =/= undefined.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% local function
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

check_register_time(Type) ->
	Now = calendar:now_to_local_time(timer_center:get_correct_now()),
	{{Y, M, _}, _} = Now,
	MatchStage = travel_match_db:get_match_stage_info(Type, register),
	{Day, StartTime, EndTime} = travel_match_db:get_stage_time_line(MatchStage),
	timer_util:is_in_time_point({{Y, M, Day}, StartTime}, {{Y, M, Day}, EndTime}, Now).

role_base_check(MatchLevelInfo, RoleInfo) ->
	if
		MatchLevelInfo =/= [] ->
			RoleInfo = creature_op:get_creature_info(),
			MinFightForce = travel_match_db:get_min_fight_force(MatchLevelInfo),
			FightForce = creature_op:get_fighting_force_from_creature_info(RoleInfo),
			if
				FightForce < MinFightForce ->
					?ERROR_LESS_FIGHTFORCE;
				true ->
					0
			end;
		true ->
			?ERROR_LESS_LEVEL
	end.

do_register(Type) ->
	RoleInfo = creature_op:get_creature_info(),
	Level = creature_op:get_level_from_creature_info(RoleInfo),
	MatchLevelInfo = travel_match_db:get_type_level_info(Type, Level),
	case role_base_check(MatchLevelInfo, RoleInfo) of
		0 ->
			Cost = travel_match_db:get_type_level_cost(MatchLevelInfo),
			case role_op:check_money(?MONEY_GOLD, Cost) of
				true ->
					RoleId = creature_op:get_id_from_creature_info(RoleInfo),
					RoleName = creature_op:get_name_from_creature_info(RoleInfo),
					Gender = creature_op:get_gender_from_creature_info(RoleInfo),
					Class = creature_op:get_class_from_creature_info(RoleInfo),
					FightForce = creature_op:get_fighting_force_from_creature_info(RoleInfo), 
					case travel_match_manager:register(Type, RoleId, 
						RoleName, Gender, Class, Level, FightForce) of
						ok ->
							role_op:money_change(?MONEY_GOLD, -Cost, 
								travel_match_register),
							0;
						{error, ErrNo2} ->
							ErrNo2
					end;
				false ->
					?ERROR_LESS_GOLD
			end;
		ErrNo ->
			ErrNo
	end.

reset_role_data() ->
	CreatureInfo = creature_op:get_creature_info(),
	NewHp = creature_op:get_hpmax_from_creature_info(CreatureInfo),
	NewMp = creature_op:get_mpmax_from_creature_info(CreatureInfo),
	CreatureInfo1 = creature_op:set_life_to_creature_info(CreatureInfo, NewHp),
	CreatureInfo2 = creature_op:set_mana_to_creature_info(CreatureInfo1, NewMp),
	CreatureInfo3 = creature_op:set_state_to_creature_info(CreatureInfo2, gaming),
	put(creature_info, CreatureInfo3),
	role_op:only_self_update([{mp,NewMp},{hp,NewHp},{state,?CREATURE_STATE_GAME}]),
	skill_op:clear_all_casttime(),
	Msg = role_packet:encode_skill_cooldown_reset_s2c(),
	role_op:send_data_to_gate(Msg).

do_enter_wait_map(Type) ->
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	case travel_match_manager:query_wait_map_info(RoleId, Type) of
		{ok, LevelZone, Stage, ZoneId, Unit, Points} ->
			MapNode = travel_battle_util:get_zone_map_node(ZoneId),
			WaitMapProc = travel_match_unit_manager:make_wait_map_proc_name(
				Type, ZoneId, Unit),
			UnitManagerProc = travel_match_unit_manager:make_unit_manager_proc_name(Unit),
			case travel_match_unit_manager:enter_wait_map(MapNode, 
				UnitManagerProc, RoleId) of
				ok ->
					MapInfo = get(map_info),
					MapId = get_mapid_from_mapinfo(MapInfo),
					LineId = get_lineid_from_mapinfo(MapInfo),
					MapProc = get_proc_from_mapinfo(MapInfo),
					Pos = creature_op:get_pos_from_creature_info(RoleInfo),
					put(travel_match_info, #travel_match_info{type = Type, 
						stage = Stage, level = LevelZone, points = Points, 
						node = node(), line_id = LineId, map_proc = MapProc, 
						map_id = MapId, pos = Pos, zone_id = ZoneId, unit = Unit}),
					MatchLevel = travel_match_db:get_type_level_info2(Type, LevelZone),
					WaitMapId = travel_match_db:get_type_level_wait_map(MatchLevel),
					Transports = travel_match_db:get_type_level_transports(MatchLevel),
					Length = erlang:length(Transports),
					{X, Y} = lists:nth(random:uniform(Length), Transports),
					role_op:change_map_in_other_node_begin(MapInfo, MapNode, 
						WaitMapProc, WaitMapId, ?TRAVEL_BATTLE_LINE_ID, X, Y);
				_ ->
					slogger:msg("travel_match_unit_manager:enter_wait_map error~n")
			end;
		{error, ErrNo} ->
			Msg = pet_packet:encode_send_error_s2c(ErrNo),
			role_op:send_data_to_gate(Msg)
	end.

is_in_travel_match() ->
	MatchInfo = get(travel_match_info),
	Type = MatchInfo#travel_match_info.type,
	Type =/= undefined.

do_leave_wait_map() ->
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	TravelMatchInfo = get(travel_match_info),
	ZoneId = TravelMatchInfo#travel_match_info.zone_id,
	Type = TravelMatchInfo#travel_match_info.type,
	Unit = TravelMatchInfo#travel_match_info.unit,
	MapNode = travel_battle_util:get_zone_map_node(ZoneId),
	WaitMapProc = travel_match_unit_manager:make_wait_map_proc_name(
		Type, ZoneId, Unit),
	UnitManagerProc = travel_match_unit_manager:make_unit_manager_proc_name(Unit),
	case travel_match_unit_manager:leave_wait_map(MapNode, 
		UnitManagerProc, RoleId) of
		ok ->
			Points = TravelMatchInfo#travel_match_info.points,
			travel_match_manager:update_role_match_result(RoleId, Type, Points),
			MapNode = TravelMatchInfo#travel_match_info.node,
			LineId = TravelMatchInfo#travel_match_info.line_id,
			MapProc = TravelMatchInfo#travel_match_info.map_proc,
			MapId = TravelMatchInfo#travel_match_info.map_id,
			{X, Y} = TravelMatchInfo#travel_match_info.pos,
			init(),
			role_op:change_map_in_other_node_begin(get(map_info), MapNode, 
				MapProc, MapId, LineId, X, Y);
		_ ->
			slogger:msg("travel_match_unit_manager:leave_wait_map error~n")
	end.

compute_section_points() ->
	{Dps, _, _} = role_statistics:get_dps_st(),
	RoleInfo = creature_op:get_creature_info(),
	Attack = creature_op:get_power_from_creature_info(RoleInfo),
	MatchInfo = get(travel_match_info),
	BattleStart = MatchInfo#travel_match_info.battle_start,
	Now = timer_center:get_correct_now(),
	Type = MatchInfo#travel_match_info.type,
	MatchProtoInfo = travel_match_db:get_type_info(Type),
	Duration = travel_match_db:get_type_duration(MatchProtoInfo),
	BattleTime = timer:now_diff(Now, BattleStart) div 1000,
	Hp = creature_op:get_life_from_creature_info(RoleInfo),
	HpMax = creature_op:get_hpmax_from_creature_info(RoleInfo),
	todo.

reset_points_compute() ->
	role_statistics:init_role_dps_info(),
	role_statistics:start_dps_st().

get_luck_win_points() ->
	TravelMatchInfo = get(travel_match_info),
	Type = TravelMatchInfo#travel_match_info.type,
	MatchProtoInfo = travel_match_db:get_type_info(Type),
	travel_match_db:get_type_default_points(MatchProtoInfo).

check_win_or_loss() ->
	RoleList = mapop:get_map_roles_id(),
	RolesLive = lists:filter(fun(RoleId) ->
		CreatureInfo = creature_op:get_creature_info(RoleId),
		not creature_op:is_creature_dead(CreatureInfo)
	end, RoleList),
	case length(RolesLive) =:= 1 of
		true ->
			?TRAVEL_MATCH_RESULT_WIN;
		false ->
			?TRAVEL_MATCH_RESULT_LOSS
	end.
