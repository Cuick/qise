-module (role_open_service_auction_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_open_service_auction_info,record_info(fields,role_open_service_auction_info),[],set),
	db_tools:create_table_disc(role_open_service_auction_max,record_info(fields,role_open_service_auction_max),[],set).

create_mnesia_split_table(_, _)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{role_open_service_auction_info,disc}, {role_open_service_auction_max,disc}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_auction_info() ->
	case dal:read_rpc(role_open_service_auction_info) of
		{ok, []} ->
			[];
		{ok, R} ->
			R
	end.

add_role_to_auction_info(RoleId, Name, Time, Bid) ->
	dal:write_rpc({role_open_service_auction_info, RoleId, Name, Time, Bid}).

delete_role_from_auction_info(RoleId) ->
	dal:delete_rpc(role_open_service_auction_info, RoleId).

get_auction_max_info() ->
	case dal:read_rpc(role_open_service_auction_max) of
		{ok, []} ->
			[];
		{ok, Result} ->
			Result
	end.

role_open_service_auction_db(RoleId) ->
	case dal:read_rpc(role_open_service_auction_max, RoleId) of
		{ok, []} ->
			[];
		{ok, [R]} ->
			R
	end.

delete_role_from_auction_max(RoleId) ->
	dal:delete_rpc(role_open_service_auction_max, RoleId).

save_auction_max(RoleId, RoleName, Time, Bid) ->
	dal:write_rpc({role_open_service_auction_max, RoleId, RoleName, Time, Bid}).

get_auction_max(BidMaxInfo) ->
	BidMaxInfo#role_open_service_auction_max.bid.