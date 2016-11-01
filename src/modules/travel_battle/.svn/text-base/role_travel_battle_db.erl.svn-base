-module (role_travel_battle_db).

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

create_mnesia_split_table(role_travel_battle_scores,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,role_travel_battle_scores),[],set).

delete_role_from_db(RoleId)->
	TableName = db_split:get_owner_table(role_travel_battle_scores, RoleId),
	dal:delete_rpc(TableName, RoleId).

tables_info()->
	[{role_travel_battle_scores,disc_split}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_role_info(RoleId) ->
	TableName = db_split:get_owner_table(role_travel_battle_scores, RoleId),
	case dal:read_rpc(TableName, RoleId) of
		{ok,[R]}-> R;
		{ok,[]}->[]
	end.

get_role_scores(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.scores.

get_role_total(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.total.

get_role_total_win(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.total_win.

get_role_serial_win(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.serial_win.

get_role_gold(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.gold.

get_role_ticket(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.ticket.

get_role_silver(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.silver.

get_role_total_scores(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.total_scores.

get_role_month(RoleTravelBattleInfo) ->
	RoleTravelBattleInfo1 = erlang:setelement(1, RoleTravelBattleInfo, role_travel_battle_scores),
	RoleTravelBattleInfo1#role_travel_battle_scores.month.
	
save_role_info(RoleId, Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, TotalScores, Month) ->
	TableName = db_split:get_owner_table(role_travel_battle_scores, RoleId),
	dmp_op:sync_write(RoleId, {TableName, RoleId, Scores, Total, TotalWin, SerialWin, 
		Gold, Ticket, Silver, TotalScores, Month}).