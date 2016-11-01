%%
%% Author:yao
%% Des:this is the pet savvy riseup proto 
%%

-module(pet_savvy_up_proto_db).

%%
%% Include files
%%
-include("pet_def.hrl").

%%
%% Exported Functions
%%
-compile(export_all).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        macro defined                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(PET_SAVVY_RISEUP_PROTO_ETS, pet_savvy_riseup_proto_ets).  
%%-define(PET_QUALITY_PROTO_ETS, 0).
%%-define(SAVVYUP_REQUIRED_ITEM, {10000001, 1}).
%%-define(SAVVYUP_REQUIRED_MONEY, 0).
%%-define(SUCESS_RATE, 0.5555).
%%-define(PET_SAVVY_PROTO_ETS, null).
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_savvy_riseup_proto,record_info(fields, pet_savvy_riseup_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_savvy_riseup_proto,proto}].

delete_role_from_db(RoleId)->
	nothing.
create()->
	ets:new(?PET_SAVVY_RISEUP_PROTO_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_savvy_riseup_proto, ?PET_SAVVY_RISEUP_PROTO_ETS,#pet_savvy_riseup_proto.grade).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Grade)->
	case ets:lookup(?PET_SAVVY_RISEUP_PROTO_ETS,Grade) of
		[]->[];
		[{_,Value}] -> Value
	end.

get_properties_from_grade_info(GradeInfo) ->
	element(#pet_savvy_riseup_proto.savvy_riseup_properties, GradeInfo).

get_property_from_properties(Properties, Quality) ->
	case lists:keyfind(Quality,  1, Properties) of
		false -> false;
		Property -> 
			Property
	end.
%%
%% DESCRIPTION:
%%	Propertes structure:
%%		 {grade,
%%		 	 [{quality,
%%			   max_savvy_value,
%%			   sucess_rate, 
%%			   [{item, count}],	
%%			    silver}]
%%		}
%%

%%
%% Des: get max_savvy_value
%%
get_max_savvy_value(Property) ->
	{_,MaxSavvyValue, _, _, _} = Property,
	MaxSavvyValue.
%%
%% Des:get sucess_rate
%%
get_sucess_rate(Property) ->
	{_, _, SucessRate, _, _} = Property,
	SucessRate.


%%
%% Des:get the required items and how many it.
%%
get_required_items(Property) ->
	{_, _, _, ItemCount, _} = Property,
	ItemCount.
%%
%% Des:get the required money.
%%
get_required_money(Property) ->
	{_, _, _, _, Money} = Property,
	Money.

