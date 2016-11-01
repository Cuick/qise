%%
-module(pet_mapping_proto_db).

%% 
%% Include
%% 
-include("pet_def.hrl").

-define(PET_MAPPING_PROTO_ETS,pet_mapping_proto_ets).

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
	db_tools:create_table_disc(pet_mapping_proto,record_info(fields,pet_mapping_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_mapping_proto,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_MAPPING_PROTO_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_mapping_proto, ?PET_MAPPING_PROTO_ETS,#pet_mapping_proto.grade_quality).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

%% 根据阶和品质得到宠物id
get_protoid(Grade, Quality)->
	case ets:lookup(?PET_MAPPING_PROTO_ETS,{Grade, Quality}) of
		[]->[];
		[{_Id,Value}] -> Value#pet_mapping_proto.protoid
	end.

