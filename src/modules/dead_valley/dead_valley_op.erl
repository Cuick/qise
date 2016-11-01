-module (dead_valley_op).

-include ("common_define.hrl").
-include ("item_define.hrl").
-include ("npc_define.hrl").
-include ("error_msg.hrl").
-include ("creature_define.hrl").
-include ("dead_valley_def.hrl").

 -export ([load_from_db/1, export_for_copy/0, load_by_copy/1, enter_map/1, leave_map/0, hook_on_be_killed/2,
 	update_points/1, add_equipment_to_package/1, is_in_dead_valley/0, hook_offline/0, hook_map_complete/0,
 	duration_check/0, touch_trap/1, leave_trap/1, save_to_db/0, hook_on_respawn/0, query_zone_info/0, update_exp/1]).

-include ("map_info_struct.hrl").
-include ("item_struct.hrl").
-include ("npc_struct.hrl").
-include("role_struct.hrl").

load_from_db(RoleId) ->
	{LeaveTime, Points, Exp} = case role_dead_valley_db:get_role_info(RoleId) of
		[] ->
			{{0, 0, 0}, 0, 0};
		{_, _, LeaveTime2, Points2, Exp2} ->
			{LeaveTime2, Points2, Exp2}
	end,
	init(LeaveTime, Points, Exp).

export_for_copy() ->
	{get(dead_valley_info), get(trap_list)}.

load_by_copy({DeadValleyInfo, TrapList}) ->
	put(dead_valley_info, DeadValleyInfo),
	put(trap_list, TrapList).

save_to_db() ->
	{_, _, _, _, _, _, LeaveTime, Points, Exp} = get(dead_valley_info),
	role_dead_valley_db:save_role_info(get(roleid), LeaveTime, Points, Exp).

hook_offline() ->
	{State, _, _, _, _, _, _, Points, Exp} = get(dead_valley_info),
	if
		State =:= true ->
			ZoneId = travel_battle_util:get_zone_id(),
			dead_valley_manager:leave(ZoneId),
			init(timer_center:get_correct_now(), Points, Exp);
		true ->
			nothing
	end.

hook_map_complete() ->
	case is_in_dead_valley() of
		true ->
			dead_valley_zone_manager:role_come(get(roleid));
		false ->
			nothing
	end.

