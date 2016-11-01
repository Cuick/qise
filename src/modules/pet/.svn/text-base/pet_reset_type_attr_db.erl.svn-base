-module(pet_reset_type_attr_db).
%%
%%
%% Exported Functions
%%
-export([start/0, create_mnesia_table/1, create_mnesia_split_table/2, delete_role_from_db/1, tables_info/0]).
-export([init/0, create/0]).
-export([get_pet_type_attr_value_config/1, get_lock_info/2, get_attr_info/2]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%% Include files
%%
-include("pet_def.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").

% 属性值计算表
-define(PET_TYPE_ATTR_VALUE_ETS, pet_type_attr_value_ets).
% 锁定条数对应表
-define(PET_TYPE_ATTR_LOCK_ETS, pet_type_attr_lock_ets).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start() ->
	db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(pet_type_attr_value_config, record_info(fields, pet_type_attr_value_config), [], set),
	db_tools:create_table_disc(pet_type_attr_lock_config, record_info(fields, pet_type_attr_lock_config), [], set).

create_mnesia_split_table(_, _) ->
	nothing.

tables_info() ->
	[{pet_type_attr_value, proto}, {pet_shop_attr_lock, proto}].

delete_role_from_db(RoleId) ->
	nothing.

create() ->
	ets:new(?PET_TYPE_ATTR_VALUE_ETS, [set, public, named_table, {read_concurrency, true}]),
	ets:new(?PET_TYPE_ATTR_LOCK_ETS, [set, public, named_table, {read_concurrency, true}]).

init() ->
	db_operater_mod:init_ets(pet_type_attr_value_config, ?PET_TYPE_ATTR_VALUE_ETS, #pet_type_attr_value_config.index),
	db_operater_mod:init_ets(pet_type_attr_lock_config, ?PET_TYPE_ATTR_LOCK_ETS, #pet_type_attr_lock_config.index).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 某一类型属性锁定信息
get_pet_type_attr_value_config(Type) ->
	case util:tab2list(?PET_TYPE_ATTR_VALUE_ETS) of
		[] ->
			{error, ?ERROR_SYSTEM};
		PetTypeAttrValueConfigList ->
			lists:foldl(fun(Ele, Acc) ->
						{Type2, _Counter} = Ele#pet_type_attr_value_config.index,
						case Type =:= Type2 of
							true ->
								Acc ++ [Ele];
							false ->
								Acc
						end
				end, [], PetTypeAttrValueConfigList)
	end.

% 锁定信息
get_lock_info(Type, Num) ->
	case ets:lookup(?PET_TYPE_ATTR_LOCK_ETS, {Type, Num}) of
		[] ->
			{error, ?ERROR_SYSTEM};
		[{{Type, Num}, LockInfo}] ->
			LockInfo
	end.

% 属性计算信息
get_attr_info(Type, AttrId) ->
	case ets:lookup(?PET_TYPE_ATTR_VALUE_ETS, {Type, AttrId}) of
		[] ->
			{error, ?ERROR_PET_TYPE_ATTR_NOT_EXIST};
		[{{Type, AttrId}, AttrInfo}] ->
			AttrInfo
	end.
