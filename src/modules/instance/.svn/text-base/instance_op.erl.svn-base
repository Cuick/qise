-module(instance_op).

-include("data_struct.hrl").

-include("role_struct.hrl").
-include("map_info_struct.hrl").
-include("common_define.hrl").
-include("instance_define.hrl").
-include("error_msg.hrl").
-include("npc_define.hrl").
-include("effect_define.hrl").
-include("wedding_def.hrl").



-compile(export_all).

%%{Instanceid,Map_proc,protoid,Starttime,Lastpostion}
%%lastpostion:{LineId,Mapid,{LastX,LastY}}
%% instance_log:[{protoid,firsttime,count,lastid}]

-define(GOLD_TYPE, 1).
-define(SILVER_TYPE, 2).

-define(CONTENT, 319).

%%副本元宝委托
process_message({instance_entrust_c2s,_,ProtoId,Times,Type})->
	slogger:msg("instance_op:instance_entrust_c2s Instance_id:~p Times:~p~n",[ProtoId,Times]),
	case Type of
	?GOLD_TYPE -> do_instance_entrust(ProtoId,Times);
	?SILVER_TYPE -> do_instance_entrust_silver(ProtoId, Times);
	_ -> ok
	end.

put_when_true(Key,Value)->
	case get(Key) =:= true orelse get(Key) =:=undefined of
	true-> put(Key,Value);
	false->nothing	
	end.	
%%
%%处理副本元宝委托
%%
do_instance_entrust(ProtoId,Times) when Times > 0 ->
    slogger:msg("instance_op:instance_entrust_c2s instance_entrust_db:~p~n",[instance_entrust_db:get_info(ProtoId)]),
 	{_,_,Gold,Level,Fighting_force,Gifts,Unknown_val} = instance_entrust_db:get_info(ProtoId),
	ProtoInfo = instance_proto_db:get_info(ProtoId),
	
	case 	check_datetimes_public(ProtoInfo,false,[],Times) of
	true->	put(instance_entrust_flag,true);		
	false->
       put(instance_entrust_flag,times)
	end,

	case  get(instance_entrust_flag) =:=true andalso role_op:check_money(?MONEY_GOLD, Gold*Times) of
	true->nothing;
	false->
		   put_when_true(instance_entrust_flag,gold)
	end,
	
	case get(instance_entrust_flag) =:=true  andalso get(level)>=Level of
	true->nothing;		
	false->
       put_when_true(instance_entrust_flag,level)
	end,
	
	case  get(instance_entrust_flag) =:=true  andalso get_fighting_force_from_roleinfo(get(creature_info))>=Fighting_force of
	true->nothing;
	false->
       put_when_true(instance_entrust_flag,fight_force)
	end,
	
    case  get(instance_entrust_flag)  of 
    true->
		Gifts1 = lists:foldl(
			fun({GiftTmp,CountTmp},Gifts0)->
			[{GiftTmp,CountTmp*Times}|Gifts0]
		  	end, [], Gifts),
		F = fun() ->
			Vip_addition = vip_op:get_addition_with_vip(entrust_addition),
			ExpRateList = get_expratio_from_roleinfo(get(creature_info)),
			case lists:keyfind(?EFFECT_EXP_ENTRUST,1,ExpRateList) of
				false->
					ExpRate = 1;
				{_,Value}->
					ExpRate = 1 + Value/100
			end,
			Exp = erlang:trunc(Unknown_val * get(level) * ExpRate * Times * (1+Vip_addition)),
			role_op:obtain_exp(Exp),
			role_op:money_change(?MONEY_GOLD, -1*Gold*Times, 'do_instance_entrust'),
			take_instance_entrust_flag(ProtoId,ProtoInfo,Times, "instance_entrust", Exp)
			end,
		send_gift(Gifts1, Times, "do_instance_entrust", F, ProtoId);
	Err->
		send_error_by_reason(Err)
	end;
do_instance_entrust(_,_) ->
	nothing.

check_silver(Num) ->
	case role_op:check_money(?MONEY_BOUND_SILVER, Num) of
	false ->
		BoundNum = get_boundsilver_from_roleinfo(get(creature_info)),
		Silver  = Num - BoundNum,
		case role_op:check_money(?MONEY_SILVER, BoundNum) of
		false -> {0, 0, false};
		true -> {Silver, BoundNum, true}
		end;
	true ->
		{0, Num, true}
	end.

check_fighting_force(Num) ->
	get_fighting_force_from_roleinfo(get(creature_info)) >= Num.

send_gift(Gifts, Times, Type, F, ProtoId) ->
	Gifts1 = lists:foldl(fun({GiftTmp,CountTmp},Gifts0)->
		[{GiftTmp,CountTmp*Times}|Gifts0]
	end, [], Gifts),
	case package_op:can_added_to_package_template_list(Gifts1) of
		false ->
			#gm_role_info{name=RoleName} = get(creature_info),

			ProtoInfo = instance_proto_db:get_info(ProtoId),
			MapId = instance_proto_db:get_level_mapid(ProtoInfo),
			MapInfo = map_info_db:get_map_info(MapId),
			MapName = map_info_db:get_map_name(MapInfo),

			FromName = MapName,
			Title = MapName,
			Content = language:get_string(?CONTENT),
			case mail_op:gm_send_multi(FromName, RoleName, Title, Content, Gifts1, 0) of
			{failed, Err} -> send_error_by_reason(Err);
			_ -> F()
			end;
		true ->
			lists:foreach(
				fun({Gift,Count})->
				role_op:auto_create_and_put(Gift,Count,Type)
				end, Gifts1),
			F()
	end.

