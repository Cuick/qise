%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module (mock_processor_type_2).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

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

%% --------------------------------------------------------------------
%% External exports
-export([start_link/7, make_proc_name/1, stop/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include ("map_info_struct.hrl").
-include ("role_struct.hrl").
-include ("item_struct.hrl").

-record(state, {}).


%% ====================================================================
%% External functions
%% ====================================================================
start_link(MockProc, MockId, ProtoId, Name, Gender, Class, LineId)->
	gen_server:start({local, MockProc}, ?MODULE, [MockId, ProtoId, Name, Gender, Class, LineId], []).

make_proc_name(MockId) ->
    list_to_atom(integer_to_list(MockId)).

stop(MockProc) ->
    gen_server:call(MockProc, {stop}).


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([MockId, ProtoId, Name, Gender, Class, LineId]) ->
    put(mock_base, {MockId, ProtoId, Name, Gender, Class, LineId}),
	self() ! {enter_map},
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({stop}, _, State) ->
    RoleInfo = get(creature_info),
    MockId = get_id_from_roleinfo(RoleInfo),
    role_op:leave_map(RoleInfo, get(map_info)),
    role_pos_db:unreg_role_pos_to_mnesia(MockId),
    role_manager:unregist_role_info(MockId),
    Gender = get_gender_from_roleinfo(RoleInfo),
    Name = get_name_from_roleinfo(RoleInfo),
    mock_name_generator:return_name_back(Gender, Name),
    {reply, ok, State};

handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({enter_map}, State) ->
    {MockId, ProtoId, Name, Gender, Class, LineId} = get(mock_base),
    erase(mock_base),
    put(roleid, MockId),
    put(creature_info,create_roleinfo()),
    MockPid = make_proc_name(MockId),
    MockNode = node(),
    MockInfo = mock_db:get_mock_info_type_2(ProtoId),
    Level = mock_db:get_mock_level_type_2(MockInfo),
    MockPos = mock_db:get_mock_pos_type_2(MockInfo),
    MapId = mock_db:get_mock_map_type_2(MockInfo),
    Viptag = 0,
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
    put(present_pet_slot,0),        %%赠送的宠物槽位
    put(mypets_add_talent,[]),
    put(pet_can_buy_goods,[]),      %%在宠物商店可以买的物品列表
    put(pet_refresh_used,[]),       %%已用刷新次数
    put(pet_account,0),             %%宠物商店积分
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
    Equipments = mock_db:get_mock_equipments_type_2(MockInfo),
    equip(Equipments),

    %% Packages
    init_package(PackageSize),

    %% Skills
    Skills = mock_db:get_mock_skills_type_2(MockInfo),
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
    MapInfo = create_mapinfo(MapId, LineId, MockNode, map_manager:make_map_process_name(LineId, MapId), ?GRID_WIDTH),
    put(map_info, MapInfo),
    {ok, {_, MapProc}} = lines_manager:get_map_name(LineId, MapId),
    NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
    put(npcinfo_db,NpcInfoDB),
    role_pos_db:reg_role_pos_to_mnesia(MockId, LineId, MapId, Name, MockNode, make_proc_name(MockId), MockNode, self()),
    case map_info_db:get_map_info(MapId) of
        []->
            nothing;
        MapProtoInfo->
            map_script:run_script(on_join,MapProtoInfo)
    end,
    %% 切换为游戏状态
    creature_op:join(get(creature_info), MapInfo),
    EnemyId = mock_db:get_mock_enemy_type_2(MockInfo),
    self() ! {attack_enemey, EnemyId},
	{noreply, State};

handle_info({other_inspect_you,{ServerId,RoleId}}, State) ->
    RoleInfo = get(creature_info),
    Class = get_class_from_roleinfo(RoleInfo),
    Level = get_level_from_roleinfo(RoleInfo),
    MockBase = mock_db:get_mock_base(Class, Level),
    Equipments = mock_db:get_mock_equipments(MockBase),
    BodyItemsInfo = lists:map(fun({ProtoId, Enchantments, Slot}) ->
        #i{
            itemid_low = 648000002,
            itemid_high = 1206000001,
            protoid = ProtoId,
            enchantments = Enchantments,
            count = 1,
            slot = Slot,
            isbonded = 1,
            socketsinfo = [],
            duration = 100,
            enchant = [],
            lefttime_s = -1
        }
    end, Equipments),
    InspectInfo = #inspect_s2c{
        roleid = get_id_from_roleinfo(RoleInfo),
        rolename = get_name_from_roleinfo(RoleInfo),
        gender = get_gender_from_roleinfo(RoleInfo),
        guildname = [],
        classtype = get_class_from_roleinfo(RoleInfo),
        level = get_level_from_roleinfo(RoleInfo),
        cloth = get_cloth_from_roleinfo(RoleInfo),
        arm = get_arm_from_roleinfo(RoleInfo),
        maxhp = get_hpmax_from_roleinfo(RoleInfo),
        maxmp = get_mpmax_from_roleinfo(RoleInfo),
        power = get_power_from_roleinfo(RoleInfo),
        magic_defense = erlang:element(1,get_defenses_from_roleinfo(RoleInfo)),
        range_defense = erlang:element(2,get_defenses_from_roleinfo(RoleInfo)),
        melee_defense = erlang:element(3,get_defenses_from_roleinfo(RoleInfo)),
        stamina = get_stamina_from_roleinfo(RoleInfo),
        strength = get_strength_from_roleinfo(RoleInfo),
        intelligence = get_intelligence_from_roleinfo(RoleInfo),
        agile = get_agile_from_roleinfo(RoleInfo),
        hitrate = get_hitrate_from_roleinfo(RoleInfo),
        criticalrate = get_criticalrate_from_roleinfo(RoleInfo),
        criticaldamage = get_criticaldamage_from_roleinfo(RoleInfo),
        dodge = get_dodge_from_roleinfo(RoleInfo),
        toughness = get_toughness_from_roleinfo(RoleInfo),
        meleeimmunity = erlang:element(3,get_immunes_from_roleinfo(RoleInfo)),
        rangeimmunity = erlang:element(2,get_immunes_from_roleinfo(RoleInfo)),
        magicimmunity = erlang:element(1,get_immunes_from_roleinfo(RoleInfo)),
        imprisonment_resist = erlang:element(1,get_debuffimmunes_from_roleinfo(RoleInfo)),
        silence_resist = erlang:element(2,get_debuffimmunes_from_roleinfo(RoleInfo)),
        daze_resist = erlang:element(3,get_debuffimmunes_from_roleinfo(RoleInfo)),
        poison_resist = erlang:element(4,get_debuffimmunes_from_roleinfo(RoleInfo)),
        normal_resist = erlang:element(5,get_debuffimmunes_from_roleinfo(RoleInfo)),
        vip_tag = get_viptag_from_roleinfo(RoleInfo),
        items_attr = BodyItemsInfo,
        guildpost = 0,
        exp = get_exp_from_roleinfo(RoleInfo),
        levelupexp = get_levelupexp_from_roleinfo(RoleInfo),
        soulpower = mock_db:get_mock_soulpower(MockBase),
        maxsoulpower = mock_db:get_mock_maxsoulpower(MockBase),
        guildlid = 0,
        guildhid = 0,
        role_crime = get_crime_from_roleinfo(RoleInfo),
        fighting_force = get_fighting_force_from_roleinfo(RoleInfo),
        curhp = get_life_from_roleinfo(RoleInfo),
        curmp = get_mana_from_roleinfo(RoleInfo)
    },
    Msg = login_pb:encode_inspect_s2c(InspectInfo), 
    role_pos_util:send_to_role_clinet_by_serverid(ServerId,RoleId,Msg),
    {noreply, State};

