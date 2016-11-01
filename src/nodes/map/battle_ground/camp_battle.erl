-module(camp_battle).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("string_define.hrl").
-include("error_msg.hrl").
-include("npc_define.hrl").
-include("activity_define.hrl").
-include("camp_battlefield.hrl").

-compile(export_all).

-include("mnesia_table_def.hrl").

-define(POS_BROAD_TIME,3000).			%%every 3s broadcast Pos
-define(POS_BROAD_NUM,10).
-define(CAMP_REWARD_INFO_ETS,camp_reward_info_ets).
-define(CAMP_A,10).
-define(CAMP_B,20).

%%ranks_info:{RoleId,RoleName,ranks,kills,extinfo,camp}
%%extinfo:{RoleClass,RoleGender,RoleLevel}
on_init(ProcName,{BattleType,BattleId})->
	ProtoInfo = yybattle_proto_db:get_info(BattleType),
	InstanceId = yybattle_proto_db:get_instanceid(ProtoInfo),
	InstanceInfo = instance_proto_db:get_info(InstanceId),
	MapId = instance_proto_db:get_level_mapid(InstanceInfo),
	MapProc = battle_ground_processor:make_map_proc_name(ProcName),
    [ActivityInfo | _] = answer_db:get_activity_info(?CAMP_BATTLE_ACTIVITY),
	Duration = answer_db:get_activity_duration(ActivityInfo),
	case map_manager:start_instance(MapProc,MapId,instance,
		{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM},
		{atom_to_list(ProcName),InstanceId}) of
		ok->
			init(Duration + ?CAMP_BATTLE_BUFFER_TIME_S * 2 * 1000,BattleType,BattleId,MapProc),
			ok;
		error->
			on_destroy()
	end.

init(Duration,BattleType,BattleId,MapProc)->
	put(camp_info,{BattleType,BattleId,MapProc}),
	NpcInfoDB = npc_op:make_npcinfo_db_name(MapProc),
	put(npcinfo_db,NpcInfoDB),
	put(ranks_info,[]),
	put(camp_ranks_info,[{10,0},{20,0}]),
	put(camp_usernum_info,[{10,0},{20,0}]),
	put(is_battling,true),
	put(has_reward,[]),
	put(can_reward,false),	%%是否能领奖
	put(has_leave,[]),
	put(camp_kill_info,[]),
	%%erlang:send_after(?POS_BROAD_NUM*1000, self(),{do_interval,[]}), 客户端不需要显示前十名
    put(honor_info,[]),
	put(fighting_power, [{?GOD_GROUP, 0}, {?DEVIL_GROUP, 0}]),			% 双方战斗力
	put(role_leave_time, []),											% 玩家离开时间([{RoleId, Time(秒)}])
	put(ext,[]),
	put(role_join_time,[]),

    notify_manager_battle_start(BattleType,BattleId).

do_interval(_Info)->
	case get(is_battling) of
		true->
			case lists:sublist(get(ranks_info), ?POS_BROAD_NUM) of
				[]->
					nothing;
				TopTens->
					Poses = lists:map(fun({RoleId,_,_,_,_,_})->
						case creature_op:get_creature_info(RoleId) of
							undefined->
								battle_ground_packet:make_tp(RoleId,0,0);
							RoleInfo->
								{X,Y} = get_pos_from_roleinfo(RoleInfo),
								battle_ground_packet:make_tp(RoleId,X,Y)
						end end, TopTens)
					%Msg = battle_ground_packet:encode_tangle_topman_pos_s2c(Poses),
					%send_to_ground_client(Msg)
			end,
			erlang:send_after(?POS_BROAD_TIME, self(),{do_interval,[]});
		_->
			nothing
	end.

get_role_score(RoleId)->
	get_role_score(RoleId,get(ranks_info)).

get_role_score(RoleId,RanksInfo)->
	case lists:keyfind(RoleId,1,RanksInfo) of
		false->
			-1;
		{_,_,Ranks,_,_,_}->
			Ranks
	end.

get_role_record(RoleId)->
	get_role_record(RoleId,get(ranks_info)).

get_role_record(RoleId,RanksInfo)->
	case lists:keyfind(RoleId,1,RanksInfo) of
		false ->
			[];
		Record ->
			[Record]
	end.

is_has_reward(RoleId)->
	lists:member(RoleId, get(has_reward)).