% 铜钱委托
do_instance_entrust_silver(ProtoId,Times) ->
	{_,_,NeedSilver,Level,Fighting_force,Gifts,Unknown_val} = instance_entrust_db:get_info_s(ProtoId),
	ProtoInfo = instance_proto_db:get_info(ProtoId),
	case check_datetimes_public(ProtoInfo, false, [], Times) of
		false ->
			send_error_by_reason(times);
		true ->
			C_UserLevel = get(level) >= Level,
			C_FightForce = check_fighting_force(Fighting_force),
			case check_silver(NeedSilver*Times) of
			{_, _, false} ->
				send_error_by_reason(silver);
			{_, _, true} when not C_UserLevel ->
				send_error_by_reason(level);
			{_, _, true} when not C_FightForce ->
				send_error_by_reason(fight_force);
			{Silver, BoundNum, true} ->
				F = fun() ->
					Vip_addition = vip_op:get_addition_with_vip(entrust_addition),
					ExpRateList = get_expratio_from_roleinfo(get(creature_info)),
					case lists:keyfind(?EFFECT_EXP_ENTRUST,1,ExpRateList) of
						false->
							ExpRate = 1;
						{_,Value}->
							ExpRate = 1 + Value/100
					end,
					slogger:msg("~p ~p ~p ~p ~p ~n", [Unknown_val, get(level), ExpRate, Times, (1+Vip_addition)]),
					Exp = erlang:trunc(Unknown_val * get(level) * ExpRate * Times * (1+Vip_addition)),
					role_op:obtain_exp(Exp),
					role_op:money_change(?MONEY_SILVER, -Silver, 'do_instance_entrust_silver'),
					role_op:money_change(?MONEY_BOUND_SILVER, -BoundNum, 'do_instance_entrust_silver'),
					take_instance_entrust_flag(ProtoId,ProtoInfo,Times,"instance_entrust_silver",Exp)
					end,
				send_gift(Gifts, Times, "do_instance_entrust_silver", F, ProtoId);
			_ -> ok
			end
	end.

take_instance_entrust_flag(ProtoId,ProtoInfo,Times,ProcName,Exp)->
	Type = instance_proto_db:get_type(ProtoInfo),
	OriLog = get(instance_log),
    %%默认单人组队
    put(group_info_old,get(group_info)),
    put(group_info,{{get(roleid),timer_center:get_correct_now()},0,0,[]}),
	InstanceId = make_instance_id(Type,ProtoId),
	{_,CountRestict} = instance_proto_db:get_datetimes(ProtoInfo),
	if CountRestict =/= 0  ->
			NOriLog = lists:filter(
				fun({Id, _, _, _}) -> ProtoId == Id;
				   ({Id, _, _, _, _, _}) -> ProtoId == Id
				end, OriLog),
			case NOriLog of
			[] ->
				put(instance_log,[{ProtoId,timer_center:get_correct_now(),Times,ProcName,Exp,Times}|OriLog]);
			NOriLog ->
				case hd(NOriLog) of
				{_,_,Max,_} -> Max;
				{_,_,Max,_,_,_} -> Max
				end,

				case lists:keyfind(ProcName, 4, NOriLog) of
				false ->
					put(instance_log,[{ProtoId,timer_center:get_correct_now(),Times+Max,ProcName,Exp,Times}|OriLog]);
				{ProtoId,_Ftime, Count, ProcName} ->
					put(instance_log,[{ProtoId,timer_center:get_correct_now(),Times+Max,ProcName,Exp,Times}|OriLog]);
				{ProtoId,_Ftime, Count, ProcName, OExp, EnTrustTimes} ->
					put(instance_log,[{ProtoId,timer_center:get_correct_now(),Times+Max, ProcName, OExp+Exp, EnTrustTimes+Times}|OriLog])
				end
			end;
	true->		%%no need log
%% 			put(instance_log,[{ProtoId,timer_center:get_correct_now(),Times,ProcName}])
			put(instance_log,[{ProtoId,timer_center:get_correct_now(),Times,ProcName,Exp,Times}])
			%%gm_logger_role:role_join_instance(get(roleid),get(level),group_op:get_member_id_list(),InstanceId,ProtoId,1)
	end,
    activity_value_op:update_public({instance,ProtoId},1,Times),
	Log = get(instance_log),
	role_instance_db:save_role_instance_info(get(roleid),0,InstanceId,0,Log),
	put(group_info,get(group_info_old)),
	%% jianhua.zhu 叫加的，应该没有必要的
    get_my_instance_count().



init()->
	put(instance,{0,0,0,0,{0,0,{0,0}}}),
	put(instance_log,[]).

load_from_db(RoleId)->
	%%slogger:msg("instance_op:load_from_db  InstanceInfo:~p ~n" ,[88888]),
	case role_instance_db:get_role_instance_info(RoleId) of
		[]->
			init();
		InstanceInfo->
			InstanceId = role_instance_db:get_instanceid(InstanceInfo),
			LastPos = role_instance_db:get_lastpostion(InstanceInfo),
			Log = role_instance_db:get_log(InstanceInfo),
			StartTime = role_instance_db:get_starttime(InstanceInfo),
			put(instance,{InstanceId,0,0,StartTime ,LastPos}),
			NewLog = lists:map(fun(LogInfo)->
						case LogInfo of
							{Proto,FirstTime,Count}->
								{Proto,FirstTime,Count,0,0,0};
							{Proto,FirstTime,Count,LastId}->
								{Proto,FirstTime,Count,LastId,0,0};
							{Proto,FirstTime,Count,LastId,Exp,EnTrustTimes}->
								{Proto,FirstTime,Count,LastId,Exp,EnTrustTimes}
						end
					end,Log),
			put(instance_log,NewLog),
			slogger:msg("instance_log ~p", [NewLog])
	end.


	

is_in_instance()->
	{Instanceid,_,_,_,_} = get(instance),
	Instanceid =/= 0.

get_cur_protoid()->
	{_Instanceid,_Map_proc,Protoid,_Starttime,_Lastpostion} = get(instance),
	Protoid.

export_for_copy()->
	{get(instance),get(instance_log)}.

write_to_db()->
	{InstanceId,_,_,StartTime,LastPos} = get(instance),
	Log = get(instance_log),
	role_instance_db:save_role_instance_info(get(roleid),StartTime,InstanceId,LastPos,Log).

async_write_to_db()->
	{InstanceId,_,_,StartTime,LastPos} = get(instance),
	Log = get(instance_log),
	role_instance_db:async_save_role_instance_info(get(roleid),StartTime,InstanceId,LastPos,Log).

load_by_copy({Info,Log})->
	put(instance,Info),
	put(instance_log,Log).

get_old_line()->
	{_Instanceid,_,_,_,Lastpostion} = get(instance),
 	{LineId,_Mapid,{_LastX,_LastY}} = Lastpostion,
	LineId.

