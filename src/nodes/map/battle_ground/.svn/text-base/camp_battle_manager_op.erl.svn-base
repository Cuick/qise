%% Author: Administrator
%% Created: 2011-3-8
%% Description: TODO: Add description to camp_battle_manager_op
-module(camp_battle_manager_op).
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% Include files
%%
-include("common_define.hrl").
-include("activity_define.hrl").
-include("error_msg.hrl").

%%
%%Define
%%
-define(BATTLE_INIT,1).
-define(BATTLE_START,2).

-define(BATTLE_STATE_START,1).
-define(BATTLE_STATE_STOP,2).
-define(BATTLE_STATE_REWARD,3).
-define(BATTLE_STATE_INIT,4).

-define(MAXPLAYERSINBATTLE,150).		%%每个战场人数上线
-define(INITBATTLETIME_S,2).		%%启动战场时间(秒)	
-define(RECORD_SAVE_DATE,7).		%%战报保存时间(天)
-define(BATTLE_YIN_AND_YANG_INFO_35_49, "battle_yin_and_yang_info_35_49").
-define(BATTLE_YIN_AND_YANG_INFO_50_100, "battle_yin_and_yang_info_50_100").

%%
%% API Functions
%%

%%
%%camp_battle_info	
%%battle_xx_xx_info 	{waitinglist,battlelist,initbattlenum}
%%	waitinglist [roleid,...]
%%	battlelist [id,state,node,proc,mapproc,num]
%%	tangle_battle_kill_info:[{tangle_battle_kill_info,{Date,Class,Index},KillInfo}]
%%battle_start
%%
%% initbattlelist 正在初始化中的战场列表 [{battleid,info},...]
%%

init()->
	put(camp_battle_info,[]),
	put(camp_battle_records,[]),
	put(camp_battle_state,?BATTLE_STATE_STOP),
	put(?BATTLE_YIN_AND_YANG_INFO_35_49,{[],[]}),
	put(?BATTLE_YIN_AND_YANG_INFO_50_100,{[],[]}),
	put(camp_battle_kill_info,[]),		%%战场角色击杀信息
	put(camp_battle_time,{0,0,0}).		%%记录战场开启时间	
	


on_check()->
	AnswerInfoList = answer_db:get_activity_info(?CAMP_BATTLE_ACTIVITY),
	CheckFun = fun(AnswerInfo)->
		{Type,TimeLines} = answer_db:get_activity_start(AnswerInfo),
        case timer_util:check_is_time_line(Type,TimeLines,?CAMP_BATTLE_BUFFER_TIME_S) of
            true->
                Duration = answer_db:get_activity_duration(AnswerInfo),
                on_start_battle(Duration),
                true;
            _->
                false
        end
	end,
	States = lists:map(CheckFun, AnswerInfoList),
	case lists:member(true,States) of
		true->
			nothing;
		_->
			on_stop_battle()
	end.

on_start_battle(Duration)->
	case get(camp_battle_state) of
		?BATTLE_STATE_STOP->
			put(camp_battle_state,?BATTLE_STATE_INIT),
			self() ! {battle_start_notify,{?CAMP_BATTLE,Duration}},
			erlang:send_after(Duration + ?CAMP_BATTLE_BUFFER_TIME_S * 1000,self(),{on_battle_end,?CAMP_BATTLE}),

			put(camp_battle_kill_info,[]),
			put(camp_battle_records,[]);
		State->
			noting			
	end.

pre_end_battle(BattleInfoKey)->
    case get(BattleInfoKey) of
        {[],[]}->
            nothing;
        {Battle,BattleList1}->
            lists:foreach(fun({Id,State,Node,ProcName,MapProc,_})->
                {ProcName,Node}!{on_destroy},
                put(BattleInfoKey,{Battle,lists:keyreplace(Id,1,BattleList1,{Id,State,Node,ProcName,MapProc,0})})  
            end, BattleList1)
    end.

on_battle_end()->
	put(camp_battle_state,?BATTLE_STATE_REWARD),
	camp_battle_db:clear_battle_info(),
	camp_battle_db:clear_player_info(),
	Message = camp_battle_packet:encode_camp_battle_stop_s2c(),
	role_pos_util:send_to_all_online_clinet(Message),
	pre_end_battle(?BATTLE_YIN_AND_YANG_INFO_35_49),
	pre_end_battle(?BATTLE_YIN_AND_YANG_INFO_50_100).
	
