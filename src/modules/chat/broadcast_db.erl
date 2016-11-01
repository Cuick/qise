-module(broadcast_db).
-include("mnesia_table_def.hrl").

-behaviour(db_operater_mod).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(ets_operater_mod).
-export([init/0,create/0]).

-export([config/1, get_chatid/1, get_condition/1]).

-define(BROADCAST_MNESIA, broadcast).
-define(BROADCAST_ETS, '$broadcast_ets$').

%%%===================================================================
%% 				behaviour functions
%%%===================================================================

% db_operater_mod
start()->
  db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
  db_tools:create_table_disc(?BROADCAST_MNESIA, record_info(fields, broadcast), [], set).

create_mnesia_split_table(_, _)->
  nothing.

tables_info()-> [{?BROADCAST_MNESIA, proto}].

delete_role_from_db(_)->
  nothing.

% ets_operater_mod
create()->
  ets:new(?BROADCAST_ETS, [set, named_table, {keypos, #broadcast.type}]).

init() ->
  ets:delete_all_objects(?BROADCAST_ETS),
  case dal:read_rpc(?BROADCAST_MNESIA) of
    {ok,Items} ->
      lists:foreach(
        fun(Item) ->
          ets:insert(?BROADCAST_ETS, Item)
        end, Items);
    _ -> slogger:msg("read broadcast failed~n")
  end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

config(Name, Key) ->
  case dal:read_rpc(Name, Key) of
    {ok,[Result]} -> Result;
    _ -> nothing
  end.

config(Key)->
  try
    case ets:lookup(?BROADCAST_ETS, Key) of
      [Result]-> Result;
      _ -> config(?BROADCAST_MNESIA, Key)
    end
  catch
    _:_ ->
      config(?BROADCAST_MNESIA, Key)
  end.

% attr
get_condition(Key)->
  case config(Key) of
    nothing -> nothing;
    Result ->
      Result#broadcast.condition
  end.

get_chatid(Key)->
  case config(Key) of
    nothing -> nothing;
    Result ->
      Result#broadcast.chatid
  end.

