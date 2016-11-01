-module(levelgold_db).
-author("zhuo.yan").
-include("logger.hrl").
%% -define(ldebug, true).

%% -include("config_db_def.hrl").
-record(levelgold, {level, gold}).

-behaviour(db_operater_mod).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(ets_operater_mod).
-export([init/0,create/0]).

-export([
	get_role_levelgold_info/1,
	save_role_levelgold_info/2,
	async_save_role_levelgold_info/2,
	gold/1,
	update_hist/2]).

-define(CONFIG, levelgold).
-define(ETS, levelgold).
-define(ROLEDATA, role_levelgold).

-record(role_levelgold, {roleid, hist :: [integer()]}).

%%%===================================================================
%% 				behaviour functions
%%%===================================================================

% db_operater_mod
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(?CONFIG, record_info(fields, ?CONFIG), [], set).

create_mnesia_split_table(?ROLEDATA, TableName)->
	db_tools:create_table_disc(TableName, record_info(fields, ?ROLEDATA), [], set).

tables_info()->
	[{?ROLEDATA, disc_split},
	{?CONFIG, proto}].

delete_role_from_db(RoleId)->
	RoleTable = db_split:get_owner_table(?ROLEDATA, RoleId),
	dal:delete_rpc(RoleTable, RoleId).

% ets_operater_mod
create()->
  ets:new(?ETS, [set, named_table]).

init() ->
	db_operater_mod:init_ets(?CONFIG, ?ETS, [#levelgold.level]).

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_role_levelgold_info(RoleId) ->
	TableName = db_split:get_owner_table(?ROLEDATA, RoleId),
	case dal:read_rpc(TableName,RoleId) of
		{ok,[{TableName, RoleId, Hist}]}->
			{TableName, RoleId, Hist};
		_ -> {TableName, RoleId, []}
	end.

save_role_levelgold_info(RoleId, Info) when Info /=[] ->
	dmp_op:sync_write(RoleId,Info);
save_role_levelgold_info(_, _) ->
	?LOG_INFO("save error").

async_save_role_levelgold_info(RoleId, Info) when Info /=[] ->
	dmp_op:async_write(RoleId,Info);
async_save_role_levelgold_info(_, _) ->
	?LOG_INFO("save error").

update_hist(Level, {TableName, RoleId, Hist}) ->
	NewHist = [Level|Hist],
	{TableName, RoleId, NewHist};
update_hist(Level, _) ->
	RoleId = get(roleid),
	TableName = db_split:get_owner_table(?ROLEDATA, RoleId),
	update_hist(Level, {TableName, RoleId, []}).

gold(Level) ->
	case ets:lookup(?ETS, Level) of
	[{Level, #levelgold{gold=Gold}}] -> Gold;
	Other -> ?LOG_INFO("config error: ~p~n", [Other]), 0
	end.
