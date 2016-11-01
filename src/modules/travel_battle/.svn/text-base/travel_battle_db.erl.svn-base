
-module (travel_battle_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define (ETS_TRAVEL_BATTLE_PROTO,ets_travel_battle_proto).
-define (ETS_TRAVEL_BATTLE_STAGE, ets_travel_battle_stage).
-define (ETS_TRAVEL_BATTLE_SECTION_AWARDS, ets_travel_battle_section_awards).
-define (ETS_TRAVEL_BATTLE_STAGE_AWARDS, ets_travel_battle_stage_awards).
-define (ETS_TRAVEL_BATTLE_MONTH_AWARDS, ets_travel_battle_month_awards).
-define (ETS_TRAVEL_BATTLE_LOTTERY, ets_travel_battle_lottery).
-define (ETS_TRAVEL_BATTLE_SHOP, ets_travel_battle_shop).
-define (ETS_TRAVEL_BATTLE_ZONE_COUNT, ets_travel_battle_zone_count).
-define (ETS_TRAVEL_BATTLE_SERIAL_WIN, ets_travel_battle_serial_win).
-define (ETS_TRAVEL_BATTLE_BUFFERS, ets_travel_battle_buffers).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(travel_battle_proto, record_info(fields,travel_battle_proto), [], set),
	db_tools:create_table_disc(travel_battle_stage, record_info(fields,travel_battle_stage), [], set),
	db_tools:create_table_disc(travel_battle_section_awards, record_info(fields,travel_battle_section_awards), [], set),
	db_tools:create_table_disc(travel_battle_stage_awards, record_info(fields,travel_battle_stage_awards), [], bag),
	db_tools:create_table_disc(travel_battle_month_awards, record_info(fields,travel_battle_month_awards), [], bag),
	db_tools:create_table_disc(travel_battle_lottery, record_info(fields,travel_battle_lottery), [], set),
	db_tools:create_table_disc(travel_battle_shop, record_info(fields,travel_battle_shop), [], set),
	db_tools:create_table_disc(travel_battle_zone_count, record_info(fields,travel_battle_zone_count), [], set),
	db_tools:create_table_disc(travel_battle_serial_win, record_info(fields,travel_battle_serial_win), [], set),
	db_tools:create_table_disc(travel_battle_buffers, record_info(fields, travel_battle_buffers), [], set).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{travel_battle_proto,proto}, {travel_battle_stage,proto}, {travel_battle_section_awards,proto},
	 {travel_battle_lottery,proto}, {travel_battle_shop,proto}, {travel_battle_zone_count, proto},
	 {travel_battle_serial_win, proto}, {travel_battle_stage_awards,proto}, {travel_battle_month_awards, proto},
	 {travel_battle_buffers, proto}].

