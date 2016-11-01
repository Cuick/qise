-module (mock_processor_type_6).

-behaviour(gen_fsm).

-include ("common_define.hrl").
-include ("map_def.hrl").
-include ("pvp_define.hrl").
-include ("vip_define.hrl").
-include ("slot_define.hrl").
-include ("item_define.hrl").
-include ("travel_battle_def.hrl").
-include ("skill_define.hrl").
-include ("creature_define.hrl").
-include ("login_pb.hrl").
-include ("webgame.hrl").
-include ("little_garden.hrl").

-export([start_link/7, make_proc_name/1, stop/1]).

-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-export([
	gaming/2, 
	moving/2,
	deading/2]).

-include ("map_info_struct.hrl").
-include ("role_struct.hrl").
-include ("item_struct.hrl").


start_link(MockProc, MockId, ProtoId, Name, Gender, Class, LineId) ->
	gen_fsm:start_link({local, MockProc}, ?MODULE, [MockId, ProtoId, Name, Gender, Class, LineId], []).

make_proc_name(MockId) ->
	list_to_atom(integer_to_list(MockId)).

init([MockId, ProtoId, Name, Gender, Class, LineId]) ->
	put(roleid,MockId),
	timer_center:start_at_process(),
	{A,B,C} = timer_center:get_correct_now(),
	random:seed(A,B,C),
	init_mock_info(MockId, ProtoId, Name, Gender, Class, LineId),
	{ok, gaming, #role_state{}}.

stop(MockProc) ->
	gen_fsm:send_all_state_event(MockProc, {stop}).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理其他事件
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_event({stop}, StateName, StateData) ->
	RoleInfo = get(creature_info),
    MockId = get_id_from_roleinfo(RoleInfo),
    role_op:leave_map(RoleInfo, get(map_info)),
    role_pos_db:unreg_role_pos_to_mnesia(MockId),
    role_manager:unregist_role_info(MockId),
    Gender = get_gender_from_roleinfo(RoleInfo),
    Name = get_name_from_roleinfo(RoleInfo),
    mock_name_generator:return_name_back(Gender, Name),
	{stop, normal, StateData};

handle_event(Event, StateName, StateData) ->
	{next_state, StateName, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理同步事件调用
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_sync_event(Event, From, StateName, StateData) ->
	Reply = ok,
	{reply, Reply, StateName, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理其他进程消息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_info({other_into_view, OtherId}, StateName, StateData) ->
	other_into_view(OtherId),
	{next_state, StateName, StateData};

handle_info({other_outof_view, OtherId}, StateName, StateData) ->
	other_outof_view(OtherId),
	{next_state, StateName, StateData};

handle_info({other_inspect_you, {ServerId, RoleId}}, StateName, StateData) ->
	handle_other_inspect_you(ServerId, RoleId),
	{next_state, StateName, StateData};

handle_info({send_to_client,Data}, StateName, StateData) ->
	Term = erlang:binary_to_term(Data),
	ID = element(2,Term),
	Message = erlang:setelement(1, Term, login_pb:get_record_name(ID)),
	case Message of
		#battle_start_s2c{type = ?TANGLE_BATTLE} ->
			Interval = 1000 + random:uniform(5000),
			erlang:send_after(Interval, self(), {join});
		#role_map_change_s2c{} ->
			enter_map();
		_ ->
			nothing
	end,
	{next_state, StateName, StateData};

handle_info({battle_intive_to_join, {?TANGLE_BATTLE,_,Node,_,_} = Info}, StateName, StateData) ->
	case node() of
		Node ->
			battle_ground_op:battle_intive_to_join(Info);
		_ ->
			nothing
	end,	
	{next_state, StateName, StateData};

handle_info({move_heartbeat, NewPos}, StateName, StateData) ->
	if
		StateName =/= deading ->
			move_heartbeat(NewPos);
		true ->
			nothing
	end,
	{next_state, StateName, StateData};

handle_info({other_be_attacked,AttackInfo}, StateName, State) ->
	if
		StateName =/= deading ->
			other_be_attacked(AttackInfo, get(creature_info), StateName);
		true ->
			nothing
	end,
	{next_state, StateName, State};

handle_info( {buffer_interval, BufferInfo}, StateName, State) ->
	NextState = if
		StateName =/= deading ->
			buffer_interval(BufferInfo, StateName);
		true ->
			StateName
	end,
	{next_state, NextState, State};
	
handle_info({hprecover_interval,HpRecInt}, StateName, State)->
	if
		StateName =/= deading ->
			hprecover_interval(HpRecInt);
		true ->
			nothing
	end,
	{next_state, StateName, State};

handle_info({mprecover_interval,MpRecInt}, StateName, State)->
	if
		StateName =/= deading ->
			mprecover_interval(MpRecInt);
		true ->
			nothing
	end,
	{next_state, StateName, State};
	
handle_info({be_add_buffer, Buffers,CasterInfo}, StateName, StateData) ->
	if
		StateName =/= deading -> 
			be_add_buffer(Buffers,CasterInfo);
		true->
			nothing
	end,
	{next_state, StateName, StateData};

handle_info({attack, TargetId}, StateName, StateData) ->
	if
		StateName =/= deading ->
			attack(TargetId);
		true ->
			nothing
	end,
	{next_state, StateName, StateData};

handle_info({start_move, PathId, Pos}, StateName, StateData) ->
	if
		StateName =/= deading ->
			start_move(PathId, Pos);
		true ->
			nothing
	end,
	{next_state, StateName, StateData};

handle_info({respawn}, StateName, State) ->
	respawn(),
	{next_state, gaming, State};

handle_info({join}, StateName, State) ->
	battle_ground_op:handle_join(?TANGLE_BATTLE),
	{next_state, gaming, State};

handle_info(Info, StateName, State) ->
	{next_state, StateName, State}.

%% --------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% --------------------------------------------------------------------
terminate(Reason, StateName,StateData) ->    
	{ok, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% --------------------------------------------------------------------
code_change(OldVsn, StateName, StateData, Extra) ->
	{ok, StateName, StateData}.

gaming(_, StateData) ->        
	{next_state, gaming, StateData}.

moving(_, StateData) ->        
	{next_state, moving, StateData}.

deading(_, StateData) ->        
	{next_state, deading, StateData}.


%% ====================================================================
%%
%% Local Functions
%%
%% ====================================================================

init_mock_info(MockId, ProtoId, Name, Gender, Class, LineId) ->
	put(creature_info,create_roleinfo()),
	MockPid = make_proc_name(MockId),
	MockNode = node(),
	MockInfo = mock_db:get_mock_info_type_6(ProtoId),
	Level = mock_db:get_mock_level_type_6(MockInfo),
	MockPos = {0,0},
	Viptag = ?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR,
	MockServerId = env:get(serverid, 1),
	PackageSize = ?MAX_PACKAGE_SLOT,
	Commoncool = 1300,
	Now = timer_center:get_correct_now(),
	PkModel = {?PVP_MODEL_KILLALL, Now},
	%%进程字典
	put(aoi_list,[]),
	put(travel_path, []),
	put(target, []),
	put(classid, Class),
	put(level, Level),
	put(is_in_world,false),
	put(current_buffer, []),	
	put(murderer,0),
	put(hp_mp_time, {0, 0}),
	put(move_timer, 0),
	role_op:set_leave_attack_time([],{0,0,0}),
	put(last_cast_time,{0,0,0}),
	put(last_nor_cast_time,{0,0,0}),
	put(is_treasure_transport, false),
	put(instance,{0,0,0,0,{0,0,{0,0}}}),
	put(battle_info, {[],[],[],[]}),
	put(av_activity_msg, []),
	put(invite_info,[]),
	put(group_info,{0,0,0,[]}),
	put(leader_instance_invite,[]),
	put(role_recruitments_tag,false),
	put(group_intimacy, []),
	put(instance_log,[]),
	put(guild_info,{0,[],0,0,0,0,[],[]}),
	put(?LAST_MAP, {300,0}),
	put(quest_list,[]),
	put(finished_quests,[]),
	put(relation_msgs,[]),
	put(start_quest,[]),
	put(everquest_list,[]),
	put(pets_skill_info,[]),
	put(gm_pets_info,[]),
	put(pets_info,[]),
	put(last_pet_switch_time,{0,0,0}),
	put(max_pet_num,0),
	put(buy_pet_slot,0),	
	put(present_pet_slot,0),		%%赠送的宠物槽位
	put(mypets_add_talent,[]),
	put(pet_can_buy_goods,[]),		%%在宠物商店可以买的物品列表
	put(pet_refresh_used,[]),		%%已用刷新次数
	put(pet_account,0),				%%宠物商店积分
	put(pet_luck_high,0),
	put(myguildbattlestate,guildbattle_op:make_state()),
	put(venation_flag,undefined),
	put(venation_info,undefined),
	put(venation_attr_addtion,undefined),
	put(venation_shareexp,undefined),
	put(venation_activepoint_info,undefined),
	put(venation_time_countdown,[]),
	put(venation_info_cache,undefined),
	put(role_venation_advanced,undefined),
	NowLevelExp = role_level_db:get_level_experience(Level),
	NextLevelExp = role_level_db:get_level_experience(Level + 1),
	MockExp = NowLevelExp + random:uniform(NextLevelExp - NowLevelExp),
	put(current_exp,MockExp),
	LevelupExp = NextLevelExp - MockExp,
	
	%% Items
	init_items(),
	Equipments = mock_db:get_mock_equipments_type_6(MockInfo),
	equip(Equipments),

	%% Packages
	init_package(PackageSize),

	%% Skills
	Skills = mock_db:get_mock_skills_type_6(MockInfo),
	init_skills(Skills),
	buffer_op:init(),
	%%计算初始人物属性,buffer的在on_into_world里添加
	{Power,Hprecover,CriDerate,Mprecover,MovespeedRate,Meleeimmunity,Rangeimmunity,Magicimmunity,
		Hpmax,Mpmax,Stamina,Strength,Intelligence,Agile,Meleedefense,Rangedefense,Magicdefense,Hitrate,
		Dodge,Criticalrate,Toughness,ImprisonmentResist,SilenceResist,DazeResist,PoisonResist,
		NormalResist,FightingForce} = compute_attrs(init,Level),
	MockIimmunes = {Magicimmunity,Rangeimmunity,Meleeimmunity},
	MockDebuffimmunes =  {ImprisonmentResist,SilenceResist,DazeResist,PoisonResist,NormalResist},
	MockDefenses = {Magicdefense,Rangedefense,Meleedefense},
	MockSpeed = erlang:trunc(?BASE_MOVE_SPEED*(100+MovespeedRate)/100),
	MockState = gaming,
	CreatureInfo = create_roleinfo(),
	GsGateInfo = #gs_system_gate_info{gate_proc = MockPid, gate_node = MockNode, gate_pid = self()},
    put(gate_info, GsGateInfo),
	put(creature_info,
		set_roleinfo(CreatureInfo,MockId,Class,Gender,Level,MockState,MockPid,MockNode,MockPos,
		Name,MockSpeed,Hpmax,Hpmax,Mpmax,Mpmax,MockExp,0,0,LevelupExp,
		0,0,Power,Commoncool,Hprecover,Mprecover,CriDerate,Criticalrate,Toughness,Dodge,
		Hitrate,Stamina,Agile,Strength,Intelligence,MockIimmunes,MockDebuffimmunes,MockDefenses,[],
		0,[],Viptag,[],0,PkModel,[],GsGateInfo,undefined,MockServerId,
		0,FightingForce,0,0,[],false)),
	put('$private_options', []),
	{ClotheTemId,ArmTemId} = item_util:get_role_cloth_and_arm_dispaly(),
	put(creature_info,set_cloth_to_roleinfo(get(creature_info),ClotheTemId)),
	put(creature_info,set_arm_to_roleinfo(get(creature_info),ArmTemId)),
	role_op:update_role_info(MockId, get(creature_info)),
	MapInfo = create_mapinfo(300, LineId, MockNode, map_manager:make_map_process_name(LineId, 300), ?GRID_WIDTH),
	put(map_info, MapInfo),
	role_pos_db:reg_role_pos_to_mnesia(MockId, LineId, 300, Name, MockNode, make_proc_name(MockId), MockNode, self()),
	battle_ground_op:hook_on_online().


enter_map() ->
	MapInfo = get(map_info),
	RoleInfo = get(creature_info),
	MapId = get_mapid_from_mapinfo(MapInfo),
	case map_info_db:get_map_info(MapId) of
		[]->
			nothing;
		MapProtoInfo->
			map_script:run_script(on_join,MapProtoInfo)
	end,
	%% 切换为游戏状态
	creature_op:join(RoleInfo, MapInfo),
	Pos = creature_op:get_pos_from_creature_info(RoleInfo),
	start_move(1, Pos).


crash_store() ->
	todo.


compute_attrs(init,Level) ->
	Class = get(classid),
	%%初始计算	
	{OriCurrentAttributes,_OriCurrentBuffers,_OriChangeAttribute} = compute_buffers:compute(Class, Level, [], [], [], [],[],[],[],[]),
	put(current_attribute,OriCurrentAttributes),
	%%获取装备属性
	BaseAttr = get_role_base_attr(),
	OtherAttr = get_role_other_attr(),
	put(base_attr,BaseAttr),
	put(other_attr,OtherAttr),
	
	%%属性计算
	{CurrentAttributes,_CurrentBuffers, _ChangeAttribute} 
	= compute_buffers:compute(Class, Level, get(current_attribute), get(current_buffer), [], [],BaseAttr,[],OtherAttr,[]),
	put(current_attribute, CurrentAttributes),
	Power = attribute:get_current(CurrentAttributes,power),
	Hprecover = attribute:get_current(CurrentAttributes,hprecover),
	CriDerate = attribute:get_current(CurrentAttributes,criticaldestroyrate),
	Mprecover = attribute:get_current(CurrentAttributes,mprecover),
	MovespeedRate = attribute:get_current(CurrentAttributes,movespeed),
	Meleeimmunity = attribute:get_current(CurrentAttributes,meleeimmunity),
	Rangeimmunity = attribute:get_current(CurrentAttributes,rangeimmunity),
	Magicimmunity = attribute:get_current(CurrentAttributes,magicimmunity),
	Hpmax = attribute:get_current(CurrentAttributes,hpmax),
	Mpmax = attribute:get_current(CurrentAttributes,mpmax),
	Stamina = attribute:get_current(CurrentAttributes,stamina),
	Strength = attribute:get_current(CurrentAttributes,strength),
	Intelligence = attribute:get_current(CurrentAttributes,intelligence),
	Agile = attribute:get_current(CurrentAttributes,agile),
	Meleedefense = attribute:get_current(CurrentAttributes,meleedefense),
	Rangedefense = attribute:get_current(CurrentAttributes,rangedefense),
	Magicdefense = attribute:get_current(CurrentAttributes,magicdefense),
	Hitrate = attribute:get_current(CurrentAttributes,hitrate),
	Dodge = attribute:get_current(CurrentAttributes,dodge),
	Criticalrate = attribute:get_current(CurrentAttributes,criticalrate),
	Toughness = attribute:get_current(CurrentAttributes,toughness),
	Imprisonment_resist = attribute:get_current(CurrentAttributes,imprisonment_resist),
	Silence_resist = attribute:get_current(CurrentAttributes,silence_resist),
	Daze_resist = attribute:get_current(CurrentAttributes,daze_resist),
	Poison_resist = attribute:get_current(CurrentAttributes,poison_resist),
	Normal_resist = attribute:get_current(CurrentAttributes,normal_resist),
	Fighting_force = role_fighting_force:computter_fight_force(Hpmax,Power,Meleedefense,Rangedefense,Magicdefense,Hitrate,Dodge,Criticalrate,
					  CriDerate,Toughness,Meleeimmunity,Rangeimmunity,Magicimmunity),
	{Power,Hprecover,CriDerate,Mprecover,MovespeedRate,Meleeimmunity,Rangeimmunity,Magicimmunity,Hpmax,Mpmax,Stamina,Strength,
	Intelligence,Agile,Meleedefense,Rangedefense,Magicdefense,Hitrate,Dodge,Criticalrate,Toughness,Imprisonment_resist,Silence_resist,
	Daze_resist,Poison_resist,Normal_resist,Fighting_force}.

init_items() ->
	put(items_info,[]).

equip(Equipments) ->
	lists:foreach(fun({TemplateId, Enchantments}) ->
		Slot = get_equipment_slot(TemplateId),
		create_objects(Slot,TemplateId,1,Enchantments)
	end, Equipments).

init_package(PackageSize) ->
	put(package_size,PackageSize),
	put(storage_size,?MAX_STORAGE_SLOT),
	InitList = lists:seq(?SLOT_BODY_INDEX+1, ?SLOT_BODY_ENDEX) ++
		lists:seq(1+?SLOT_PACKAGE_INDEX, ?SLOT_PACKAGE_INDEX+PackageSize),
	put(package,lists:map(fun(Index)->{Index,0,0}end,InitList)),
	AllItems = get(items_info),
	lists:foreach(fun({ItemId,ItemInfo,_,_})->		
		if
			is_record(ItemInfo,item_info)->			
				SlotNum = get_slot_from_iteminfo(ItemInfo);
			true->
				SlotNum = playeritems_db:get_slot(ItemInfo)
		end,
		case (package_op:where_slot(SlotNum)=:=body) or (package_op:where_slot(SlotNum)=:=package)
		of 
			true ->
				Count = get_count_from_iteminfo(ItemInfo),
				set_item_to_slot(SlotNum,ItemId,Count);
			false ->
				nothing
		end
	end,AllItems).

init_skills(Skills) ->
	SkillsInfo = [{SkillId, SkillLevel, {0, 0, 0}} || {SkillId, SkillLevel} <- Skills],
	put(skill_info, SkillsInfo).

add_item_to_itemsinfo(ItemFullInfo)->
	ItemId = get_id_from_iteminfo(ItemFullInfo),
	CoolDown = get_cooldowninfo_from_iteminfo(ItemFullInfo),
	put(items_info,[{ItemId,ItemFullInfo,CoolDown,1}| get(items_info)]).

create_objects_with_ownerid(Slot,TemplateId,Count,OwnerId,CoolDownArgh,Enchantments)->
	TemplateInfo = item_template_db:get_item_templateinfo(TemplateId),
	BondType = item_template_db:get_bonding(TemplateInfo),
	Id = itemid_generator:gen_newid(),
	%%处理绑定
	if BondType =:= ?ITEM_BIND_TYPE_OBTAIN -> %%bind when pick
			IsBond = 1;
		true->
			IsBond = 0
	end,
	%%处理冷却
	if
		CoolDownArgh=:=[]->
			CoolDownInfo = {{0,0,0},0};
		true->
			CoolDownInfo = CoolDownArgh,
			nothing
	end,
	%%处理过期
	ChentInfo = item_template_db:get_enchant_ext(TemplateInfo), 
	BaseInfo = create_item_baseinfo(Id,OwnerId,TemplateId,Enchantments,Count,Slot,IsBond ,[],0,CoolDownInfo,ChentInfo,[]),
	FullInfo_Noduration = set_protoinfo_to_iteminfo(BaseInfo,TemplateInfo),
	FullInfo = set_duration_to_iteminfo(FullInfo_Noduration,get_maxduration_from_iteminfo(FullInfo_Noduration)),
	add_item_to_itemsinfo(FullInfo),
	{Id,FullInfo}.

create_objects(Slot,TemplateId,Count,Enchantments)->
	create_objects_with_ownerid(Slot,TemplateId,Count,get(roleid),[],Enchantments).

get_equipment_slot(TemplateId) ->
	TemplateInfo = item_template_db:get_item_templateinfo(TemplateId),
	case item_template_db:get_clase(TemplateInfo) of
		?ITEM_TYPE_MAINHAND ->
			?MAINHAND_SLOT;
		?ITEM_TYPE_OFFHAND ->
			?OFFHAND_SLOT;
		?ITEM_TYPE_HEAD ->
			?HEAD_SLOT;
		?ITEM_TYPE_SHOULDER ->
			?SHOULDER_SLOT;
		?ITEM_TYPE_CHEST ->
			?CHEST_SLOT;
		?ITEM_TYPE_BELT ->
			?BELT_SLOT;
		?ITEM_TYPE_GLOVE ->
			?GLOVE_SLOT;
		?ITEM_TYPE_SHOES ->
			?SHOES_SLOT;
		?ITEM_TYPE_NECK ->
			?NECK_SLOT;
		?ITEM_TYPE_ARMBAND ->
			lists:nth(random:uniform(2), [?LARMBAND_SLOT, ?RARMBAND_SLOT]);
		?ITEM_TYPE_FINGER ->
			lists:nth(random:uniform(2), [?LFINGER_SLOT, ?RFINGER_SLOT]);
		?ITEM_TYPE_SHIELD ->
			?OFFHAND_SLOT;
		?ITEM_TYPE_MANTEAU ->
			?MANTEAU_SLOT;
		?ITEM_TYPE_FASHION ->
			?FASHION_SLOT;
		?ITEM_TYPE_RIDE ->
			?RIDE_SLOT
	end.

set_item_to_slot(SlotNum,ItemId,Count)->
	put(package,lists:keyreplace(SlotNum,1,get(package),{SlotNum,ItemId,Count})).

get_role_base_attr() ->
	get_all_bodyitems_attr() ++ get_skill_add_attr().

get_role_other_attr() ->
	[].

get_all_bodyitems_attr()->
	BodyItemsId = package_op:get_body_items_id(),
	BodyItemsInfo = lists:map(fun(Id)-> items_op:get_item_info(Id) end,BodyItemsId ),
	ItemsAttr1 = lists:foldl(fun(ItemInfo,Attr)->
			case ItemInfo =/= [] of
				true ->
					items_op:get_item_attr(ItemInfo)++Attr ;
				false ->	
					slogger:msg("get_all_bodyitems_attr,error Itemid in ~p ~n",[BodyItemsId]),
					Attr
			end
			end,[],BodyItemsInfo),
	EnchantmensetsItems = lists:filter(fun(ItemInfoTmp)->
					Slot = get_slot_from_iteminfo(ItemInfoTmp),
					(Slot =/= ?MANTEAU_SLOT) and (Slot =/= ?FASHION_SLOT) and (Slot =/= ?RIDE_SLOT)
				end,BodyItemsInfo),
	case erlang:length(EnchantmensetsItems) >= ?SLOT_BODY_ENDEX -3 of
		true ->				%% 原始装备属性+全星属性+套装属性 
			MinEnchant = get_item_enchantmentset(BodyItemsInfo),
			apply_enchantments_changed(MinEnchant),
			ItemsAttr2 = get_item_enchantmentset_attr(MinEnchant) ++ ItemsAttr1;							
		false ->			%%装备不足，只计算套装属性
			apply_enchantments_changed(0),
			ItemsAttr2 = ItemsAttr1
	end,
	ItemsAttr2.

get_item_enchantmentset(BodyItemsInfo)->
	MinEnchant = lists:foldl(fun(Info,MinEnt)->
		Ent = get_enchantments_from_iteminfo(Info),
		Level = get_level_from_iteminfo(Info),
		Slot = get_slot_from_iteminfo(Info),
		case (Slot =:= ?MANTEAU_SLOT) or (Slot =:= ?FASHION_SLOT) or (Slot =:= ?RIDE_SLOT) of
			true ->
				MinEnt;
			false ->	 
				if 
					(Ent < MinEnt) -> 
						Ent;
					true -> 
						MinEnt
				end
		end
	end,?MAX_ENCHANTMENTS+1,BodyItemsInfo),
	if
		MinEnchant=:= ?MAX_ENCHANTMENTS+1->
			0;
		true->	
			MinEnchant
	end.

apply_enchantments_changed(Enchant)->
	case get_view_from_roleinfo(get(creature_info)) of
		Enchant->
			nothing;
		_->
			put(creature_info,set_view_to_roleinfo(get(creature_info),Enchant)),
			self_update_and_broad([{view,Enchant}])
	end.

get_item_enchantmentset_attr(MinEnchant)->
	if 
		(MinEnchant=:=0)->
			[];
		true ->
			case enchantments_db:get_enchantments_info(MinEnchant) of
				[]->
					[];
				EnchantmentInfo->
					enchantments_db:get_enchantments_set_attr(EnchantmentInfo)
			end
	end.

get_skill_add_attr() ->
	lists:foldl(fun({SkillId,Level,_},AddAttrTmp)->
		SkillInfo = skill_db:get_skill_info(SkillId, Level),
		case skill_db:get_type(SkillInfo) of
			?SKILL_TYPE_PASSIVE_ATTREXT->
				AddBuffs = skill_db:get_caster_buff(SkillInfo),
				lists:foldl(fun({{BufferId,BuffLevel},_Rate},AttrTmp)-> 
								AttrTmp ++ buffer_op:get_buffer_attr_effect(BufferId,BuffLevel)
							end, [], AddBuffs)++AddAttrTmp;
			_->
				AddAttrTmp
		end
	end, [], get(skill_info)).


self_update_and_broad([])->
	nothing;
self_update_and_broad(UpdateAttr)->
	UpdateObj = object_update:make_update_attr(?UPDATETYPE_ROLE,get(roleid),UpdateAttr),
	creature_op:direct_broadcast_to_aoi_gate({object_update_update,UpdateObj}).

other_into_view(OtherId) ->
	case creature_op:get_creature_info(OtherId) of
		undefined ->
			nothing;
		OtherInfo->	
			creature_op:handle_other_into_view(OtherInfo)
	end.

other_outof_view(OtherId) ->
	creature_op:remove_from_aoi_list(OtherId).

handle_other_inspect_you(ServerId,RoldId)->
	BodyItemsId = package_op:get_body_items_id(),
	BodyItemsInfo = lists:map(fun(Id)->items_op:get_item_info(Id)end,BodyItemsId),
	GuildInfo= {0, [], 0},
	SoulPowerInfo = {0, 0},
	Msg = role_packet:encode_inspect_s2c(get(creature_info),BodyItemsInfo,GuildInfo,SoulPowerInfo),	
	role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoldId,Msg).

other_be_attacked({EnemyId, _, _, Damage, _,_}, SelfInfo,StateName) ->
	SelfId = get(roleid),            
	OtherInfo = creature_op:get_creature_info(EnemyId),   
	IsGod = combat_op:is_target_god(SelfInfo),
	Now = timer_center:get_correct_now(),
	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_BEATTACK),
	case ((OtherInfo=:=undefined) or IsGod or is_dead()) of
		true->
			StateName;
		_->
			%% 伤害列表中有自己	
			NowHp = get_life_from_roleinfo(SelfInfo),	
			MaxHp = get_hpmax_from_roleinfo(SelfInfo),
			role_op:set_leave_attack_time(EnemyId,Now),			
			NewLiftOri = erlang:min(MaxHp,erlang:max(NowHp + Damage, 0)),			 			
			if 
				NewLiftOri =/= NowHp->
					ChangedAttrLife = [{hp, NewLiftOri}];							
				true->
					ChangedAttrLife = []
			end,
			%%战士加怒气
			case (get_class_from_roleinfo(SelfInfo) =:= ?CLASS_MELEE) and (NewLiftOri < NowHp) of
				true ->
					NewMana = erlang:min(get_mana_from_roleinfo(SelfInfo) + 
						?MELEE_MANA_ADD_BY_ATTACK, get_mpmax_from_roleinfo(SelfInfo)),
					ChangedAttrLife_Mana = ChangedAttrLife ++ [{mp, NewMana}];
				false->
					ChangedAttrLife_Mana = 	ChangedAttrLife											
			end,				
			%%buff 对伤害的影响
			AllChangedAttr = buffer_op:hook_on_beattack(Damage,ChangedAttrLife_Mana),
			case lists:keyfind(hp,1,AllChangedAttr) of
				false->
					NewLift = NewLiftOri;
				{hp,NewLift}->
					nothing
			end,	
			NewRoleInfo = apply_skill_attr_changed(SelfInfo,AllChangedAttr),
			put(creature_info,NewRoleInfo),
			StateName2 = case NewLift =< 0 of
				true ->									
					EnemyName = creature_op:get_name_from_creature_info(OtherInfo),
					%% 被杀害了	
					player_be_killed(EnemyId,EnemyName),
					role_op:update_role_info(SelfId, get(creature_info)),
					deading;																		
				false->
					put(travel_path, []),
					put(path_info, {10000, {0, 0}}),
					self() ! {attack, EnemyId},
					role_op:update_role_info(SelfId, get(creature_info)),
					StateName				
			end,			
			StateName2
	end.

player_be_killed(EnemyId,EnemyName)->
	on_dead(),		
	put(murderer,EnemyId),
	Pos = get_pos_from_roleinfo(get(creature_info)),
	SelfId = get(roleid),	
	Message2 = role_packet:encode_be_killed_s2c(SelfId, EnemyName,?DEADTYPE_ROLES,Pos,series_kill:get_cur_series_kill_num()),
	role_op:broadcast_message_to_aoi({other_be_killed, {SelfId,EnemyId, EnemyName,?DEADTYPE_ROLES,Pos}}),
	erlang:send_after(1000, self(), {respawn}).

on_dead()->
	put(creature_info, set_path_to_roleinfo(get(creature_info),[])),
	put(creature_info, set_state_to_roleinfo(get(creature_info), deading)),
	buffer_op:stop_mprecover(),
	buffer_op:stop_hprecover(),
	self_update_and_broad([{state,?CREATURE_STATE_DEAD}]),
	creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_DEAD).

buffer_interval(BufferInfo, StateName) ->
	case buffer_op:do_interval(BufferInfo) of
		{remove,{BufferId,BufferLevel}}->
			role_op:remove_buffer({BufferId,BufferLevel}),
			StateName;
		{changattr,{BufferId,_Level},BuffChangeAttrs}->
			%%处理变化属性
			case effect:proc_buffer_function_effects(BuffChangeAttrs) of
				[]->
					StateName;
				ChangedAttrs->	
					RoleID = get(roleid),
					role_op:update_role_info(RoleID,get(creature_info)),						
					role_op:self_update_and_broad(ChangedAttrs),
					%%广播当前buff影响
					BuffChangesForSend = lists:map(fun({AttrTmp,ValueTmp})-> role_attr:to_role_attribute({AttrTmp,ValueTmp}) end,BuffChangeAttrs),
					Message = role_packet:encode_buff_affect_attr_s2c(RoleID,BuffChangesForSend),
					role_op:broadcast_message_to_aoi_client(Message),
					%%检查一下有没有影响到血量,如果有的话,看是否导致死掉
					case lists:keyfind(hp,1,ChangedAttrs) of
						{_,HPNew}->
							if
								HPNew =< 0 ->
									{EnemyId,EnemyName} = buffer_op:get_buff_casterinfo(BufferId),
									%% 被杀害了	
									player_be_killed(EnemyId,EnemyName),
									deading;																		
								true->					
									StateName					
							end;
						_->
							StateName
					end
			end;									
		_ -> 
			StateName
	end.

hprecover_interval(HpRecInt) ->
	CurrAttributes = get(current_attribute),
	RoleInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(RoleInfo),
	CurHp = get_life_from_roleinfo(RoleInfo),
	case buffer_op:do_hprecover(HpRecInt,CurHp,CurrAttributes) of
		{hp,0}	-> 0;
		{hp,ChangeValue}->
			if 	
				CurHp > 0 ->
					HP = CurHp + ChangeValue,
					put(creature_info, set_life_to_roleinfo(get(creature_info), HP)),
					role_op:update_role_info(RoleID,get(creature_info)),		
					self_update_and_broad([{hp,HP}]);
				true->
					nothing
			end
	end.

mprecover_interval(MpRecInt) ->
	CurrAttributes = get(current_attribute),
	RoleInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(RoleInfo),
	CurMp = creature_op:get_mana_from_creature_info(RoleInfo),
	case buffer_op:do_mprecover(MpRecInt,CurMp,CurrAttributes) of
		{mp,0}	-> 0;
		{mp,ChangeValue}->
			MP = erlang:max(CurMp + ChangeValue, 0),		%%防止战士掉蓝会掉到负值 
			case (CurMp =/= MP) of
				true ->
					put(creature_info, set_mana_to_roleinfo(get(creature_info), MP)),
					role_op:update_role_info(RoleID,get(creature_info)),
					self_update_and_broad([{mp,MP}]);
				false ->
					nothing
			end
	end.

be_add_buffer(NewBuffersOri,CasterInfo) ->
	NewBuffers = lists:ukeysort(1,NewBuffersOri),
	case is_dead() of
		false->
			%% 处理Buffer的覆盖情况		
			Fun = fun({BufferID, BufferLevel},{TmpNewBuffer,TmpRemoveBuffer}) ->
		    	case lists:keyfind(BufferID, 1, get(current_buffer)) of
			        false ->
				        %% 该Buff没有被加过，所以可以加					      		      
				        {TmpNewBuffer ++ [{BufferID, BufferLevel}],TmpRemoveBuffer};					      
			        {_, OldBufferLeve} ->
				        case BufferLevel >= OldBufferLeve of
					        false ->
						        %% 加过,新Buff的级别低
						        {TmpNewBuffer,TmpRemoveBuffer};
					        true ->
						        %% 加过，但是新Buff的级别高
							    remove_without_compute({BufferID, OldBufferLeve}),							    
						        {TmpNewBuffer ++ [{BufferID, BufferLevel}],TmpRemoveBuffer ++
						            [{BufferID, OldBufferLeve}]}
				        end
		        end
			end,   	      	      
			{NewBuffers2,RemoveBuff} = lists:foldl(Fun,{[],[]},NewBuffers),
			case (RemoveBuff =/= []) or (NewBuffers2 =/= []) of
				true->			
					role_op:recompute_attr(NewBuffers2, RemoveBuff),
					put(current_buffer, lists:ukeymerge(1, NewBuffers2, get(current_buffer))),
					NewBuffers_with_Time = lists:map(fun({BufferID, BufferLevel})->
						{BufferID, BufferLevel,timer_center:get_correct_now(),CasterInfo}
					end,NewBuffers2),
					apply_buffers_with_starttime(NewBuffers_with_Time),
					combat_op:interrupt_state_with_buff(get(creature_info));
				false->
					nothing
			end,
			role_op:update_role_info(get(roleid),get(creature_info));
		_->
			nothing
	end.

apply_buffers_with_starttime(NewBuffers_with_Time)->
	put(creature_info,set_buffer_to_roleinfo(get(creature_info),get(current_buffer))),
	RoleId = get(roleid),
	%% 设置Buffer给人物造成的状态改变
	lists:foreach(fun({BufferID, BufferLevel,_StartTime,_}) ->
				      BufferInfo = buffer_db:get_buffer_info(BufferID, BufferLevel),
				      put(creature_info, buffer_extra_effect:add(get(creature_info),BufferInfo))
		      end, NewBuffers_with_Time),
	%% 触发由Buffer导致的事件
 	lists:foreach(fun({BufferID, BufferLevel,StartTime,CasterInfo}) ->
				      buffer_op:generate_interval(BufferID, BufferLevel, 0,StartTime,CasterInfo)
 		      end, NewBuffers_with_Time),
 	
 	%%获取剩余时间
 	NewBuffers_with_LeftTime = lists:map(fun({BufferID, BufferLevel,StartTime,_}) ->
 		BufferInfo = buffer_db:get_buffer_info(BufferID, BufferLevel),						
		DurationTime = buffer_db:get_buffer_duration(BufferInfo),
		UsedTime = erlang:trunc(timer:now_diff(timer_center:get_correct_now(),StartTime)/1000),
		if 
			(UsedTime <1000) or (DurationTime=:= -1)  ->LeftTime = DurationTime;
			true -> LeftTime = DurationTime - UsedTime
		end,
		{BufferID, BufferLevel,LeftTime}
	end,NewBuffers_with_Time),				
					
	%% 广播中了Buff的消息
	Message3 = role_packet:encode_add_buff_s2c(RoleId, NewBuffers_with_LeftTime),
	role_op:broadcast_message_to_aoi_client(Message3).

remove_without_compute({BufferId,BufferLevel})->
	RoleId = get(roleid),
	case buffer_op:has_buff(BufferId) of
		true->
			buffer_op:remove_buffer(BufferId),
			put(current_buffer, lists:keydelete(BufferId, 1, get(current_buffer))),
			BufferInfo2 = buffer_db:get_buffer_info(BufferId, BufferLevel),
			%% 从人物状态中删除
			put(creature_info,buffer_extra_effect:remove(get(creature_info),BufferInfo2)),
			put(creature_info,set_buffer_to_roleinfo(get(creature_info),get(current_buffer))),	
			%%发送	
			Message = role_packet:encode_del_buff_s2c(RoleId,BufferId),
			role_op:broadcast_message_to_aoi_client(Message);
		_->
			nothing
	end.

is_dead()->
	creature_op:is_creature_dead(get(creature_info)).

choose_skill() ->
	Now = timer_center:get_correct_now(),
	Result = lists:filter(fun({SkillIdTmp, SkillLevelTmp, LastCastTime}) ->
		SkillInfo = skill_db:get_skill_info(SkillIdTmp, SkillLevelTmp),
		CoolDown = skill_db:get_cooldown(SkillInfo),
		timer:now_diff(Now,LastCastTime) >= CoolDown * 1000
	end, get(skill_info)),
	if
		Result =:= [] ->
			nothing;
		true ->
			[{SkillId, SkillLevel, _} | _] = Result,
			{SkillId, SkillLevel}
	end.

apply_skill_attr_changed(SelfInfo,ChangedAttr)->
	lists:foldl(fun(Attr,Info)->
		self_update_and_broad([Attr]),
		role_attr:to_creature_info(Attr,Info)
	end,SelfInfo,ChangedAttr).

respawn() ->
	RoleInfo = get(creature_info),
	MapInfo = get(map_info),
	role_op:leave_map(RoleInfo, MapInfo),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	NewHp = creature_op:get_hpmax_from_creature_info(RoleInfo),
	NewMp = creature_op:get_mpmax_from_creature_info(RoleInfo),
	RoleInfo1 = creature_op:set_life_to_creature_info(RoleInfo, NewHp),
	RoleInfo2 = creature_op:set_mana_to_creature_info(RoleInfo1, NewMp),
	RoleInfo3 = creature_op:set_state_to_creature_info(RoleInfo2, gaming),
	Pos = lists:nth(random:uniform(erlang:length(?TANGLE_SPAWN_POS)),?TANGLE_SPAWN_POS),
	RoleInfo4 = creature_op:set_pos_to_creature_info(RoleInfo3, Pos),
	put(creature_info, RoleInfo4),
	role_op:update_role_info(RoleId, RoleInfo4),
	creature_op:join(RoleInfo4, MapInfo),
	start_move(1, Pos).

attack(TargetId) ->
	TargetInfo = creature_op:get_creature_info(TargetId),
	SelfInfo = get(creature_info),
	case choose_skill() of
		nothing ->
			nothing;
		{SkillId, SkillLevel} ->
			SkillInfo = skill_db:get_skill_info(SkillId, SkillLevel),
			case can_attack(SelfInfo, TargetInfo, SkillInfo) of
				true ->
					creature_op:clear_all_buff_for_type(?MODULE, ?BUFF_CANCEL_TYPE_ATTACK),
					proc_cast_skill(SelfInfo, TargetInfo, SkillId, SkillLevel,SkillInfo,TargetId);
				false ->
					nothing
			end
	end.

can_attack(SelfInfo, TargetInfo, SkillInfo) ->
	TargetId = creature_op:get_id_from_creature_info(TargetInfo),
	case creature_op:is_in_aoi_list(TargetId) of
		true ->
			case creature_op:is_creature_dead(TargetInfo) of
				true ->
					false;
				_ ->
					MyPos = creature_op:get_pos_from_creature_info(SelfInfo),
					TargetPos = creature_op:get_pos_from_creature_info(TargetInfo),
					MaxDistance = skill_db:get_max_distance(SkillInfo),
					util:is_in_range(MyPos, TargetPos, MaxDistance)
			end;
		false ->
			false
	end.

proc_cast_skill(SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo,TargetID)->
	SelfId = get(roleid),
	MyPos = creature_op:get_pos_from_creature_info(SelfInfo),
	MyTarget = creature_op:get_pos_from_creature_info(TargetInfo),
	Speed = skill_db:get_flyspeed(SkillInfo),
	FlyTime = Speed*util:get_distance(MyPos,MyTarget),
	{ChangedAttr, CastResult} = 
	combat_op:process_instant_attack(SelfInfo, TargetInfo, SkillID, SkillLevel,SkillInfo),													
	set_casttime(SkillID),						
	%%所有伤害一起发出去
	process_damage_list(SelfId,SelfInfo,SkillID,SkillLevel, FlyTime, CastResult),
	%%处理buff
	creature_op:combat_bufflist_proc(SelfInfo,CastResult,FlyTime),
	Now = timer_center:get_correct_now(),
	role_op:set_leave_attack_time(creature_op:get_id_from_creature_info(TargetInfo),Now),
	case combat_op:is_normal_attack(SkillID) of
		true->
			put(last_nor_cast_time,Now);
		false->	 
	 		put(last_cast_time,Now), 
	 		put(last_nor_cast_time,Now)
	end,			      
	NewInfo2 = apply_skill_attr_changed(get(creature_info),ChangedAttr),
	put(creature_info, NewInfo2),								
	role_op:update_role_info(SelfId,NewInfo2).

process_damage_list(TrueId,SelfInfo,SkillId,SkillLevel,FlyTime, CastResult)->
	SelfId = get_id_from_roleinfo(SelfInfo),
	Units = lists:foldl(fun({TargetID, DamageInfo, _},Units1 ) ->
		case DamageInfo of
			missing ->
		 		Units1 ++ [{SelfId, TargetID, ?SKILL_MISS, 0, SkillId,SkillLevel}];
		 	{critical,Damage} ->
		 		role_statistics:update_role_dps_damage(Damage),
		 	 	Units1 ++ [{SelfId,TargetID, ?SKILL_CRITICAL, Damage, SkillId,SkillLevel}];
		 	{normal, Damage} ->
		 		role_statistics:update_role_dps_damage(Damage),
		 		Units1 ++ [{SelfId, TargetID, ?SKILL_NORMAL, Damage, SkillId,SkillLevel}];
		 	recover ->
		 		Units1 ++ [{SelfId, TargetID, ?SKILL_RECOVER, 0, SkillId,SkillLevel}]
		end									     
	end,[],CastResult),
	%%服务器上需要根据flytime延迟计算伤害
	role_op:attacked_broadcast(SelfId, FlyTime,Units),
	%%先通知他们的客户端被攻击了
	AttackMsg = role_packet:encode_be_attacked_s2c(TrueId,SkillId,Units,FlyTime),
	role_op:broadcast_message_to_aoi_client(AttackMsg).

set_casttime(SkillId) ->
	SkillsInfo = get(skill_info),
	{SkillId, SkillLevel, _} = lists:keyfind(SkillId, 1, SkillsInfo),
	put(skill_info, lists:keyreplace(SkillId, 1, SkillsInfo, {SkillId, SkillLevel, 
		timer_center:get_correct_now()})).

start_move(PathId, Pos) ->
    RoleInfo = get(creature_info),
	case mock_db:get_mock_path_type_6(PathId, Pos) of
		[] ->
            Interval = 5000 + random:uniform(15000),
            erlang:send_after(Interval, self(), {respawn});
		PathInfo ->
			Path = mock_db:get_mock_path_type_6(PathInfo),
            %% move([{61,112},{64,112},{67,112},{70,112},{73,109},{76,106},{79,103}]),
            move(Path),
			put(path_info, {PathId, Pos})
	end.


move([]) ->
	{PathId, Pos} = get(path_info),
	self() ! {start_move, PathId + 1, Pos};

move(Path) ->
	CreatureInfo = get(creature_info),
	case length(Path) >= ?PATH_POIN_NUMBER of
		true->
			{NewMovePath,LeftPath} = lists:split(?PATH_POIN_NUMBER, Path);
		_->
			LeftPath = [],NewMovePath = Path 
	end,		
	put(travel_path,LeftPath),
	clear_now_move(),
	creature_op:move_notify_aoi_roles(CreatureInfo, NewMovePath),
	put(creature_info, set_path_to_roleinfo(CreatureInfo,NewMovePath)),
	[NextPos|_T] = NewMovePath, 
	Speed = get_speed_from_roleinfo(CreatureInfo),												
	RunTime = erlang:trunc(1000/Speed)*?PATH_POIN_NUMBER,
	Timer = erlang:send_after(RunTime, self(), {move_heartbeat, NextPos}),
	set_move_timer(Timer).

move_heartbeat(NowPos) ->
	CreatureInfo = get(creature_info),
	MapInfo = get(map_info),
	MoveResult = creature_op:move_heartbeat(CreatureInfo, MapInfo, NowPos),
	case MoveResult of
		{moving, RemainPath} ->
			[NextPos|_T] = RemainPath,
			Speed = get_speed_from_roleinfo(CreatureInfo),												
			RunTime = erlang:trunc(1000/Speed)*?PATH_POIN_NUMBER,								
			Timer = erlang:send_after(RunTime, 
				self(), {move_heartbeat, NextPos}),
			set_move_timer(Timer);
		gaming ->
			move(get(travel_path))
	end.
	
clear_now_move()->
	set_move_timer(0),
	set_path_to_roleinfo(get(creature_info),[]).

set_move_timer(NewTimer)->
	case get(move_timer) of
		0->
			put(move_timer,NewTimer);
		Timer->
			erlang:cancel_timer(Timer),
			put(move_timer,NewTimer)
	end.