-module(login_continuously_db).
-author("zhuo.yan").
-include("login_continuously.hrl").

-behaviour(db_operater_mod).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(ets_operater_mod).
-export([init/0,create/0]).

-export([
	get_role_logincontinously_info/1,
	save_role_logincontinously_info/2,
	async_save_role_logincontinously_info/2
	]).

-export([
    get_reward/2
	]).

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
  ets:new(?CONFIG, [set, named_table]).

init() ->
	db_operater_mod:init_ets(?CONFIG, ?CONFIG, [#logincontinuously.day]).

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_role_logincontinously_info(RoleId) ->
	TableName = db_split:get_owner_table(?ROLEDATA, RoleId),
	case dal:read_rpc(TableName,RoleId) of
		{ok,[{TableName, RoleId, Login_Date, Counter, Normal, Pay}]}->
			{TableName, RoleId, Login_Date, Counter, Normal, Pay};
		_ -> {TableName, RoleId, {{2010,1,1},{0,0,0}}, 0, 0, 0}
	end.

save_role_logincontinously_info(RoleId, Info) when Info /=[] ->
	dmp_op:sync_write(RoleId,Info);
save_role_logincontinously_info(_, _) ->
	nothing.

async_save_role_logincontinously_info(RoleId, Info) when Info /=[] ->
	dmp_op:async_write(RoleId,Info);
async_save_role_logincontinously_info(_, _) ->
	nothing.


% cfg
get_reward(Day, Type) ->
	case ets:lookup(?CONFIG, Day) of
	[{Day, #logincontinuously{normal_rward=R1, pay_rward=R2}}] ->
		case Type of
		?NORMAL -> R1;
		?PAY -> R2;
		Other -> slogger:msg("cfg error type: ~p ~n", [Other])
		end;
	_ ->
		Max =
		ets:foldl(
			fun ({CDay, _}, Acc) when CDay > Acc ->
				CDay;
				(_, Acc) ->
				Acc
			end, 0, ?CONFIG
		),
		case Day > Max andalso Max /= 0 of
		true ->	get_reward(Max, Type);
		_ -> nothing
		end
	end.
