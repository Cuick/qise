%% Author: yao
%% Created: 2012-9-3
%% Des: record(pet_quality_value_riseup_proto,{
%%                                            grade,
%%                                            quality_value_riseup_properties}
%%             ).
%%      quality_value_riseup_properties格式：
%%			[{品质，升级成功率，所需要的金币数目，
%%			  所需要的道具列表，每次升级的资质值的百分比}]
%%TODO: Add description to pet_quality_value_riseup_proto_db

-module(pet_quality_value_riseup_proto_db).

%%
%% Include files and Macro
%%
-include("pet_def.hrl").
-define(PET_QUALITY_VALUE_RISEUP_ETS,pet_quality_value_riseup_proto_ets).
%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-export([get_info/1]).

%%
%%  Behaviours
%%
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_quality_value_riseup_proto,record_info(fields,pet_quality_value_riseup_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_quality_value_riseup_proto,proto}].

delete_role_from_db(_RoleId) ->
	nothing.

create()->
	ets:new(?PET_QUALITY_VALUE_RISEUP_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_quality_value_riseup_proto,?PET_QUALITY_VALUE_RISEUP_ETS,#pet_quality_value_riseup_proto.grade).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


get_info(Grade) ->
	case ets:lookup(?PET_QUALITY_VALUE_RISEUP_ETS, Grade) of
		[] ->[];
		[{_Grade, Value} ] -> Value
	end.
%%
%% Des:GradeInfo里是record pet_quality_value_riseup_proto的内容。
%%      例：{1,[{1,0.1,100,[{7000001,1}],1,10},{2,0.1,100,[{7000001,1}],1,10},]}
%% Ret: 元祖中的列表。
get_quality_value_riseup_properties_from_info(GradeInfo) ->
	element(#pet_quality_value_riseup_proto.quality_value_riseup_properties, GradeInfo).

%%
%% Des:从列表中找到相应的元祖。
%% Ret：tuple | false;
%%
get_quality_value_riseup_property_from_properties(Properties, Quality) ->
	case lists:keyfind(Quality, 1, Properties) of
		false -> false;
		Property -> Property
	end.
	
get_sucess_rate_from_property(Property) ->
	case Property of
		{_,SucessRate, _, _, _} ->
			SucessRate;
		Other -> false
	end.

get_money_from_property(Property) ->
	case Property of
		{_, _, Money, _, _} ->
			Money;
		Other -> false
	end.
%%
%% Des:RequiredItems is a list type	
%%
get_required_items_from_property(Property, Quality) ->
	case Property of
		{_, _, _, RequiredItems, _} ->
			RequiredItems;
		Other -> false
	end.
%%
%%Des:每次升级的资质值的百分比。用来测试提升的资质值是否超每次提升的最大范围
%%
get_max_riseup_percent_from_property(Property, Quality) ->
	case Property of
		{_, _, _, _, MaxRiseupPercent} ->
			MaxRiseupPercent;
		Other -> false
	end.

%% 通过阶位和品质得到资质项
%% 返回的结构为:{品质，升级成功率，所需要的金币数目，所需要的道具列表，每次升级的资质值的百分比}
get_quality_value_riseup_property(Grade, Quality)->
	GradeInfo = get_info(Grade),
	Quality_value_riseup_properties = GradeInfo#pet_quality_value_riseup_proto.quality_value_riseup_properties,
	lists:keyfind(Quality, 1, Quality_value_riseup_properties).
	
%% 通过阶位和品质得到提升资质值的万分比。
get_riseup_percent(Grade, Quality)->
	Quality_value_riseup_property = get_quality_value_riseup_property(Grade, Quality),
	element(5, Quality_value_riseup_property).
	
%% 通过阶位和品质得到提升资质的所需的钱。
get_riseup_money(Grade, Quality)->
	Quality_value_riseup_property = get_quality_value_riseup_property(Grade, Quality),
	element(3, Quality_value_riseup_property).
	
%% 通过阶位和品质得到提升资质的所需的道具信息。 
get_riseup_iteminfo(Grade, Quality)->
	Quality_value_riseup_property = get_quality_value_riseup_property(Grade, Quality),
	element(4, Quality_value_riseup_property).
	
%% 通过阶位和品质得到提升资质的成功率。 
get_riseup_success_rate(Grade, Quality)->
	Quality_value_riseup_property = get_quality_value_riseup_property(Grade, Quality),
	element(2, Quality_value_riseup_property).

	