%%on change_map for leave_instance
on_change_map(NewMapProc)->
	{InstanceId,_,_,_,_} = get(instance),
	NowProc = get_proc_from_mapinfo(get(map_info)),			%%maybe trans instance from instance,and MapProc in get(instance) =:= NewMapProc now ,so,we should use NowProc in map_info
	if
		(InstanceId =/= 0) and (NowProc =/= NewMapProc)->						%%leave instance
			leave_instance();
		true->
			nothing
	end.

on_offline()->
	{InstanceId,MapProc,_,_,_} = get(instance),
	if
		InstanceId =/= 0->
			map_processor:leave_instance(get(roleid),MapProc,offline);
		true->
			nothing
	end.

%%kick out from group
on_group_destroy(GroupId)->
	kick_instance_by_reason({?INSTANCE_TYPE_GROUP,GroupId}).

kick_from_cur_instance()->
	{Instanceid,MapProc,_,_,_} = get(instance),
	if
		Instanceid =/= 0->
			map_processor:leave_instance(get(roleid),MapProc),
			back_home(MapProc);
		true->
			nothing
	end.

kick_instance_by_reason({Type,Creation})->
	{Instanceid,MapProc,Proto,_,_} = get(instance),
	Proc = make_instance_id(Type,Creation,Proto),
	if
		Proc =:= Instanceid ->
			map_processor:leave_instance(get(roleid),MapProc),
			back_home(MapProc);
		true->
			nothing
	end.

on_leave_from_instance()->
	role_chess_spirits:hook_on_kick_from_instance().

%%disband group!TODO:delete all instance by groupid
on_group_disband(GroupId)->%%TODO======================================================================
	CreationTag = make_creation_tag(?INSTANCE_TYPE_GROUP,GroupId),
	destroy_instance_by_creation(CreationTag).

destroy_instance_by_creation(Creation)->
	case instance_pos_db:get_instance_pos_from_mnesia_by_creation(Creation) of
		[]->
			nothing;
		Instances->
			lists:foreach(fun({_,_,_,_,_,Node,MapProc,_,_,_})-> map_processor:destroy_instance(Node,MapProc) end,Instances)
	end.

back_home(DestroyProcName)->
	on_leave_from_instance(),
	{_,MapProc,_,_,LastPos} = get(instance),
	{OldLine,OldMapId,Coord} = LastPos,				%%use now line
	MapInfo = get(map_info),
	% 离开当前地图后清buffer
	buffer_op:clear_buffer_for_level_map(get_mapid_from_mapinfo(MapInfo)),
	if
		DestroyProcName =:= MapProc-> 
			role_op:transport(get(creature_info), MapInfo,OldLine,OldMapId,Coord);
		true->								%%not in instance
			nothing
	end.

get_instance_times(ProtoId)->
	OriLog = get(instance_log),
	case lists:keyfind(ProtoId,1,OriLog) of
		{ProtoId,_,Count,_}->
			Count;
		{ProtoId,_,Count,_,_,_} ->
			Count;
		false->
			0
	end.

on_join_send(ProtoInfo,Starttime)->
	ProtoId = instance_proto_db:get_protoid(ProtoInfo),
	Time = instance_proto_db:get_duration_time(ProtoInfo),
	Duration = Time - erlang:trunc(timer:now_diff(timer_center:get_correct_now(),Starttime)/1000),
	Times = get_instance_times(ProtoId),
	Msg = role_packet:encode_instance_info_s2c(ProtoId,Times,Duration),
	role_op:send_data_to_gate(Msg).

%%check instance or not
on_line_by_instance(_NowMapId,NowLineId,MapInfo)->
	{Instanceid,_,_,Starttime,Lastpostion} = get(instance),
	OldMapNode = get_node_from_mapinfo(MapInfo),
	case instance_pos_db:get_instance_pos_from_mnesia(Instanceid) of	
		[]->
			StillInInstance = false;
		{Instanceid,_Creation,InstanceTime,CanJoin,InstanceNode ,MapProc,MapId,ProtoId,Members}->
			ProtoInfo = instance_proto_db:get_info(ProtoId),
			Type = instance_proto_db:get_type(ProtoInfo),
			NumCheck = check_membernum(ProtoInfo,Members),
			put(instance,{Instanceid,MapProc,ProtoId,Starttime,Lastpostion}),
			TypeCheck = (check_type(Type) =:= true),
			if
				%%(Starttime =/= InstanceTime) : maybe same creation instance but starttime is not mine
				(Starttime =/= InstanceTime)  or (not CanJoin) or (not NumCheck) or (not TypeCheck) ->			%%another instance,not main
					StillInInstance = false;
				true->									
					case make_instance_id(Type,ProtoId) =:= Instanceid of						
						true->					%%in instance still
							case map_processor:join_instance(get(roleid),MapProc,InstanceNode) of
								{ok,InstanceStartTime}->
									LineId = ?INSTANCE_LINEID,
									{X,Y} = get_pos_from_roleinfo(get(creature_info)),
									on_join_send(ProtoInfo,Starttime),
									if
										InstanceNode =:= OldMapNode ->
											role_op:change_map_in_same_node(MapInfo,InstanceNode,MapProc,MapId,LineId,X,Y);
										true->
											role_op:change_map_in_other_node_begin(MapInfo,InstanceNode,MapProc,MapId,LineId,X,Y)
									end,
									StillInInstance = true;
								error->
									StillInInstance = false,
									send_error_by_reason(error),
									slogger:msg("on_line_by_instance  join_instance error~n")
							end;
						_->
							StillInInstance = false
					end
			end
	end,
	if
		not StillInInstance->				%%need trans to old map
			clear_instance(),
			{_OldLine,OldMapId,Coord} = Lastpostion,				%%use now line
			role_op:transport(get(creature_info), MapInfo,NowLineId,OldMapId,Coord);
		true->
			nothing
	end.	

clear_instance()->
	put(instance,{0,0,0,0,{0,0,{0,0}}}).

can_role_trans_to_instance(TransInfo)->
	ProtoId = transport_db:get_channel_mapid(TransInfo),
	ProtoInfo = instance_proto_db:get_info(ProtoId),
	case get_role_instance_trans_deatail(ProtoInfo) of
		{false,Reason}->
			send_error_by_reason(Reason),
			false;
		_->
			true
	end.

%% return: 
%% {false,Reason} : can't trans for Reason
%% {true,NeedCreate,InstanceNode,MapProc}

