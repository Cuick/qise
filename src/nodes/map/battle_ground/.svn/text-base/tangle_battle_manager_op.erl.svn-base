%% Author: Administrator
%% Created: 2011-3-8
%% Description: TODO: Add description to tangle_battle_manager_op
-module(tangle_battle_manager_op).
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

%%
%% API Functions
%%

%%
%%tangle_battle_info	
%%battle_xx_xx_info 	{waitinglist,battlelist,initbattlenum}
%%	waitinglist [roleid,...]
%%	battlelist [id,state,node,proc,mapproc,num]
%%	tangle_battle_kill_info:[{tangle_battle_kill_info,{Date,Class,Index},KillInfo}]
%%battle_start
%%
%% initbattlelist 正在初始化中的战场列表 [{battleid,info},...]
%%

init()->
	put(tangle_battle_info,[]),
	put(tangle_battle_records,[]),
	put(battle_state,?BATTLE_STATE_STOP),
	put(battle_50_100_info,{[],[]}),
	put(tangle_battle_kill_info,[]),		%%战场角色击杀信息
	put(tangle_battle_time,{0,0,0}).		%%记录战场开启时间	
	

%%
%%将init状态下的battle切换为start
%%并将排队中的人员加入战场中
%%
%%check_init_battle()->
%%	case get(battle_start) of
%%		true->
%%			change_init_to_start(?STARTBATTLEPRETIME),
%%			erlang:send_after(?INITBATTLETIME_S*1000,self(),{check_init_battle,?TANGLE_BATTLE});
%%		_->
%%			nothing
%%	end.	

on_check()->
	AnswerInfoList = answer_db:get_activity_info(?TANGLE_BATTLE_ACTIVITY),
	CheckFun = fun(AnswerInfo)->
				{Type,TimeLines} = answer_db:get_activity_start(AnswerInfo),
				case timer_util:check_is_time_line(Type,TimeLines,?TANGLE_BATTLE_BUFFER_TIME_S) of
					true->
						on_start_battle(),
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

on_start_battle()->
	case get(battle_state) of
		?BATTLE_STATE_STOP->
			put(battle_state,?BATTLE_STATE_INIT),
			[ActivityInfo | _] = answer_db:get_activity_info(?TANGLE_BATTLE_ACTIVITY),
			Duration = answer_db:get_activity_duration(ActivityInfo),
			self() ! {battle_start_notify,{?TANGLE_BATTLE,Duration}},
			erlang:send_after(Duration + ?TANGLE_BATTLE_BUFFER_TIME_S * 1000,self(),{on_battle_end,?TANGLE_BATTLE}),
			put(tangle_battle_kill_info,[]),
			put(tangle_battle_records,[]);
		_->
			noting			
	end.
 
on_battle_end()->
	MessageBin = battle_ground_packet:encode_tangle_battle_end_s2c(),
	role_pos_util:send_to_all_online_clinet(MessageBin),
	put(battle_state,?BATTLE_STATE_REWARD),
	case get(battle_50_100_info) of
		{[],[]}->
			nothing;
		{Battle,BattleList1}->		
			lists:foreach(fun({Id,State,Node,ProcName,MapProc,_})->
							{ProcName,Node}!{on_destroy},
							put(battle_50_100_info,{Battle,lists:keyreplace(Id,1,BattleList1,{Id,State,Node,ProcName,MapProc,0})})  
							end, BattleList1)
	end.
	
%%
%% kill all battle processor
%%
on_stop_battle()->
%%	io:format("~p on_stop_battle ~p ~n",[?MODULE,get(battle_start)]),
	case get(battle_state) of
		?BATTLE_STATE_STOP->
			nothing;
		_->
			put(battle_state,?BATTLE_STATE_STOP),
			case get(battle_50_100_info) of
				{[],[]}->
					nothing;
				{_,BattleList1}->		
					lists:foreach(fun({_,_,Node,ProcName,MapProc,_})->
							rpc:call(Node,battle_ground_sup,stop_child, [ProcName])	  
							end, BattleList1)
			end,
			init(),
			update_tangle_battle_records(),
			update_tangle_battle_kill_info()
	end.

