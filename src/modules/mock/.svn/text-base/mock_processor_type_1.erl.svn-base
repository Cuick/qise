%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module (mock_processor_type_1).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include ("mock_def.hrl").
-include ("login_pb.hrl").

%% --------------------------------------------------------------------
%% External exports
-export([start_link/7, make_proc_name/1, stop/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include ("role_struct.hrl").
-include ("map_def.hrl").

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
    Node = node(),
    MockProto = mock_db:get_mock_info_type_1(ProtoId),
    MapId = mock_db:get_mock_map_id_type_1(MockProto),
    Pos = mock_db:get_mock_pos_type_1(MockProto),
    {ok, {_, MapProc}} = lines_manager:get_map_name(LineId, MapId),
    MapInfo = create_mapinfo(MapId, LineId, node(), MapProc, ?GRID_WIDTH),
    put(map_info, MapInfo),
    NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
    put(npcinfo_db,NpcInfoDB),
    put(aoi_list, []),
    GsGateInfo = #gs_system_gate_info{gate_proc = self(), gate_node = Node, gate_pid = self()},
    put(gate_info, GsGateInfo),
    Level = mock_db:get_mock_level_type_1(MockProto),
    MockBase = mock_db:get_mock_base(Class, Level),
    RideDisplay = case mock_db:get_mock_ride_display(MockBase) of
        0 ->
            0;
        DropRules ->
            [{ItemId, _} | _] = drop:apply_quest_droplist(DropRules),
            ItemId
    end,
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
        state = mock_db:get_mock_state(MockBase),  
        extra_states = [],
        path = [],
        level = Level,
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
        ride_display = RideDisplay,
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
	creature_op:join(SelfInfo, MapInfo),
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
other_into_view(OtherId) ->
    case creature_op:get_creature_info(OtherId) of
        undefined ->
            nothing;
        OtherInfo-> 
            creature_op:handle_other_into_view(OtherInfo)
    end.

other_outof_view(OtherId) ->
    creature_op:remove_from_aoi_list(OtherId).