%%
%% kill all battle processor
%%
pre_stop_battle(BattleInfoKey)->
    case get(BattleInfoKey) of
	    {[],[]}->
	        nothing;
	    {_,BattleList1}->
	        lists:foreach(fun({_,_,Node,ProcName,MapProc,_})->
	            rpc:call(Node,battle_ground_sup,stop_child, [ProcName])
		    end, BattleList1)
    end.

on_stop_battle()->
%%	io:format("~p on_stop_battle ~p ~n",[?MODULE,get(battle_start)]),
	case get(camp_battle_state) of
		?BATTLE_STATE_STOP->
			nothing;
		_->
			put(camp_battle_state,?BATTLE_STATE_STOP),
			pre_stop_battle(?BATTLE_YIN_AND_YANG_INFO_35_49),
			pre_stop_battle(?BATTLE_YIN_AND_YANG_INFO_50_100),
			init(),
			update_camp_battle_records(),
			update_camp_battle_kill_info()
	end.

%%
%% 申请加入战场:目前每种阵营战只开1个战场,所以BattleList只有1个成员
%%
apply_for_battle({RoleId,RoleLevel})->
	slogger:msg("camp_battle_state is ~p",[get(camp_battle_state)]),
	case get(camp_battle_state) of
		?BATTLE_STATE_START->
%%			io:format("apply_for_battle ~p ~n",[RoleId]),
			BattleInfo = get_adapt_battle_ground_info(RoleLevel),
			BattleType = get_adapt_battle_ground_type(RoleLevel),
			case get(BattleInfo) of
				{[],[]}-> %% 第一个人
					%%开启一个战场
					{BattleId,Node,Proc,MapProc} = start_new_battle(BattleType,get_battle_index(BattleType)),
					%%加入等待列表
					NewWaitingList = [RoleId],
					BattleList = [{BattleId,?BATTLE_INIT,Node,Proc,MapProc,0}],
					put(BattleInfo,{NewWaitingList,BattleList});
				{[],BattleList}-> %%没人在排队
					%%检查是否存在已开启的战场
					case find_best_battle(BattleList) of
						{start,BattleTerm}->
							{BattleId,State,Node,Proc,MapProc,Num} = BattleTerm,
							NewBattleList = [{BattleId,State,Node,Proc,MapProc,Num+1}],
							put(BattleInfo,{[],NewBattleList}),
							%% notify Header join battle
							notify_role_join_battle(RoleId,BattleId,Node,Proc,MapProc);
						{init,BattleTerm}->
							NewWaitingList = [RoleId],
							put(BattleInfo,{NewWaitingList,BattleList}),
							%% 通知客户端排队成功
							notify_client_apply_success(RoleId,?INITBATTLETIME_S);
						_->
							Message = battle_ground_packet:encode_join_battle_error_s2c(?ERRNO_BATTLE_FULL),
							role_pos_util:send_to_role_clinet(RoleId,Message)
					end;
				{WaitingList,BattleList}->		%%有人在排队
					WaitingNum = length(WaitingList),
					if
						WaitingNum < ?MAXPLAYERSINBATTLE ->	%% 够用
							NewWaitingList = WaitingList ++ [RoleId],
							put(BattleInfo,{NewWaitingList,BattleList}),
							%%通知客户端排队成功
							notify_client_apply_success(RoleId,trunc(?INITBATTLETIME_S));
						true->	
							Message = battle_ground_packet:encode_join_battle_error_s2c(?ERRNO_BATTLE_FULL),
							role_pos_util:send_to_role_clinet(RoleId,Message)
					end;
				Other->
					slogger:msg("~p camp_battle_manager_op:apply_for_battle faild ~p ~n",[RoleId,Other]),
					nothing
			end;
		_->
			Msg = battle_ground_packet:encode_battlefield_info_error_s2c(?ERRNO_BATTLE_NOT_START),
			role_pos_util:send_to_role_clinet(RoleId,Msg)
	end.

%%
%%取消申请战场
%%
cancel_apply_battle({RoleId,RoleLevel})->
	case get(camp_battle_state) of
		?BATTLE_STATE_STOP->
			nothing;
		_->
			BattleInfo = get_adapt_battle_ground_info(RoleLevel),
			BattleType = get_adapt_battle_ground_type(RoleLevel),
			{WaitingList,BattleList} = get(BattleInfo),
			case lists:member(RoleId,WaitingList) of
				true->	
					NewWatingList = lists:keydelete(RoleId,1,WaitingList),
					put(BattleInfo,{WaitingList,BattleList});
				false->
					nothing
			end
	end.
