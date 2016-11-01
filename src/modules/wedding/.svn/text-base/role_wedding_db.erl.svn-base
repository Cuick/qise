-module (role_wedding_db).

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
	db_tools:create_table_disc(role_ceremony_info,record_info(fields,role_ceremony_info),[],set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{role_ceremony_info,disc}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_all_role_ceremony_info()->
	case dal:read_rpc(role_ceremony_info) of
		{ok, R} ->
			R
	end.
	
get_role_ceremony_info(CeremonyId) ->
	case dal:read_rpc(role_ceremony_info, CeremonyId) of
		{ok, []} ->
			[];
		{ok, [R]} ->
			R
	end.

get_role_ceremony_date(RoleCeremonyInfo) ->
	RoleCeremonyInfo#role_ceremony_info.date.

get_role_ceremony_applicant(RoleCeremonyInfo) ->
	RoleCeremonyInfo#role_ceremony_info.applicant.

get_role_ceremony_spouse(RoleCeremonyInfo) ->
	RoleCeremonyInfo#role_ceremony_info.spouse.

save_role_ceremony_info(Applicant,Spouse,Type, Date)->
	dal:write_rpc({role_ceremony_info,Applicant,Spouse,Type,Date}).
