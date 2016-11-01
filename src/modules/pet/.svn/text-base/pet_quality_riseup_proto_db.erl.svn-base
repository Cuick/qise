%% Author: Bergpoon
%% Created: 2012-9-05
%% Description: TODO: Add description to pet_quality_riseup_proto_db
-module(pet_quality_riseup_proto_db).

%%
%% Include files
%%
-include("pet_def.hrl").
-include("error_msg.hrl").

%% (quality_riseup_properties,
%% 			{quality,  %%品质
%% 			success_rate, %%成功概率
%% 			money, %%所需金钱
%% 			required_items,  %%所需物品列表
%% 			min_num, %%最小次数
%% 			max_num, %%最大次数
%%			lucky, %%lucky number
%%			max_lucky
%%  }).
%%
%% Exported Functions
%%
-compile(export_all).
% 宠物品质进阶信息配置表
-define(PET_QUALITY_RISEUP_PROTO_ETS,pet_quality_riseup_proto_ets).

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
	db_tools:create_table_disc(pet_quality_riseup_proto,record_info(fields,pet_quality_riseup_proto),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_quality_riseup_proto,proto}].

delete_role_from_db(_RoleId) ->
	nothing.

create()->
	ets:new(?PET_QUALITY_RISEUP_PROTO_ETS,[set,named_table]).

init()->
	db_operater_mod:init_ets(pet_quality_riseup_proto,?PET_QUALITY_RISEUP_PROTO_ETS,#pet_quality_riseup_proto.quality).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Grade) ->
	case ets:lookup(?PET_QUALITY_RISEUP_PROTO_ETS, Grade) of
		[] ->[];
		[{_,Value}] -> Value
	end.

% 是否品质进阶达到最大
is_max_quality_grade(Quality, Grade) ->
	case ets:tab2list(?PET_QUALITY_RISEUP_PROTO_ETS) of
		[] ->
			{error, ?ERROR_SYSTEM};
		List ->
			{PetQualityList, PetQualityRiseupList} = lists:unzip(List),
			PetQuality = hd(lists:reverse(lists:sort(PetQualityList))),
			PetQualityRiseup = hd(lists:reverse(lists:keysort(#pet_quality_riseup_proto.quality, PetQualityRiseupList))),
			PetQualityRiseup2 = hd(lists:reverse(lists:keysort(1, PetQualityRiseup#pet_quality_riseup_proto.quality_riseup_properties))),
			case Quality >= PetQuality andalso lists:keyfind(Grade, 1, [PetQualityRiseup2]) =/= false of
				true ->
					{error, ?ERROR_QUALITY_GRADE_MAX};
				false ->
					% 可以品质进阶
					true
			end
	end.

% 是否达到当前品质的最大阶数
is_current_max_quality_grade(Quality, Grade) ->
	PetQualityRiseup = get_info(Quality),
	MaxRiseup = element(1, hd(lists:reverse(lists:keysort(1, PetQualityRiseup#pet_quality_riseup_proto.quality_riseup_properties)))),
	Grade >= MaxRiseup.

% 品质阶数对应信息
get_quality_riseup_property_from_properties(RiseupProperties,Quality)->
    case lists:keyfind(Quality,1,RiseupProperties) of
    false ->
      false;
    Property ->
      Property
    end.

% 消耗金币
get_quality_grade_gold(Property) ->
    element(#properties.gold-1, Property).

%%得到宠物位阶
get_grade_from_info(GradeInfo) ->
	element(#pet_quality_riseup_proto.quality,GradeInfo).

%%得到宠物品质属性列表
get_quality_riseup_properties_from_info(GradeInfo) ->
	element(#pet_quality_riseup_proto.quality_riseup_properties,GradeInfo).

get_grade_from_riseup_property(Property) ->
    element(#properties.grade-1, Property).

%%得到品质升级的金钱
get_money_from_riseup_property(Property) ->
    element(#properties.money-1, Property).

get_gold_from_riseup_property(Property) ->
    element(#properties.gold-1, Property).

%%传入宠物的品质等级，返回其中的成功率
get_success_rate_from_riseup_property(Property) ->
    element(#properties.success_rate-1, Property).

%%得到最小次数
get_min_retries_from_riseup_property(Property) ->
    element(#properties.min_retries-1, Property).

%%得到最大次数
get_max_retries_from_riseup_property(Property) ->
    element(#properties.max_retries-1, Property).

%%得到所需物品列表,include money
get_required_items_from_riseup_property(Property) ->
    element(#properties.required_items-1, Property).

get_random_num_from_riseup_property(Property) ->
    element(#properties.random_num-1, Property).

get_max_lucky_from_riseup_property(Property) ->
    element(#properties.max_lucky-1, Property).

%% %%得到品质升级的金钱
%% get_money_from_riseup_property(Property) ->
%% 	{_, _, Money, _, _} = Property,
%% 	Money.
%%
%% get_gold_from_riseup_property(Property) ->
%% 	{_, _, _, _, Gold} = Property,
%% 	Gold.
%%
%% %%传入宠物的品质等级，返回其中的成功率
%% get_success_rate_from_riseup_property(Property) ->
%% 	{_, SuccessRate, _, _, _} = Property,
%% 	SuccessRate.
%%
%% %%得到最小次数
%% get_min_retries_from_riseup_property(Property) ->
%% 	{_,_,_,_,MinNum,_,_,_} = Property,
%% 	MinNum.
%%
%% %%得到最大次数
%% get_max_retries_from_riseup_property(Property) ->
%% 	{_,_,_,_,_,MaxNum,_,_} = Property,
%% 	MaxNum.
%%
%% %%得到所需物品列表,include money
%% get_required_items_from_riseup_property(Property) ->
%% 	{_,_,_,RequiredItems, _} = Property,
%% 	RequiredItems.
%%
%% %%get min and max retries from property
%% %% return {MinNum,MaxNum}
%% get_min_max_retries_from_riseup_property(Property) ->
%% 	{_,_,_,_,MinNum,MaxNum,_,_} = Property,
%% 	{MinNum,MaxNum}.
%%
%% get_lucky_from_riseup_property(Property) ->
%% 	{_,_,_,_,_,_,Lucky,_} = Property,
%% 	Lucky.
%%
%% get_max_lucky_from_riseup_property(Property) ->
%% 	{_,_,_,_,_,_,_,LuckyMax} = Property,
%% 	LuckyMax.
