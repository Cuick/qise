%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module (mock_processor_type_3).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include ("mock_def.hrl").
-include ("login_pb.hrl").

%% --------------------------------------------------------------------
%% External exports
-export([start_link/7, make_proc_name/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include ("role_struct.hrl").
-include ("map_def.hrl").

-record(state, {}).


%% ====================================================================
%% External functions
%% ====================================================================
start_link(MockId, Name, Gender, Class, SpeakMin, SpeakMax, BroadCastRate)->
    MockProc = make_proc_name(MockId),
	gen_server:start({local, MockProc}, ?MODULE, [MockId, Name, Gender, Class, 
        SpeakMin, SpeakMax, BroadCastRate], []).


make_proc_name(MockId) ->
    list_to_atom(integer_to_list(MockId)).

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
init([MockId, Name, Gender, Class, SpeakMin, SpeakMax, BroadCastRate]) ->
    timer_center:start_at_process(),
    {A,B,C} = timer_center:get_correct_now(),
    random:seed(A,B,C),
    put(mock_base, {MockId, Name, Gender, Class}),
    put(speak_interval, {SpeakMin, SpeakMax}),
    case check_broadcast(BroadCastRate) of
        true ->
            BroadCastInfo = mock_db:get_mock_broadcast_info(),
            BoradCastLevel = mock_db:get_mock_broadcast_level(BroadCastInfo),
            put(broadcast_level, BoradCastLevel + random:uniform(30 - BoradCastLevel));
        false ->
            nothing
    end,
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
    {MockId, Name, Gender, Class} = get(mock_base),
    erase(mock_base),
    put(roleid, MockId),
    Node = node(),
    MapId = if
    	Gender =:= 1 ->
    		?BORN_MAP_MALE;
    	true ->
    		?BORN_MAP_FEMALE
    end,
    Pos = ?BORN_POS,
    LineId = mock_util:get_line_id(Node),
    {ok, {_, MapProc}} = lines_manager:get_map_name(LineId, MapId),
    MapInfo = create_mapinfo(MapId, LineId, node(), MapProc, ?GRID_WIDTH),
    put(map_info, MapInfo),
    NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
    put(npcinfo_db,NpcInfoDB),
    put(aoi_list, []),
    GsGateInfo = #gs_system_gate_info{gate_proc = self(), gate_node = Node, gate_pid = self()},
    put(gate_info, GsGateInfo),
    MockBase = mock_db:get_mock_base(Class, ?BORN_LEVEL),
    SelfInfo = #gm_role_info{
        gs_system_role_info = #gs_system_role_info{role_id = MockId, role_pid = self(), role_node = Node}, 
        gs_system_map_info = #gs_system_map_info{map_id = MapId, line_id = LineId, map_proc = MapProc, map_node = Node},
        gs_system_gate_info = GsGateInfo,
        pos = Pos,
        name = Name, 
        view = 0,
        life = mock_db:get_mock_life(MockBase),
        mana = mock_db:get_mock_mana(MockBase),
        gender = Gender,
        icon = [],
        speed = 8,
        state = gaming,  
        extra_states = [],
        path = [],
        level = ?BORN_LEVEL,
        silver = 0,
        boundsilver = 0,
        gold = 0,
        ticket = 0,
        hatredratio = 1,
        expratio = [],
        lootflag = 1,
        exp = mock_db:get_mock_exp(MockBase),
        levelupexp = mock_db:get_mock_levelupexp(MockBase),
        agile = mock_db:get_mock_agile(MockBase),
        strength = mock_db:get_mock_strength(MockBase),
        intelligence = mock_db:get_mock_intelligence(MockBase),
        stamina = mock_db:get_mock_stamina(MockBase),
        hpmax = mock_db:get_mock_hpmax(MockBase),       
        mpmax = mock_db:get_mock_mpmax(MockBase),
        hprecover = 2,
        mprecover = 2,
        power = mock_db:get_mock_power(MockBase),
        class = Class,
        commoncool = 1300,
        immunes = mock_db:get_mock_immunes(MockBase),
        hitrate = mock_db:get_mock_hitrate(MockBase),
        dodge = mock_db:get_mock_dodge(MockBase),
        criticalrate = mock_db:get_mock_criticalrate(MockBase),
        criticaldamage = mock_db:get_mock_criticaldamage(MockBase),
        toughness = mock_db:get_mock_toughness(MockBase),
        debuffimmunes = {0,0,0,0,0},
        defenses = mock_db:get_mock_defenses(MockBase),
        buffer = [],
        guildname = [],
        guildposting = 0,
        cloth = mock_db:get_mock_cloth(MockBase),
        arm = mock_db:get_mock_arm(MockBase),
        pkmodel = {0,{0,0,0}},
        crime = mock_db:get_mock_crime(MockBase),
        viptag = mock_db:get_mock_viptag(MockBase),
        pet_id = 0,
        ride_display = 0,
        camp = 0,
        displayid = 0,
        companion_role = 0,
        dancing_role = 0,
        spouse = 0,
        serverid = env:get(serverid, 1),
        treasure_transport = 0,
        petexpratio = 1,
        group_id = 0,
        fighting_force = mock_db:get_mock_fightforce(MockBase),
        guildtype = 0,
        honor = 0,
        battlefield_dead_counter = [],
        pet_skill = [],
        money_check_lock = false
    },
    put(creature_info, SelfInfo),
    role_pos_db:reg_role_pos_to_mnesia(MockId, LineId, MapId, Name, Node, make_proc_name(MockId), Node, self()),
    role_op:update_role_info(MockId, SelfInfo),
    MapDb = mapdb_processor:make_db_name(MapId),
	put(map_db,MapDb),
    put(move_timer, 0),
	creature_op:join(SelfInfo, MapInfo),
	start_move(?BORN_PATH_ID),
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

handle_info({speak}, State) ->
    speak(),
    {noreply, State};

handle_info({exit}, State) ->
    RoleInfo = get(creature_info),
    MockId = get_id_from_roleinfo(RoleInfo),
    role_op:leave_map(RoleInfo, get(map_info)),
    role_pos_db:unreg_role_pos_to_mnesia(MockId),
    role_manager:unregist_role_info(MockId),
    Gender = get_gender_from_roleinfo(RoleInfo),
    Name = get_name_from_roleinfo(RoleInfo),
    mock_name_generator:return_name_back(Gender, Name),
	{stop, normal, State};

handle_info({move_heartbeat, NewPos}, State) ->
	move_heartbeat(NewPos),
	{noreply, State};

handle_info({start_move, PathId}, State) ->
	start_move(PathId),
	{noreply, State};

handle_info({other_into_view, OtherId}, State) ->
    other_into_view(OtherId),
    {noreply, State};

handle_info({other_outof_view, OtherId}, State) ->
    other_outof_view(OtherId),
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
start_move(PathId) ->
    RoleInfo = get(creature_info),
	case mock_db:get_mock_info_type_3(PathId) of
		[] ->
            Gender = get_gender_from_roleinfo(RoleInfo),
            Name = get_name_from_roleinfo(RoleInfo),
            mock_name_generator:return_name_back(Gender, Name),
			self() ! {exit};
		PathInfo ->
			Level = mock_db:get_mock_level_type_3(PathInfo),
			OldLevel = get_level_from_roleinfo(get(creature_info)),
			if
				Level =/= OldLevel ->
					update_role_info(Level),
                    broadcast(Level);
				true ->
					nothing
			end,
            if
                Level > 10 ->
                    start_speak();
                true ->
                    nothing
            end,
            MockId = get_id_from_roleinfo(RoleInfo),
			role_op:update_role_info(MockId, RoleInfo),
			Path = mock_db:get_mock_path_type_3(PathInfo),
            %% move([{61,112},{64,112},{67,112},{70,112},{73,109},{76,106},{79,103}]),
            move(Path),
			put(path_id, PathId)
	end.


move([]) ->
	PathId = get(path_id),
	PathInfo = mock_db:get_mock_info_type_3(PathId),
	case mock_db:get_mock_next_map_type_3(PathInfo) of
		0 ->
			nothing;
		{NextMapId, NextPos} ->
			change_map(NextMapId, NextPos)
	end,
	WaitTime = mock_db:get_mock_wait_time_type_3(PathInfo),
	if
		WaitTime =:= 0 ->
			self() ! {start_move, PathId + 1};
		true ->
			erlang:send_after(WaitTime, self(), {start_move, PathId + 1})
	end;

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

change_map(NextMapId, NextPos) ->
	RoleInfo = get(creature_info),
	MapInfo = get(map_info),
	role_op:leave_map(RoleInfo, MapInfo),
	LineId = get_lineid_from_mapinfo(MapInfo),
	{ok, {_, MapProc}} = lines_manager:get_map_name(LineId, NextMapId),
	MapInfo2 = set_proc_to_mapinfo(MapInfo, MapProc),
	MapInfo3 = set_mapid_to_mapinfo(MapInfo2, NextMapId),
	put(map_info, MapInfo3),
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
    put(npcinfo_db,NpcInfoDB),
    GsMapInfo = #gs_system_map_info{
    	map_id=NextMapId,
		line_id=LineId, 
		map_proc=MapProc, 
	    map_node=node()},
	RoleInfo2 = set_pos_to_roleinfo(RoleInfo, NextPos),
	RoleInfo3 = set_mapinfo_to_roleinfo(RoleInfo2, GsMapInfo),
	put(creature_info, RoleInfo3),
	MapDb = mapdb_processor:make_db_name(NextMapId),
	put(map_db,MapDb),
	role_pos_util:update_role_line_map(get_id_from_roleinfo(RoleInfo3), LineId, NextMapId),
	creature_op:join(RoleInfo3, MapInfo3).

