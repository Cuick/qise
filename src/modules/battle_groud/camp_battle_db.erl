
-module(camp_battle_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("common_define.hrl").
-include("camp_battlefield.hrl").
-include_lib("stdlib/include/qlc.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 						behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-define(YYBATTLE_RECORD_NAME,yybattle_record).
-define(YYBATTLE_PLAYER_RECORD_NAME,yybattle_player_record).
-define(CAMP_BATTLEFIELD_MINOR_ETS, camp_battlefield_minor_config).


-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(yybattle_record, record_info(fields,yybattle_record), [], set),
	db_tools:create_table_disc(yybattle_player_record, record_info(fields,yybattle_player_record), [], set),
	db_tools:create_table_disc(camp_battlefield_minor_config, record_info(fields, camp_battlefield_minor_config), [], set).
      

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{yybattle_record,proto},{yybattle_player_record,proto}, {camp_battlefield_minor_config, proto}].
	
create()->
	ets:new(?YYBATTLE_RECORD_NAME, [set,named_table]),
	ets:new(?YYBATTLE_PLAYER_RECORD_NAME,[set,named_table]),
	ets:new(?CAMP_BATTLEFIELD_MINOR_ETS, [set, public, named_table, {read_concurrency, true}]).

init()->
	db_operater_mod:init_ets(yybattle_record, ?YYBATTLE_RECORD_NAME, #yybattle_record.battleid),
	db_operater_mod:init_ets(yybattle_player_record, ?YYBATTLE_PLAYER_RECORD_NAME, #yybattle_player_record.roleid),
	db_operater_mod:init_ets(camp_battlefield_minor_config, ?CAMP_BATTLEFIELD_MINOR_ETS, #camp_battlefield_minor_config.counter).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_battle_info()->
	case dal:read_rpc(yybattle_record) of
		{ok,BattleInfo}-> BattleInfo;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.

load_player_info()->
	case dal:read_rpc(yybattle_player_record) of
		{ok,PlayerInfo}-> PlayerInfo;
		{failed,_Reason}-> [];
		{failed,badrpc,_Reason}-> []
	end.
	
sync_add_battle_info(BattleId,PlayerInfo,DeserterInfo,Ascore,Bscore,Anum,Bnum,Ext)->
        dmp_op:sync_write(BattleId,{yybattle_record,BattleId,PlayerInfo,DeserterInfo,Ascore,Bscore,Anum,Bnum,Ext}).
        
sync_add_player_info(RoleId,BattleType,BattleId,KillInfo,BeKillInfo,Ext) ->
        dmp_op:sync_write(RoleId,{yybattle_player_record,RoleId,BattleType,BattleId,KillInfo,BeKillInfo,Ext}).
        

clear_battle_info()->
	dal:clear_table_rpc(yybattle_record).

clear_player_info() ->
	dal:clear_table_rpc(yybattle_player_record).

get_player_battletype(PlayerInfo) ->
	erlang:element(#yybattle_player_record.battletype, PlayerInfo).

	
get_player_battleid(PlayerInfo) ->
        erlang:element(#yybattle_player_record.battleid, PlayerInfo).
  
get_player_killinfo(PlayerInfo) ->
        erlang:element(#yybattle_player_record.killinfo, PlayerInfo).

get_player_bekillinfo(PlayerInfo) ->
	erlang:element(#yybattle_player_record.bekillinfo, PlayerInfo).

get_battle_playerinfo(BattleInfo) ->
	erlang:element(#yybattle_record.playerinfo, BattleInfo).

get_battle_deserterinfo(BattleInfo) ->
	erlang:element(#yybattle_record.deserterinfo, BattleInfo).

get_battle_ascore(BattleInfo) ->
	erlang:element(#yybattle_record.ascore, BattleInfo).

get_battle_bscore(BattleInfo) ->
	erlang:element(#yybattle_record.bscore, BattleInfo).

get_battle_anum(BattleInfo) ->
	erlang:element(#yybattle_record.anum, BattleInfo).

get_battle_bnum(BattleInfo) ->
	erlang:element(#yybattle_record.bnum, BattleInfo).

% 获取死亡、离开本战场对应信息
get_camp_battlefield_minor_config(Counter) ->
	case util:tab2list(?CAMP_BATTLEFIELD_MINOR_ETS) of
		[] ->
			[];
		CampBattlefieldMinorConfigList ->
			SortCampBattlefieldMinorConfigList = lists:keysort(#camp_battlefield_minor_config.counter, CampBattlefieldMinorConfigList),
			case lists:keyfind(Counter, #camp_battlefield_minor_config.counter, SortCampBattlefieldMinorConfigList) of
				false ->
					case Counter > 0 of
						true ->
							lists:nth(length(SortCampBattlefieldMinorConfigList), SortCampBattlefieldMinorConfigList);
						false ->
							[]
					end;
				CampBattlefieldMinorConfigTuple ->
					CampBattlefieldMinorConfigTuple
			end
	end.