%%
%%中途离开战场  留下一个空位
%%
role_leave_battle({BattleType,BattleId})->
	BattleInfo = get_adapt_battle_ground_info_for_type(BattleType),
	case get(BattleInfo) of
		{[],BattleList}->
			BattleTerm = lists:keyfind(BattleId,1,BattleList),
			{_,State,Node,Proc,MapProc,Num} = BattleTerm,
			NewBattleList = [{BattleId,State,Node,Proc,MapProc,Num-1}],
			put(BattleInfo,{[],NewBattleList});
		{WaitingList,BattleList}->
			BattleTerm = lists:keyfind(BattleId,1,BattleList),
			{_,State,Node,Proc,MapProc,Num} = BattleTerm,
			[Header|Last] = WaitingList,
			%% notify Header join battle
			notify_role_join_battle(Header,BattleId,Node,Proc,MapProc),
			NewWaitingList = Last,
			put(BattleInfo,{NewWaitingList,BattleList})
	end.			

battle_start_notify(Duration)->
	put(camp_battle_state,?BATTLE_STATE_START),
	put(camp_battle_time,timer_center:get_correct_now()),
	Message = camp_battle_packet:encode_camp_battle_start_s2c(),
	role_pos_util:send_to_all_online_clinet(Message).
	
%%
%% Local Functions
%%

%%
%%从列表中查找一个合适的战场
%%优先查找已开启战场
%%其实查找正在初始化的战场
%%返回 {start,battleinfo}|
%%		{init,battleinfo}|
%%		{false,[]}
find_best_battle(BattleList)->
	lists:foldl(fun(BattleTerm,{Check,TempInfo})->
		case Check of
			false->
				{_,State,_,_,_,Num} = BattleTerm,
				case State of
					?BATTLE_START->
						if
							Num >= ?MAXPLAYERSINBATTLE ->
								{Check,TempInfo};
							true->
								{start,BattleTerm}
						end;
					?BATTLE_INIT->
								{init,BattleTerm};
							_->
								{Check,TempInfo}
						end;
					init->
						{_,State,_,_,_,Num} = BattleTerm,
						case State of
							?BATTLE_START->
								if
									Num >= ?MAXPLAYERSINBATTLE ->
										{Check,TempInfo};
									true->
										{start,BattleTerm}
								end;
							_->
								{Check,TempInfo}
						end;
					start->
						{Check,TempInfo}
				end
			end,{false,[]},BattleList).

%%
%% 开启一个新战场
%%
start_new_battle(BattleType,BattleId)->
	%%选取候选节点
	Nodes = node_util:get_low_load_node(?CANDIDATE_NODES_NUM),
	%%从候选节点中随机选择一个节点
	%%避免所有战场都挤在一个节点的尴尬
	Node = lists:nth(random:uniform(length(Nodes)),Nodes),
	%Node = lists:nth(1,Nodes),
	rpc:call(Node,battle_ground_sup,start_child, [camp_battle,{BattleType,BattleId}]),
	Proc = battle_ground_sup:make_battle_proc_name(camp_battle,{BattleType,BattleId}),
	MapProc = battle_ground_processor:make_map_proc_name(Proc),
	{BattleId,Node,Proc,MapProc}.
	

get_adapt_battle_ground_info(RoleLevel)->
	if 
		(RoleLevel >= 35) and (RoleLevel < 50) ->
			?BATTLE_YIN_AND_YANG_INFO_35_49;
		(RoleLevel >=50) ->
			?BATTLE_YIN_AND_YANG_INFO_50_100;
		true ->
			error
	end.

get_adapt_battle_ground_info_for_type(BattleType)->
	case BattleType of
		?CAMP_BATTLE_35_49->
			?BATTLE_YIN_AND_YANG_INFO_35_49;
		?CAMP_BATTLE_50_100->
			?BATTLE_YIN_AND_YANG_INFO_50_100
	end.

get_adapt_battle_ground_type(RoleLevel)->
	if
	    (RoleLevel >= 35) and (RoleLevel < 50) ->
		    ?CAMP_BATTLE_35_49;
	    (RoleLevel >=50) ->
	        ?CAMP_BATTLE_50_100;
        true ->
	        error
	end.


