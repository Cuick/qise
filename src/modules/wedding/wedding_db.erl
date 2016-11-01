-module (wedding_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(WEDDING_CEREMONY_ETS,ets_wedding_ceremony).
-define(WEDDING_TYPE_ETS,ets_wedding_type).
-define(WEDDING_INTIMACY_ETS,ets_wedding_intimacy).
-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(wedding_ceremony, record_info(fields,wedding_ceremony), [], set),
	db_tools:create_table_disc(wedding_type, record_info(fields,wedding_type), [], set),
	db_tools:create_table_disc(wedding_intimacy, record_info(fields,wedding_intimacy), [], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{wedding_ceremony,proto},{wedding_type,proto},{wedding_intimacy,proto}].

create()->
	ets:new(?WEDDING_CEREMONY_ETS, [set,named_table]),
	ets:new(?WEDDING_TYPE_ETS, [set,named_table]),
	ets:new(?WEDDING_INTIMACY_ETS, [set,named_table]).

init()->
	db_operater_mod:init_ets(wedding_ceremony, ?WEDDING_CEREMONY_ETS,#wedding_ceremony.id),
	db_operater_mod:init_ets(wedding_type, ?WEDDING_TYPE_ETS,#wedding_type.type),
	db_operater_mod:init_ets(wedding_intimacy, ?WEDDING_INTIMACY_ETS,#wedding_intimacy.type).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_ceremony_time_time_info(CeremonyId)->
	case ets:lookup(?WEDDING_CEREMONY_ETS,CeremonyId) of
		[]->[];
		[{CeremonyId,Term}]-> Term
	end.

get_ceremony_time_time(CeremonyInfo) ->
	CeremonyInfo#wedding_ceremony.time.

get_all_ceremony_time_ids() ->
	lists:flatten(ets:match('$1', '_')).

get_ceremony_type_info(Type) ->
	case ets:lookup(?WEDDING_TYPE_ETS,Type) of
		[]->[];
		[{Type,Term}]-> Term
	end.

get_ceremony_type_cost(CeremonyTypeInfo) ->
	CeremonyTypeInfo#wedding_type.cost.

get_ceremony_type_items(CeremonyTypeInfo) ->
	CeremonyTypeInfo#wedding_type.items.

get_intimacy_info(Type) ->
	case ets:lookup(?WEDDING_INTIMACY_ETS,Type) of
		[]->[];
		[{CeremonyId,Term}]-> Term
	end.

get_intimacy_condition(IntimacyInfo) ->
	IntimacyInfo#wedding_intimacy.condition.


get_intimacy_value(IntimacyInfo) ->
	IntimacyInfo#wedding_intimacy.value.

