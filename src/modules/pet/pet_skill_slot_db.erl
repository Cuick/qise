%% Author: Administrator
%% Created: 2011-10-9
%% Description: TODO: Add description to pet_skill_slot_db
-module(pet_skill_slot_db).

%%
%% Include files
%%
-include("pet_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

-define(ETS_TABLE,pet_skill_slot_ets).
-define(PET_SKILL_FUSE_ETS,pet_skill_fuse_ets).

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
	db_tools:create_table_disc(pet_skill_slot,record_info(fields,pet_skill_slot),[],set),
	db_tools:create_table_disc(pet_skill_fuse,record_info(fields,pet_skill_fuse),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_skill_slot,proto},{pet_skill_fuse,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?ETS_TABLE,[set,named_table]),
	ets:new(?PET_SKILL_FUSE_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_skill_slot, ?ETS_TABLE,#pet_skill_slot.index),
	db_operater_mod:init_ets(pet_skill_fuse, ?PET_SKILL_FUSE_ETS,#pet_skill_fuse.index).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



init_pet_skill_fuse()->
	case dal:read_rpc(pet_skill_fuse) of
		{ok,Pet_skill_fuses}->
			Pet_skill_fuses1 = lists:reverse(lists:keysort(#pet_skill_fuse.index, Pet_skill_fuses)),
			lists:foreach(fun(Term)-> add_pet_skill_fuse_to_ets(Term) end, Pet_skill_fuses1);
		_-> slogger:msg("init_pet_skill_fuse failed~n")
	end.

add_pet_skill_fuse_to_ets(Term) ->
	try
		Index = erlang:element(#pet_skill_fuse.index, Term),
 		ets:insert(?PET_SKILL_FUSE_ETS,{Index,Term})	
	catch
		_Error:Reason-> {error,Reason}
	end.

get_all_skill_fuse_info()->
	ets:tab2list(?PET_SKILL_FUSE_ETS).

get_info(Id)->
	case ets:lookup(?ETS_TABLE,Id) of
		[]->[];
		[{_Id,Value}] -> Value
	end.

get_rate(Info)->
	element(#pet_skill_slot.rate,Info).


%%
%% Local Functions
%%

