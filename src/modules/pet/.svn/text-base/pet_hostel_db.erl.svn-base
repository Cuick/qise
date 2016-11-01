-module(pet_hostel_db).

-include("mnesia_table_def.hrl").

-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).


-define(ROLE_PET_HOSTEL,role_pet_hostel_db).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(?ROLE_PET_HOSTEL, record_info(fields,pet_hostel), [], set).

create_mnesia_split_table(pet_hostel,TrueTabName)->
	nothing.

delete_role_from_db(RoleId)->
	dal:delete_rpc(?ROLE_PET_HOSTEL, RoleId).

tables_info()->
	[{pet_hostel,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_role_hostel_info(RoleId)->
	% TableName = db_split:get_owner_table(pet_hostel, RoleId),
	case dal:read_rpc(?ROLE_PET_HOSTEL,RoleId) of
		{ok,[R]}-> R;
		{ok,[]}->[];
		{failed,badrpc,_Reason}->{?ROLE_PET_HOSTEL,RoleId,[]};
		{failed,_Reason}-> {?ROLE_PET_HOSTEL,RoleId,[]}
	end.
	
save_role_hostel_info(RoleId,Role_room)->
	TableName = ?ROLE_PET_HOSTEL,
	dmp_op:sync_write(RoleId,{TableName,RoleId,Role_room}).

async_save_role_hostel_info(RoleId,Role_room)->
	TableName = ?ROLE_PET_HOSTEL,
	dmp_op:async_write(RoleId,{TableName,RoleId,Role_room}).

get_role_id(RolehostelInfo)->
	case RolehostelInfo of
		[]->[];
		_->
			erlang:element(#pet_hostel.roleid, RolehostelInfo)
	end.
	
get_role_room(RolehostelInfo)->
	case RolehostelInfo of
		[]->[];
		_->
			erlang:element(#pet_hostel.role_room, RolehostelInfo)
	end.