get_role_instance_trans_deatail(ProtoInfo)->
	case travel_battle_op:is_in_zone() of
		true ->
			{false, travel_battle_start};
		_ ->
			Type = instance_proto_db:get_type(ProtoInfo),
			ProtoId = instance_proto_db:get_protoid(ProtoInfo),
			case check_type(Type) of
				true->
					InstanceId = make_instance_id(Type,ProtoId),
					case instance_pos_db:get_instance_pos_from_mnesia(InstanceId) of			
						[]->
							Members = [],
							case can_create(Type,ProtoInfo) of
								true->
									Goon = true;
								Error->
									Goon = Error
							end,
							NeedCreate = true,
							InstanceNode = [],
							MapProc = [],
							Members = [];
						{_Id,_Creation,_,CanJoin,InstanceNode ,MapProc,_MapId,OriProtoId,Members}->
							if
								OriProtoId =/=  ProtoId->
									Goon = already_exsit;
								not CanJoin ->
									Goon = resetting;
								true->
									Goon = true
							end,							
							NeedCreate = false
					end,
					if
						Goon ->
							case can_teleport(ProtoInfo,Members,NeedCreate,MapProc) of
								true->
									{true,NeedCreate,InstanceNode,MapProc,Members};
								Reason->
									{false,Reason}
							end;
						true->
							{false,Goon}
					end;
				Error2->
					{false,Error2}
			end
	end.

instance_trans(MapInfo,ProtoId,MapPos)->
	ProtoInfo = instance_proto_db:get_info(ProtoId),
	Type = instance_proto_db:get_type(ProtoInfo),
	MapId = instance_proto_db:get_level_mapid(ProtoInfo),
	case get_role_instance_trans_deatail(ProtoInfo) of
		{true,NeedCreate,InstanceNode,MapProc,Members}->
			trans_to_dungeon(NeedCreate,MapProc,MapInfo,MapPos,Type,ProtoInfo,InstanceNode,MapId,Members);
		{false,Reason}->
			send_error_by_reason(Reason)
	end.

trans_to_dungeon(NeedCreate,MapProc,MapInfo,Coord,Type,ProtoInfo,ProcNode,MapId,Members)->
	OldLineId = get_lineid_from_mapinfo(MapInfo),
	OldMapId = get_mapid_from_mapinfo(MapInfo),
	OldMapNode = get_node_from_mapinfo(MapInfo),
	if
		ProcNode =:= []->
			InstanceNode = OldMapNode;
		true->
			InstanceNode = ProcNode
	end,
	LineId = ?INSTANCE_LINEID,
	ProtoId = instance_proto_db:get_protoid(ProtoInfo),
	InstanceId = make_instance_id(Type,ProtoId ),
	Creation = make_creation_tag(Type),
	{X,Y} = Coord,
	if
		NeedCreate ->
			case instanceid_generator:get_procname(InstanceId) of
				[]->
					Goon = false,
					ProcName = [],
					slogger:msg("map_manager:start_instance get_procname error ~n");
				{exsit,ProcName}->
					slogger:msg("instanceid_generator:get_procname InstanceId error ~p RoleId ~p ~n",[InstanceId,get(roleid)]),
					Goon = false;
				ProcName->
					MyLevel = get_level_from_roleinfo(get(creature_info)),
					case map_manager:start_instance(ProcName,MapId,instance,{MyLevel,?CREATOR_BY_SYSTEM},{Creation,ProtoId}) of
						ok->
							CreateItems = instance_proto_db:get_create_item(ProtoInfo),
							lists:foreach(fun({ItemTemp,Count})->role_op:consume_items(ItemTemp,Count) end,CreateItems),
							instance_create_to_notify(ProtoInfo,Coord),
							Goon = true;				
						error->
							Goon = false,
							slogger:msg("map_manager:start_instance error ~n")
					end
			end;
		true->
			ProcName = MapProc,
			Goon = true			
	end,
	if
		Goon->
			group_op:hook_on_join_instance(),
			case map_processor:join_instance(get(roleid),ProcName,InstanceNode) of
				{ok,InstanceStartTime}->
					instance_quality_op:bakup_instance_quality(ProtoId),
					instance_quality_op:reset_instance_quality(ProtoId),
					instance_quality_op:reset_instance_free_quality_time(ProtoId),
					join_instance(InstanceId,ProcName,ProtoInfo,OldLineId,OldMapId,InstanceStartTime),
					on_join_send(ProtoInfo,InstanceStartTime),
					if
						Type =:= ?INSTANCE_TYPE_GROUP ->
							add_intimacy(Members);
						true ->
							nothing
					end,
					if
						NeedCreate or (InstanceNode =:= OldMapNode) ->
							role_op:change_map_in_same_node(MapInfo,OldMapNode,ProcName,MapId,LineId,X,Y);
						true->
							role_op:change_map_in_other_node_begin(MapInfo,InstanceNode,ProcName,MapId,LineId,X,Y)
					end;
				error->
					send_error_by_reason(error),
					slogger:msg("map_processor:join_instance error~n")
			end;
		true->
			send_error_by_reason(resetting)
	end.