%%
%% 申请加入战场
%%
apply_for_battle({RoleId,RoleLevel})->
	case get(battle_state) of
		?BATTLE_STATE_START->
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
					slogger:msg("~p apply_for_battle faild ~p ~n",[RoleId,Other]),
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
	case get(battle_state) of
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
	put(battle_state,?BATTLE_STATE_START),
	put(tangle_battle_time,timer_center:get_correct_now()),
	Message = battle_ground_packet:encode_battle_start_s2c(?TANGLE_BATTLE,trunc(Duration/1000)),
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
	Nodes = travel_battle_util:get_travel_battle_map_node(),
	% Nodes = node_util:get_low_load_node(?CANDIDATE_NODES_NUM),
	%%从候选节点中随机选择一个节点
	%%避免所有战场都挤在一个节点的尴尬
	Node = lists:nth(random:uniform(length(Nodes)),Nodes),
	rpc:call(Node,battle_ground_sup,start_child, [tangle_battle,{BattleType,BattleId}]),
	Proc = battle_ground_sup:make_battle_proc_name(tangle_battle,{BattleType,BattleId}),
	MapProc = battle_ground_processor:make_map_proc_name(Proc),
	{BattleId,Node,Proc,MapProc}.
	

get_adapt_battle_ground_info(RoleLevel)->
	if
		(RoleLevel>=30) and (RoleLevel=<100)->
			battle_50_100_info;
		true->
			nothing
	end.

get_adapt_battle_ground_info_for_type(BattleType)->
	case BattleType of
		?TANGLE_BATTLE_50_100->
			battle_50_100_info;
		_->
			nothing
	end.

get_adapt_battle_ground_type(RoleLevel)->
	if
		(RoleLevel>=30) and (RoleLevel=<100)->
			?TANGLE_BATTLE_50_100;
		true->
			0
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
	

%%
%%获取某天战场信息
%%返回给客户端 日志 战场类型 该类型总战场数 role位于哪个战场(没参加为0)
%%
get_role_battle_info({RoleId,Date,BattleType})->
	{TotalBattle,MyBattle} = lists:foldl(fun(Term,{TempTotal,TempBattleId})->
						%%io:format("Term ~p ~n",[Term]),
						{Type,{TempDate,TempType,BattleId},List,_} = Term,
						case (TempDate =:= Date) and (TempType =:= BattleType) and (Type =:= tangle_battle) of
							true->
								NewTempTotal = TempTotal + 1,	
								case tangle_battle:get_role_score(RoleId,List) of
									-1->
										NewTempBattleList = TempBattleId;
									_->
										NewTempBattleList = TempBattleId ++ [BattleId]
								end,
								{NewTempTotal,NewTempBattleList};								
							_->
								{TempTotal,TempBattleId}
						end
			end,{0,[]},get(tangle_battle_records)),
	Message = battle_ground_packet:encode_tangle_records_s2c(Date,BattleType,TotalBattle,MyBattle),
	role_pos_util:send_to_role_clinet(RoleId,Message);

%%
%%获取某天战场详细信息
%%返回指定战场的排名 以及role在该战场中的排名
%%RankInfos,{Year,Month,Day},Class,BattleId,Myrank
get_role_battle_info({RoleId})->
	case get(tangle_battle_records) of
		[{_,_,AllInfo,Has_Reward}] ->
			case tangle_battle:get_role_score(RoleId,AllInfo) of
				-1->
					CanReward = 0,
					MyRank = 0;
				Scroe->
					MyRank = tangle_battle:get_my_rank_by_score(Scroe,AllInfo),
					case lists:member(RoleId, Has_Reward) of
						false->
							CanReward = 1;
						_->
							CanReward = 0
					end
			end,    
			Info = lists:sublist(AllInfo, 10),
			NewInfo = lists:filter(fun({_,_,ScoreTmp,_,_})-> ScoreTmp =/= -1 end,Info),
			FullInfo = lists:map(fun({RoleIdTmp,RoleNameTmp,ScoreTmp,KillsTmp,{ClassTmp,GenderTmp,LevelTmp}})-> battle_ground_packet:make_tangle_battle_role(RoleIdTmp,RoleNameTmp,KillsTmp,ScoreTmp,GenderTmp,ClassTmp,LevelTmp) end,NewInfo),
			Message = battle_ground_packet:encode_tangle_more_records_s2c(FullInfo,MyRank,CanReward);
		_->
			Message = battle_ground_packet:encode_tangle_more_records_s2c([],0,0)
	end,
	role_pos_util:send_to_role_clinet(RoleId,Message).


