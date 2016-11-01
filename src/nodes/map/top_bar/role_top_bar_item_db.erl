-module (role_top_bar_item_db).


-include("mnesia_table_def.hrl").

-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_temp_activity_count2,record_info(fields,role_temp_activity_count2),[],set).

create_mnesia_split_table(role_temp_activity_count,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,role_temp_activity_count),[],set);
create_mnesia_split_table(role_temp_activity_awards,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,role_temp_activity_awards),[],set).

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(role_temp_activity_count, RoleId),
	dal:delete_rpc(TableName, RoleId),
	TableName2 = db_split:get_owner_table(role_temp_activity_awards, RoleId),
	dal:delete_rpc(TableName2, RoleId).

tables_info()->
	[{role_temp_activity_count,disc_split},{role_temp_activity_awards,disc_split},
	{role_temp_activity_count2,disc}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_rank_list(Key) ->
	case dal:read_rpc(role_temp_activity_count2, Key) of
		{ok, [Result]} ->
			Result#role_temp_activity_count2.count;
		_ ->
			[]
	end.

get_role_count(RoleId) ->
	TableName = db_split:get_owner_table(role_temp_activity_count, RoleId),
	case dal:read_rpc(TableName, RoleId) of
		{ok, [Result]} ->
			{_, _, Count} = Result,
			Count;
		_ ->
			[]
	end.


get_role_awards(RoleId) ->
	TableName = db_split:get_owner_table(role_temp_activity_awards, RoleId),
	case dal:read_rpc(TableName, RoleId) of
		{ok, [Result]} ->
			{_, _, Count} = Result,
			Count;
		_ ->
			[]
	end.

save_role_awards(RoleId, Awards) ->
	TableName = db_split:get_owner_table(role_temp_activity_awards, RoleId),
	dmp_op:sync_write(RoleId,{TableName,RoleId,Awards}).

save_role_count(RoleId, Count) ->
	TableName = db_split:get_owner_table(role_temp_activity_count, RoleId),
	dmp_op:sync_write(RoleId,{TableName,RoleId,Count}).

save_rank_list(RoleId, Count) ->
	dmp_op:sync_write(RoleId,{role_temp_activity_count2,RoleId,Count}).