join_instance(InstanceId,ProcName,ProtoInfo,LineId,MapId,InstanceStartTime)->
	ProtoId = instance_proto_db:get_protoid(ProtoInfo),
	{OldInstanceId,_,_,_,OriPos} = get(instance),
	OriLog = get(instance_log),
	if
		OldInstanceId =/= 0->		%%join_instance from instance
			NewOriMap = OriPos;
		true->
			NowPos = get_pos_from_roleinfo(get(creature_info)),
			NewOriMap = {LineId,MapId,NowPos}
	end,
	{_,CountRestict} = instance_proto_db:get_datetimes(ProtoInfo),
	InsType = instance_proto_db:get_type(ProtoInfo),
	if
		CountRestict =/= 0->	
			case lists:keyfind(ProtoId,1,OriLog) of
				false->
					put(instance,{InstanceId,ProcName,ProtoId,InstanceStartTime,NewOriMap}),
					put(instance_log,[{ProtoId,timer_center:get_correct_now(),1,ProcName,0,0}|OriLog]),
					activity_value_op:update({instance,ProtoId}),
					gm_logger_role:role_join_instance(get(roleid),get(level),group_op:get_member_id_list(),InstanceId,ProtoId,1);
				{ProtoId,FTime,Count,LastProc}->
					put(instance,{InstanceId,ProcName,ProtoId,InstanceStartTime,NewOriMap}),
					if
						ProcName=/=LastProc->
							NewLogTemp = lists:keyreplace(ProtoId,1,OriLog,{ProtoId,FTime,Count+1,ProcName}),
							case Count>= (CountRestict+vip_op:get_addition_with_vip({instance,ProtoId})) of 		%%must destroy items
								true->
									Items = instance_proto_db:get_item_need(ProtoInfo),
									lists:foreach(fun({ItemTemp,CountTmp})->role_op:consume_items(ItemTemp,CountTmp) end,Items),
									%%reduce next proto join time 
									case instance_proto_db:get_nextproto(ProtoInfo) of
										[]->
											NewLog = NewLogTemp;
										NextProtoList->
											NewLog =
												lists:foldl(fun(NextProto,NewLogAcc)->
													case lists:keyfind(NextProto,1,NewLogAcc) of
														false->
															NewLogAcc;
														{_,NFTime,NCount,NLastProc}->
															NewNCount = max(NCount - 1,0),
															lists:keyreplace(NextProto,1,NewLogAcc,{NextProto,NFTime,NewNCount,NLastProc})
													end
												end,NewLogTemp,NextProtoList)
									end;
								_->
									NewLog = NewLogTemp
							end,
							put(instance_log,NewLog),
							activity_value_op:update({instance,ProtoId}),
							gm_logger_role:role_join_instance(get(roleid),get(level),group_op:get_member_id_list(),InstanceId,ProtoId,Count+1);
						true->
							nothing
					end;
				{ProtoId,FTime,Count,LastProc,OExp, EnTrustTimes}->
					put(instance,{InstanceId,ProcName,ProtoId,InstanceStartTime,NewOriMap}),
					if
						ProcName=/=LastProc->
							NewLogTemp = lists:keyreplace(ProtoId,1,OriLog,{ProtoId,FTime,Count+1,ProcName,OExp,EnTrustTimes}),
							case Count>= (CountRestict+vip_op:get_addition_with_vip({instance,ProtoId})) of 		%%must destroy items
								true->
									Items = instance_proto_db:get_item_need(ProtoInfo),
									lists:foreach(fun({ItemTemp,CountTmp})->role_op:consume_items(ItemTemp,CountTmp) end,Items),
									case instance_proto_db:get_nextproto(ProtoInfo) of
										[]->
											NewLog = NewLogTemp;
										NextProtoList->
											NewLog =
												lists:foldl(fun(NextProto,NewLogAcc)->
													case lists:keyfind(NextProto,1,NewLogAcc) of
														false->
															NewLogAcc;
														{_,NFTime,NCount,NLastProc}->
															NewNCount = max(NCount - 1,0),
															lists:keyreplace(NextProto,1,NewLogAcc,{NextProto,NFTime,NewNCount,NLastProc});
														{_,NFTime,NCount,NLastProc,Exp, EnTrustTimes}->
															NewNCount = max(NCount - 1,0),
															lists:keyreplace(NextProto,1,NewLogAcc,{NextProto,NFTime,NewNCount,NLastProc,Exp,EnTrustTimes})
													end
												end,NewLogTemp,NextProtoList)
									end;
								_->
									NewLog = NewLogTemp
							end,
							put(instance_log,NewLog),
							activity_value_op:update({instance,ProtoId}),
							gm_logger_role:role_join_instance(get(roleid),get(level),group_op:get_member_id_list(),InstanceId,ProtoId,Count+1);
						true->
							nothing
					end
			end;
		true->					%%no need log
			put(instance,{InstanceId,ProcName,ProtoId,InstanceStartTime,NewOriMap}),
			activity_value_op:update({instance,ProtoId}),
			gm_logger_role:role_join_instance(get(roleid),get(level),group_op:get_member_id_list(),InstanceId,ProtoId,1)
	end.

leave_instance()->
	{_InstanceId,MapProc,ProtoId,_,_} = get(instance),
	MapProcName = get_proc_from_mapinfo(get(map_info)),
	map_processor:leave_instance(get(roleid),MapProcName),
	gm_logger_role:role_level_instance(get(roleid),get(level),group_op:get_member_id_list(),_InstanceId,ProtoId),
	if
		MapProc =:= MapProcName ->
			clear_instance();
		true->								%%trans to instance(NowInstance) from instance(MapProcName)
			nothing
	end.
	
instance_create_to_notify(ProtoInfo,Pos)->
	case instance_proto_db:get_create_leadertag(ProtoInfo) of
		true->
			case group_op:get_leader() =:= get(roleid) of
				true->
					ProtoId = instance_proto_db:get_protoid(ProtoInfo),
					group_op:send_to_all_without_self({group_instance_start,{ProtoId,Pos,get(roleid)}});
				_->
					nothing
			end;
		_->
			nothing
	end.
	
check_type(TransType)->			
	case TransType of
		?INSTANCE_TYPE_GROUP->
			case group_op:get_id() of
				0-> 
					group;
				_->
					true
			end;
		?INSTANCE_TYPE_GUILD->
			case guild_util:get_guild_id() of
				0->
					guild;
				_->
					true
			end;
		?INSTANCE_TYPE_TANGLE_BATTLE->
			battle;
		?INSTANCE_TYPE_CAMP_BATTLE->
		    battle;
		?INSTANCE_TYPE_YHZQ->
			battle;
		?INSTANCE_TYPE_JSZD->
			battle;
		?INSTANCE_TYPE_BANQUET->
			banquet;
		?INSTANCE_TYPE_GUILDBATTLE->
			guild_battle;
		?INSTANCE_TYPE_LOOP_INSTANCE->
			loop_instance;
		_->
			true
	end.

can_create(Type,ProtoInfo)->
	case check_create_leader(Type,ProtoInfo)of
		true->
			case check_create_item(ProtoInfo) of
				true->
					case check_create_membernum(Type,ProtoInfo) of	
						true->
							true;
						_->
							membernum
					end;
				_->
					item
			end;
		_->
			leader
	end.

check_create_leader(TransType,ProtoInfo)->
	if	
		TransType=:= ?INSTANCE_TYPE_GROUP->
			case instance_proto_db:get_create_leadertag(ProtoInfo) of
				true->
					group_op:get_leader()=:= get(roleid);
				_->
					true
			end;
		true->
			true
	end.