%%return :[nowinfo]
add_role_score(RoleId,Score,Type)->
	case lists:keyfind(RoleId,1,get(ranks_info)) of
		false->
			[];
		{_,Name,OriScore,Kills,ExtInfo,Camp}->
			NewScore = erlang:max(OriScore+Score,0),
			if
				Type=:=killer->
					NewKills = Kills+1;
				true->
					%%NewKills = erlang:max(Kills-1,0)
					NewKills  = Kills
			end,
			put(ranks_info,lists:keyreplace(RoleId,1,get(ranks_info),{RoleId,Name,NewScore,NewKills,ExtInfo,Camp})),
			{_,CampOriScore} = lists:keyfind(Camp,1,get(camp_ranks_info)),
			CampNewScore = erlang:max(CampOriScore+Score,0),
			put(camp_ranks_info,lists:keyreplace(Camp,1,get(camp_ranks_info),{Camp,CampNewScore})),
			
			[{RoleId,Name,NewScore,NewKills,ExtInfo,Camp,CampNewScore}]
	end.

get_role_level(RoleId)->
	case creature_op:get_creature_info(RoleId) of
		undefined->
			0;
		CreatureInfo->
			creature_op:get_level_from_creature_info(CreatureInfo)
	end.

get_role_camp(RoleId)->
        case lists:keyfind(RoleId,1,get(ranks_info)) of
		false->
			-1;
		{_,_,_,_,_,Camp}->
			Camp
	end.

get_type()->
	{Type,_,_} = get(camp_info),
	Type.


get_map_proc_name(Proc)->
	atom_to_list(Proc).

get_map_proc()->
	{_,_,MapProc} = get(camp_info),
	MapProc.

get_role_name(RoleId)->
	case lists:keyfind(RoleId,1,get(ranks_info)) of
		false->
			[];
		{RoleId,RoleName,_Ranks,_Kills,_ExtInfo,_Camp}->
			RoleName
	end.

on_role_join({RoleId,RoleName,RoleClass,RoleGender,RoleLevel,CampInfo, RoleFightingPower})->
	put(has_leave,lists:delete(RoleId, get(has_leave))),
	% 清除上次离开时间
	put(role_leave_time, lists:keydelete(RoleId, 1, get(role_leave_time))),
	join_time(RoleId),
	case lists:keyfind(RoleId,1,get(ranks_info)) of
		false->
	        Camp = CampInfo,        
			put(ranks_info,get(ranks_info) ++ [{RoleId,RoleName,0,0,{RoleClass,RoleGender,RoleLevel},Camp}]),
	        {_,Num} = lists:keyfind(Camp,1,get(camp_usernum_info)),
			put(camp_usernum_info,lists:keyreplace(Camp,1,get(camp_usernum_info),{Camp,Num+1})),
		    put(honor_info,get(honor_info) ++ [{RoleId,0}]);
		        
		{RoleId,RoleName,Ranks,Kills,ExtInfo,Camp}->		%%rejoin? now reset
			NewCamp = CampInfo,
                        {_,Num} = lists:keyfind(NewCamp,1,get(camp_usernum_info)),
                        put(camp_usernum_info,lists:keyreplace(NewCamp,1,get(camp_usernum_info),{NewCamp,Num+1})),
			put(ranks_info,lists:keyreplace(RoleId,1, get(ranks_info), {RoleId,RoleName,0,0,ExtInfo,NewCamp})),
			put(ranks_info,lists:reverse(lists:keysort(3,get(ranks_info))))
	end,
	% 更新阵营战斗力和
	FightingPowerList = get(fighting_power),
	case lists:keyfind(CampInfo, 1, FightingPowerList) of
		false ->
			put(fighting_power, FightingPowerList ++ [{CampInfo, RoleFightingPower}]);
		{CampInfo, OldTotalFightingPower} ->
			put(fighting_power, lists:keyreplace(CampInfo, 1, FightingPowerList, {CampInfo, OldTotalFightingPower + RoleFightingPower}))
	end,
	{BattleType,BattleId,_} = get(camp_info),
	TempInfo = lists:filter(fun({_,_,ScoreTmp,_,_,_})-> ScoreTmp =/= -1 end,get(ranks_info)),
	AllInfo = lists:map(fun({RoleIdTmp,RoleNameTmp,ScoreTmp,KillsTmp,{ClassTmp,GenderTmp,LevelTmp},CampTmp})-> camp_battle_packet:make_camp_battle_role(RoleIdTmp,RoleNameTmp,LevelTmp,ClassTmp,0,0,[],CampTmp,ScoreTmp) end,TempInfo),
	case battle_ground_manager:get_battle_start(?CAMP_BATTLE) of
		{0,0,0}->
			TimeValue = {0,0,0};
		Time->
			TimeValue = Time
	end,
	DesertersTempInfo = lists:filter(fun({_,_,ScoreTmp,_,_,_})-> ScoreTmp =:= -1 end, get(ranks_info)),
	DesertersInfo = lists:map(fun({RoleIdTmp,RoleNameTmp,ScoreTmp,KillsTmp,{ClassTmp,GenderTmp,LevelTmp},CampTmp})->camp_battle_packet:make_camp_battle_role(RoleIdTmp,RoleNameTmp,LevelTmp,ClassTmp,0,0,[],CampTmp,0) end, DesertersTempInfo),

    [ActivityInfo | _] = answer_db:get_activity_info(?CAMP_BATTLE_ACTIVITY),
	Duration = answer_db:get_activity_duration(ActivityInfo),
    LeftTime = trunc((Duration - timer:now_diff(timer_center:get_correct_now(),TimeValue)/1000)/1000),
    {_,CampAScore} = lists:keyfind(?CAMP_A,1,get(camp_ranks_info)),
    {_,CampBScore} = lists:keyfind(?CAMP_B,1,get(camp_ranks_info)),
    {_,CampANum} = lists:keyfind(?CAMP_A,1,get(camp_usernum_info)),
    {_,CampBNum} = lists:keyfind(?CAMP_B,1,get(camp_usernum_info)),
    Message = camp_battle_packet:encode_camp_battle_init_s2c(CampAScore,CampBScore,CampANum,CampBNum,AllInfo,DesertersInfo,LeftTime),
    role_pos_util:send_to_role_clinet(RoleId,Message),
    MessageAdd = camp_battle_packet:encode_camp_battle_otherrole_init_s2c(camp_battle_packet:make_camp_battle_role(RoleId,RoleName,RoleLevel,RoleClass,0,0,[],get_role_camp(RoleId),get_role_score(RoleId))),
    send_to_ground_client_but(MessageAdd,RoleId),
    RecordMessage = camp_battle_packet:encode_camp_battle_record_init_s2c([],[]),
        role_pos_util:send_to_role_clinet(RoleId,RecordMessage),
    Honor = get_role_honor(RoleId),
    HonorMessage = battle_ground_packet:encode_battle_totleadd_honor_s2c(Honor),
    role_pos_util:send_to_role_clinet(RoleId,Message).


