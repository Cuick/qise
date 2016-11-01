-module(pet_type_change).
%%
%%
%% Exported Functions
%%
-export([start/0, create_mnesia_table/1, create_mnesia_split_table/2, delete_role_from_db/1, tables_info/0]).
-export([init/0, create/0]).
-export([get_type_change/1]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%% Include files
%%
-include("pet_def.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").

-define(PET_TYPE_CHANGE_CONFIG_ETS, pet_type_change_config).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start() ->
	db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(pet_type_change_config, record_info(fields, pet_type_change_config), [], set).

create_mnesia_split_table(_, _) ->
	nothing.

tables_info() ->
	[{pet_type_change_config, proto}].

delete_role_from_db(RoleId) ->
	nothing.

create() ->
	ets:new(?PET_TYPE_CHANGE_CONFIG_ETS, [set, public, named_table, {read_concurrency, true}]).

init()->
	db_operater_mod:init_ets(pet_type_change_config, ?PET_TYPE_CHANGE_CONFIG_ETS, #pet_type_change_config.type).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_type_change(Type) ->
	case ets:lookup(?PET_TYPE_CHANGE_CONFIG_ETS, Type) of
		[] ->
			error;
		[{Type, PeyTypeChange}] ->
			PeyTypeChange
	end.
