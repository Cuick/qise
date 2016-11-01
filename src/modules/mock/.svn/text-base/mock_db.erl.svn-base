-module (mock_db).

%%
%% Include files
%%
-include("mock_def.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define (ETS_MOCK_TYPE_1,ets_mock_type_1).
-define (ETS_MOCK_TYPE_2,ets_mock_type_2).
-define (ETS_MOCK_TYPE_3,ets_mock_type_3).
-define (ETS_MOCK_TYPE_4,ets_mock_type_4).
-define (ETS_MOCK_TYPE_5,ets_mock_type_5).
-define (ETS_MOCK_TYPE_6,ets_mock_type_6).
-define (ETS_MOCK_PATH_TYPE_6,ets_mock_path_type_6).
-define (ETS_MOCK_BASE, ets_mock_base).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(mock_type_1, record_info(fields,mock_type_1), [], set),
	db_tools:create_table_disc(mock_type_2, record_info(fields,mock_type_2), [], set),
	db_tools:create_table_disc(mock_type_3, record_info(fields,mock_type_3), [], set),
	db_tools:create_table_disc(mock_type_4, record_info(fields,mock_type_4), [], set),
	db_tools:create_table_disc(mock_type_5, record_info(fields,mock_type_5), [], set),
	db_tools:create_table_disc(mock_type_6, record_info(fields,mock_type_6), [], set),
	db_tools:create_table_disc(mock_path_type_6, record_info(fields,mock_path_type_6), [], bag),
	db_tools:create_table_disc(mock_base, record_info(fields,mock_base), [], bag).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{mock_type_1,proto}, {mock_type_3,proto}, {mock_type_4,proto}, {mock_type_5, proto}, 
	{mock_type_6, proto}, {mock_path_type_6, proto}, {mock_base,proto}, {mock_type_2, proto}].

create()->
	ets:new(?ETS_MOCK_TYPE_1, [set,named_table]),
	ets:new(?ETS_MOCK_TYPE_2, [set,named_table]),
	ets:new(?ETS_MOCK_TYPE_3, [set,named_table]),
	ets:new(?ETS_MOCK_TYPE_4, [set,named_table]),
	ets:new(?ETS_MOCK_TYPE_5, [set,named_table]),
	ets:new(?ETS_MOCK_TYPE_6, [set,named_table]),
	ets:new(?ETS_MOCK_PATH_TYPE_6, [set,named_table]),
	ets:new(?ETS_MOCK_BASE, [set, named_table]).