on_role_leave({RoleId, RoleFightingPower})->
	case get(is_battling) of
		true->
			put(has_leave,[RoleId|get(has_leave)]),
			% 记录离开时间
			leave_time(RoleId),
			LeaveTime = get_leave_time(RoleId),
			JoinTime = get_join_time(RoleId),
			case lists:keyfind(RoleId,1,get(ranks_info)) of
				false->
					nothing;
				{RoleId,RoleName,_Ranks,Kills,ExtInfo,Camp}->
					put(ranks_info,lists:keyreplace(RoleId,1, get(ranks_info), {RoleId,RoleName,-1,Kills,ExtInfo,Camp})),
					put(ranks_info,lists:reverse(lists:keysort(3,get(ranks_info)))),
                                        {_,Num} = lists:keyfind(Camp,1,get(camp_usernum_info)),
                                        put(camp_usernum_info,lists:keyreplace(Camp,1,get(camp_usernum_info),{Camp,Num-1})),
					% 扣除本方战斗力
					reduce_camp_fighting_powr(Camp, RoleFightingPower),
					gm_logger_role:insert_log_activity(RoleId,2,Camp,0,0,0,JoinTime,LeaveTime),
					delete_role_killinfo(RoleId)
			end,
			%Message = battle_ground_packet:encode_tangle_remove_s2c(RoleId),
			

			Message = camp_battle_packet:encode_camp_battle_otherrole_leave_s2c(RoleId),
			send_to_ground_client(Message),
			notify_manager_role_leave();
		_->
			put(has_leave,[RoleId|get(has_leave)]),
			nothing
	end.	

on_killed({Killer,BeKilled})->
	case get(is_battling) of
		true->
			case creature_op:what_creature(Killer) of
				npc->
					nothing;
				role->
					case creature_op:what_creature(BeKilled) of
						npc ->
							creature_killed_score(Killer,BeKilled);
						role->
							%%io:format("tangle_battle on killed ~n"),
							update_bekiller_info(Killer,BeKilled),
							update_killer_info(Killer,BeKilled),
							player_killed_score(Killer,BeKilled)
					end,
					put(ranks_info,lists:reverse(lists:keysort(3,get(ranks_info))))			%%fresh ranks
			end;
		_->
			nothing
	end.
	