check_create_membernum(TransType,ProtoInfo)->
	case TransType of
		?INSTANCE_TYPE_GROUP->
			{MinNum,MaxNum} = instance_proto_db:get_membernum(ProtoInfo),
			MemberNum = erlang:length(group_op:get_members_info()),
			(MemberNum >= MinNum) and(MemberNum =< MaxNum);  
		?INSTANCE_TYPE_GUILD->
			true;
		_->
			true
	end.

check_create_item(ProtoInfo)->
	Items = instance_proto_db:get_create_item(ProtoInfo),
	lists:foldl(fun({TemplateId,Count},Result)->
						if
							Result->
								item_util:is_has_enough_item_in_package(TemplateId,Count);							
							true->
								false
						end end,true,Items).

can_teleport(ProtoInfo,Members,NeedCreate,MapProc)->
	case check_level(ProtoInfo) of
		true->
			case check_membernum(ProtoInfo,Members) of
				true->
					case timer_util:check_dateline(instance_proto_db:get_dateline(ProtoInfo)) of
						true->
							case check_quests(ProtoInfo) of
								true->
									case check_datetimes(ProtoInfo,NeedCreate,MapProc) or check_item(ProtoInfo) of
										true->
											true;
										_->
											times
									end;
								Reason->
									Reason
							end;
						_->
							dateline
					end;
				_->
					member_full
			end;
		_->
			level
	end.
	
check_membernum(ProtoInfo,Members)->
	{_MinNum,MaxNum} = instance_proto_db:get_membernum(ProtoInfo),
	MemberNum = erlang:length(Members),
	MemberNum < MaxNum.

check_level(ProtoInfo)->
	{LevelMin,LevelMax} = instance_proto_db:get_level(ProtoInfo),
	(get(level) >= LevelMin) and (get(level) =< LevelMax). 

%% true/Reason
check_quests(ProtoInfo)->
	{NeedHasQuests,NeedFinQuest} = instance_proto_db:get_quests(ProtoInfo),
	Check1 = lists:foldl(fun(HasQuest,Result1)->
				if
					Result1->	
						quest_op:has_quest(HasQuest);
					true->
						false
				end end,true,NeedHasQuests),
	if
		Check1->
				Check2 = lists:foldl(fun(FinQuest,Result2)->
				if
					not Result2 ->
						false;
					Check1->	
						quest_op:has_been_finished(FinQuest);
					true->
						false
				end end,true,NeedFinQuest),
				if
					Check2->
						true;
					true->
						not_fin_quest			
				end;	
		true->
			not_has_quest
	end.

check_item(ProtoInfo)->
	case instance_proto_db:get_item_need(ProtoInfo) of
		[]->
			false;
		Items->
			lists:foldl(fun({TemplateId,Count},Result)->
						if
							Result->
								item_util:is_has_enough_item_in_package(TemplateId,Count);							
							true->
								false
						end end,true,Items)
	end.

check_datetimes(ProtoInfo,NeedCreate,MapProc)->					%%restric times in date
 	check_datetimes_public(ProtoInfo,NeedCreate,MapProc,1).

check_datetimes_public(ProtoInfo,NeedCreate,MapProc,Times)->					%%restric times in date
	ProtoId = instance_proto_db:get_protoid(ProtoInfo),
	case instance_proto_db:get_datetimes(ProtoInfo) of
		[]->
			true;
		{0,0}->
			true;
		{{Type,Args},CountRestrict}->
			OriLog = get(instance_log),
			case lists:keyfind(ProtoId,1,OriLog) of
				{ProtoId,FTime,Count,LastProc}->
					case check_is_overdue(FTime,Type,Args) of
						true->
							NewLog = lists:keyreplace(ProtoId,1,OriLog,{ProtoId,timer_center:get_correct_now(),0,0,0,0}),
							put(instance_log,NewLog),
							true;
						_->
							InsType = instance_proto_db:get_type(ProtoInfo),
							if
								NeedCreate;MapProc=/=LastProc->
								% NeedCreate;MapProc=/=LastProc;InsType=:=?INSTANCE_TYPE_GROUP->
									Count+Times =<CountRestrict+vip_op:get_addition_with_vip({instance,ProtoId});
								true->
									true
							end
					end;
				{ProtoId,FTime,Count,LastProc,_Exp,_EnTrustTimes}->
					case check_is_overdue(FTime,Type,Args) of
						true->
							NewLog = lists:keyreplace(ProtoId,1,OriLog,{ProtoId,timer_center:get_correct_now(),0,0,0,0}),
							put(instance_log,NewLog),
							true;
						_->
							InsType = instance_proto_db:get_type(ProtoInfo),
							if
								NeedCreate;MapProc=/=LastProc->
									Count+Times =<CountRestrict+vip_op:get_addition_with_vip({instance,ProtoId});
								true->
									true
							end
					end;
				false->
					true
			end
	end.										%%todo

check_is_overdue(FristTime,Type,Args)->
	case Type of
		?DUE_TYPE_DAY->
			{_,{ClearH,ClearMin,ClearSec}} = Args,
			timer_util:check_is_overdue(Type,{ClearH,ClearMin,ClearSec},FristTime);
		_->
			false
	end.
				
				
make_instance_id(Type,Proto)->
	case Type of
		?INSTANCE_TYPE_CAMP_BATTLE->
			erlang:atom_to_list(battle_ground_op:get_map_proc_name());
		?INSTANCE_TYPE_TANGLE_BATTLE->
			erlang:atom_to_list(battle_ground_op:get_map_proc_name());
		?INSTANCE_TYPE_YHZQ->
			erlang:atom_to_list(battle_ground_op:get_map_proc_name());
		?INSTANCE_TYPE_GUILDBATTLE->
			erlang:atom_to_list(guild_battle);
		?INSTANCE_TYPE_JSZD->
			erlang:atom_to_list(battle_ground_op:get_map_proc_name());
		?INSTANCE_TYPE_GUILD->
			{MapProc,_} = get(guild_instance_info),
			erlang:atom_to_list(MapProc);
		?INSTANCE_TYPE_LOOP_INSTANCE->
			erlang:atom_to_list(loop_instance_op:get_map_proc_name());
		_->
			make_id_by_creationtag(make_creation_tag(Type),Proto)
	end.		