%%
%%某战场已开启
%%
notify_manager_battle_start({BattleType,BattleId})->
	BattleInfo = get_adapt_battle_ground_info_for_type(BattleType),
	{WaitingList,BattleList} = get(BattleInfo),
	BattleTerm = lists:keyfind(BattleId,1,BattleList),
	{_,_,Node,Proc,MapProc,_} = BattleTerm,
	WaitingNum = length(WaitingList),
	if
		WaitingNum > ?MAXPLAYERSINBATTLE->
			RoleList = lists:sublist(WaitingList,?MAXPLAYERSINBATTLE),
			NewWaitingList = lists:sublist(WaitingList,?MAXPLAYERSINBATTLE+1,min(?MAXPLAYERSINBATTLE,WaitingNum - ?MAXPLAYERSINBATTLE)),
			notify_new_battle_start(RoleList,BattleId,Node,Proc,MapProc),
			NewBattleList = [{BattleId,?BATTLE_START,Node,Proc,MapProc,?MAXPLAYERSINBATTLE}],
			put(BattleInfo,{NewWaitingList,NewBattleList});
		true->
			notify_new_battle_start(WaitingList,BattleId,Node,Proc,MapProc),
			NewBattleList = [{BattleId,?BATTLE_START,Node,Proc,MapProc,WaitingNum}],
			put(BattleInfo,{[],NewBattleList})
	end.

%%
%%通知客户端排队成功 
%%Time_s 估算等待时间(秒)
%%
notify_client_apply_success(RoleId,Time_s)->
	nothing.
	

%%获取阵营战的人数
get_camp_battle_player_num({RoleId})->
	{PlayerNum1,PlayerMaxNum1} = get_battle_player_num(?CAMP_BATTLE_35_49),
	{PlayerNum2,PlayerMaxNum2} = get_battle_player_num(?CAMP_BATTLE_50_100),
	Result1 = camp_battle_packet:make_camp_battle_playernum(?CAMP_BATTLE_35_49,PlayerNum1,PlayerMaxNum1),
	Result2 = camp_battle_packet:make_camp_battle_playernum(?CAMP_BATTLE_50_100,PlayerNum2,PlayerMaxNum2),
	Message = camp_battle_packet:encode_camp_battle_player_num_s2c([Result1,Result2]),
    role_pos_util:send_to_role_clinet(RoleId,Message).

get_battle_player_num(BattleType)->
	BattleProtoInfo = yybattle_proto_db:get_info(BattleType),
	MaxNum = yybattle_proto_db:get_campplayernum(BattleProtoInfo)*2,
	BattleInfo = get_adapt_battle_ground_info_for_type(BattleType),
	case get(BattleInfo) of
		{_,[]}->
			{0,MaxNum};
	    {_,BattleList}->
			[BattleTerm] = BattleList,
			{_,_,_,_,_,Num} = BattleTerm,
			{Num,MaxNum}
	end.

%%获取阵营战最后一次的日志
get_camp_battle_last_record({RoleId})->
	case get(camp_battle_kill_info) of
		[{_,_,AllKillInfo}]->
			case lists:keyfind(RoleId,1,AllKillInfo) of
				false->
					nothing;
				{RoleId,BattleType,BattleId,KillInfo,BeKilledInfo,Ext}->
					case get(camp_battle_records) of
						[{_,_,AllBattleRecords}]->
							case lists:keyfind({BattleType,BattleId},1,AllBattleRecords) of
								false ->
									nothing;
								{_,PlayerInfo,DeserterInfo,Ascore,Bscore,Anum,Bnum,_} ->
									 Players = lists:map(fun({RoleIdTmp,RoleNameTmp,ScoreTmp,KillsTmp,{ClassTmp,GenderTmp,LevelTmp},CampTmp})-> camp_battle_packet:make_camp_battle_role(RoleIdTmp,RoleNameTmp,LevelTmp,ClassTmp,0,0,[],CampTmp,ScoreTmp) end,PlayerInfo),
									
									 Deserters = lists:map(fun({RoleIdTmp,RoleNameTmp,ScoreTmp,KillsTmp,{ClassTmp,GenderTmp,LevelTmp},CampTmp})-> camp_battle_packet:make_camp_battle_role(RoleIdTmp,RoleNameTmp,LevelTmp,ClassTmp,0,0,[],CampTmp,0) end,DeserterInfo),
									
									 Kills = lists:map(fun({_,BekilledId,BekilledName,BekilledTime,Score,Value})->
										 {_,{H,M,S}} = calendar:now_to_local_time(BekilledTime),
                                         camp_battle_packet:make_camp_battle_record_kill(2,BekilledId,BekilledName,Score,Value,H,M,S) end, KillInfo),
							         BeKills = lists:map(fun({KillerId,KilledNum})->
										 camp_battle_packet:make_camp_battle_record_bekill(KillerId,KilledNum) end, BeKilledInfo),

									 Message = camp_battle_packet:encode_camp_battle_last_record_s2c(Players,Deserters,Kills,BeKills,Ascore,Bscore,Anum,Bnum),
									 role_pos_util:send_to_role_clinet(RoleId,Message);
                                _ ->
									nothing
							end;
						_ ->
							nothing
					end;
				_ ->
					nothing
			end;
		_->
			nothing
	end.