init()->
	db_operater_mod:init_ets(mock_type_1, ?ETS_MOCK_TYPE_1,#mock_type_1.id),
	db_operater_mod:init_ets(mock_type_2, ?ETS_MOCK_TYPE_2,#mock_type_2.id),
	db_operater_mod:init_ets(mock_type_3, ?ETS_MOCK_TYPE_3,#mock_type_3.id),
	db_operater_mod:init_ets(mock_type_4, ?ETS_MOCK_TYPE_4,#mock_type_4.id),
	db_operater_mod:init_ets(mock_type_5, ?ETS_MOCK_TYPE_5,#mock_type_5.id),
	db_operater_mod:init_ets(mock_type_6, ?ETS_MOCK_TYPE_6,#mock_type_6.id),
	db_operater_mod:init_ets(mock_path_type_6, ?ETS_MOCK_PATH_TYPE_6,[#mock_path_type_6.id, #mock_path_type_6.pos]),
	db_operater_mod:init_ets(mock_base, ?ETS_MOCK_BASE,[#mock_base.class, #mock_base.level]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_mock_info_type_1(MockId) ->
	case ets:lookup(?ETS_MOCK_TYPE_1, MockId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_mock_level_type_1(MockInfo) ->
	MockInfo#mock_type_1.level.

get_mock_id_type_1(MockInfo) ->
	MockInfo#mock_type_1.id.

get_mock_map_id_type_1(MockInfo) ->
	MockInfo#mock_type_1.map_id.

get_mock_pos_type_1(MockInfo) ->
	MockInfo#mock_type_1.pos.

get_all_mock_type_1() ->
	[X || {_, X} <- ets:tab2list(?ETS_MOCK_TYPE_1)].

get_mock_base(Class, Level) ->
	case ets:lookup(?ETS_MOCK_BASE, {Class, Level}) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_mock_exp(MockBase) ->
	MockBase#mock_base.exp.

get_mock_life(MockBase) ->
	MockBase#mock_base.life.

get_mock_mana(MockBase) ->
	MockBase#mock_base.mana.

get_mock_levelupexp(MockBase) ->
	MockBase#mock_base.levelupexp.

get_mock_agile(MockBase) ->
	MockBase#mock_base.agile.

get_mock_strength(MockBase) ->
	MockBase#mock_base.strength.

get_mock_intelligence(MockBase) ->
	MockBase#mock_base.intelligence.

get_mock_stamina(MockBase) ->
	MockBase#mock_base.stamina.

get_mock_hpmax(MockBase) ->
	MockBase#mock_base.hpmax.

get_mock_mpmax(MockBase) ->
	MockBase#mock_base.mpmax.

get_mock_power(MockBase) ->
	MockBase#mock_base.power.

get_mock_immunes(MockBase) ->
	MockBase#mock_base.immunes.

get_mock_hitrate(MockBase) ->
	MockBase#mock_base.hitrate.

get_mock_dodge(MockBase) ->
	MockBase#mock_base.dodge.

get_mock_criticalrate(MockBase) ->
	MockBase#mock_base.criticalrate.

get_mock_state(MockBase) ->
	MockBase#mock_base.state.

get_mock_criticaldamage(MockBase) ->
	MockBase#mock_base.criticaldamage.

get_mock_toughness(MockBase) ->
	MockBase#mock_base.toughness.

get_mock_defenses(MockBase) ->
	MockBase#mock_base.defenses.

get_mock_cloth(MockBase) ->
	MockBase#mock_base.cloth.

get_mock_arm(MockBase) ->
	MockBase#mock_base.arm.

get_mock_crime(MockBase) ->
	MockBase#mock_base.crime.

get_mock_viptag(MockBase) ->
	MockBase#mock_base.viptag.

get_mock_ride_display(MockBase) ->
	MockBase#mock_base.ride_display.

get_mock_fightforce(MockBase) ->
	MockBase#mock_base.fighting_force.

get_mock_soulpower(MockBase) ->
	MockBase#mock_base.soulpower.

get_mock_maxsoulpower(MockBase) ->
	MockBase#mock_base.maxsoulpower.

get_mock_equipments(MockInfo) ->
	MockInfo#mock_base.eqipments.

get_mock_info_type_3(PathId) ->
	case ets:lookup(?ETS_MOCK_TYPE_3, PathId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_mock_next_map_type_3(PathInfo) ->
	PathInfo#mock_type_3.next_map.

get_mock_wait_time_type_3(PathInfo) ->
	PathInfo#mock_type_3.wait_time.

get_mock_level_type_3(PathInfo) ->
	PathInfo#mock_type_3.level.

get_mock_path_type_3(PathInfo) ->
	PathInfo#mock_type_3.path.

get_msg_info(MsgId) ->
	case ets:lookup(?ETS_MOCK_TYPE_4, MsgId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_msg(MsgInfo) ->
	MsgInfo#mock_type_4.msg.

get_msg_num() ->
	ets:info(?ETS_MOCK_TYPE_4, size).

get_mock_broadcast_info() ->
	case ets:lookup(?ETS_MOCK_TYPE_5, 1) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_mock_broadcast_level(BroadCastInfo) ->
	BroadCastInfo#mock_type_5.level.

get_mock_broadcast_list(BroadCastInfo) ->
	BroadCastInfo#mock_type_5.broadcasts.

get_mock_id_type_6(MockInfo) ->
	MockInfo#mock_type_6.id.

get_all_mock_type_6() ->
	[X || {_, X} <- ets:tab2list(?ETS_MOCK_TYPE_6)].

get_mock_info_type_6(MockId) ->
	case ets:lookup(?ETS_MOCK_TYPE_6, MockId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_mock_level_type_6(MockInfo) ->
	MockInfo#mock_type_6.level.

get_mock_equipments_type_6(MockInfo) ->
	MockInfo#mock_type_6.equipments.

get_mock_skills_type_6(MockInfo) ->
	MockInfo#mock_type_6.skills.

get_mock_class_type_6(MockInfo) ->
	MockInfo#mock_type_6.class.

get_mock_path_type_6(PathId, Pos) ->
	case ets:lookup(?ETS_MOCK_PATH_TYPE_6, {PathId, Pos}) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_mock_path_type_6(PathInfo) ->
	PathInfo#mock_path_type_6.path.

get_all_mock_type_2() ->
	[X || {_, X} <- ets:tab2list(?ETS_MOCK_TYPE_2)].

get_mock_info_type_2(MockId) ->
	case ets:lookup(?ETS_MOCK_TYPE_2, MockId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_mock_id_type_2(MockInfo) ->
	MockInfo#mock_type_2.id.

get_mock_class_type_2(MockInfo) ->
	MockInfo#mock_type_2.class.

get_mock_map_type_2(MockInfo) ->
	MockInfo#mock_type_2.map_id.

get_mock_pos_type_2(MockInfo) ->
	MockInfo#mock_type_2.pos.

get_mock_equipments_type_2(MockInfo) ->
	MockInfo#mock_type_2.equipments.

get_mock_skills_type_2(MockInfo) ->
	MockInfo#mock_type_2.skills.

get_mock_enemy_type_2(MockInfo) ->
	MockInfo#mock_type_2.enemy_id.

get_mock_level_type_2(MockInfo) ->
	MockInfo#mock_type_2.level.