update_role_info(Level) ->
    RoleInfo = get(creature_info),
    Class = get_class_from_roleinfo(RoleInfo),
    MockBase = mock_db:get_mock_base(Class, Level),
    Cloth = mock_db:get_mock_cloth(MockBase),
    Arm = mock_db:get_mock_arm(MockBase),
    Hp = mock_db:get_mock_life(MockBase),
    Mp = mock_db:get_mock_mana(MockBase),
    VipTag = case get_viptag_from_roleinfo(RoleInfo) of
        5 ->
            5;
        7 ->
            7;
        _ ->
            mock_db:get_mock_viptag(MockBase)
    end,
    RideDisplay = case get_ride_display_from_roleinfo(RoleInfo) of
        0 ->
            case mock_db:get_mock_ride_display(MockBase) of
                0 ->
                    0;
                DropRules ->
                    [{ItemId, _} | _] = drop:apply_quest_droplist(DropRules),
                    ItemId
            end;
        RideDisplay3 ->
            RideDisplay3
    end,
    RoleInfo2 = RoleInfo#gm_role_info{
        life = Hp,
        mana = Mp,
        level = Level,
        exp = mock_db:get_mock_exp(MockBase),
        levelupexp = mock_db:get_mock_levelupexp(MockBase),
        agile = mock_db:get_mock_agile(MockBase),
        strength = mock_db:get_mock_strength(MockBase),
        intelligence = mock_db:get_mock_intelligence(MockBase),
        stamina = mock_db:get_mock_stamina(MockBase),
        hpmax = mock_db:get_mock_hpmax(MockBase),       
        mpmax = mock_db:get_mock_mpmax(MockBase),
        power = mock_db:get_mock_power(MockBase),
        immunes = mock_db:get_mock_immunes(MockBase),
        hitrate = mock_db:get_mock_hitrate(MockBase),
        dodge = mock_db:get_mock_dodge(MockBase),
        criticalrate = mock_db:get_mock_criticalrate(MockBase),
        criticaldamage = mock_db:get_mock_criticaldamage(MockBase),
        toughness = mock_db:get_mock_toughness(MockBase),
        defenses = mock_db:get_mock_defenses(MockBase),
        cloth = Cloth,
        arm = Arm,
        crime = mock_db:get_mock_crime(MockBase),
        viptag = VipTag,
        ride_display = RideDisplay,
        fighting_force = mock_db:get_mock_fightforce(MockBase)
    },
    put(creature_info, RoleInfo2),
    role_op:self_update_and_broad([{level, Level}, {hp, Hp}, {mp, Mp}, {arm, Arm}, {cloth, Cloth}]).

