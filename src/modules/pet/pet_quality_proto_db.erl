%% Author: Bergpoon
%% Created: 2012-9-05
%% Description:
-module(pet_quality_proto_db).

%%
%% Include files
%%
-include("pet_def.hrl").

%% (quality_properties,
%% 		{[{quality, %%品质
%% 		   min_quality_value, %%最小资质值
%% 		   max_quality_value %%最大资质值
%% 		   }]}).

%%
%% Exported Functions
%%
-compile(export_all).

-define(PET_QUALITY_PROTO_ETS,pet_quality_proto_ets).

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
	db_tools:create_table_disc(pet_quality_proto,record_info(fields,pet_quality_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_quality_proto,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_QUALITY_PROTO_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_quality_proto, ?PET_QUALITY_PROTO_ETS,#pet_quality_proto.grade).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Grade)->
	case ets:lookup(?PET_QUALITY_PROTO_ETS,Grade) of
		[]->[];
		[{_,Value}] -> Value
	end.

%%得到宠物位阶等级
get_grade_from_info(GradeInfo) ->
	element(#pet_quality_proto.grade,GradeInfo).

%%得到宠物的品质属性列表
get_quality_properties_from_info(GradeInfo) ->
	element(#pet_quality_proto.quality_properties,GradeInfo).

%%get quality_properties list
get_quality_proto_property_from_properties(QualityProperties,Quality) ->
	case lists:keyfind(Quality,1,QualityProperties) of
		false ->
			flase;
		Property ->
			Property
	end.

%%得到最大品质等级
get_max_quality_level_from_info(QualityProperties) ->
	{MaxQualityLevel,_,_}  = lists:last(lists:keysort(1, QualityProperties)),
	MaxQualityLevel.

%% @doc 获取品质下的最低等级的最小成长值
get_min_growth_in_quality_from_info(QualityProperties) ->
	[ {_lvl,_Rate,MinGrowth,_MaxGrowth} | _T] = lists:keysort(1, QualityProperties),
	MinGrowth.

%%得到最小资质
get_min_quality_value_from_property(Property) ->
	{_,Min_Quality_Value,_} = Property,
    Min_Quality_Value.

%%得到最大资质
get_max_quality_value_from_property(Property) ->
	{_,_,Max_Quality_Value} = Property,
    Max_Quality_Value.

get_quality_property(Info,Quality)->
    lists:keyfind(Quality,1,erlang:element(#pet_quality_proto.quality_properties,Info)).

%%get min and max quailty value
%% return {Min_Quality_Value,Max_Quality_Value}
get_min_max_quality_value_from_property(Property) ->
	{_,Min_Quality_Value,Max_Quality_Value} = Property,
	{Min_Quality_Value,Max_Quality_Value}.

