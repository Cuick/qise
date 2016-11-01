%% Author: MacX
%% Created: 2011-11-18
%% Description: TODO: Add description to battle_jszd_packet
-module(camp_battle_packet).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("login_pb.hrl"). 
-include("common_define.hrl").
-record(fbr,{roleid,rolename,rolelevel,roleclass,guildlid,guildhid,guildname,camp,score}).
-record(cbpn,{type,total,max}).
-record(cbk,{type,id,name,score,value,h,m,s}).
-record(cbbk,{roleid,num}).
%%
%% API Functions
%%
handle(Message=#camp_battle_entry_c2s{},RolePid)->
	RolePid!{camp_battle,Message};
handle(Message=#camp_battle_player_num_c2s{},RolePid)->
    RolePid!{camp_battle,Message};
handle(Message=#camp_battle_leave_c2s{},RolePid)->
	RolePid!{camp_battle,Message};
handle(Message=#camp_battle_last_record_c2s{},RolePid)->
	RolePid!{camp_battle,Message};
handle(_Message,_RolePid)->
	nothing.

process_msg(#camp_battle_entry_c2s{})->
	battle_ground_op:handle_join(?CAMP_BATTLE);
process_msg(#camp_battle_player_num_c2s{})->
        battle_ground_op:handle_battle_player_num();
process_msg(#camp_battle_leave_c2s{})->
	battle_ground_op:handle_battle_leave();
process_msg(#camp_battle_last_record_c2s{})->
	battle_ground_op:handle_camp_battle_last_record();
process_msg(Message)->
        nothing.

encode_camp_battle_init_s2c(CampAScore, CampBScore, CampANum, CampBNum, Roles, Deserters, Lefttime_s) ->
	login_pb:encode_camp_battle_init_s2c(#camp_battle_init_s2c{campascore=CampAScore,campbscore=CampBScore,campanum=CampANum,campbnum=CampBNum,roles=Roles,deserters=Deserters,lefttime_s=Lefttime_s}).

encode_camp_battle_otherrole_init_s2c(Role)->
	login_pb:encode_camp_battle_otherrole_init_s2c(#camp_battle_otherrole_init_s2c{role=Role}).

make_camp_battle_role(RoleId,RoleName,RoleLevel,RoleClass,GuildLId,GuildHId,GuildName,Camp,Score) ->
        #fbr{roleid=RoleId,rolename=RoleName,rolelevel=RoleLevel,roleclass=RoleClass,guildlid=GuildLId,guildhid=GuildHId,guildname=GuildName,camp=Camp,score=Score}.

make_camp_battle_playernum(Type,Total,Max) ->
	#cbpn{type=Type,total=Total,max=Max}.

encode_camp_battle_player_num_s2c(PlayerNum) ->
	login_pb:encode_camp_battle_player_num_s2c(#camp_battle_player_num_s2c{playnum=PlayerNum}).

make_camp_battle_record_kill(Type,RoleId,RoleName,Score,Value,Hour,Min,Sec)->
	#cbk{type=Type,id=RoleId,name=RoleName,score=Score,value=Value,h=Hour,m=Min,s=Sec}.

make_camp_battle_record_bekill(RoleId,Num) ->
	#cbbk{roleid=RoleId,num=Num}.

encode_camp_battle_record_update_s2c(Killed,BeKilled) ->
	login_pb:encode_camp_battle_record_update_s2c(#camp_battle_record_update_s2c{kill=Killed,bekill=BeKilled}).

encode_camp_battle_otherrole_update_s2c(RoleId,NewScore,Camp,CampScore) ->
	login_pb:encode_camp_battle_otherrole_update_s2c(#camp_battle_otherrole_update_s2c{roleid=RoleId,newscore=NewScore,camp=Camp,campscore=CampScore}).

encode_camp_battle_start_s2c() ->
	login_pb:encode_camp_battle_start_s2c(#camp_battle_start_s2c{}).
encode_camp_battle_otherrole_leave_s2c(RoleId)->
	login_pb:encode_camp_battle_otherrole_leave_s2c(#camp_battle_otherrole_leave_s2c{roleid=RoleId}).
encode_camp_battle_leave_s2c(Result) ->
	login_pb:encode_camp_battle_leave_s2c(#camp_battle_leave_s2c{result=Result}).

encode_camp_battle_stop_s2c()->
	login_pb:encode_camp_battle_stop_s2c(#camp_battle_stop_s2c{}).

encode_camp_battle_last_record_s2c(Players,Deserters,Kills,BeKills,Ascore,Bscore,Anum,Bnum) ->
	login_pb:encode_camp_battle_last_record_s2c(#camp_battle_last_record_s2c{roles=Players,deserters=Deserters, kill=Kills, bekilled=BeKills, campascore=Ascore, campbscore=Bscore, campanum = Anum, campbnum = Bnum}).

encode_camp_battle_record_init_s2c(Kills,BeKills) ->
	login_pb:encode_camp_battle_record_init_s2c(#camp_battle_record_init_s2c{kill = Kills,bekilled = BeKills}).

encode_camp_battle_result_s2c(Winner,Exp,Honor,Items)->
	login_pb:encode_camp_battle_result_s2c(#camp_battle_result_s2c{winner=Winner, exp=Exp, honor=Honor, items=Items}).

encode_camp_battle_add_buff_s2c(FightValue) ->
	login_pb:encode_add_buff_in_battle_s2c(#add_buff_in_battle_s2c{value = FightValue}).