make_instance_id(Type,Creation,Proto)->
	case Type of
		?INSTANCE_TYPE_CAMP_BATTLE->
			erlang:atom_to_list(battle_ground_processor:make_map_proc_name(Creation));
		?INSTANCE_TYPE_TANGLE_BATTLE->
			erlang:atom_to_list(battle_ground_processor:make_map_proc_name(Creation));
		?INSTANCE_TYPE_YHZQ->
			erlang:atom_to_list(battle_ground_processor:make_map_proc_name(Creation));
		?INSTANCE_TYPE_JSZD->
			erlang:atom_to_list(battle_ground_processor:make_map_proc_name(Creation));
		?INSTANCE_TYPE_GUILDBATTLE->
			erlang:atom_to_list(guild_battle);
		?INSTANCE_TYPE_GUILD->
			erlang:atom_to_list(battle_ground_processor:make_map_proc_name(Creation));
		?INSTANCE_TYPE_LOOP_INSTANCE->
			erlang:atom_to_list(Creation);
		_->
			make_id_by_creationtag(make_creation_tag(Type,Creation),Proto)
	end.

make_id_by_creationtag(CreationTag,Proto)->
	lists:append([CreationTag,"_",integer_to_list(Proto)]).

make_creation_tag(Type,Creation)->
	case Type of
		?INSTANCE_TYPE_SINGLE->			%%Roleid
			Arg = Creation,
			lists:append(["instance_",integer_to_list(Type),"_",integer_to_list(Arg)]);
		?INSTANCE_TYPE_GROUP->			%%{Roleid,Time}
			{_,Arg1} = Creation,
			Arg =timer:now_diff(Arg1, {0,0,0}),
			lists:append(["instance_",integer_to_list(Type),"_",integer_to_list(Arg)]);
		?INSTANCE_TYPE_GUILD->			%%{ServerId,Index}
			{_,Arg} = Creation,
			lists:append(["instance_",integer_to_list(Type),"_",integer_to_list(Arg)]);
		?INSTANCE_TYPE_CAMP_BATTLE->
			erlang:atom_to_list(battle_ground_op:get_proc());
		?INSTANCE_TYPE_TANGLE_BATTLE->
			erlang:atom_to_list(battle_ground_op:get_proc());
		?INSTANCE_TYPE_YHZQ->
			erlang:atom_to_list(battle_ground_op:get_proc());
		?INSTANCE_TYPE_JSZD->
			erlang:atom_to_list(battle_ground_op:get_proc());
		?INSTANCE_TYPE_BANQUET->
			erlang:atom_to_list(banquet_op:get_map_proc_name());
		?INSTANCE_TYPE_GUILDBATTLE->
			erlang:atom_to_list(guildbattle_op:get_map_proc_name());
		?INSTANCE_TYPE_LOOP_INSTANCE->
			erlang:atom_to_list(loop_instance_op:get_map_proc_name());
		_->
			Arg = Creation,
			lists:append(["instance_",integer_to_list(Type),"_",integer_to_list(Arg)])
	end.

make_creation_tag(Type)->
	case Type of
		?INSTANCE_TYPE_SINGLE->			%%Roleid
			Arg = get(roleid),
			lists:append(["instance_",integer_to_list(Type),"_",integer_to_list(Arg)]);
		?INSTANCE_TYPE_GROUP->			%%{Roleid,Time}
			{_,Arg1} = group_op:get_id(),
			Arg =timer:now_diff(Arg1, {0,0,0}),
			lists:append(["instance_",integer_to_list(Type),"_",integer_to_list(Arg)]);
		?INSTANCE_TYPE_GUILD->			%%{ServerId,Index}
			{_,Arg} = guild_util:get_guild_id(),
			lists:append(["instance_",integer_to_list(Type),"_",integer_to_list(Arg)]);
		?INSTANCE_TYPE_TANGLE_BATTLE->
			erlang:atom_to_list(battle_ground_op:get_proc());
		?INSTANCE_TYPE_CAMP_BATTLE->
		    erlang:atom_to_list(battle_ground_op:get_proc());
		?INSTANCE_TYPE_YHZQ->
			erlang:atom_to_list(battle_ground_op:get_proc());
		?INSTANCE_TYPE_JSZD->
			erlang:atom_to_list(battle_ground_op:get_proc());
		?INSTANCE_TYPE_BANQUET->
			erlang:atom_to_list(banquet_op:get_map_proc_name());
		?INSTANCE_TYPE_GUILDBATTLE->
			erlang:atom_to_list(guildbattle_op:get_map_proc_name());
		?INSTANCE_TYPE_LOOP_INSTANCE->
			erlang:atom_to_list(loop_instance_op:get_map_proc_name());
		_->
			Arg = get(roleid),
			lists:append(["instance_",integer_to_list(Type),"_",integer_to_list(Arg)])
	end.


send_error_by_reason(Reason)->
	case Reason of
		gold-> Errno = ?ERROR_LESS_GOLD;
		times->
			Errno = ?ERRNO_INSTANCE_TIMES;
		buff->
			Errno = ?ERRNO_INSTANCE_BUFF;
		item->
			Errno = ?ERROR_MISS_ITEM;
		dateline->
			Errno = ?ERRNO_INSTANCE_DATELINE;
		member_full->
			Errno = ?ERRNO_INSTANCE_MOREMEMBER;
		level->
			Errno = ?ERRNO_INSTANCE_LEVELRESTRICT;
		not_fin_quest->
			Errno = ?ERRNO_INSTANCE_FINQUEST;
		not_has_quest->
			Errno = ?ERRNO_INSTANCE_QUEST;
		membernum->
			Errno = ?ERRNO_INSTANCE_LESSMEMBER;
		level_map->
			Errno = ?ERRNO_INSTANCE_LEVELRESTRICT;
		resetting->
		  	Errno = ?ERRNO_INSTANCE_RESETING;
		group->
			Errno = ?ERRNO_INSTANCE_NOTEAM;
		guild->
			Errno = ?ERRNO_INSTANCE_NOGUILD;
		leader->
			Errno = ?ERRNO_INSTANCE_TEAMLEADER;
		
		fight_force->
			Errno = ?ERROR_LESS_FIGHTFORCE;
		package_full->
			Errno= ?ERROR_PACKEGE_FULL;
		silver ->
			Errno = ?ERROR_LESS_SILVER;
		already_exsit->
			Errno = ?ERRNO_INSTANCE_EXSIT;
		travel_battle_start ->
			Errno = ?TRAVEL_BATTLE_HAS_REGISTERED;
		_->
			Errno = ?ERRNO_INSTANCE_UNKNOWN
	end,
	Msg = role_packet:encode_map_change_failed_s2c(Errno),
	role_op:send_data_to_gate(Msg).

