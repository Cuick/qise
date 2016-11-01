-module (role_dead_valley_db).

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

create_mnesia_split_table(role_dead_valley_info,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,role_dead_valley_info),[],set).

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(role_dead_valley_info, RoleId),
	dal:delete_rpc(TableName, RoleId).

tables_info()->
	[{role_dead_valley_info,disc_split}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_role_info(RoleId) ->
	TableName = db_split:get_owner_table(role_dead_valley_info, RoleId),
	case dal:read_rpc(TableName, RoleId) of
		{ok,[R]}-> R;
		{ok,[]}->[]
	end.
	
save_role_info(RoleId, LeaveTime, Points, Exp) ->
	TableName = db_split:get_owner_table(role_dead_valley_info, RoleId),
	dmp_op:sync_write(RoleId, {TableName, RoleId, LeaveTime, Points, Exp}).