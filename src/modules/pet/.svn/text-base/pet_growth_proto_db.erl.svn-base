%%% -------------------------------------------------------------------
%%% Author  : kebo
%%% @doc 宠物成长数据库操作模块
%%% @end
%%% Created : 2012-9-22
%%% -------------------------------------------------------------------
-module(pet_growth_proto_db).

-include("pet_def.hrl").

-compile(export_all).

-define(PET_GROWTH_PROTO_ETS,pet_growth_proto_ets).

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
	db_tools:create_table_disc(pet_growth_proto,record_info(fields,pet_growth_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_growth_proto,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_GROWTH_PROTO_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_growth_proto, ?PET_GROWTH_PROTO_ETS,#pet_growth_proto.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_growth(Id)->
	case ets:lookup(?PET_GROWTH_PROTO_ETS,Id) of
		[]->[];
		[{Id, Growth}] -> Growth
	end.

%% 获取次成长级别下的基础属性值
get_growth_pet_attr(Id)->
	case ets:lookup(?PET_GROWTH_PROTO_ETS,Id) of
		[]->[];
		[{Id, #pet_growth_proto{pet_attrs = PetAttrs}} ] -> PetAttrs
	end.




