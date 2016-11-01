-module (role_bdyy_db).

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
	db_tools:create_table_disc(role_bdyy_info,record_info(fields,role_bdyy_info),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(role_bdyy_info, RoleId).

tables_info()->
	[{role_bdyy_info,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


get_role_bdyy_info(RoleId)->
	case dal:read_rpc(role_bdyy_info,RoleId) of
		{ok,[R]}-> R;
		{ok,[]}->[]
	end.
	
save_role_bdyy_info(RoleId)->
	dmp_op:sync_write(RoleId,{role_bdyy_info,RoleId, 1}).

async_save_role_bdyy_info(RoleId)->
	dmp_op:async_write(RoleId,{role_bdyy_info,RoleId, 1}).