handle_info({other_into_view, OtherId}, State) ->
    other_into_view(OtherId),
    {noreply, State};

handle_info({other_outof_view, OtherId}, State) ->
    other_outof_view(OtherId),
    {noreply, State};

handle_info({attack_enemey, EnemyId}, State) ->
    attack_enemey(EnemyId),
    {noreply, State};

handle_info({other_be_attacked,AttackInfo}, State) ->
    other_be_attacked(AttackInfo, get(creature_info)),
    {noreply, State};

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================
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
        true ->             %% 原始装备属性+全星属性+套装属性 
            MinEnchant = get_item_enchantmentset(BodyItemsInfo),
            apply_enchantments_changed(MinEnchant),
            ItemsAttr2 = get_item_enchantmentset_attr(MinEnchant) ++ ItemsAttr1;                            
        false ->            %%装备不足，只计算套装属性
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

attack_enemey(EnemyId) ->
    TargetInfo = creature_op:get_creature_info(EnemyId),
    SelfInfo = get(creature_info),
    case choose_skill() of
        nothing ->
            nothing;
        {SkillId, SkillLevel} ->
            SkillInfo = skill_db:get_skill_info(SkillId, SkillLevel),
            case creature_op:is_creature_dead(TargetInfo) of
                false ->
                    creature_op:clear_all_buff_for_type(?MODULE, ?BUFF_CANCEL_TYPE_ATTACK),
                    proc_cast_skill(SelfInfo, TargetInfo, SkillId, SkillLevel, SkillInfo, EnemyId);
                true ->
                    nothing
            end
    end,
    erlang:send_after(1500, self(), {attack_enemey, EnemyId}).

other_be_attacked({EnemyId, _, _, Damage, _,_}, SelfInfo) ->
    SelfId = get(roleid),            
    OtherInfo = creature_op:get_creature_info(EnemyId),   
    IsGod = combat_op:is_target_god(SelfInfo),
    Now = timer_center:get_correct_now(),
    creature_op:clear_all_buff_for_type(?MODULE,?BUFF_CANCEL_TYPE_BEATTACK),
    case ((OtherInfo=:=undefined) or IsGod or is_dead()) of
        true->
            nothing;
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
                    ChangedAttrLife_Mana =  ChangedAttrLife                                         
            end,                 
            NewRoleInfo = apply_skill_attr_changed(SelfInfo,ChangedAttrLife_Mana),
            put(creature_info,NewRoleInfo),
            role_op:update_role_info(SelfId, get(creature_info))
    end.

apply_skill_attr_changed(SelfInfo,ChangedAttr)->
    lists:foldl(fun(Attr,Info)->
        self_update_and_broad([Attr]),
        role_attr:to_creature_info(Attr,Info)
    end,SelfInfo,ChangedAttr).

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

is_dead()->
    creature_op:is_creature_dead(get(creature_info)).

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
                Units1 ++ [{SelfId,TargetID, ?SKILL_CRITICAL, Damage, SkillId,SkillLevel}];
            {normal, Damage} ->
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