flag2num(Str) when Str == "instance_entrust_silver" ->
	?SILVER_TYPE;
flag2num(Str) when Str == "instance_entrust" ->
	?GOLD_TYPE;
flag2num(Str) ->
	0.


%%[{InstanceId,UseTimes}]
get_instance_times_log()->
	lists:foldl(fun({ProtoId,FTime,Count,ProcName},AccInfo)->
				case instance_proto_db:get_info(ProtoId) of
					[]->
						AccInfo;
					ProtoInfo->
						case instance_proto_db:get_datetimes(ProtoInfo) of
							[]->
								[{ProtoId,0,flag2num(ProcName),0,0}|AccInfo];
							{0,0}->
								[{ProtoId,0,flag2num(ProcName),0,0}|AccInfo];
							{{Type,Args},_CountRestrict}->
								case check_is_overdue(FTime,Type,Args) of
									true->
						 				[{ProtoId,0,flag2num(ProcName),0,0}|AccInfo];
									false->
										[{ProtoId,Count,flag2num(ProcName),0,0}|AccInfo]
								end
						end
				end;
				 ({ProtoId, FTime, Count, ProcName, Exp, EnTrustTimes}, AccInfo) ->
					 case instance_proto_db:get_info(ProtoId) of
						 []->
							 AccInfo;
						 ProtoInfo->
							 case instance_proto_db:get_datetimes(ProtoInfo) of
								 []->
									 [{ProtoId,0,flag2num(ProcName),0,0}|AccInfo];
								 {0,0}->
									 [{ProtoId,0,flag2num(ProcName),0,0}|AccInfo];
								 {{Type,Args},_CountRestrict}->
									 case check_is_overdue(FTime,Type,Args) of
										 true->
											 [{ProtoId,0,flag2num(ProcName),0,0}|AccInfo];
										 false->
											 [{ProtoId,Count,flag2num(ProcName),Exp,EnTrustTimes}|AccInfo]
									 end
							 end
					 end
	end,[],get(instance_log)).

get_my_instance_count()->
	SendLogs = get_instance_times_log() ++ [{-1,loop_tower_op:get_cur_loop_tower_count(),0,0,0}] ++ loop_instance_op:get_instance_record2(),
	slogger:msg("instance_log ~p", [get(instance_log)]),
	slogger:msg("instance ~p ~n", [SendLogs]),
	{Ids, Times, Types, Exps, EnTrustTimes} = lists:foldr(
		fun({Id, Time, Type, Exp,EnTrustTimes}, {A,B,C,D,E}) ->
			{[Id|A],[Time|B],[Type|C],[Exp|D],[EnTrustTimes|E]}
		end,{[],[],[],[],[]},SendLogs),
	Msg = role_packet:encode_get_instance_log_s2c(Ids,Times,Types,Exps,EnTrustTimes),
	role_op:send_data_to_gate(Msg).

check_need_add_instance_time(InstanceProtoId,MapProc)->
	case lists:keyfind(InstanceProtoId, 1,get(instance_log)) of
		false->
			true;
		{_,_,_,OriMapProc}->
			if
				OriMapProc=:=MapProc->
					false;
				true->
					true
			end;
		{_,_,_,OriMapProc,_,_}->
			if
				OriMapProc=:=MapProc->
					false;
				true->
					true
			end
	end.

%% return : {JoinTimes,NeedAddTime,UsedTime_S}
get_instance_preview_details(InstanceProtoId)->
	case instance_proto_db:get_info(InstanceProtoId) of
		[]->
			{0,0,0};
		ProtoInfo->	
			case lists:keyfind(InstanceProtoId, 1, get_instance_times_log()) of
				false->
					JoinTimes = 0;
				{_InstanceProtoId, JoinTimes, _Other, _Other2, _Other3}->
					nothing
			end,
			case instance_op:get_role_instance_trans_deatail(ProtoInfo) of
				{false,_}->
					NeedAddTime = 1,
					UsedTime_S = 0;
				{true,NeedCreate,MapNode,MapProc,_}->
					if
						NeedCreate->
							NeedAddTime = 1,
							UsedTime_S = 0;
						true->			%%has proc 
							case check_need_add_instance_time(InstanceProtoId,MapProc) of
								true->
									NeedAddTime = 1;
								_->
									NeedAddTime = 0
							end,
							UsedTime_S = map_processor:get_map_details(MapProc,MapNode)
					end
			end,
			{JoinTimes,NeedAddTime,UsedTime_S}
	end.
		
%%InstanceProtoId / 0:all instance										
get_instance_and_group_recruit_info(InstanceProtoId)->
	{Rec_infos,Role_rec_infos} = group_op:get_all_recruit_teaminfo(InstanceProtoId),
	if
		InstanceProtoId=:=0->
			JoinTimes = 0,NeedAddTime = 0,UsedTime_S = 0;
		true->
			{JoinTimes,NeedAddTime,UsedTime_S} = get_instance_preview_details(InstanceProtoId)
	end,
	Message = role_packet:encode_recruite_query_s2c(InstanceProtoId,Rec_infos,Role_rec_infos,JoinTimes,NeedAddTime,UsedTime_S),
	role_op:send_data_to_gate(Message).
																				
proc_player_instance_exit()->
	case get_cur_protoid() of
		0->
			nothing;
		ProtoId->
			InstanceProto = instance_proto_db:get_info(ProtoId),
			case instance_proto_db:get_can_direct_exit(InstanceProto) of
				1->
					kick_from_cur_instance();
				_->
					nothing
			end
	end.
	
add_intimacy(Members) ->
	IntimacyInfo = wedding_db:get_intimacy_info(?WEDDING_INTIMACY_BY_INSTANCE),
	IntimacyValue = wedding_db:get_intimacy_value(IntimacyInfo),
	lists:foreach(fun(RoleId) ->
		case friend_op:is_friend_bilateral(RoleId) of
			true ->
				friend_op:add_intimacy(RoleId, IntimacyValue);
			false ->
				nothing
		end
	end, Members).
										
										
										
										
										
	