%%camp_kill_info:[killinfo],
%%killinfo:{roleid,{[{bekillroleid,num}],[{killroleid,num}]}}
delete_role_killinfo(RoleId)->
	case lists:keyfind(RoleId,1,get(camp_kill_info)) of
		false->
			ignor;
		_->
			lists:keydelete(RoleId, 1, get(camp_kill_info))
	end.

%%update killer's kill info
update_killer_info(Killer,BeKiller)->
	Now = timer_center:get_correct_now(),
	case lists:keyfind(BeKiller,1,get(ranks_info)) of
	    false->
		    nothing;
		{_,BeKilledRoleName,_,_,_,_} ->
	        case lists:keyfind(Killer,1,get(camp_kill_info)) of
		        false->
			        NewKillInfo = {Killer,{[{2,BeKiller,BeKilledRoleName,Now,1,1}],[]}},
			        put(camp_kill_info,[NewKillInfo|get(camp_kill_info)]);
		        {Killer,{KillList,BeKillList}}->
			        NewKillList = [{2,BeKiller,BeKilledRoleName,Now,1,1}|KillList],
			        NewKillInfo = {Killer,{NewKillList,BeKillList}},
			        put(camp_kill_info,lists:keyreplace(Killer,1,get(camp_kill_info),NewKillInfo))
	        end,
            %make_camp_battle_record_kill(Type,RoleId,RoleName,Score,Value,Hour,Min,Sec)-
			{_,{H,M,S}} = calendar:now_to_local_time(Now),
			Kill = [camp_battle_packet:make_camp_battle_record_kill(2,BeKiller,BeKilledRoleName,1,1,H,M,S)],
			Message = camp_battle_packet:encode_camp_battle_record_update_s2c(Kill,[]),
			role_pos_util:send_to_role_clinet(Killer,Message)
	end.

		
        

%%update bekiller's kill info
update_bekiller_info(Killer,BeKiller)->
	case lists:keyfind(BeKiller,1,get(camp_kill_info)) of
		false->
			NewKillInfo = {BeKiller,{[],[{Killer,1}]}},
			put(camp_kill_info,[NewKillInfo|get(camp_kill_info)]),
		    BekilledTimes = 1;
		{BeKiller,{KillList,BeKillList}}->
			case lists:keyfind(Killer,1,BeKillList) of
				false->
					TmpBeKillList = [{Killer,1}|BeKillList],
				    BekilledTimes = 1;
				{Killer,Times}->
					TmpBeKillList = lists:keyreplace(Killer,1,BeKillList,{Killer,Times+1}),
                    BekilledTimes = Times + 1
			end,
			NewBeKillList =  lists:reverse(lists:keysort(2,TmpBeKillList)),
			NewKillInfo = {BeKiller,{KillList,NewBeKillList}},
			put(camp_kill_info,lists:keyreplace(BeKiller,1,get(camp_kill_info),NewKillInfo))
	end,
	BeKill = [camp_battle_packet:make_camp_battle_record_bekill(Killer,BekilledTimes)],
	Message = camp_battle_packet:encode_camp_battle_record_update_s2c([],BeKill),
	role_pos_util:send_to_role_clinet(BeKiller,Message).
		
killed_role_broad_cast(Type,MyInfo,OtherInfo,Score)->
	ParamRole = system_chat_util:make_role_param(MyInfo),
	ParamInt = system_chat_util:make_int_param(Score),
	case (MyInfo=:=undefined) or (OtherInfo=:=undefined) of
		true ->
			nothing;
		_ ->
			if Type=:=role->
					ParamOther = system_chat_util:make_role_param(OtherInfo),
					MsgInfo = [ParamRole, ParamOther, ParamInt],
					system_chat_op:system_broadcast_instance(?SYSTEM_CHAT_TANGLE_BATTLE_ROLE_KILLED,MsgInfo,camp_battle:get_map_proc_name(get_map_proc()));
				true->
					OtherName = get_name_from_npcinfo(OtherInfo),
					ParamString = system_chat_util:make_string_param(OtherName),
					MsgInfo = [ParamRole,ParamString],
					system_chat_op:system_broadcast_instance(?SYSTEM_CHAT_TANGLE_BATTLE_MONSTER_KILLED,MsgInfo,camp_battle:get_map_proc_name(get_map_proc()))
			end
	end.		
	

on_destroy()->
	notify_role_reward(),
	put(is_battling,false),
	put(can_reward,true),
	MapProc = get_map_proc(),
	MapProc ! {on_destroy},
	self() ! {destory_self}.
	
