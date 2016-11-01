-module (travel_match_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define (ETS_TRAVEL_MATCH_PROTO,ets_travel_match_proto).
-define (ETS_TRAVEL_MATCH_LEVEL, ets_travel_match_level).
-define (ETS_TRAVEL_MATCH_STAGE, ets_travel_match_stage).
-define (ETS_TRAVEL_MATCH_ZONE_COUNT, ets_travel_match_zone_count).
-define (ETS_TRAVEL_MATCH_LEVEL_STAGE, ets_travel_match_level_stage).
-define (ETS_TRAVEL_MATCH_RANK_AWARDS, ets_travel_match_rank_awards).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(travel_match_proto, record_info(fields,travel_match_proto), [], set),
	db_tools:create_table_disc(travel_match_level, record_info(fields,travel_match_level), [], bag),
	db_tools:create_table_disc(travel_match_stage, record_info(fields,travel_match_stage), [], bag),
	db_tools:create_table_disc(travel_match_zone_count, record_info(fields,travel_match_zone_count), [], set),
	db_tools:create_table_disc(travel_match_level_stage, record_info(fields,travel_match_level_stage), [], bag),
	db_tools:create_table_disc(travel_match_rank_awards, record_info(fields,travel_match_rank_awards), [], bag).
create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{travel_match_proto,proto}, {travel_match_level,proto}, {travel_match_stage,proto},
	 {travel_match_zone_count,proto},{travel_match_level_stage,proto}, {travel_match_rank_awards,proto}].

create()->
	ets:new(?ETS_TRAVEL_MATCH_PROTO, [set,named_table]),
	ets:new(?ETS_TRAVEL_MATCH_LEVEL, [set, named_table]),
	ets:new(?ETS_TRAVEL_MATCH_STAGE, [set, named_table]),
	ets:new(?ETS_TRAVEL_MATCH_ZONE_COUNT, [set, named_table]),
	ets:new(?ETS_TRAVEL_MATCH_LEVEL_STAGE, [set, named_table]),
	ets:new(?ETS_TRAVEL_MATCH_RANK_AWARDS, [set, named_table]).
init()->
	db_operater_mod:init_ets(travel_match_proto, ?ETS_TRAVEL_MATCH_PROTO,#travel_match_proto.type),
	db_operater_mod:init_ets(travel_match_level, ?ETS_TRAVEL_MATCH_LEVEL,[#travel_match_level.type, 
		#travel_match_level.level]),
	db_operater_mod:init_ets(travel_match_stage, ?ETS_TRAVEL_MATCH_STAGE, [#travel_match_stage.type,
		#travel_match_stage.stage]),
	db_operater_mod:init_ets(travel_match_zone_count, ?ETS_TRAVEL_MATCH_ZONE_COUNT, [
		#travel_match_zone_count.zone_id, #travel_match_zone_count.type, #travel_match_zone_count.level]),
	db_operater_mod:init_ets(travel_match_level_stage, ?ETS_TRAVEL_MATCH_LEVEL_STAGE, [
		#travel_match_level_stage.type, #travel_match_level_stage.level, #travel_match_level_stage.stage]),
	db_operater_mod:init_ets(travel_match_rank_awards, ?ETS_TRAVEL_MATCH_RANK_AWARDS, [
		#travel_match_rank_awards.type, #travel_match_rank_awards.level, #travel_match_rank_awards.rank]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_type_level_info(Type, Level) ->
	case ets:select(?ETS_TRAVEL_MATCH_LEVEL,[{{{Type, {'$1', '$2'}}, '$3'}, 
		[{'=<', '$1', Level}, {'=<', Level, '$2'}], ['$3']}]) of
		[] ->
			[];
		[H | _] ->
			H
	end.

get_type_level_info2(Type, LevelZone) ->
	case ets:lookup(?ETS_TRAVEL_MATCH_LEVEL, {Type, LevelZone}) of
		[] ->
			[];
		[{_,Term}] ->
			Term
	end.

get_type_level(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.level.

get_min_fight_force(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.min_fight_force.

get_type_level_cost(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.cost.

get_type_level_min_num(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.min_num.

get_type_level_awards_rate(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.awards_rate.

get_type_level_unit(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.unit.

get_type_level_wait_map(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.wait_map.

get_type_level_distribution(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.distribution.

get_zone_count_info(ZoneId, Type, LevelZone) ->
	case ets:lookup(?ETS_TRAVEL_MATCH_ZONE_COUNT, {ZoneId, Type, LevelZone}) of
		[] ->
			[];
		[{_,Term}] ->
			Term
	end.

get_type_level_transports(MatchLevelInfo) ->
	MatchLevelInfo#travel_match_level.transports.

get_match_stage_info(Type, Stage) ->
	case ets:lookup(?ETS_TRAVEL_MATCH_STAGE, {Type, Stage}) of
		[] ->
			[];
		[{_,Term}] ->
			Term
	end.

get_stage_time_line(MatchStageInfo) ->
	MatchStageInfo#travel_match_stage.time_line.

get_level_stage_info(Type, LevelZone, Stage) ->
	case ets:lookup(?ETS_TRAVEL_MATCH_LEVEL_STAGE, {Type, LevelZone, Stage}) of
		[] ->
			[];
		[{_,Term}] ->
			Term
	end.

get_level_stage_sections(LevelStageInfo) ->
	LevelStageInfo#travel_match_level_stage.section_num.

get_level_stage_map_id(LevelStageInfo) ->
	LevelStageInfo#travel_match_level_stage.match_map.

get_level_stage_pos_list(LevelStageInfo) ->
	LevelStageInfo#travel_match_level_stage.pos_list.

get_type_info(Type) ->
	case ets:lookup(?ETS_TRAVEL_MATCH_PROTO, Type) of
		[] ->
			[];
		[{_,Term}] ->
			Term
	end.

get_type_duration(MatchTypeInfo) ->
	MatchTypeInfo#travel_match_proto.duration.

get_type_interval(MatchTypeInfo) ->
	MatchTypeInfo#travel_match_proto.interval.

get_type_start_date(MatchTypeInfo) ->
	MatchTypeInfo#travel_match_proto.start_date.

get_zone_max_count(ZoneCountInfo) ->
	ZoneCountInfo#travel_match_zone_count.max_count.

get_level_stage_awards(LevelStageInfo) ->
	LevelStageInfo#travel_match_level_stage.awards.

get_level_stage_qualified(LevelStageInfo) ->
	LevelStageInfo#travel_match_level_stage.qualified.

get_rank_awards_info(Type, LevelZone, Rank) ->
	case ets:lookup(?ETS_TRAVEL_MATCH_RANK_AWARDS, {Type, LevelZone, Rank}) of
		[] ->
			[];
		[{_,Term}] ->
			Term
	end.

get_type_rank_awards(AwardsInfo) ->
	AwardsInfo#travel_match_rank_awards.awards.
