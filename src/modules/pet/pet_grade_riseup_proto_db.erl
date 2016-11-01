%% Author: Daiwenjie
%% Created: 2012-9-3
%% Description: 位阶升级数据库
%% record(pet_growth_riseup_proto,{grade,grade_riseup_success_rate,money,required_itemsmin_retries,max_retries}).
-module(pet_grade_riseup_proto_db).

%%-record(pet_growth_riseup_proto,{grade,grade_riseup_success_rate,money,required_items,min_retries,max_retries,random_num,max_lucky}).
%% Include files
%%
-define(PET_GRADE_RISEUP_PROTO_ETS,pet_growth_riseup_proto_ets).
-include("pet_def.hrl").
-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%
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
	db_tools:create_table_disc(pet_growth_riseup_proto,record_info(fields,pet_growth_riseup_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_growth_riseup_proto,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_GRADE_RISEUP_PROTO_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_growth_riseup_proto,?PET_GRADE_RISEUP_PROTO_ETS,#pet_growth_riseup_proto.growth).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


get_grade_riseup_proto_info(Grade)->
%% 	slogger:msg("%%---get_grade_db---~p~n",[Grade]),
%% 	List = ets:tab2list(?PET_GRADE_RISEUP_PROTO_ETS),
%% 	slogger:msg("%%---get_grade_db--ET_GRADE_RISEUP_PROTO_ET-~p~n",[List]),
	case ets:lookup(?PET_GRADE_RISEUP_PROTO_ETS, Grade) of
		[]-> [];
		[{_,Info}]-> 
			slogger:msg("%%---get_grade_db-Info--~p~n",[Info]),
			Info
	end.

get_grade_riseup_success_rate(GradeInfo)->
	element(#pet_growth_riseup_proto.grade_riseup_success_rate,GradeInfo).

get_min_retries(GradeInfo)->
	element(#pet_growth_riseup_proto.min_retries,GradeInfo).

get_max_retries(GradeInfo)->
	element(#pet_growth_riseup_proto.max_retries,GradeInfo).

get_money(GradeInfo)->
	element(#pet_growth_riseup_proto.money,GradeInfo).

get_required_items(GradeInfo)->
	element(#pet_growth_riseup_proto.required_items,GradeInfo).

get_random_num(GradeInfo)->
	element(#pet_growth_riseup_proto.random_num,GradeInfo).

get_max_lucky(GradeInfo)->
	element(#pet_growth_riseup_proto.max_lucky,GradeInfo).

								  
