%%

%%
%% Exported Functions
%%
-module(load_map_process).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3]).

-record(state,{}).

%%
%% API Functions
%%

start_link()->
	gen_server:start_link({local,?MODULE},?MODULE,[],[]).

init([])->
	AllMapInfo = map_info_db:get_all_maps_and_serverdata(),
	lists:foreach(fun({MapId,MapDataId})->
		MapDb = mapdb_processor:make_db_name(MapId),
		case ets:info(MapDb) of
			undefined->
				ets:new(MapDb, [set,named_table]),	%% first new the database, and then register proc
				case MapDataId of
					[]->
						nothing;
					_->
						map_db:load_map_ext_file(MapDataId,MapDb),
						map_db:load_map_file(MapDataId,MapDb)
				end;
			_->
				nothing
		end end,AllMapInfo),
	erlang:garbage_collect(),	
	{ok,#state{}}.

handle_call(_Request,_From,State)->
	Reply = ok,
	{reply,Reply,State}.

handle_cast(_Msg,State)->
	{noreply,State}.

handle_info(_Info,State)->
	{noreply,State}.
terminate(_Reason,_State)->
	ok.

code_change(_OldVsn,State,_Extra)->
	{ok,State}.