destroy_self()->
	send_to_ground({battle_leave_c2s}),
	send_reward_mail(),
	put(can_reward,false),
	write_to_db().

notify_role_reward()->
	WinnerCamp = get_winner_camp(),
	CurrentUserInfo = lists:filter(fun({_,_,ScoreTmp,_,_,_})-> ScoreTmp =/= -1 end,get(ranks_info)),
	Fun = fun({RoleId,_,_,_,_,_})->
		{Honor,Exp,Items} = 
		    case get_role_record(RoleId) of
		        []->
		 	        {0,0,[]};
		        [{RoleId,RoleName,Score,Kills,{_,_,RoleLevel},Camp}]->
		            case Score of
		                -1->
		                    {0,0,[]};
		                _->
		                     Rank = get_my_rank_by_score(Score),
		                     % 记录离开时间
							 leave_time(RoleId),
		                     LeaveTime = get_leave_time(RoleId),
		                     JoinTime = get_join_time(RoleId),
		                     Result = case Camp =:= WinnerCamp of
		                     	true->
		                     		1;
		                     	_->
		                     		0
		                     end,
		                     gm_logger_role:insert_log_activity(RoleId,2,Camp,Result,Rank,0,JoinTime,LeaveTime),
						     get_rewards_by_rank_and_camp(RoleLevel,Rank,Camp)
				    end
			end,
		RewardItems=util:term_to_record_for_list(Items, l),
		Message = camp_battle_packet:encode_camp_battle_result_s2c(WinnerCamp,Exp,Honor,RewardItems),
        role_pos_util:send_to_role_clinet(RoleId,Message),
		role_pos_util:send_to_role(RoleId, {battle_reward_honor_exp,?CAMP_BATTLE,Honor,Exp})
	end,
	lists:foreach(Fun, CurrentUserInfo).

send_reward_mail()->
	CurrentUserInfo = lists:filter(fun({_,_,ScoreTmp,_,_,_})-> ScoreTmp =/= -1 end,get(ranks_info)),
	Fun = fun({RoleId,RoleName,_,_,_,_})->
	  case lists:member(RoleId, get(has_reward)) of
		  false->
				put(has_reward,[RoleId|get(has_reward)]),
		    	FromName = language:get_string(?STR_BATTLE_MAIL_SIGN),
				Title = language:get_string(?STR_CAMP_BATTLE_MAIL_TITLE),
				ContextFormat = language:get_string(?STR_CAMP_BATTLE_MAIL_CONTENT),
				{_,_,Items} = 
				    case get_role_record(RoleId) of
					    []->
					        {0,0,[]};
					    [{RoleId,RoleName,Score,Kills,{_,_,RoleLevel},Camp}]->
					        case Score of
					            -1->
								    {0,0,[]};
							    _-> 
							        Rank = get_my_rank_by_score(Score),
							        get_rewards_by_rank_and_camp(RoleLevel,Rank,Camp)
							end 
				    end,
				lists:foreach(fun({ItemId,Count})->
				    gm_op:gm_send_rpc(FromName,RoleName,Title,ContextFormat,ItemId,Count,0)	
			    end,Items);
		  _->
			  ignor
	  end
	end,
	lists:foreach(Fun, CurrentUserInfo).
       
write_to_db()->
	%%先写battle record
	PlayerInfo = lists:filter(fun({_,_,ScoreTmp,_,_,_})-> ScoreTmp =/= -1 end,get(ranks_info)),
	DeserterInfo = lists:filter(fun({_,_,ScoreTmp,_,_,_})->ScoreTmp =:= -1 end,get(ranks_info)),
	{BattleType,BattleId,_}=get(camp_info),
	{_,Ascore} = lists:keyfind(?CAMP_A,1,get(camp_ranks_info)),
    {_,Bscore} = lists:keyfind(?CAMP_B,1,get(camp_ranks_info)),
    {_,Anum} = lists:keyfind(?CAMP_A,1,get(camp_usernum_info)),
	{_,Bnum} = lists:keyfind(?CAMP_B,1,get(camp_usernum_info)),
	%%BattleId,PlayerInfo,DeserterInfo,Ascore,Bscore,Anum,Bnum,Ext
	camp_battle_db:sync_add_battle_info({BattleType,BattleId},PlayerInfo,DeserterInfo,Ascore,Bscore,Anum,Bnum,[]),
    %%再写player record
	lists:foreach(fun({RoleId,{KillInfo,BeKilledInfo}})->
		camp_battle_db:sync_add_player_info(RoleId,BattleType,BattleId,KillInfo,BeKilledInfo,[])
	end,get(camp_kill_info)).


