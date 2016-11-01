-module(role_mystical_card_db).

-include ("mnesia_table_def.hrl").

-behaviour(db_operater_mod).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	nothing.

create_mnesia_split_table(mystical_card_info,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,mystical_card_info),[],set).

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(mystical_card_info, RoleId),
	dal:delete_rpc(TableName, RoleId).

tables_info()->
	[{mystical_card_info,disc_split}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
save_mystical_card_info(RoleId, Info) ->
	TableName = db_split:get_owner_table(mystical_card_info, RoleId),
	dmp_op:sync_write(RoleId, {TableName, RoleId, Info}).