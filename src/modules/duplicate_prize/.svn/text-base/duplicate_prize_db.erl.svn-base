-module(duplicate_prize_db).
%%
%%
%% Exported Functions
%%
-export([start/0, create_mnesia_table/1, create_mnesia_split_table/2, delete_role_from_db/1, tables_info/0]).
-export([init/0, create/0]).
-export([get_duplicate_prize/1, calculate_prize/1, get_duplicate_prize2/1,get_duplicate_prize_map/1,save_duplicate_prize_map/2]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%% Include files
%%
-include("duplicate_prize.hrl").
-include("webgame.hrl").
-include("error_msg.hrl").
-include ("mnesia_table_def.hrl").

-define(DUPLICATE_PRIZE_CONFIG_ETS, duplicate_prize_config).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start() ->
	db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(duplicate_prize_config, record_info(fields, duplicate_prize_config), [], set).

create_mnesia_split_table(duplicate_prize_map,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,duplicate_prize_map),[],set).

tables_info() ->
	[{duplicate_prize_config, proto},{duplicate_prize_map,disc_split}].

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(duplicate_prize_map, RoleId),
	dal:delete_rpc(TableName, RoleId).

create() ->
	ets:new(?DUPLICATE_PRIZE_CONFIG_ETS, [set, public, named_table, {read_concurrency, true}]).

init()->
	db_operater_mod:init_ets(duplicate_prize_config, ?DUPLICATE_PRIZE_CONFIG_ETS, #duplicate_prize_config.duplicate_id).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 副本地图所对应的奖励信息
get_duplicate_prize(DuplicateId) ->
	case util:tab2list(?DUPLICATE_PRIZE_CONFIG_ETS) of
		[] ->
			?S2CERR(?ERROR_SYSTEM);
		DuplicatePrizeList ->
			DuplicatePrizeInfo = lists:keyfind(DuplicateId, #duplicate_prize_config.duplicate_id, DuplicatePrizeList),
			?IF(DuplicatePrizeInfo =/= false, DuplicatePrizeInfo, ?S2CERR(?ERROR_SYSTEM))
	end.

% 副本地图所对应的奖励信息(不抛错误)
get_duplicate_prize2(DuplicateId) ->
	case util:tab2list(?DUPLICATE_PRIZE_CONFIG_ETS) of
		[] ->
			[];
		DuplicatePrizeList ->
			case lists:keyfind(DuplicateId, #duplicate_prize_config.duplicate_id, DuplicatePrizeList) of
				false ->
					[];
				DuplicatePrizeInfo ->
					ok
			end
	end.

% 计算获得奖励
calculate_prize(DuplicatePrizeInfo) ->
	PrizeList = DuplicatePrizeInfo#duplicate_prize_config.prize_list,
	% 验证各组物品概率总和是否为10000
	TotalProb = lists:foldl(fun(Ele, Acc) ->
				{_Index, Rate, _ItemTemplateId, _Num} = Ele,
				Acc + Rate
		end, 0, PrizeList),
	?IF(TotalProb =:= ?PROB_BASE, ok, ?S2CERR(?ERROR_SYSTEM)),
	do_calculate_prize(PrizeList, util:random_num()).

do_calculate_prize([H|T], BaseProb) ->
	{Index, Rate, ItemTemplateId, Num} = H,
	case BaseProb =< Rate of
		true ->
			{Index, ItemTemplateId, Num};
		false ->
			do_calculate_prize(T, BaseProb - Rate)
	end.

get_duplicate_prize_map(RoleId) ->
	TableName = db_split:get_owner_table(duplicate_prize_map, RoleId),
	case dal:read_rpc(TableName, RoleId) of
		{ok,[R]}-> R;
		{ok,[]}->[]
	end.
	
save_duplicate_prize_map(RoleId, Info) ->
	TableName = db_split:get_owner_table(duplicate_prize_map, RoleId),
	dmp_op:sync_write(RoleId, {TableName, RoleId, Info}).