other_into_view(OtherId) ->
    case creature_op:get_creature_info(OtherId) of
        undefined ->
            nothing;
        OtherInfo-> 
            creature_op:handle_other_into_view(OtherInfo)
    end.

other_outof_view(OtherId) ->
    creature_op:remove_from_aoi_list(OtherId).

start_speak() ->
    case get(msg_num) of
        undefined ->
            send_time_speak();
        _ ->
            nothing
    end.

send_time_speak() ->
    {SpeakMin, SpeakMax} = get(speak_interval),
    MsgNum = mock_db:get_msg_num(),
    put(msg_num, MsgNum),
    Internal = SpeakMin + random:uniform(SpeakMax - SpeakMin),
    erlang:send_after(Internal, self(), {speak}).

speak() ->
    MsgNum = get(msg_num),
    MsgId = random:uniform(MsgNum),
    MsgInfo = mock_db:get_msg_info(MsgId),
    Message = mock_db:get_msg(MsgInfo),
    RoleInfo = get(creature_info),
    RoleName = get_name_from_roleinfo(RoleInfo),
    RoleId = get(roleid),
    Gender = "gender" ++ integer_to_list(get_gender_from_roleinfo(RoleInfo)),
    Details = ["details","0","0","0","0",Gender],
    ChatContent = #chat_s2c{type = 1,serverid = 0,privateflag = 2,desroleid = RoleId, 
        desrolename = binary_to_list(RoleName), msginfo = Message, details = Details, identity = 0},
    Msg = login_pb:encode_chat_s2c(ChatContent),
    role_pos_util:send_to_all_online_clinet(Msg).

