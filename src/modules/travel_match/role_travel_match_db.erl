-module (role_travel_match_db).

-include ("mnesia_table_def.hrl").

-behaviour(db_operater_mod).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_travel_match_info,record_info(fields,role_travel_match_info), [], set),
	db_tools:create_table_disc(role_travel_match_result,record_info(fields,role_travel_match_result),[],set),
	db_tools:create_table_disc(role_travel_match_rank,record_info(fields,role_travel_match_rank),[],bag),
	db_tools:create_table_disc(role_wait_map_zone,record_info(fields,role_wait_map_zone),[],bag).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{role_travel_match_info,disc},{role_travel_match_result,disc},{role_travel_match_rank,disc}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_register_info(RoleId) ->
	case dal:read_rpc(role_travel_match_info, RoleId) of
		{ok, []} ->
			[];
		{ok, [H | _]} ->
			H
	end.

save_register_info(RoleId, RoleName, Gender, Class, Level, FightForce) ->
	dal:write_rpc(#role_travel_match_info{role_id = RoleId, role_name = RoleName,
		gender = Gender, class = Class, level = Level, fight_force = FightForce}).

get_register_info_by_level({MinLevel, MaxLevel}) ->
	Fun = fun() ->
		MatchHead = #role_travel_match_info{level = '$1', _='_'},
		Guard = [{'=<', MinLevel, '$1'}, {'=<', '$1', MaxLevel}],
		Result = ['$_'],
		mnesia:select(role_travel_match_info,[{MatchHead, Guard, Result}])
	end,
	case dal:run_transaction_rpc(Fun) of
		{ok, Result} ->
			Result;
		_ ->
			[]
	end.

get_register_role_id(RegisterInfo) ->
	RegisterInfo#role_travel_match_info.role_id.

delete_role_register_info(RoleId) ->
	dal:delete_rpc(role_travel_match_info, RoleId).

get_register_level(RegisterInfo) ->
	RegisterInfo#role_travel_match_info.level.

get_register_name(RegisterInfo) ->
	RegisterInfo#role_travel_match_info.role_name.

get_register_gender(RegisterInfo) ->
	RegisterInfo#role_travel_match_info.gender.

get_register_class(RegisterInfo) ->
	RegisterInfo#role_travel_match_info.class.

get_register_fight_force(RegisterInfo) ->
	RegisterInfo#role_travel_match_info.fight_force.

save_match_result(RoleId, LevelZone, MatchInfo) ->
	dal:write_rpc(#role_travel_match_result{role_id = RoleId, level = LevelZone,
		info = MatchInfo}).

get_match_result(RoleId) ->
	case dal:read_rpc(role_travel_match_result, RoleId) of
		{ok, []} ->
			[];
		{ok, [H | _]} ->
			H
	end.

get_match_result_by_level(LevelZone) ->
	Fun = fun() ->
		MatchHead = #role_travel_match_result{level = LevelZone, _='_'},
		Guard = [],
		Result = ['$_'],
		mnesia:select(role_travel_match_result,[{MatchHead, Guard, Result}])
	end,
	case dal:run_transaction_rpc(Fun) of
		{ok, Result} ->
			Result;
		_ ->
			[]
	end.

get_match_result_role_id(MatchResult) ->
	MatchResult#role_travel_match_result.role_id.

get_match_result_info(MatchResult) ->
	MatchResult#role_travel_match_result.info.

get_match_result_level(MatchResult) ->
	MatchResult#role_travel_match_result.level.

save_wait_map_zone(Type, LevelZone, Unit, ZoneId) ->
	dal:write_rpc(#role_wait_map_zone{type = Type, level = LevelZone,
		unit = Unit, zone_id = ZoneId}).

get_all_wait_map_info_by_type(Type) ->
	{ok, Result} = dal:read_rpc(role_wait_map_zone, Type),
	Result.

get_wait_map_info(Type, LevelZone, Unit) ->
	Fun = fun() ->
		MatchHead = #role_wait_map_zone{type = Type, level = LevelZone, 
			unit = Unit, _='_'},
		Guard = [],
		Result = ['$_'],
		mnesia:select(role_wait_map_zone,[{MatchHead, Guard, Result}])
	end,
	case dal:run_transaction_rpc(Fun) of
		{ok, Result} ->
			Result;
		_ ->
			[]
	end.

get_wait_map_zone_id(WaitMapInfo) ->
	WaitMapInfo#role_wait_map_zone.zone_id.

get_wait_map_unit(WaitMapInfo) ->
	WaitMapInfo#role_wait_map_zone.unit.

get_zone_used() ->
	Fun = fun() ->
		MatchHead = #role_wait_map_zone{zone_id = '$1', _='_'},
		Guard = [],
		Result = ['$1'],
		mnesia:select(role_wait_map_zone,[{MatchHead, Guard, Result}])
	end,
	case dal:run_transaction_rpc(Fun) of
		{ok, Result} ->
			Result;
		_ ->
			[]
	end.

clear_wait_map_zone() ->
	dal:clear_table_rpc(role_wait_map_zone).

clear_register_info() ->
	dal:clear_table_rpc(role_travel_match_info).

clear_match_result() ->
	dal:clear_table_rpc(role_travel_match_result).

save_match_rank_info(Type, Session, LevelZone, RoleId, RoleName, Gender,
	Class, Rank, FightForce, Gold, Level) ->
	RankData = #role_travel_match_rank{session = Session, level_zone = LevelZone,
	role_id = RoleId, role_name = RoleName, gender = Gender, class = Class, 
	level = Level, fight_force = FightForce, rank = Rank, awards = Gold, type = Type},
	dal:write_rpc(RankData).

get_session_data(Type, Session, LevelZone) ->
	Fun = fun() ->
		MatchHead = #role_travel_match_rank{type = Type, level = LevelZone, 
			session = Session, _='_'},
		Guard = [],
		Result = ['$_'],
		mnesia:select(role_travel_match_rank,[{MatchHead, Guard, Result}])
	end,
	case dal:run_transaction_rpc(Fun) of
		{ok, Result} ->
			Result;
		_ ->
			[]
	end.

get_session_role_id(SessionData) ->
	SessionData#role_travel_match_rank.role_id.

get_session_role_name(SessionData) ->
	SessionData#role_travel_match_rank.role_name.

get_session_role_gender(SessionData) ->
	SessionData#role_travel_match_rank.gender.

get_session_role_class(SessionData) ->
	SessionData#role_travel_match_rank.class.

get_session_role_level(SessionData) ->
	SessionData#role_travel_match_rank.level.

get_session_role_fight_force(SessionData) ->
	SessionData#role_travel_match_rank.fight_force.

get_session_role_rank(SessionData) ->
	SessionData#role_travel_match_rank.rank.

get_session_role_gold(SessionData) ->
	SessionData#role_travel_match_rank.awards.