enter_map(ZoneId) ->
	RoleInfo1 = get(creature_info),
	Flag = lists:any(fun(E) -> RoleInfo1#gm_role_info.gs_system_map_info#gs_system_map_info.map_id =:=E end,env:get(travel_battle_map1, [])),
	if
		Flag ->
			Msg = pet_packet:encode_send_error_s2c(?PLEASE_LEAVE_VIPMAP),
			role_op:send_data_to_gate(Msg);
		true ->


	Result = case is_open_time() of
		false ->
			?DEAD_VALLEY_NOT_START;
		true ->
			ProtoInfo = dead_valley_db:get_proto_info(),
			BaseLevel = dead_valley_db:get_proto_level(ProtoInfo),
			RoleInfo = creature_op:get_creature_info(),
			Level = creature_op:get_level_from_creature_info(RoleInfo),
			if
				Level < BaseLevel ->
					?ERROR_LESS_LEVEL;
				true ->
					case is_in_dead_valley() of
						true ->
							?DEAD_VALLEY_ZONE_ERROR;
						false ->
							case instance_op:is_in_instance() of
								true ->
									?ERRNO_ALREADY_IN_INSTANCE;
								false ->
									case check_equipments_can_drop() of
										true ->
											case check_cooldown_time_ok() of
												true ->
													0;
												false ->
													?DEAD_VALLEY_COOLDOWN_TIME
											end;
										false ->
											?DEAD_VALLEY_NO_DROP_EQUIPMENT
									end
							end
					end
			end
	end,
	if
		Result =:= 0 ->
			do_enter_map(ZoneId);
		true ->
			Msg = pet_packet:encode_send_error_s2c(Result),
			role_op:send_data_to_gate(Msg)
	end

	end.

leave_map() ->
	{State, Node, LineId, MapId, MapProc, {X, Y}, _, _, _} = get(dead_valley_info),
	if
		State =:= true ->
			ZoneId = travel_battle_util:get_zone_id(),
			case dead_valley_manager:leave(ZoneId) of
				ok ->
					clear_trap_buffers(),
					init(timer_center:get_correct_now(), 0, 0),
					MapInfo = get(map_info),
					role_op:change_map_in_other_node_begin(MapInfo, Node, MapProc, MapId, LineId, X, Y);
				_ ->
					nothing
			end;
		true ->
			nothing
	end.

hook_on_be_killed(EnemyId, EnemyType) ->
	{State, _, _, _, _, _, _, _, _} = get(dead_valley_info),
	if
		State =:= true ->
			SelfInfo = creature_op:get_creature_info(),
			SelfId = creature_op:get_id_from_creature_info(SelfInfo),
			if
				EnemyType =:= role, SelfId =/= EnemyId ->
					ParamSelf = system_chat_util:make_role_param(SelfInfo),
					EnemyInfo = creature_op:get_creature_info(EnemyId),
				    ParamEnemy = system_chat_util:make_role_param(EnemyInfo),
				    MsgInfo = [ParamSelf,ParamEnemy],
				    system_chat_op:system_broadcast(1198,MsgInfo),
					EquipmentsCanDrop = get_equipments_can_drop(),
					do_drop_equipment(EquipmentsCanDrop),
					ProtoInfo = dead_valley_db:get_proto_info(),
					{PersonVal, _, _} = dead_valley_db:get_proto_points(ProtoInfo),
					role_pos_util:send_to_role(EnemyId, {dead_valley_points, PersonVal});
				true ->
					nothing
			end,
			map_script:run_script(on_leave);
		true ->
			nothing
	end.

update_points(Points) ->
	{State, Node, LineId, MapId, MapProc, Pos, LeaveTime, PointsOld, Exp} = get(dead_valley_info),
	NewPoints = PointsOld + Points,
	put(dead_valley_info, {State, Node, LineId, MapId, MapProc, Pos, LeaveTime, NewPoints, Exp}),
	Msg = dead_valley_packet:encode_dead_valley_points_update_s2c(NewPoints),
	role_op:send_data_to_gate(Msg).

update_exp(Exp) ->
	{State, Node, LineId, MapId, MapProc, Pos, LeaveTime, Point, ExpOld} = get(dead_valley_info),
	if
		State =:= true ->
			NowExp = ExpOld + Exp,
			put(dead_valley_info, {State, Node, LineId, MapId, MapProc, Pos, 
				LeaveTime, Point, NowExp}),
			Msg = dead_valley_packet:encode_dead_valley_exp_update_s2c(NowExp),
			role_op:send_data_to_gate(Msg);
		true ->
			nothing
	end.

add_equipment_to_package(EquipmentInfo) ->
	ItemId = itemid_generator:gen_newid(),
	EquipmentInfo1 = set_id_to_iteminfo(EquipmentInfo, ItemId),
	EquipmentInfo2 = set_ownerid_to_iteminfo(EquipmentInfo1, get(roleid)),
	[NewSlot | _] = package_op:get_empty_slot_in_package(1),
	EquipmentInfo3 = set_slot_to_iteminfo(EquipmentInfo2, NewSlot),
	slogger:msg("dead_valley, equipment pick up, EquipmentInfo: ~p~n", [EquipmentInfo3]),
	items_op:add_new_item_by_info(EquipmentInfo3),
	package_op:set_item_to_slot(NewSlot, ItemId, 1),
	Message = role_packet:encode_add_item_s2c(EquipmentInfo3),
	role_op:send_data_to_gate(Message),	
	ItemProtoId = get_template_id_from_iteminfo(EquipmentInfo3),
	SelfInfo = creature_op:get_creature_info(),
	ParamSelf = system_chat_util:make_role_param(SelfInfo),
    ParamItem = system_chat_util:make_item_param(ItemProtoId),
    MsgInfo = [ParamSelf,ParamItem],
    system_chat_op:system_broadcast(1206,MsgInfo),
	quest_op:update({obt_item, ItemProtoId}),
	achieve_op:achieve_update({item}, [ItemProtoId], 1),
	gm_logger_role:role_get_item(get(roleid), [ItemId], 1, ItemProtoId, dead_valley_pickup, get(level)),
	ProtoInfo = dead_valley_db:get_proto_info(),
	{_, _, ConsumeVal} = dead_valley_db:get_proto_points(ProtoInfo),
	update_points(-ConsumeVal).

is_in_dead_valley() ->
	{State, _, _, _, _, _, _, _, _} = get(dead_valley_info),
	State =:= true.

duration_check() ->
	is_open_time().

touch_trap(TrapId) ->
	CreatureInfo = creature_op:get_creature_info(TrapId),
	TrapTouchCheck = if
		CreatureInfo =:= undefined ->
			false;
		true ->
			NpcFlag = creature_op:get_npcflags_from_creature_info(CreatureInfo),
			if
				NpcFlag =:= ?CREATURE_TRAP ->
					MyPos = creature_op:get_pos_from_creature_info(get(creature_info)),
					TargetPos = creature_op:get_pos_from_creature_info(CreatureInfo),
					util:is_in_range(MyPos, TargetPos, ?DEAD_VALLEY_TRAP_TOUCH_RANGE);
				true ->
					false
			end
	end,
	if
		TrapTouchCheck =:= true ->
			TrapList = get(trap_list),
			TapList2 = case lists:keymember(TrapId, 1, TrapList) of
				false ->
					ProtoId = get_templateid_from_npcinfo(CreatureInfo),
					TrapInfo = dead_valley_db:get_trap_info(ProtoId),
					{BuffId, BuffLevel} = dead_valley_db:get_trap_buffer(TrapInfo),
					role_op:add_buffers_by_self([{BuffId, BuffLevel}]),
					[{TrapId, {BuffId, BuffLevel}} | TrapList];
				true ->
					TrapList
			end,
			put(trap_list, TapList2);
		true ->
			nothing
	end.

leave_trap(TrapId) ->
	CreatureInfo = creature_op:get_creature_info(TrapId),
	TrapLeaveCheck = if
		CreatureInfo =:= undefined ->
			true;
		true ->
			NpcFlag = creature_op:get_npcflags_from_creature_info(CreatureInfo),
			if
				NpcFlag =:= ?CREATURE_TRAP ->
					MyPos = creature_op:get_pos_from_creature_info(get(creature_info)),
					TargetPos = creature_op:get_pos_from_creature_info(CreatureInfo),
					not util:is_in_range(MyPos, TargetPos, ?DEAD_VALLEY_TRAP_LEAVE_RANGE);
				true ->
					false
			end
	end,
	if
		TrapLeaveCheck =:= true ->
			TrapList = get(trap_list),
			TapList2 = case lists:keyfind(TrapId, 1, TrapList) of
				{TrapId, {BuffId, BuffLevel}} ->
					role_op:remove_buffers([{BuffId, BuffLevel}]),
					lists:keydelete(TrapId, 1, TrapList);
				false ->
					TrapList
			end,
			put(trap_list, TapList2);
		true ->
			nothing
	end.

hook_on_respawn() ->
	case is_in_dead_valley() of
		true ->
			case check_equipments_can_drop() of
				true ->
					MapId = get_mapid_from_mapinfo(get(map_info)),
					MapProtoInfo = map_info_db:get_map_info(MapId),
					map_script:run_script(on_join,MapProtoInfo);
				false ->
					Msg = dead_valley_packet:encode_dead_valley_force_leave_s2c(),
					role_op:send_data_to_gate(Msg),
					leave_map()
			end;
		false ->
			nothing
	end.

query_zone_info() ->
	Msg = case dead_valley_manager:query_zone_info() of
		{error, ErrNo} ->
			pet_packet:encode_send_error_s2c(ErrNo);
		{ok, ZoneInfo} ->
			Info = lists:map(fun({ZoneId, ZoneCount}) ->
				ZoneCntInfo = dead_valley_db:get_zone_count_info(ZoneId),
				ZoneMaxCnt = dead_valley_db:get_zone_max_count(ZoneCntInfo),
				#dead_valley_zone{id = ZoneId, num = ZoneCount, max = ZoneMaxCnt}
			end, ZoneInfo),
			dead_valley_packet:encode_dead_valley_query_zone_info_s2c(Info)
	end,
	role_op:send_data_to_gate(Msg).

%% ============================================================================
%%
%% Local Functions
%%
%% ============================================================================

do_enter_map(ZoneId) ->
	case dead_valley_manager:join(ZoneId) of
		{ok, InstanceProc} ->
			RoleInfo = creature_op:get_creature_info(),
			Pos = creature_op:get_pos_from_creature_info(RoleInfo),
			MapInfo = get(map_info),
			MapId = get_mapid_from_mapinfo(MapInfo),
			LineId = get_lineid_from_mapinfo(MapInfo),
			MapProc = get_proc_from_mapinfo(MapInfo),
			Node = node(),
			ProtoInfo = dead_valley_db:get_proto_info(),
			MapId2 = dead_valley_db:get_map_id(ProtoInfo),
			PosList = dead_valley_db:get_transports(ProtoInfo),
			{X, Y} = lists:nth(random:uniform(length(PosList)), PosList),
			MapNode2 = travel_battle_util:get_zone_map_node(ZoneId),
			{_, _, _, _, _, _, LeaveTime, Points, Exp} = get(dead_valley_info),
			TimeDelta = timer:now_diff(timer_center:get_correct_now(), LeaveTime),
			if
				TimeDelta >= ?DEAD_VALLEY_DATA_OVERDUE_TIME * 1000 * 1000 ->
					Points2 = 0,
					Exp2 = 0;
				true ->
					Points2 = Points,
					Exp2 = Exp
			end,
			put(dead_valley_info, {true, Node, LineId, MapId, MapProc, Pos, {0, 0, 0}, Points2, Exp2}),
			Msg = dead_valley_packet:encode_dead_valley_points_update_s2c(Points2),
			role_op:send_data_to_gate(Msg),
			Msg2 = dead_valley_packet:encode_dead_valley_exp_update_s2c(Exp2),
			role_op:send_data_to_gate(Msg2),
			role_op:change_map_in_other_node_begin(MapInfo, MapNode2, InstanceProc, MapId2, ?TRAVEL_BATTLE_LINE_ID, X, Y);
		{error, ErrNo} ->
			Msg = pet_packet:encode_send_error_s2c(ErrNo),
			role_op:send_data_to_gate(Msg)
	end.

is_open_time() ->
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
	lists:any(fun({Secs, Duration}) ->
		Secs - ?DEAD_VALLEY_BUFF_TIME =< NowSecs andalso
		NowSecs =< Secs + (Duration div 1000) + ?DEAD_VALLEY_BUFF_TIME
	end, StartLines).

check_equipments_can_drop() ->
	get_equipments_can_drop() =/= [].

clear_trap_buffers() ->
	BuffList = [{BuffId, BuffLevel} || {_, {BuffId, BuffLevel}} <- get(trap_list)],
	role_op:remove_buffers(BuffList),
	put(trap_list, []).

get_equipments_can_drop() ->
	lists:filter(fun(EquipmentId) ->
		EquipmentInfo = items_op:get_item_info(EquipmentId),
		Class = get_class_from_iteminfo(EquipmentInfo),
        Class =/= ?ITEM_TYPE_RIDE andalso Class =/= ?ITEM_TYPE_FASHION andalso
        Class =/= ?ITEM_TYPE_MANTEAU
	end, package_op:get_body_items_id()).

do_drop_equipment(EquipmentsCanDrop) ->
	ProtoInfo = dead_valley_db:get_proto_info(),
	DropRate = dead_valley_db:get_proto_drop_rate(ProtoInfo),
	case random:uniform(100) =< DropRate of
		true ->
			Idx = random:uniform(length(EquipmentsCanDrop)),
			EquipmentDrop = lists:nth(Idx, EquipmentsCanDrop),
			EquipmentDropInfo = items_op:get_item_info(EquipmentDrop),
			role_op:proc_destroy_equip(EquipmentDropInfo, dead_valley_drop),
			MyPos = creature_op:get_pos_from_creature_info(get(creature_info)),
			slogger:msg("dead_valley, equipment drop, EquipmentInfo: ~p~n", [EquipmentDropInfo]),
			ProtoInfo = dead_valley_db:get_proto_info(),
			ProtoId = dead_valley_db:get_proto_equipment(ProtoInfo),
			creature_op:call_creature_spawn_by_create(ProtoId, MyPos,
				{?CREATOR_LEVEL_BY_SYSTEM, EquipmentDropInfo}),
			SelfInfo = creature_op:get_creature_info(),
			ParamSelf = system_chat_util:make_role_param(SelfInfo),
			ItemProtoId = get_template_id_from_iteminfo(EquipmentDropInfo),
		    ParamItem = system_chat_util:make_item_param(ItemProtoId),
		    MsgInfo = [ParamSelf,ParamItem],
		    system_chat_op:system_broadcast(1199,MsgInfo);
		false ->
			nothing
	end.

init(LeaveTime, Points, Exp) ->
	put(dead_valley_info, {false, undefined, undefined, undefined, undefined, 
		undefined, LeaveTime, Points, Exp}),
	put(trap_list, []).

check_cooldown_time_ok() ->
	{_, _, _, _, _, _, LeaveTime, _, _} = get(dead_valley_info),
	ProtoInfo = dead_valley_db:get_proto_info(),
	CoolDown = dead_valley_db:get_proto_cooldown(ProtoInfo),
	timer:now_diff(timer_center:get_correct_now(), LeaveTime) > CoolDown * 1000.