check_broadcast(BroadCastRate) ->
    Num = random:uniform(100),
    Num =< BroadCastRate.

broadcast(Level) ->
    case get(broadcast_level) of
        Level ->
            do_broadcast();
        _ ->
            nothing
    end.

do_broadcast() ->
    BroadCastInfo = mock_db:get_mock_broadcast_info(),
    BroadCastList = mock_db:get_mock_broadcast_list(BroadCastInfo),
    Length = length(BroadCastList),
    ChatId = lists:nth(random:uniform(Length), BroadCastList),
    ChatMsg = format_broadcast_msg(ChatId),
    if
        is_list(ChatMsg) ->
            [role_pos_util:send_to_all_online_clinet(X) || X <- ChatMsg];
        true ->
            role_pos_util:send_to_all_online_clinet(ChatMsg)
    end.

format_broadcast_msg(1192) ->
    %% 鸿运大转盘
    Money = lists:nth(random:uniform(6), [100,200,300,500,1000,5000]),
    RoleInfo = get(creature_info),
    ParamRole = system_chat_util:make_role_param(RoleInfo),
    ParamInt = system_chat_util:make_int_param(Money),
    MsgInfo = [ParamRole,ParamInt],
    login_pb:encode_system_broadcast_s2c(
        #system_broadcast_s2c{
            id = 1192,
            param = MsgInfo
        });
format_broadcast_msg(21) ->
    %% VIP白银卡
    RoleInfo = get(creature_info),
    put(creature_info, set_viptag_to_roleinfo(RoleInfo, 5)),
    ParamRole = system_chat_util:make_role_param(RoleInfo),
    ParamItem = system_chat_util:make_item_param(19010190),
    MsgInfo1 = [ParamRole],
    MsgInfo2 = [ParamRole,ParamItem],
    [login_pb:encode_system_broadcast_s2c(
        #system_broadcast_s2c{
            id = 1151,
            param = MsgInfo2
        }),
    login_pb:encode_system_broadcast_s2c(
        #system_broadcast_s2c{
            id = 21,
            param = MsgInfo1
        })];
    
format_broadcast_msg(22) ->
    %% VIP黄金卡
    RoleInfo = get(creature_info),
    put(creature_info, set_viptag_to_roleinfo(RoleInfo, 7)),
    ParamRole = system_chat_util:make_role_param(RoleInfo),
    MsgInfo1 = [ParamRole],
    ParamItem = system_chat_util:make_item_param(19010210),
    MsgInfo2 = [ParamRole,ParamItem],
    [login_pb:encode_system_broadcast_s2c(
        #system_broadcast_s2c{
            id = 1151,
            param = MsgInfo2
        }),
    login_pb:encode_system_broadcast_s2c(
        #system_broadcast_s2c{
            id = 22,
            param = MsgInfo1
        })];
format_broadcast_msg(ChatId) ->
    RoleInfo = get(creature_info),
    ParamRole = system_chat_util:make_role_param(RoleInfo),
    MsgInfo = [ParamRole],
    login_pb:encode_system_broadcast_s2c(
        #system_broadcast_s2c{
            id = ChatId,
            param = MsgInfo
        }).