%%获取自己在某天战场的击杀数据
get_role_battle_kill_info({RoleId,Date,BattleType,BattleId})->
	case get(tangle_battle_records) of
		[{_,_,RankInfo,Has_Reward}] ->
			case get(tangle_battle_kill_info) of
				[{_,_,AllKillInfo}] ->
					case lists:keyfind(RoleId,1,AllKillInfo) of
						false-> 
							Msg = battle_ground_packet:encode_tangle_kill_info_request_s2c(Date,BattleType,BattleId,[],[]);
						{RoleId,{KillInfo,BeKillInfo}}->
							CKillInfo = battle_ground_packet:make_ki(KillInfo,RankInfo),
							CBeKillInfo = battle_ground_packet:make_ki(BeKillInfo,RankInfo),
							Msg = battle_ground_packet:encode_tangle_kill_info_request_s2c(Date,BattleType,BattleId,CKillInfo,CBeKillInfo)
					end;
				_->
					Msg = battle_ground_packet:encode_tangle_kill_info_request_s2c(Date,BattleType,BattleId,[],[])
			end;
		_->
			Msg = battle_ground_packet:encode_tangle_kill_info_request_s2c(Date,BattleType,BattleId,[],[])
	end,
	role_pos_util:send_to_role_clinet(RoleId,Msg).


%%
%%获取指定战场的奖励
%%
get_role_battle_reward(RoleId)->
	case get(tangle_battle_records) of
		[{_,{Date,BattleType,BattleId},AllInfo,Has_Reward}] ->
			case lists:member(RoleId,Has_Reward) of
				false->
					Rewards = tangle_battle:get_reward_by_rankinfo(RoleId,AllInfo),
					NewRewardRecord = Has_Reward ++ [RoleId],
					NewTerm = {tangle_battle,{Date,BattleType,BattleId},AllInfo,NewRewardRecord},
					put(tangle_battle_records,lists:keyreplace({Date,BattleType,BattleId},2,get(tangle_battle_records),NewTerm)),
					tangle_battle_db:sync_add_battle_info(Date,BattleType,BattleId,AllInfo,NewRewardRecord),
					notify_role_tangle_battle_reward(RoleId,Rewards);
				_->
					nothing
			end;
		_->
			nothing
	end.
	
get_reward_error(RoleId)->
	case get(tangle_battle_records) of
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
notify_role_tangle_battle_reward(RoleId,Reward)->
	role_pos_util:send_to_role(RoleId,{battle_reward_from_manager,{?TANGLE_BATTLE,Reward}}).

notify_new_battle_start(RoleList,BattleId,Node,Proc,MapProc)->
	lists:foreach(fun(RoleId)->
				notify_role_join_battle(RoleId,BattleId,Node,Proc,MapProc)
				end,RoleList).	


notify_role_join_battle(Role,BattleId,Node,Proc,MapProc)->
	%%io:format("notify_role_join_battle ~n"),
	role_pos_util:send_to_role(Role,{battle_intive_to_join,{?TANGLE_BATTLE,BattleId,Node,Proc,MapProc}}).		
			
update_tangle_battle_records()->
	case tangle_battle_db:load_tangle_battle_info() of
		[]->
			nothing;
		Infos->
			NowDate = calendar:now_to_local_time(timer_center:get_correct_now()),
			write_tangle_to_log(NowDate,Infos),
			put(tangle_battle_records,Infos)
	end.

update_tangle_battle_kill_info()->
	case tangle_battle_db:load_tangle_battle_kill_info() of
		[]->
			noting;
		Infos->
			put(tangle_battle_kill_info,Infos)
	end.

write_tangle_to_log(NowDate,Infos)->
	{Today,_} = NowDate,
	TodayKillersList = lists:foldl(fun(Term,KillerList)->
										{Type,{Date,Battletype,BattleId},Info,Has_Reward} = Term,
										case Type of
											tangle_battle->
												if
													Date =:= Today->
														NewInfo = lists:filter(fun({_,_,ScoreTmp,_,_})-> ScoreTmp =/= -1 end,Info),
														KillsInfo = lists:map(fun({RoleIdTmp,_,_,KillsTmp,_})->{RoleIdTmp,KillsTmp} end, NewInfo),
														KillerList ++ KillsInfo;
													true->
														KillerList
												end;
											_->
												KillerList			
										end
									end,[],Infos),
	LogLists = 	lists:sublist(lists:reverse(lists:keysort(2, TodayKillersList)), 100 ),
	role_game_rank:hook_on_tangle_kill_log(LogLists),
	gm_logger_role:role_ranks_info(LogLists).

check_battle_time()->
	case get(battle_state) of
		?BATTLE_STATE_START->
			get(tangle_battle_time);
		_->
			{0,0,0}
	end.	

%%
%%获取一个合适的战场编号
%%
get_battle_index(Type)->
	DicKey = 
		case Type of
			?TANGLE_BATTLE_50_100->
				last_index_50100;
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
	
get_tangle_battle_curenum()->
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
	lists:foldl(Func,{0,[]},[battle_50_100_info]).
	
	
			
	
	
	
	
	
	
	
	
	
	
	
	
	