create()->
	ets:new(?ETS_TRAVEL_BATTLE_PROTO, [set,named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_STAGE, [set, named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_LOTTERY, [set, named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_SHOP, [set, named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_ZONE_COUNT, [set, named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_SECTION_AWARDS, [set, named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_SERIAL_WIN, [set, named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_STAGE_AWARDS, [set, named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_MONTH_AWARDS, [set, named_table]),
	ets:new(?ETS_TRAVEL_BATTLE_BUFFERS, [set, named_table]).

init()->
	db_operater_mod:init_ets(travel_battle_proto, ?ETS_TRAVEL_BATTLE_PROTO,#travel_battle_proto.id),
	db_operater_mod:init_ets(travel_battle_stage, ?ETS_TRAVEL_BATTLE_STAGE,#travel_battle_stage.stage),
	db_operater_mod:init_ets(travel_battle_lottery, ?ETS_TRAVEL_BATTLE_LOTTERY,#travel_battle_lottery.id),
	db_operater_mod:init_ets(travel_battle_shop, ?ETS_TRAVEL_BATTLE_SHOP,#travel_battle_shop.id),
	db_operater_mod:init_ets(travel_battle_zone_count, ?ETS_TRAVEL_BATTLE_ZONE_COUNT,#travel_battle_zone_count.zone_id),
	db_operater_mod:init_ets(travel_battle_serial_win, ?ETS_TRAVEL_BATTLE_SERIAL_WIN,#travel_battle_serial_win.id),
	db_operater_mod:init_ets(travel_battle_section_awards, ?ETS_TRAVEL_BATTLE_SECTION_AWARDS, #travel_battle_section_awards.stage),
	db_operater_mod:init_ets(travel_battle_stage_awards, ?ETS_TRAVEL_BATTLE_STAGE_AWARDS, [#travel_battle_stage_awards.stage, 
		#travel_battle_stage_awards.rank]),
	db_operater_mod:init_ets(travel_battle_month_awards, ?ETS_TRAVEL_BATTLE_MONTH_AWARDS, [#travel_battle_month_awards.stage, 
		#travel_battle_month_awards.rank]),
	db_operater_mod:init_ets(travel_battle_buffers, ?ETS_TRAVEL_BATTLE_BUFFERS, #travel_battle_buffers.proto_id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_battle_info()->
	case ets:lookup(?ETS_TRAVEL_BATTLE_PROTO,1) of
		[]->[];
		[{1,Term}]-> Term
	end.

get_battle_time_line(BattleInfo) ->
	case BattleInfo of
		[]->[];
		_->
			erlang:element(#travel_battle_proto.time_line, BattleInfo)
	end.

get_stage_info(StageId) ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_STAGE, StageId) of
		[]->[];
		[{StageId,Term}]-> Term
	end.

get_stage_level(StageInfo) ->
	StageInfo#travel_battle_stage.level.

get_stage_cost(StageInfo) ->
	StageInfo#travel_battle_stage.cost.

get_stage_interval(StageInfo) ->
	StageInfo#travel_battle_stage.interval.

get_stage_zone_list(StageInfo) ->
	StageInfo#travel_battle_stage.zone_list.

get_stage_person_num(StageInfo) ->
	StageInfo#travel_battle_stage.person_num.

get_stage_points(StageInfo) ->
	StageInfo#travel_battle_stage.points.

get_stage_id(StageInfo) ->
	StageInfo#travel_battle_stage.stage.

get_stage_npc_id(StageInfo) ->
	StageInfo#travel_battle_stage.npc_id.

get_stage_map_id(StageInfo) ->
	case StageInfo of
		[]->[];
		_->
			erlang:element(#travel_battle_stage.map_id, StageInfo)
	end.

get_stage_pos_list(StageInfo) ->
	case StageInfo of
		[]->[];
		_->
			erlang:element(#travel_battle_stage.pos_list, StageInfo)
	end.

get_stage_duration(StageInfo) ->
	case StageInfo of
		[]->[];
		_->
			erlang:element(#travel_battle_stage.duration, StageInfo)
	end.

get_stage_skills(StageInfo) ->
	case StageInfo of
		[]->[];
		_->
			erlang:element(#travel_battle_stage.skills, StageInfo)
	end.

get_stage_skill_change_cost(StageInfo) ->
	case StageInfo of
		[]->[];
		_->
			erlang:element(#travel_battle_stage.skill_change_cost, StageInfo)
	end.

get_stage_prepare_time(StageInfo) ->
	case StageInfo of
		[]->[];
		_->
			erlang:element(#travel_battle_stage.prepare_time, StageInfo)
	end.

get_stage_info_by_npc_id(NpcId) ->
	Result = [X || {_, X} <- ets:tab2list(?ETS_TRAVEL_BATTLE_STAGE), X#travel_battle_stage.npc_id =:= NpcId],
	lists:nth(1, Result).

get_lottery_info(Id) ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_LOTTERY, Id) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_lottery_cost(LotteryInfo) ->
	LotteryInfo#travel_battle_lottery.cost.

get_lottery_awards(LotteryInfo) ->
	LotteryInfo#travel_battle_lottery.awards.

get_shop_info() ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_SHOP, 1) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_shop_item_list(ShopInfo) ->
	ShopInfo#travel_battle_shop.item_list.

get_serial_win_info(WinTimes) ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_SERIAL_WIN, WinTimes) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_serial_win_awards(SerialWinInfo) ->
	SerialWinInfo#travel_battle_serial_win.awards.

get_zone_count_info(ZoneId) ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_ZONE_COUNT, ZoneId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_zone_count(ZoneCountInfo) ->
	ZoneCountInfo#travel_battle_zone_count.max_count.

get_section_awards_info(StageId) ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_SECTION_AWARDS, StageId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_section_losser_score(SectionAwardsInfo) ->
	SectionAwardsInfo#travel_battle_section_awards.losser_score.

get_section_winner_score(SectionAwardsInfo) ->
	SectionAwardsInfo#travel_battle_section_awards.winner_score.

get_stage_awards_info(StageId, Rank) ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_STAGE_AWARDS, {StageId, Rank}) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_stage_money(StageAwardsInfo) ->
	StageAwardsInfo#travel_battle_stage_awards.money.

get_stage_scores(StageAwardsInfo) ->
	StageAwardsInfo#travel_battle_stage_awards.scores.

get_stage_info_by_zone_id(ZoneId) ->
	StageInfoList = ets:foldl(fun({_, StageInfo}, Acc) ->
		ZoneList = get_stage_zone_list(StageInfo),
		case lists:member(ZoneId, ZoneList) of
			true ->
				[StageInfo | Acc];
			false ->
				Acc
		end
	end, [], ?ETS_TRAVEL_BATTLE_STAGE),
	[H | _] = StageInfoList,
	H.

get_month_awards_info(Rank) ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_MONTH_AWARDS, {1, Rank}) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_month_awards(MonthAwardsInfo) ->
	MonthAwardsInfo#travel_battle_month_awards.awards.

get_buffers_info(ProtoId) ->
	case ets:lookup(?ETS_TRAVEL_BATTLE_BUFFERS, ProtoId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_proto_buffs(BufferInfo) ->
	BufferInfo#travel_battle_buffers.buffers.