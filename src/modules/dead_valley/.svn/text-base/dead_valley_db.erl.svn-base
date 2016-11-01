-module (dead_valley_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define (ETS_DEAD_VALLEY_PROTO,ets_dead_valley_proto).
-define (ETS_DEAD_VALLEY_ZONE_COUNT, ets_dead_valley_zone_count).
-define (ETS_DEAD_VALLEY_EXP, ets_dead_valley_exp).
-define (ETS_DEAD_VALLEY_TRAP, ets_dead_valley_trap).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(dead_valley_proto, record_info(fields,dead_valley_proto), [], set),
	db_tools:create_table_disc(dead_valley_zone_count, record_info(fields,dead_valley_zone_count), [], set),
	db_tools:create_table_disc(dead_valley_exp, record_info(fields,dead_valley_exp), [], set),
	db_tools:create_table_disc(dead_valley_trap, record_info(fields,dead_valley_trap), [], set).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{dead_valley_proto,proto}, {dead_valley_zone_count, proto}, {dead_valley_exp, proto},
	{dead_valley_trap,proto}].

create()->
	ets:new(?ETS_DEAD_VALLEY_PROTO, [set,named_table]),
	ets:new(?ETS_DEAD_VALLEY_ZONE_COUNT, [set,named_table]),
	ets:new(?ETS_DEAD_VALLEY_EXP, [set, named_table]),
	ets:new(?ETS_DEAD_VALLEY_TRAP, [set, named_table]).

init()->
	db_operater_mod:init_ets(dead_valley_proto, ?ETS_DEAD_VALLEY_PROTO,#dead_valley_proto.id),
	db_operater_mod:init_ets(dead_valley_zone_count, ?ETS_DEAD_VALLEY_ZONE_COUNT,#dead_valley_zone_count.zone_id),
	db_operater_mod:init_ets(dead_valley_exp, ?ETS_DEAD_VALLEY_EXP,#dead_valley_exp.level),
	db_operater_mod:init_ets(dead_valley_trap, ?ETS_DEAD_VALLEY_TRAP,#dead_valley_trap.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_proto_info()->
	case ets:lookup(?ETS_DEAD_VALLEY_PROTO,1) of
		[]->[];
		[{1,Term}]-> Term
	end.

get_time_lines(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.time_lines.

get_map_id(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.map_id.

get_transports(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.transports.

get_proto_equipment(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.equip_proto.

get_proto_points(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.points.

get_expire_time(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.expire.

get_proto_level(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.level.

get_proto_drop_rate(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.drop_rate.

get_proto_cooldown(ProtoInfo) ->
	ProtoInfo#dead_valley_proto.cooldown.

get_zone_count_info(ZoneId) ->
	case ets:lookup(?ETS_DEAD_VALLEY_ZONE_COUNT, ZoneId) of
		[]->[];
		[{_, Term}]-> Term
	end.

get_zone_max_count(ZoneCntInfo) ->
	ZoneCntInfo#dead_valley_zone_count.max_count.

get_exp_info(Level) ->
	case ets:lookup(?ETS_DEAD_VALLEY_EXP, Level) of
		[]->[];
		[{_, Term}]-> Term
	end.

get_exp(ExpInfo) ->
	ExpInfo#dead_valley_exp.exp.

get_trap_info(TrapId) ->
	case ets:lookup(?ETS_DEAD_VALLEY_TRAP, TrapId) of
		[]->[];
		[{_, Term}]-> Term
	end.

get_trap_id(TrapInfo) ->
	TrapInfo#dead_valley_trap.id.

get_trap_show(TrapInfo) ->
	TrapInfo#dead_valley_trap.show.

get_trap_hide(TrapInfo) ->
	TrapInfo#dead_valley_trap.hide.

get_trap_buffer(TrapInfo) ->
	TrapInfo#dead_valley_trap.buffer.