on_reward(RoleId)->
	case (not get(is_battling)) and (not is_has_reward(RoleId)) and (get(can_reward)) of
		true->
			put(has_reward,[RoleId|get(has_reward)]),
			case get_role_record(RoleId) of
				[]->
					{0,0,[]};
				[{RoleId,RoleName,Score,Kills,{_,_,RoleLevel},Camp}]->
					case Score of
						-1->
							{0,0,[]};
						_->
					        Rank = get_my_rank_by_score(Score),
					        get_rewards_by_rank_and_camp(RoleLevel,Rank,Camp)
					end
			end;
		_->
			{0,0,[]}
	end.

get_winner_camp()->
	[{CampA,CampAScore},{CampB,CampBScore}] = get(camp_ranks_info),
	if
		CampAScore>CampBScore ->
			CampA;
		CampAScore < CampBScore ->
			CampB;
		true ->
			0
	end.
%%
%%根据rankinfo计算RoleId的奖励
%%
get_reward_by_rankinfo(RoleId,RankInfo)->
	%Score = get_role_score(RoleId,RankInfo),
	%Rank = get_my_rank_by_score(Score,RankInfo),
	%get_rewards_by_rank(Rank).
	nothing.
	
get_my_rank_by_score(Score)->
	get_my_rank_by_score(Score,get(ranks_info)).
get_my_rank_by_score(Score,RanksInfo)->
	{_,Tmprank} = lists:foldl(fun({_,_,Ranks,_,_,_},{Re,Tmprank})->
		if
			Re or (Ranks=:=Score)->
				{true,Tmprank};
			true->
				{false,Tmprank+1}
			end
		end,{false,1},RanksInfo),
	Tmprank.				   

get_winner_camp_rewards() ->
	{BattleType,_,_} = get(camp_info),
	BattleFieldInfo = yybattle_proto_db:get_info(BattleType),
	WinnerBaseExp = yybattle_proto_db:get_winnerbaseexp(BattleFieldInfo),
	WinnerExpFactor = yybattle_proto_db:get_winnerexpfactor(BattleFieldInfo),
	WinnerBaseHonor = yybattle_proto_db:get_winnerbasehonor(BattleFieldInfo),
	WinnerHonorFactor = yybattle_proto_db:get_winnerhonorfactor(BattleFieldInfo),
	[WinnerReward,WinnerRewardWithoutRank,_] = yybattle_proto_db:get_winnerward(BattleFieldInfo),
	{WinnerBaseHonor,WinnerHonorFactor,WinnerBaseExp,WinnerExpFactor,WinnerReward,WinnerRewardWithoutRank}.
get_loser_camp_rewards() ->
    {BattleType,_,_} = get(camp_info),
    BattleFieldInfo = yybattle_proto_db:get_info(BattleType),
    LoserBaseExp = yybattle_proto_db:get_loserbaseexp(BattleFieldInfo),
    LoserBaseHonor = yybattle_proto_db:get_loserbasehonor(BattleFieldInfo),
    LoserHonorFactor = yybattle_proto_db:get_loserhonorfactor(BattleFieldInfo),
	LoserExpFactor = yybattle_proto_db:get_loserexpfactor(BattleFieldInfo),
    [LoserReward,LoserRewardWithoutRank,_] = yybattle_proto_db:get_loserward(BattleFieldInfo),
    {LoserBaseHonor,LoserHonorFactor,LoserBaseExp,LoserExpFactor,LoserReward,LoserRewardWithoutRank}.

get_rewards_by_camp(Camp) ->
    WinnerCamp = get_winner_camp(),
	case WinnerCamp of
		0 ->
            get_loser_camp_rewards();
		Camp ->
            get_winner_camp_rewards();
		_ ->
			get_loser_camp_rewards()
	end.
		
