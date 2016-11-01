-module(levelitem_db).

-include_lib("stdlib/include/ms_transform.hrl").
-include("logger.hrl").
-include("levelitem.hrl").
%% -define(ldebug, true).

%% -include("config_db_def.hrl").
-behaviour(db_operater_mod).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(ets_operater_mod).
-export([init/0,create/0]).

-export([
	get_role_levelitem_info/1,
	save_role_levelitem_info/2,
	item/1
	]).

-define(CONFIG, levelitem).
-define(ETS, levelitem).
-define(ROLEDATA, role_levelitem).

%%%===================================================================
%% 				behaviour functions
%%%===================================================================

% db_operater_mod
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(?CONFIG, record_info(fields, ?CONFIG), [], set),
	db_tools:create_table_disc(?ROLEDATA, record_info(fields, ?ROLEDATA), [], set).

create_mnesia_split_table(_, _) ->
	nothing.


tables_info()->
	[{?ROLEDATA, disc},
	{?CONFIG, proto}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(?ROLEDATA, RoleId).

% ets_operater_mod
create()->
	ets:new(?ETS, [set, public, named_table, {read_concurrency, true}]).

init() ->
	db_operater_mod:init_ets(?CONFIG, ?ETS, [#levelitem.show_level]).

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_role_levelitem_info(RoleId) ->
	case dal:read_rpc(?ROLEDATA,RoleId) of
		{ok,[{TableName, RoleId, Hist}]}->
			{TableName, RoleId, Hist};
		_ -> {?ROLEDATA, RoleId, []}
	end.

save_role_levelitem_info(Id,Hist)->
  dal:write_rpc(#role_levelitem{roleid=Id,hist=Hist}).

item(Level) ->
  MatchSpec = ets:fun2ms(
      fun({_,#levelitem{show_level=S,obtain_level=O}}=T) when Level >= S;Level>=O-> 
          T 
      end),
  L = [X||{_,X}<-ets:select(?ETS, MatchSpec)],
  %slogger:msg("Level:~p~n,L:~p~n",[Level,L]),
  L.