%%
%%获取指定战场的奖励
%%
%get_role_battle_reward(RoleId)->
%	case get(camp_battle_records) of
%		[{_,{Date,BattleType,BattleId},AllInfo,Has_Reward}] ->
%			case lists:member(RoleId,Has_Reward) of
%				false->
%					Rewards = camp_battle:get_reward_by_rankinfo(RoleId,AllInfo),
%					NewRewardRecord = Has_Reward ++ [RoleId],
%					NewTerm = {camp_battle,{Date,BattleType,BattleId},AllInfo,NewRewardRecord},
%					put(camp_battle_records,lists:keyreplace({Date,BattleType,BattleId},2,get(camp_battle_records),NewTerm)),
%					%tangle_battle_db:sync_add_battle_info(Date,BattleType,BattleId,AllInfo,NewRewardRecord),
%					notify_role_camp_battle_reward(RoleId,Rewards);
%				_->
%					nothing
%			end;
%		_->
%			nothing
%	end.
	
get_reward_error(RoleId)->
	case get(camp_battle_records) of
		[{_,{Date,BattleType,BattleId},AllInfo,Has_Reward}] ->
			case lists:member(RoleId,Has_Reward) of
				false->
					ignor;
				_->
					Has_Reward -- [RoleId]
			end;
		_->
			ignor
	end.

%%
%%通知role领取奖励
%%
notify_role_camp_battle_reward(RoleId,Reward)->
	role_pos_util:send_to_role(RoleId,{battle_reward_from_manager,{?CAMP_BATTLE,Reward}}).

notify_new_battle_start(RoleList,BattleId,Node,Proc,MapProc)->
	lists:foreach(fun(RoleId)->
		notify_role_join_battle(RoleId,BattleId,Node,Proc,MapProc)
	end,RoleList).	


notify_role_join_battle(Role,BattleId,Node,Proc,MapProc)->
	%%io:format("notify_role_join_battle ~n"),
	role_pos_util:send_to_role(Role,{battle_intive_to_join,{?CAMP_BATTLE,BattleId,Node,Proc,MapProc}}).		
			
update_camp_battle_records()->
	case camp_battle_db:load_battle_info() of
		[]->
			nothing;
		Infos->
			put(camp_battle_records,Infos)
    end.

update_camp_battle_kill_info()->
	case camp_battle_db:load_player_info() of
		[]->
			noting;
		Infos->
		    put(camp_battle_kill_info,Infos)
	end.

check_battle_time()->
	case get(camp_battle_state) of
		?BATTLE_STATE_START->
			get(camp_battle_time);
		_->
			{0,0,0}
	end.	

%%
%%获取一个合适的战场编号
%%
get_battle_index(Type)->
	DicKey = 
		case Type of
			?CAMP_BATTLE_35_49->
				last_camp_battle_index_35_49;
			?CAMP_BATTLE_50_100->
				last_camp_battle_index_50_100;
			_->
				nothing
		end,
	{NowDate,_} = calendar:now_to_local_time(timer_center:get_correct_now()), 
	case get(DicKey) of
		undefined->
			NewIndex = 1,
			put(DicKey,{NowDate,NewIndex}),
			NewIndex;	
		{Date,Index}->
			if
				NowDate =:= Date ->
					NewIndex = Index+1,
					put(DicKey,{NowDate,NewIndex}),
					NewIndex;	
				true->
					NewIndex = 1,
					put(DicKey,{NowDate,NewIndex}),
					NewIndex
			end
	end.
	
get_camp_battle_curenum()->
	Func = fun(BattleInfo,{BattleId,Acc})->
			case get(BattleInfo) of
				{[],[]}->
					{BattleId+1,Acc};
				{_,BattleList}->
					[{_,State,_,_,_,Num}] = BattleList,
					case State of
						?BATTLE_START->
								{BattleId+1,[{BattleId+1,Num,?MAXPLAYERSINBATTLE}|Acc]}; 
						_->
							{BattleId+1,[{BattleId+1,0,?MAXPLAYERSINBATTLE}|Acc]}
					end
			end
		end,
	lists:foldl(Func,{0,[]},[?BATTLE_YIN_AND_YANG_INFO_35_49,?BATTLE_YIN_AND_YANG_INFO_50_100]).
	
	
			
	
	
	
	
	
	
	
	
	
	
	
	
	