%奖励公式是：exp = lv*baseexp+factor*lv*(11-排名）
%            honor = basehonor
get_rewards_by_rank_and_camp(RoleLevel,Rank,Camp)->
	{BaseHonor,HonorFactor,BaseExp,ExpFactor,Reward,RewardWithoutRank} = get_rewards_by_camp(Camp),
	if 
		Rank < 11 ->
			RewardExp = RoleLevel*BaseExp+ExpFactor*RoleLevel*(11-Rank),
			RewardHonor = BaseHonor,
            RewardItems = Reward;
		true ->
			RewardExp = RoleLevel*BaseExp,
		    RewardHonor = BaseHonor,
		    RewardItems = RewardWithoutRank
	end,
	{RewardHonor,RewardExp,RewardItems}.

creature_killed_score(Killer,BeKilledNpc)->
	 NpcInfo = creature_op:get_creature_info(BeKilledNpc),
	 KillerInfo = creature_op:get_creature_info(Killer),
	 CreatureV = get_maxsilver_from_npcinfo(NpcInfo),
	 killed_role_broad_cast(npc,KillerInfo,NpcInfo,CreatureV),
	 case add_role_score(Killer,CreatureV,killer) of
		[]->
			nothing;
		[{RoleId,RoleName,Score,Kills,{RoleClass,RoleGender,RoleLevel},Camp,CampScore}]->
			Message = camp_battle_packet:encode_camp_battle_otherrole_update_s2c(RoleId,Score,Camp,CampScore),
			send_to_ground_client(Message)
	end.

player_killed_score(Killer,BeKilled)->
	{AddScore,SubScore} = calculate_player_killed_score(Killer,BeKilled),
	BeKillInfo = creature_op:get_creature_info(BeKilled),
	KillerInfo = creature_op:get_creature_info(Killer),
	case (BeKillInfo =/= undefined) and (KillerInfo=/= undefined) of
		true->   
			killed_role_broad_cast(role,KillerInfo,BeKillInfo,AddScore),
			case add_role_score(Killer,AddScore,killer) of
			    []->
			       nothing;
			    [{RoleId,RoleName,Score,Kills,{RoleClass,RoleGender,RoleLevel},Camp,CampScore}]->
			       Message = camp_battle_packet:encode_camp_battle_otherrole_update_s2c(RoleId,Score,Camp,CampScore),
			       send_to_ground_client(Message)
			end,
			case add_role_honor(Killer,1) of
				[]->
					nothing;
				[{Killer,Honor}]->
					HonorMessage = battle_ground_packet:encode_battle_totleadd_honor_s2c(Honor),
					role_pos_util:send_to_role_clinet(Killer,HonorMessage)

			end

	end.

		
%%returen{AddScore,SubScore}
%%max(roundup((other_level - self_level + other_score )/score_rate),1)
calculate_player_killed_score(KillerRole,BeKilledRole)->
%	BeKilledScore = get_role_score(BeKilledRole),
%	BeKilledRank = get_my_rank_by_score(BeKilledScore),
%	ScroreRate = get_score_rate_by_rank(BeKilledRank),
%	AddScore = erlang:max(1,util:even_div(get_role_level(BeKilledRole) - get_role_level(KillerRole) + BeKilledScore, ScroreRate)),
%	if
%		BeKilledRank=<10->
%			{AddScore,-trunc(AddScore/2)};
%		true->
%			{AddScore,0}
%	end.
	{1, 0}.

send_to_ground(Message)->
	lists:foreach(fun({RoleId,_,_,_,_,_})->
		case lists:member(RoleId, get(has_leave)) of
			false->
				role_op:send_to_other_role(RoleId,Message);
			_->
				nothing
		end
	end,get(ranks_info)).
	
send_to_ground_client(Message)->
	lists:foreach(fun({RoleId,_,_,_,_,_})->
		case lists:member(RoleId, get(has_leave)) of
			false->
				role_op:send_to_other_client(RoleId,Message);
			_->
				nothing
		end			  
	end,get(ranks_info)). 
	
send_to_ground_client_but(Message,NotId)->
	lists:foreach(fun({RoleId,_,_,_,_,_})->
		case (NotId=/=RoleId) and (not lists:member(RoleId, get(has_leave))) of
			true-> 
				role_op:send_to_other_client(RoleId,Message);
			_->
				nothing
		end
	end,get(ranks_info)). 

%%
%%֪ͨmanagerս���Ѿ�����
%%
notify_manager_battle_start(BattleType,BattleId)->
	battle_ground_manager:notify_manager_battle_start(?CAMP_BATTLE,{BattleType,BattleId}).

notify_manager_role_leave()->
%%	io:format("notify_manager_role_leave ~n"),
	{BattleType,BattleId,_} = get(camp_info),
	battle_ground_manager:notify_manager_role_leave(?CAMP_BATTLE,{BattleType,BattleId}).

add_role_honor(RoleId,Honor)->
    case lists:keyfind(RoleId,1,get(honor_info)) of
        false->
            [];
        {_,OriHonor}->
		    NewHonor = 
			    if 
					OriHonor+Honor<0 ->
						0;
					OriHonor+Honor>80 ->
						80;
					true ->
						role_pos_util:send_to_role(RoleId, {battle_reward_honor_exp,?CAMP_BATTLE,Honor,0}),
						OriHonor+Honor
				end,
			put(honor_info,lists:keyreplace(RoleId,1,get(honor_info),{RoleId,NewHonor})),
            [{RoleId,NewHonor}]
	end.

get_role_honor(RoleId) ->
    case lists:keyfind(RoleId,1,get(honor_info)) of
        false->
	        0;
        {_,Honor}->
		    Honor
    end.
get_score_rate_by_rank(Rank)->
    if
        Rank=:=1 ->
            5;
        Rank=<3->
            5.5;
        Rank=<6->
            6;
	    Rank=<8->
	        6.5;
	    Rank=<10->
	        7;
	    Rank=<20->
	        8;
	    Rank=<30->
	        9;
	   true->
	        10
    end.

% 获取玩家死亡次数
get_dead_counter() ->
	RoleInfo = get(creature_info),
	case lists:keyfind(?TANGLE_BATTLE, 1, RoleInfo#gm_role_info.battlefield_dead_counter) of
		false ->
			0;
		{?TANGLE_BATTLE, Counter} ->
			Counter
	end.

% 设置玩家死亡次数
set_dead_counter(NewCounter) ->
	RoleInfo = get(creature_info),
	BattlefieldDeadCounterList = RoleInfo#gm_role_info.battlefield_dead_counter,
	case lists:keyfind(?TANGLE_BATTLE, 1, BattlefieldDeadCounterList) of
		false ->
			NewBattlefieldDeadCounterList = BattlefieldDeadCounterList ++ [{?TANGLE_BATTLE, NewCounter}];
		{?TANGLE_BATTLE, _OldCounter} ->
			NewBattlefieldDeadCounterList = lists:keyreplace(?TANGLE_BATTLE, 1, BattlefieldDeadCounterList, {?TANGLE_BATTLE, NewCounter})
	end,
	RoleInfo#gm_role_info{battlefield_dead_counter = NewBattlefieldDeadCounterList}.

% 根据本战场的死亡次数获取相应buffer
get_buffer_list() ->
	DeadCounter = get_dead_counter(),
	case camp_battle_db:get_camp_battlefield_minor_config(DeadCounter) of
		[] ->
			[];
		CampBattlefieldMinorConfigTuple ->
			CampBattlefieldMinorConfigTuple#camp_battlefield_minor_config.buffer_list
	end.

% 初始阵营
get_camp() ->
	FightingPowerList = get(fighting_power),
	case FightingPowerList =:= [] of
		true ->
			lists:nth(random:uniform(2), [?GOD_GROUP, ?DEVIL_GROUP]);
		false ->
			{?GOD_GROUP, GodFightingPower} = lists:keyfind(?GOD_GROUP, 1, FightingPowerList),
			{?DEVIL_GROUP, DevilFightingPower} = lists:keyfind(?DEVIL_GROUP, 1, FightingPowerList),
			if
				GodFightingPower =:= DevilFightingPower ->
					lists:nth(random:uniform(2), [?GOD_GROUP, ?DEVIL_GROUP]);
				GodFightingPower > DevilFightingPower ->
					?DEVIL_GROUP;
				true ->
					?GOD_GROUP
			end
	end.

% 离开本阵营，本阵营战斗力和减少
reduce_camp_fighting_powr(Camp, RoleFightingPower) ->
	FightingPowerList = get(fighting_power),
	{Camp, GodFightingPower} = lists:keyfind(Camp, 1, FightingPowerList),
	put(fighting_power, lists:keyreplace(Camp, 1, FightingPowerList, {Camp, GodFightingPower - RoleFightingPower})).

% 记录离开时间
leave_time(RoleId) ->
	put(role_leave_time, get(role_leave_time) ++ [{RoleId, util:now_sec()}]).

% 获取离开时间
get_leave_time(RoleId) ->
	case lists:keyfind(RoleId, 1, get(role_leave_time)) of
		false ->
			0;
		{RoleId, LevelTime} ->
			LevelTime
	end.
% 记录参加时间
join_time(RoleId) ->
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	JoinTime = Secs+MegaSecs*1000000,
	put(role_join_time,get(role_join_time) ++ [{RoleId, JoinTime}]).

% 获取参加时间
get_join_time(RoleId) ->
	case lists:keyfind(RoleId, 1, get(role_join_time)) of
		false ->
			0;
		{RoleId, JoinTime} ->
			JoinTime
	end.