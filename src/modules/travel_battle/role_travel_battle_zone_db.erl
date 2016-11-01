%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (role_travel_battle_zone_db).

-include ("mnesia_table_def.hrl").

-behaviour(db_operater_mod).

-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-compile(export_all).

-define (TRAVEL_BATTLE_ZONE_INFO, ets_travel_battle_zone_info).

-record(role_travel_battle_zone_info,{role_id,fight_force,node,pid,map_id,proc,line_id,pos,group_id}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(role_travel_battle_rank, record_info(fields,role_travel_battle_rank), [], set),
	db_tools:create_table_disc(role_travel_battle_rank_clear, record_info(fields,role_travel_battle_rank_clear), [], set).

create_mnesia_split_table(_, _)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{role_travel_battle_rank, disc}, {role_travel_battle_rank_clear, disc}].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

create_travel_battle_zone_ets() ->
	ets:new(?TRAVEL_BATTLE_ZONE_INFO, [set,named_table,public]).

save_role_info(RoleId, FightForce, RoleNode, RolePid, MapId, MapProc, LineId, Pos, GroupId) ->
	RoleInfo = #role_travel_battle_zone_info{
		role_id = RoleId,
		fight_force = FightForce,
		node = RoleNode,
		pid = RolePid,
		map_id = MapId,
		proc = MapProc,
		line_id = LineId,
		pos = Pos,
		group_id = GroupId
	},
	ets:insert(?TRAVEL_BATTLE_ZONE_INFO, {RoleId, RoleInfo}).

update_role_group_id(RoleId, GroupId) ->
	case get_role_info(RoleId) of
		[] ->
			nothing;
		RoleInfo ->
			ets:insert(?TRAVEL_BATTLE_ZONE_INFO, {RoleId, 
				RoleInfo#role_travel_battle_zone_info{group_id = GroupId}})
	end.

get_role_info(RoleId) ->
	case ets:lookup(?TRAVEL_BATTLE_ZONE_INFO, RoleId) of
		[] -> [];
		[{_, Term}] -> Term
	end.

get_role_group_id(RoleInfo) ->
	RoleInfo#role_travel_battle_zone_info.group_id.

get_role_node(RoleInfo) ->
	RoleInfo#role_travel_battle_zone_info.node.

get_role_pid(RoleInfo) ->
	RoleInfo#role_travel_battle_zone_info.pid.

get_role_fight_force(RoleInfo) ->
	RoleInfo#role_travel_battle_zone_info.fight_force.

get_role_line_id(RoleInfo) ->
	RoleInfo#role_travel_battle_zone_info.line_id.

get_role_map_id(RoleInfo) ->
	RoleInfo#role_travel_battle_zone_info.map_id.

get_role_pos(RoleInfo) ->
	RoleInfo#role_travel_battle_zone_info.pos.

get_role_map_proc(RoleInfo) ->
	RoleInfo#role_travel_battle_zone_info.proc.

delete_role(RoleId) ->
	ets:delete(?TRAVEL_BATTLE_ZONE_INFO, RoleId).

	
load_rank_data() ->
	case dal:read_rpc(role_travel_battle_rank) of
		{ok, Result} ->
			[{RoleId, Name, Gender, Class, Scores} || {_, 
			RoleId, Name, Gender, Class, Scores} <- Result];
		_ ->
			[]
	end.

add_role_to_rank(RoleId, Name, Gender, Class, Scores) ->
	dal:write_rpc({role_travel_battle_rank, RoleId, Name, Gender, Class, Scores}).

delete_role_from_rank(RoleId) ->
	dal:delete_rpc(role_travel_battle_rank, RoleId).

clear_role_rank_info() ->
	dal:clear_table_rpc(role_travel_battle_rank).

get_rank_clear_month() ->
	case dal:read_rpc(role_travel_battle_rank_clear) of
		{ok, []} ->
			0;
		{ok, [Result]} ->
			Result#role_travel_battle_rank_clear.month;
		_ ->
			0
	end.

update_rank_clear_month(Month) ->
	dal:write_rpc({role_travel_battle_rank_clear, 1, Month}).
