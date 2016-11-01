%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-19
%%% -------------------------------------------------------------------
-module(role_processor).

-behaviour(gen_fsm).

-export([start_link/2,whereis_role/1]).

-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-export([
	gaming/2, 
	moving/2,
	deading/2,
	singing/2,
	sitting/2]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("map_info_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("skill_define.hrl").
-include("mnesia_table_def.hrl").
-include("error_msg.hrl").
-include("little_garden.hrl").
-include("npc_define.hrl").
-include("pet_struct.hrl").

-compile(export_all).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 关于名字: 
%% 在Erlang中, 所有的通信都可以使用PID来解决, 绑定名字的好处是为了是我们进程通信的时候方便，无需关心PID
%% 所以，我们需要把命名规则给抽取出来放到一个统一的地方
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_link(RoleStartInfo,RoleId)->
	Role_proc_name = role_op:make_role_proc_name(RoleId),	
	gen_fsm:start_link({local, Role_proc_name}, ?MODULE, [RoleStartInfo,RoleId, Role_proc_name], []).

init([{start_copy_role,{MapInfo, RoleInfo, GateInfo, X, Y,AllInfo}},RoleId,_RoleProc]) ->
	base_init(RoleId),
	NewRoleinfo = set_pid_to_roleinfo(RoleInfo, self()),
	role_op:copy_init(MapInfo, NewRoleinfo, GateInfo, X, Y,AllInfo),
	NextState = role_op:get_processor_state_by_roleinfo(),
	% 初始化role_state
	RoleState = role_op:init_role_state(#role_state{}),
	{ok, NextState, RoleState};

%% zhangting  
init([{start_one_role,{GS_system_map_info, GS_system_role_info, GS_system_gate_info,OtherInfo}},RoleId,_RoleProc]) ->
	base_init(RoleId),
	New_gs_system_roleinfo = GS_system_role_info#gs_system_role_info{role_pid=self()},
	role_op:init(GS_system_map_info, GS_system_gate_info, New_gs_system_roleinfo,OtherInfo),
	% 初始化role_state
	RoleState = role_op:init_role_state(#role_state{}),
	{ok, gaming, RoleState}.

%%local base init
base_init(RoleId)->
	put(roleid,RoleId),
	timer_center:start_at_process(),
	{A,B,C} = timer_center:get_correct_now(),
	random:seed(A,B,C).
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 外部函数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
account_charge(Node,ProcName,{account_charge,IncGold,NewGold})->     
	try
		gen_fsm:sync_send_all_state_event({ProcName,Node}, {account_charge,IncGold,NewGold},20000)
	catch
		E:R -> slogger:msg("account_charge ~p E ~p Reason:~p ~n",[ProcName,E,R]),error
	end;

account_charge(Node,ProcName,{gm_account_charge,IncGold,NewGold})->     
	try
		gen_fsm:sync_send_all_state_event({ProcName,Node}, {gm_account_charge,IncGold,NewGold},20000)
	catch
		E:R -> slogger:msg("account_charge ~p E ~p Reason:~p ~n",[ProcName,E,R]),error
	end.
	   	
%% 查询角色是否存在
whereis_role(ProcName) when is_atom(ProcName)->
	case whereis(ProcName) of
		undefined-> undefined;
		_-> ProcName
	end;

whereis_role(RoleId) when is_integer(RoleId)->
	RoleProcName = role_op:make_role_proc_name(RoleId),
	whereis_role(RoleProcName);

whereis_role(_UnknArg) ->
	undefined.
	
other_login(MapNode, RolePid,RoleId)->
	gs_rpc:cast(MapNode,RolePid,{other_login,RoleId}).

%% 事件: 移动开始
role_move_request(RolePid,MoveInfo) ->
	util:send_state_event(RolePid, {role_move_request,MoveInfo}).
		
stop_move_c2s(RolePid, MoveInfo)->
	util:send_state_event(RolePid, {stop_move_c2s,MoveInfo}).
%% 事件: 客户端地图加载完成
map_complete(RolePid) ->
	RolePid	! {map_complete}.

%% 事件: 销毁指定的角色进程
stop_role_processor(RolePid,Tag,RoleId)->
	try
		gen_fsm:sync_send_all_state_event(RolePid, {stop_role_processor,Tag,RoleId},10000)
	catch
		E:Reason->
			slogger:msg("stop_role_processor RolePid RoleId error ~p E ~p R ~p Tag ~p ~n ",[RoleId,E,Reason,Tag]),
			{error,Reason}
	end.
		
stop_role_processor(RoleNode, RoleProc,Tag,RoleId)->
	try
		gen_fsm:sync_send_all_state_event({RoleProc, RoleNode}, {stop_role_processor,Tag,RoleId},10000)
	catch
		E:Reason->
			slogger:msg("stop_role_processor RoleId error ~p E ~p R ~p Tag ~p ~n ",[RoleId,E,Reason,Tag]),
			{error,Reason}
	end.

%% 事件: 反初始化角色进程
uninit_role(Role_node, Role_proc) ->
	util:send_state_event(Role_node, Role_proc, {uninit_role}).

%% 事件: 发起点攻击
start_attack(RolePid, SkillID, TargetID) ->
	util:send_state_event(RolePid, {start_attack, {SkillID, TargetID}}).

shift_pos_request(RolePid, PosX, PosY) ->
	util:send_state_event(RolePid, {shift_pos, PosX, PosY}).

pull_objects_request(RolePid, SkillId, Objects) ->
	util:send_state_event(RolePid, {pull_objects, SkillId, Objects}).

push_objects_request(RolePid, SkillId, Objects) ->
	util:send_state_event(RolePid, {push_objects, SkillId, Objects}).

%% 事件：角色请求接任务
accept_quest_request(RolePid,QuestId)->
	RolePid	!{accept_quest,QuestId}.

%% 事件：角色请求放弃（删除）任务
quit_quest_request_c2s(RolePid,QuestId)->	
	RolePid	!{quit_quest,QuestId}.

%% 事件：角色请求提交任务
submit_quest_request(RolePid,QuestId,ChoiceItem)->
	RolePid	!{submit_quest,QuestId,ChoiceItem}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 					成就系统	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
achieve_open_c2s(RolePid)->
	RolePid ! {achieve_open_c2s}.
achieve_reward_c2s(RolePid,Chapter,Part)->
	RolePid ! {achieve_reward_c2s,{Chapter,Part}}.

%%loop_tower
loop_tower_enter_c2s(RolePid,Layer,Enter,Convey)->
	RolePid ! {loop_tower_enter_c2s,{Layer,Enter,Convey}}.
loop_tower_challenge_c2s(RolePid,Type)->
	RolePid ! {loop_tower_challenge_c2s,{Type}}.
loop_tower_reward_c2s(RolePid,Bonus)->
	RolePid ! {loop_tower_reward_c2s,{Bonus}}.
loop_tower_challenge_again_c2s(RolePid,Type,Again)->
	RolePid ! {loop_tower_challenge_again_c2s,{Type,Again}}.
loop_tower_masters_c2s(RolePid,Master)->
	RolePid ! {loop_tower_masters_c2s,{Master}}.

%%VIP
vip_ui_c2s(RolePid)->
	RolePid ! {vip_ui_c2s}.
vip_reward_c2s(RolePid)->
	RolePid ! {vip_reward_c2s}.
login_bonus_reward_c2s(RolePid)->
	RolePid ! {login_bonus_reward_c2s}.
	
%%answer activity
answer_sign_request_c2s(RolePid)->
	RolePid ! {answer_sign_request_c2s}.
answer_question_c2s(RolePid,Id,Answer,Flag)->
	RolePid ! {answer_question_c2s,Id,Answer,Flag}.
			
use_item(RolePid,SrcSlot)->
	util:send_state_event(RolePid,{use_item,SrcSlot}).
%%	RolePid ! {use_item,SrcSlot}.	
	
chat_message(RolePid,Msg)->	
	RolePid ! {chat_c2s,Msg}.	
	
chat_loudspeaker_queue_num_c2s(RolePid)->
	RolePid ! {chat_loudspeaker_queue_num_c2s}.
	
role_respawn(RolePid,Type)->
	util:send_state_event(RolePid,{role_respawn,Type}).
%%	RolePid ! {role_respawn,Type}.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%任务相关
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
questgiver_accept_quest_c2s(RolePid,NpcId,QuestId)->
	RolePid ! {questgiver_accept_quest_c2s,NpcId,QuestId}.
	
questgiver_hello_c2s(RolePid,NpcId)->
	RolePid ! {questgiver_hello_c2s,NpcId}.
		
quest_quit_c2s(RolePid,QuestId)->
	RolePid ! {quest_quit_c2s,QuestId}.
		
questgiver_complete_quest_c2s(RolePid,Npcid,QuestId,ChoiceItem)->
	RolePid ! {questgiver_complete_quest_c2s,Npcid,QuestId,ChoiceItem}.

quest_details_c2s(RolePid,QuestId)->
	RolePid ! {quest_details_c2s,QuestId}.
		
questgiver_states_update_c2s(RolePid,Npcids)->
	RolePid ! {questgiver_states_update_c2s,Npcids}.

quest_get_adapt_c2s(RolePid)->
	RolePid ! {quest_get_adapt_c2s}.
	
refresh_everquest_c2s(RolePid,EverId,Type,MaxQuality,MaxTimes)->
	RolePid ! {refresh_everquest_c2s,EverId,Type,MaxQuality,MaxTimes}.
	
npc_start_everquest_c2s(RolePid,EverQId,NpcId)->
	RolePid ! {npc_start_everquest_c2s,EverQId,NpcId}.
	
npc_everquests_enum_c2s(RolePid,NpcId)->
	RolePid ! {npc_everquests_enum_c2s,NpcId}.

start_block_training_c2s(RolePid)->
	RolePid ! {block_training_c2s}.
quest_direct_complete_c2s(RolePid,QuestId)->
	RolePid	!{quest_direct_complete_c2s,QuestId}.
role_quest_status_c2s(RolePid, Quests) ->
	RolePid	!{role_quest_status_c2s,Quests}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%							交易相关								%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trade_role_apply_c2s(RolePid,RoleId)->
	RolePid ! {trade_role_apply_c2s,RoleId}.

trade_role_accept_c2s(RolePid,RoleId)->
	RolePid ! {trade_role_accept_c2s,RoleId}.

trade_role_decline_c2s(RolePid,RoleId)->
	RolePid ! {trade_role_decline_c2s,RoleId}.

set_trade_money_c2s(RolePid,MoneyType,MoneyCount)->
	RolePid ! {set_trade_money_c2s,MoneyType,MoneyCount}.

set_trade_item_c2s(RolePid,Trade_slot,Package_slot)->
	RolePid ! {set_trade_item_c2s,Trade_slot,Package_slot}.

trade_role_lock_c2s(RolePid)->
	RolePid ! {trade_role_lock_c2s}.

trade_role_dealit_c2s(RolePid)->
	RolePid ! {trade_role_dealit_c2s}.
	
cancel_trade_c2s(RolePid)->
	RolePid ! {cancel_trade_c2s}.

%%新手祝贺
other_role_congratulations_you(Node,RolePid,Info)->
	try
		gen_fsm:sync_send_all_state_event({RolePid,Node}, {other_role_congratulations_you,Info})
	catch
		E:R->slogger:msg("other_role_congratulations_you Error ~p : ~p ~n",[E,R]),error
	end.

set_leader_to_you(Node,RolePid,GroupInfo)->
	try
		gen_fsm:sync_send_all_state_event({RolePid,Node}, {set_leader_to_you,GroupInfo})
	catch
		_E:_R->error
	end.

gm_get_roleinfo(Node,RolePid,Type)->
	try
		gen_fsm:sync_send_all_state_event({RolePid,Node}, {gm_get_roleinfo,Type})
	catch
		_E:_R->error
	end.

set_group_to_you(Node,RolePid,GroupId)->
	try
		gen_fsm:sync_send_all_state_event({RolePid,Node}, {set_group_to_you,GroupId})
	catch
		E:R->slogger:msg("set_group_to_you Error ~p : ~p ~n",[E,R]),false
	end.


%%交易
trade_finish(RolePid,TradeItems)->	
	try
		gen_fsm:sync_send_all_state_event(RolePid, {trade_finish,TradeItems})
	catch
		E:R->slogger:msg("trade_finish Error ~p : ~p ~n",[E,R]),error
	end.
%%交易,别人成交	
other_deal(RolePid)->
	try
		gen_fsm:sync_send_all_state_event(RolePid, {other_deal})
	catch
		E:R->slogger:msg("other_deal Error ~p : ~p ~n",[E,R]),error
	end.
	
%%双修
companion_sitdown_with_me(RolePid,RoleId)->	
	gen_fsm:sync_send_all_state_event(RolePid,{add_companion_sitdown,RoleId}, 1000).

%%wedding
wedding_with_me(RoleRef,RoleId)->	
	gen_fsm:sync_send_all_state_event(RoleRef,{add_wedding_role,RoleId}, 1000).

wedding_check(RoleRef)->	
	gen_fsm:sync_send_all_state_event(RoleRef,{wedding_check}, 1000).

%% friends
make_friends(RoleRef, FriendName) ->
	gen_fsm:sync_send_all_state_event(RoleRef,{make_friends, FriendName}, 1000).

delete_friends(RoleRef, MyRoleId, MyRoleName, MyClass, MyGender, Intimacy, Status) ->
	gen_fsm:sync_send_all_state_event(RoleRef,{delete_friends, MyRoleId, MyRoleName, 
		MyClass, MyGender, Intimacy, Status}, 1000).

update_friend_status(RoleRef, RoleName, Status, NewStatus) ->
	gen_fsm:sync_send_all_state_event(RoleRef,{update_friend_status, RoleName, Status, NewStatus}, 1000).

%%%%   跳舞
companion_dancing_with_me(RolePid,RoleId)->	
	gen_fsm:sync_send_all_state_event(RolePid,{add_companion_dancing,RoleId}, 1000).

		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%							交易结束								%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%PVP
set_pkmodel_c2s(RolePid,PkModel)->
	RolePid ! {set_pkmodel_c2s,PkModel}.

clear_crime_c2s(RolePid,Type)->
	RolePid ! {clear_crime_c2s,Type}.		
		
%%进入战场
battle_join_c2s(RolePid,Type)->
	RolePid ! {battle_join_c2s,Type}.

%%离开战场	
battle_leave_c2s(RolePid)->
	RolePid ! {battle_leave_c2s}.
	
battle_reward_c2s(RolePid)->
	RolePid ! {battle_reward_c2s}.
	
battle_reward_by_records_c2s(Date,BattleType,BattleId,RolePid)->
	RolePid ! {battle_reward_by_records_c2s,Date,BattleType,BattleId}.

get_instance_log_c2s(RolePid)->
	RolePid ! {get_instance_log_c2s}.

tangle_records_c2s(Date,Class,RolePid)->
	RolePid ! {tangle_records_c2s,Date,Class}.

%%群雄逐鹿击某个玩家杀数据请求
tangle_kill_info_request_c2s(Date,BattleType,BattleId,RolePid)->
	RolePid ! {tangle_kill_info_request_c2s,Date,BattleType,BattleId}.
%%
%%yhzq 战场
%%
join_yhzq_c2s(Reject,RolePid)->
	RolePid ! {join_yhzq_c2s,Reject}.
	
leave_yhzq_c2s(RolePid)->
	RolePid ! {leave_yhzq_c2s}.
	
yhzq_award_c2s(RolePid)->
	RolePid ! {yhzq_award_c2s}.

tangle_more_records_c2s(RolePid)->
	RolePid ! {tangle_more_records_c2s}.
	
%%exchange item
enum_exchange_item_c2s(RolePid,NpcId)->
	RolePid ! {enum_exchange_item_c2s,NpcId}.
	
exchange_item_c2s(RolePid, NpcID, ItemClsid, Count, Slots) ->
	RolePid ! {exchange_item_c2s, NpcID, ItemClsid, Count, Slots}.

%%限时礼包
get_timelimit_gift_c2s(RolePid)->
	RolePid ! {get_timelimit_gift_c2s}.
	
%%新手卡	
gift_card_apply_c2s(RolePid,Key,Type)->
	RolePid ! {gift_card_apply_c2s,Key,Type}.

% 副本奖励
duplicate_prize_item(RolePid) ->
	RolePid ! duplicate_prize_item.

duplicate_prize_get(Message,RolePid) ->
	RolePid ! {duplicate_prize_get,Message}.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 事件: 角色初始化		修改为同步在init里调用
%%gaming({init_role, {GS_system_map_info, GS_system_role_info, GS_system_gate_info,OtherInfo}}, StateData) ->
%%	role_op:init(GS_system_map_info, GS_system_gate_info, GS_system_role_info,OtherInfo),	
%%	{next_state, gaming, StateData};

%% 事件: 角色移动请求
gaming({role_move_request,MoveInfo}, StateData) ->	
	%%1. 去MapDB服务器查询路径数据是否合法;
	case get(is_in_world) of
		true->
			RoleInfo = get(creature_info),
			MapInfo = get(map_info),
			role_op:move_request(RoleInfo, MapInfo, MoveInfo, role_op:can_move(RoleInfo));
		_ ->
			nothing
	end,		
	{next_state, moving, StateData};

gaming({stop_move_c2s,MoveInfo}, StateData) ->	
	%%1. 去MapDB服务器查询路径数据是否合法;
	case get(is_in_world) of
		true->
			role_op:stop_move_c2s(MoveInfo);
		_ ->
			nothing
	end,		
	{next_state, gaming, StateData};


gaming({start_attack, {SkillID, TargetID}}, State) ->
	%% 移动请求
	NextState = case get(is_in_world) of
		true->					
			role_op:start_attack(SkillID, TargetID);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

gaming({shift_pos, PosX, PosY}, State) ->
	NextState = case get(is_in_world) of
		true->					
			role_op:shift_pos(PosX, PosY);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

gaming({pull_objects, SkillId, Objects}, State) ->
	NextState = case get(is_in_world) of
		true->					
			role_op:pull_objects(SkillId, Objects);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

gaming({push_objects, SkillId, Objects}, State) ->
	NextState = case get(is_in_world) of
		true->					
			role_op:push_objects(SkillId, Objects);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

gaming({use_item,SrcSlot}, State) ->
	role_op:handle_use_item(SrcSlot),
	{next_state,gaming, State};

gaming({sitdown_c2s,RoleId},StateData) ->
	case role_sitdown_op:can_sitdown() of
		true->
			role_sitdown_op:handle_start_sitdown_with_role(RoleId),
			State = sitting;
		_->
			State = gaming,
			nothing
	end,	        
	{next_state, State, StateData};


gaming(_Event, StateData) ->        
	{next_state, gaming, StateData}.
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态: 移动
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 事件: 开始移动

moving({move_admend_path,Path}, State) ->
	RoleInfo = get(creature_info),
	case  role_op:can_move(RoleInfo) of
		true->
			role_op:move_admend_path(Path),
			NextState= moving;
		false->
			NextState = gaming
	end,
	{next_state, NextState, State};

%% 已经在移动了, 提前请求下一段路径
moving({role_move_request, Path}, StateData) ->
	case get(is_in_world) of
		true->
			MapInfo = get(map_info),
			RoleInfo = get(creature_info),
			role_op:move_request(RoleInfo, MapInfo, Path, role_op:can_move(RoleInfo));
		_ ->
			nothing
	end,		
	{next_state, moving, StateData};

moving({stop_move_c2s,MoveInfo}, StateData) ->	
	%%1. 去MapDB服务器查询路径数据是否合法;
	case get(is_in_world) of
		true->
			role_op:stop_move_c2s(MoveInfo);
		_ ->
			nothing
	end,		
	{next_state, gaming, StateData};

moving({start_attack, {SkillID, TargetID}}, State) ->
	%% 移动请求
	NextState = case get(is_in_world) of
		true->					
			role_op:start_attack(SkillID, TargetID);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

moving({shift_pos, PosX, PosY}, State) ->
	NextState = case get(is_in_world) of
		true->					
			role_op:shift_pos(PosX, PosY);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

moving({pull_objects, SkillId, Objects}, State) ->
	NextState = case get(is_in_world) of
		true->					
			role_op:pull_objects(SkillId, Objects);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

moving({push_objects, SkillId, Objects}, State) ->
	NextState = case get(is_in_world) of
		true->					
			role_op:push_objects(SkillId, Objects);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

moving({use_item,SrcSlot}, State) ->
	NextState = case get(is_in_world) of
		true->					
			role_op:handle_use_item(SrcSlot);
		_ ->
			nothing	
	end,	
	{next_state,moving, State};

moving({sitdown_c2s,RoleId},StateData) ->        
	case role_sitdown_op:can_sitdown() of
		true->
			role_sitdown_op:handle_start_sitdown_with_role(RoleId),
			State = sitting;
		_->
			State = moving,
			nothing
	end,	        
	{next_state, State, StateData};

moving({dancing_start,RoleId},StateData) ->
    case banquet_op:can_companion_dancing() of
    	true ->
			banquet_op:companion_dancing_start(RoleId);
		_ -> 
			nothing
	end,
	{next_state, moving, StateData};

moving(Event, State) ->
	{next_state, moving, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态: 吟唱
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 事件: 吟唱结束
singing({sing_complete, TargetID, SkillID, SkillLevel, FlyTime}, State) ->
	%% 进入施法阶段
	case get(is_in_world) of
		true->			
			RoleInfo = get(creature_info),
			role_op:process_sing_complete(RoleInfo, TargetID, SkillID, SkillLevel, FlyTime);
		_ ->			
			nothing
	end,		
	{next_state, gaming, State};

singing({role_move_request, Path}, State) ->
	%% 移动请求
	case get(is_in_world) of
		true->
			SelfId = get(roleid),
			role_op:process_cancel_attack(SelfId, move),
			util:send_state_event(self(), {role_move_request, Path});
		_ ->
			nothing
	end,			
	{next_state, gaming, State};

singing({stop_move_c2s,MoveInfo}, StateData) ->	
	%%1. 去MapDB服务器查询路径数据是否合法;
	case get(is_in_world) of
		true->
			SelfId = get(roleid),
			role_op:process_cancel_attack(SelfId, move),
			util:send_state_event(self(), {stop_move_c2s, MoveInfo});
		_ ->
			nothing
	end,		
	{next_state, gaming, StateData};

singing({start_attack, {SkillID, TargetID}}, State) ->
	%% 移动请求
	case get(is_in_world) of
		true->
			case combat_op:get_singing_skill() of
				SkillID->			%%吟唱相同技能,忽略
					NextState = gaming;
				_->
					SelfId = get(roleid),
					role_op:process_cancel_attack(SelfId, move),
					NextState = role_op:start_attack(SkillID, TargetID)
			end;	
		_ ->
			NextState = gaming
	end,			
	{next_state, NextState, State};

singing({shift_pos, PosX, PosY}, State) ->
	NextState = case get(is_in_world) of
		true->
			SelfId = get(roleid),
			role_op:process_cancel_attack(SelfId, move),				
			role_op:shift_pos(PosX, PosY);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

singing({pull_objects, SkillId, Objects}, State) ->
	NextState = case get(is_in_world) of
		true->	
			SelfId = get(roleid),
			role_op:process_cancel_attack(SelfId, move),				
			role_op:pull_objects(SkillId, Objects);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

singing({push_objects, SkillId, Objects}, State) ->
	NextState = case get(is_in_world) of
		true->	
			SelfId = get(roleid),
			role_op:process_cancel_attack(SelfId, move),				
			role_op:push_objects(SkillId, Objects);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

singing({use_item,SrcSlot}, State) ->
	SelfId = get(roleid),
	role_op:process_cancel_attack(SelfId, move),					
	util:send_state_event(self(),{use_item,SrcSlot}),
	{next_state,gaming, State};
	
singing({interrupt_by_buff},State) ->
	SelfId = get(roleid),
	role_op:process_cancel_attack(SelfId, interrupt_by_buff),
	{next_state, gaming, State};	

singing(Event, State) ->
	{next_state, singing, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%			打坐状态
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sitting({use_item,SrcSlot}, State) ->
	role_sitdown_op:interrupt_sitdown_with_processor_state_change(),			
	util:send_state_event(self(),{use_item,SrcSlot}),
	{next_state,gaming, State};
	
sitting({role_move_request, Path}, State) ->
	%% 移动请求
	case get(is_in_world) of
		true->
			role_sitdown_op:interrupt_sitdown_with_processor_state_change(),
			util:send_state_event(self(), {role_move_request, Path});
		_ ->
			nothing
	end,			
	{next_state, gaming, State};

sitting({stop_move_c2s,MoveInfo}, StateData) ->	
	%%1. 去MapDB服务器查询路径数据是否合法;
	case get(is_in_world) of
		true->
			role_sitdown_op:interrupt_sitdown_with_processor_state_change(),
			util:send_state_event(self(), {stop_move_c2s, MoveInfo});
		_ ->
			nothing
	end,		
	{next_state, gaming, StateData};

sitting({start_attack, {SkillID, TargetID}}, State) ->
	%% 移动请求
	case get(is_in_world) of
		true->
			role_sitdown_op:interrupt_sitdown_with_processor_state_change(),
			NextState = role_op:start_attack(SkillID, TargetID);
		_ ->
			NextState = gaming,
			nothing
	end,			
	{next_state, NextState, State};

sitting({shift_pos, PosX, PosY}, State) ->
	NextState = case get(is_in_world) of
		true->
			role_sitdown_op:interrupt_sitdown_with_processor_state_change(),			
			role_op:shift_pos(PosX, PosY);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

sitting({pull_objects, SkillId, Objects}, State) ->
	NextState = case get(is_in_world) of
		true->	
			role_sitdown_op:interrupt_sitdown_with_processor_state_change(),				
			role_op:pull_objects(SkillId, Objects);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

sitting({push_objects, SkillId, Objects}, State) ->
	NextState = case get(is_in_world) of
		true->		
			role_sitdown_op:interrupt_sitdown_with_processor_state_change(),			
			role_op:push_objects(SkillId, Objects);
		_ ->
			gaming
	end,			
	{next_state, NextState, State};

sitting({interrupt_by_buff},State) ->
	role_sitdown_op:interrupt_sitdown_with_processor_state_change(),
	{next_state, gaming, State};
	
sitting({interrupt_sitdown},State) ->
	role_sitdown_op:interrupt_sitdown_with_processor_state_change(),
	{next_state, gaming, State};

sitting(stop_sitdown_c2s,State) ->
	role_sitdown_op:interrupt_sitdown_with_processor_state_change(),
	{next_state, gaming, State};
	
sitting({del_companion_sitdown,Info},State) ->
	role_sitdown_op:handle_other_role_msg(del_companion_sitdown,Info),
	{next_state, sitting, State};

sitting({sitdown_c2s,RoleId},State) ->        
	role_sitdown_op:handle_start_sitdown_with_role(RoleId),       
	{next_state, sitting, State};
	
sitting(_Event, State) ->
	{next_state,sitting, State}.


	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 状态: 挂了
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deading({role_respawn,Type}, State) ->
	role_op:proc_aplly_role_respawn(Type),
	NextState = role_op:get_processor_state_by_roleinfo(), 
	{next_state, NextState, State};

deading({respawn_self,Type}, State) ->
	role_op:respawn_self(Type),
	{next_state, gaming, State};

deading(Event, State) ->
	{next_state, deading, State}.

cleanuping(Event, State) ->
	{next_state, cleanuping, State}.	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理其他事件
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_event(Event, StateName, StateData) ->
	{next_state, StateName, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理同步事件调用
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%交易确认
handle_sync_event({other_deal}, From, StateName, StateData) ->
	Replay = 
	try
		trade_role:trade_role(other_deal),
		ok
	catch
		E:R-> slogger:msg("handle_sync_event trade_finish error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
		error
	end,
	{reply, Replay, StateName, StateData};
%%交易达成
handle_sync_event({trade_finish,TradeItems}, From, StateName, StateData) ->
	Replay = 
	try
		{ok,trade_role:self_finish(TradeItems)}
	catch
		E:R-> slogger:msg("handle_sync_event trade_finish error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
		error
	end,
	{reply, Replay, StateName, StateData};

handle_sync_event({set_leader_to_you,GroupInfo},From, StateName, StateData) ->
	Replay = 
	try
		group_op:set_me_leader(GroupInfo)
	catch
		E:R-> slogger:msg("handle_sync_event set_leader_to_you error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
		error
	end,
	{reply, Replay, StateName, StateData};

handle_sync_event({gm_get_roleinfo,Type},From, StateName, StateData) ->
	Replay = 
	try
		case Type of
			1 ->
				get(creature_info);
			2 ->
				get(items_info);
			3 ->
				get(storages_info)
		end
	catch
		E:R-> slogger:msg("handle_sync_event set_leader_to_you error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
		error
	end,
	{reply, Replay, StateName, StateData};

handle_sync_event({set_group_to_you,GroupId},From, StateName, StateData) ->
	Replay = 
	try
		group_op:set_group_to_you(GroupId)
	catch
		E:R-> slogger:msg("handle_sync_event set_group_to_you error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
		false
	end,
	{reply, Replay, StateName, StateData};

%%停止进程
handle_sync_event({stop_role_processor,Tag,RoleId}, From, StateName, StateData) ->
	case Tag of
		other_login->
			role_op:handle_other_login(RoleId);
		uninit->
			role_op:kick_out(RoleId);
		_->			
			role_op:do_cleanup(Tag,RoleId)			
	end,
	{reply, ok, cleanuping, StateData};
	
handle_sync_event({account_charge,IncGold,NewGold}, From, StateName, StateData) ->
	role_op:account_charge(IncGold,NewGold),
	{reply, ok, StateName, StateData};

handle_sync_event({gm_account_charge,IncGold,NewGold}, From, StateName, StateData) ->
	role_op:gm_account_charge(IncGold,NewGold),
	{reply, ok, StateName, StateData};
	
% handle_sync_event({first_charge_gift,State}, From, StateName, StateData) ->	
% 	first_charge_gift_op:reinit(State),
% 	{reply, ok, StateName, StateData};
	
handle_sync_event({get_state}, _From, StateName, StateData) ->
    Reply = StateName,
    {reply, Reply, StateName, StateData};		

handle_sync_event({other_role_congratulations_you,Info},From, StateName, StateData) ->
	Replay = 
	try
		congratulations_op:other_role_congratulations_you(Info)
	catch
		E:R-> slogger:msg("handle_sync_event other_role_congratulations_you error ~p ~p ~p ~n",[E,R,erlang:get_stacktrace()]),
		error
	end,
	{reply, Replay, StateName, StateData};
	
handle_sync_event({facebook_quest_update,MsgId},From, StateName, StateData) ->	
	quest_special_msg:proc_specail_msg({facebook_quest_state,MsgId}),
	{reply, ok, StateName, StateData};

handle_sync_event({add_companion_sitdown,RoleId}, From, StateName, StateData) ->
	Reply = role_sitdown_op:handle_other_role_msg(add_companion_sitdown,RoleId),
	{reply, Reply, StateName, StateData};

handle_sync_event({add_wedding_role,RoleId}, From, StateName, StateData) ->
	Reply = wedding_handle:handle_other_role_msg({add_wedding_role,RoleId}),
	{reply, Reply, StateName, StateData};
	
handle_sync_event({wedding_check}, From, StateName, StateData) ->
	Reply = wedding_handle:handle_other_role_msg({wedding_check}),
	{reply, Reply, StateName, StateData};

handle_sync_event({make_friends, FriendName}, From, StateName, StateData) ->
	Reply = friend_op:make_friends(FriendName),
	{reply, Reply, StateName, StateData};

handle_sync_event({delete_friends, MyRoleId, MyRoleName, MyClass, MyGender, Intimacy, Status}, 
	From, StateName, StateData) ->
	Reply = friend_op:delete_friends(MyRoleId, MyRoleName, MyClass, MyGender, Intimacy, Status),
	{reply, Reply, StateName, StateData};

handle_sync_event({update_friend_status, RoleName, Status, NewStatus}, From, StateName, StateData) ->
	Reply = friend_op:update_friend_status(RoleName, Status, NewStatus),
	{reply, Reply, StateName, StateData};

handle_sync_event({add_companion_dancing,RoleId}, From, StateName, StateData) ->
	Reply = banquet_op:handle_other_role_msg(add_companion_dancing,RoleId),
	{reply, Reply, StateName, StateData};

handle_sync_event(Event, From, StateName, StateData) ->
	Reply = ok,
	{reply, Reply, StateName, StateData}.

  
%%  
%%完成注册
%%  
 finish_visitor(RolePid,AccountName)->
   RolePid ! {finish_visitor,AccountName}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理其他进程消息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%test
% handle_info({pet,N,Msg}, StateName, StateData) ->
% 	pet_handle:do(N,Msg),
% 	{next_state, StateName, StateData};


handle_info({get_state}, StateName, StateData) ->
	{next_state, StateName, StateData};

handle_info(Event, cleanuping, StateData) ->
	{next_state, cleanuping, StateData};

handle_info({map_complete}, StateName, StateData) ->
	SelfInfo = get(creature_info),
	MapInfo = get(map_info),
	role_op:map_complete(SelfInfo, MapInfo),
	NewState = role_op:get_processor_state_by_roleinfo(),
	{next_state, NewState, StateData};
	
handle_info({directly_send, Message}, StateName, StateData) ->
	role_op:send_data_to_gate(Message),
	{next_state, StateName, StateData};

handle_info({be_add_buffer, Buffers,CasterInfo}, StateName, StateData) ->
	if
		(StateName =/= deading)-> 
			role_op:be_add_buffer(Buffers,CasterInfo);
		true->
			nothing
	end,
	{next_state, StateName, StateData};	

handle_info({timer_check ,NowTime}, StateName, StateData)->
	RoleInfo = get(creature_info),
	LastTick = get(last_tick),
	role_op:timer_check(RoleInfo, LastTick, NowTime),
	{next_state, StateName, StateData};

handle_info({other_into_view, OtherId}, StateName, StateData) ->
	case creature_op:get_creature_info(OtherId) of
		undefined ->
			nothing;
		OtherInfo->	
			creature_op:handle_other_into_view(OtherInfo)
	end,
	{next_state, StateName, StateData};

handle_info({other_outof_view, OtherId}, StateName, StateData) ->
	role_op:other_outof_view(OtherId),
	{next_state, StateName, StateData};
	
handle_info({other_be_attacked,AttackInfo}, StateName, State) ->
	if
		StateName =:= sitting->
			role_sitdown_op:hook_on_action_sync_interrupt(timer_center:get_correct_now(),be_attacked),
			NextState = role_op:other_be_attacked(AttackInfo, get(creature_info));
		StateName =/= deading -> 
			NextState = role_op:other_be_attacked(AttackInfo, get(creature_info));
		true->
			NextState = StateName
	end,	
	{next_state, NextState, State};

handle_info({pull_or_push, NewPos}, StateName, State) ->
	role_op:shift_pos2(NewPos),
	timer:sleep(?PULL_OR_PUSH_DELAY),
	{next_state, StateName, State};

handle_info({other_be_killed, Message}, StateName, State) ->
	role_op:other_be_killed(Message),
	{next_state, StateName, State};

%%取消buff
handle_info({cancel_buff_c2s,BuffId}, StateName, StateData) ->
	buffer_op:cancel_buff_c2s(BuffId),
	{next_state, StateName, StateData};

handle_info({change_pet_sex,Sex,PetId}, StateName, StateData) ->
	item_obt_pet:change_pet_sex(Sex,PetId),
	{next_state, StateName, StateData};

handle_info({feedback_info_c2s,Type,Title,Message,ContactWay}, StateName, StateData) ->
	CurInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(CurInfo),
  	RoleName = get_name_from_roleinfo(CurInfo),
  	feedback_op:submit_feedback(RoleName,RoleID,Type, Title,Message,ContactWay),	
	{next_state, StateName, StateData};
	
	
handle_info({role_packet,Message}, StateName, StateData)->
	role_handle:process_client_msg(Message),
	{next_state, StateName, StateData};

handle_info({instance_from_client, Message}, StateName, StateData) ->
	instance_handle:process_client_msg(Message),
	{next_state, StateName, StateData};

handle_info({wedding_from_client,Message}, StateName, StateData)->
	wedding_handle:process_client_msg(Message),
	{next_state, StateName, StateData};


%%%%%%%%%%%%%%%%%%
%% 商城开始
%%%%%%%%%%%%%%%%%
	
%% 事件： 获取商城物品列表
handle_info({process_mall,Message},StateName, State) ->
	mall_packet:process_mall(Message),
	{next_state, StateName, State};
	
%%%%%%%%%%%%%%%%%%
%% 好友
%%%%%%%%%%%%%%%%%	
handle_info({friend,Message},StateName, State) ->
	friend_packet:process_friend(Message),
	{next_state, StateName, State};

handle_info({friend_add_intimacy, RoleId, Intimacy}, StateName, State)->
	friend_op:friend_add_intimacy(RoleId, Intimacy),
	{next_state, StateName, State};

handle_info({delete_friend_directly, RoleId}, StateName, State)->
	friend_op:delete_friend_directly(RoleId),
	{next_state, StateName, State};

handle_info({check_activity_awards, ActivityId}, StateName, State) ->
	top_bar_manager_op:check_activity_awards(ActivityId),
	{next_state, StateName, State};

handle_info({double_exp_end}, StateName, State) ->
	role_op:update_double_exp(false),
	{next_state, StateName, State};

handle_info({double_exp_start}, StateName, State) ->
	role_op:update_double_exp(true),
	{next_state, StateName, State};

handle_info({open_charge_feedback,Message},StateName,State)->
	open_charge_feedback_handle:process_msg(Message),
	{next_state, StateName, State};	
	
%%%%%%%%%%%%%%%%%%
%% 装备
%%%%%%%%%%%%%%%%%
handle_info({equipment,Message},StateName,State)->
	try 
		equipment_packet:process_equipment(Message) 
	catch
		Type:Error ->
		slogger:msg("ERROR equipment batch ~p and ~p ~n", [Type, Error])
	end,
	% equipment_packet:process_equipment(Message),
	{next_state, StateName, State};		
%%SPA
handle_info({banquet,Message},StateName,State)->
	banquet_packet:process_banquet(Message),
	{next_state, StateName, State};	

handle_info({dead_valley,Message},StateName,State)->
	dead_valley_handle:process_msg(Message),
	{next_state, StateName, State};

handle_info({dead_valley_points, Points}, StateName, State) ->
	dead_valley_op:update_points(Points),
	{next_state, StateName, State};

handle_info({dead_valley_trap_show, SelfId}, StateName, State) ->
	dead_valley_op:touch_trap(SelfId),
	{next_state, StateName, SelfId};

handle_info({dead_valley_trap_hide, SelfId}, StateName, State) ->
	dead_valley_op:leave_trap(SelfId),
	{next_state, StateName, SelfId};

handle_info({dead_valley_pick_up_equipment, EquipmentInfo}, StateName, State) ->
	dead_valley_op:add_equipment_to_package(EquipmentInfo),
	{next_state, StateName, State};

handle_info({kick_from_dead_valley}, StateName, State) ->
	dead_valley_op:leave_map(),
	{next_state, StateName, State};

handle_info({travel_battle,Message},StateName,State)->
	travel_battle_handle:process_msg(Message),
	{next_state, StateName, State};

handle_info({travel_match,Message},StateName,State)->
	travel_match_handle:process_msg(Message),
	{next_state, StateName, State};

handle_info({travel_battle_register_wait, State2, Num}, StateName, State) ->
	travel_battle_op:register_wait(State2, Num),		
	{next_state, StateName, State};	

handle_info({travel_battle_join_instance, InstanceId, Pos}, StateName, State) ->
	travel_battle_op:join_instance(InstanceId, Pos),		
	{next_state, StateName, State};	

handle_info({kick_from_travel_battle_section, Result}, _, State) ->
	StateName = travel_battle_op:do_section_end(Result),		
	{next_state, StateName, State};	

handle_info({travel_match_join_instance, InstanceProc, LineId, MapId, Pos}, StateName, State) ->
	travel_match_op:join_instance(InstanceProc, LineId, MapId, Pos),
	{next_state, StateName, State};	

handle_info({travel_match_luck_win}, StateName, State) ->
	travel_match_op:luck_win(),
	{next_state, StateName, State};	

handle_info({travel_match_battle_end}, StateName, State) ->
	travel_match_op:section_end(),
	{next_state, StateName, State};	

handle_info({travel_match_stage_end}, StateName, State) ->
	travel_match_op:stage_end(),
	{next_state, StateName, State};	

handle_info({kick_from_travel_battle_stage, RoleNode, MapId, MapProc, LineId, Pos, Rank}, StateName, State) ->
	travel_battle_op:do_stage_end(RoleNode, MapId, MapProc, LineId, Pos, Rank),		
	{next_state, StateName, State};	

handle_info({open_service_auction,Message},StateName,State)->
	open_service_auction_handle:process_msg(Message),
	{next_state, StateName, State};	

handle_info({query_open_service_time},StateName,State)->
	role_op:query_open_service_time(),
	{next_state, StateName, State};	
	
handle_info({banquet_apply_stop_player},StateName,State)->
	banquet_op:banquet_apply_stop_player(),
	{next_state, StateName, State};
handle_info({handle_banquet_touch,Type,Message},StateName,State)->
	banquet_op:handle_banquet_touch(Type,Message),
	{next_state, StateName, State};
handle_info({handle_be_banquet_touch,Type,Message},StateName,State)->
	banquet_op:handle_be_banquet_touch(Type,Message),
	{next_state, StateName, State};
handle_info({handle_pet_swanking,_,Message},StateName,State)->
	banquet_op:handle_pet_swanking(Message),
	{next_state, StateName, State};
	
%%jszd_battle
handle_info({jszd_battle,Message},StateName,State)->
	battle_jszd_packet:process_jszd_battle(Message),
	{next_state, StateName, State};

handle_info({battle_reward_honor_exp,Battle,Honor,Exp},StateName,State)->
	battle_ground_op:battle_reward_honor_exp(Battle,Honor,Exp),
	{next_state, StateName, State};

%%双修
handle_info({companion_sitdown,Msg},StateName,State)->
	role_sitdown_op:handle_companion_sitdown(Msg),		
	{next_state, StateName, State};		
	
%%%%%%%%%%%%%%%%%%
%% 成就开始
%%%%%%%%%%%%%%%%%	
handle_info({achieve_open_c2s},StateName, State) ->
	achieve_op:achieve_open(),
	{next_state, StateName, State};	
handle_info({achieve_reward_c2s,{Chapter,Part}},StateName, State) ->
	achieve_op:achieve_reward(Chapter,Part),
	{next_state, StateName, State};	
	
%%目标
handle_info({goals,Message},StateName,State)->
	goals_packet:process_goals(Message),
	{next_state, StateName, State};
	
%%loop tower
handle_info({loop_tower_enter_c2s,{Layer,Enter,Convey}},StateName, State) ->
	loop_tower_op:loop_tower_enter(Layer,Enter,Convey),
	{next_state, StateName, State};	
handle_info({loop_tower_challenge_c2s,{Type}},StateName, State) ->
	loop_tower_op:loop_tower_challenge(Type),
	{next_state, StateName, State};	
handle_info({loop_tower_reward_c2s,{Bonus}},StateName, State) ->
	loop_tower_op:loop_tower_reward(Bonus),
	{next_state, StateName, State};	
handle_info({loop_tower_challenge_again_c2s,{Type,Again}},StateName, State) ->
	loop_tower_op:loop_tower_challenge_again(Type,Again),
	{next_state, StateName, State};	
handle_info({loop_tower_masters_c2s,{Master}},StateName, State) ->
	loop_tower_op:loop_tower_masters_c2s(Master),
	{next_state, StateName, State};
	
%%VIP
handle_info({vip_ui_c2s},StateName, State) ->
	vip_op:vip_ui_c2s(),
	{next_state, StateName, State};
handle_info({vip_reward_c2s},StateName, State) ->
	vip_op:vip_reward_c2s(),
	{next_state, StateName, State};
handle_info({login_bonus_reward_c2s},StateName, State) ->
	vip_op:login_bonus_reward_c2s(),
	{next_state, StateName, State};
	
handle_info({vip,Message},StateName, State) ->
	vip_packet:process_msg(Message),
	{next_state, StateName, State};

%%exchange item
handle_info({enum_exchange_item_c2s, NpcID}, StateName, StateData) ->
	exchange_op:enum_exchange_item(get(creature_info), NpcID),
	{next_state, StateName, StateData};
handle_info({exchange_item_c2s, NpcID, ItemClsid, Count, Slots}, StateName, StateData) ->
	case get(is_in_world) of
		true->
			exchange_op:exchange_item(get(creature_info), ItemClsid, Count, NpcID, Slots);
		_ ->
			nothing		
	end,	
	{next_state, StateName, StateData};

%%answer activity
handle_info({answer_sign_request_c2s}, StateName, StateData) ->
	answer_op:answer_sign_request_c2s(),	
	{next_state, StateName, StateData};
handle_info({answer_question_c2s,Id,Answer,Flag}, StateName, StateData) ->
	answer_op:answer_question_c2s(Id,Answer,Flag),	
	{next_state, StateName, StateData};
	

%% 事件:	 掉落删除{delete_loot, }
handle_info({delete_loot,{PacketId,Statu}}, StateName, State) ->
	role_op:delete_loot(PacketId,Statu),
	{next_state, StateName, State};	

%%染红怪物被我杀死
handle_info({creature_killed,{NpcId,ProtoId,DeadPos,TeamShare,QuestShareRoles}}, StateName, State) ->
	role_op:on_creature_killed(NpcId,ProtoId,DeadPos,TeamShare,QuestShareRoles),
	{next_state, StateName, State};

%%aoi队友杀死怪物,分享	
handle_info({teamate_killed,{NpcId,ProtoId,Pos,Money,Exp}}, StateName, State) ->
	role_op:teams_loot(NpcId,ProtoId,Pos,Money,Exp),
	{next_state, StateName, State};	

%%aoi怪物任务分享
handle_info({death_share_killed,{NpcId,ProtoId}}, StateName, State) ->
	role_op:death_share_killed(NpcId,ProtoId),
	{next_state, StateName, State};			

handle_info({other_inspect_you,RoleInfo}, StateName, State) ->
	role_op:handle_other_inspect_you(RoleInfo),
	{next_state, StateName, State};
	
%%handle_info({chat_interview,{ServerId,RoldId,Signature}}, StateName, State) ->
%%	chat_interview:handle_chat_interview({ServerId,RoldId,Signature}),
%%	{next_state, StateName, State};

handle_info({other_inspect_your_pet,{MyServerId,MyRoldId,PetId}}, StateName, State) ->
	role_op:handle_other_inspect_your_pet({MyServerId,MyRoldId,PetId}),
	{next_state, StateName, State};	
	
handle_info({other_friend_inspect_you,{RoldId,Ntype}}, StateName, State) ->
	friend_op:handle_other_inspect_you(RoldId,Ntype),
	{next_state, StateName, State};
	
handle_info({other_friend_online,{RoldId,RoleName,LineId}}, StateName, State) ->
	friend_op:handle_friend_online(RoldId,RoleName,LineId),
	{next_state, StateName, State};

handle_info({other_friend_offline,{RoldId,RoleName,LineId}}, StateName, State) ->
	friend_op:handle_friend_offline(RoldId,RoleName,LineId),
	{next_state, StateName, State};
	
%% 事件：用于进行buffer的计算
handle_info( {buffer_interval, BufferInfo}, StateName, State) ->
	case buffer_op:do_interval(BufferInfo) of
		{remove,{BufferId,BufferLevel}}-> 
			NextState = StateName,
			role_op:remove_buffer({BufferId,BufferLevel});
		{changattr,{BufferId,_Level},BuffChangeAttrs}->
			%%处理变化属性
			NextState = 
			case effect:proc_buffer_function_effects(BuffChangeAttrs) of
				[]->
					StateName;
				ChangedAttrs->	
					RoleID = get(roleid),
					role_op:update_role_info(RoleID,get(creature_info)),						
					role_op:self_update_and_broad(ChangedAttrs),
					%%广播当前buff影响
					BuffChangesForSend = lists:map(fun({AttrTmp,ValueTmp})-> role_attr:to_role_attribute({AttrTmp,ValueTmp}) end,BuffChangeAttrs),
					Message = role_packet:encode_buff_affect_attr_s2c(RoleID,BuffChangesForSend),
					role_op:send_data_to_gate(Message),
					role_op:broadcast_message_to_aoi_client(Message),
					%%检查一下有没有影响到血量,如果有的话,看是否导致死掉
					case lists:keyfind(hp,1,ChangedAttrs) of
						{_,HPNew}->
							if
								HPNew =< 0 ->
									{EnemyId,EnemyName} = buffer_op:get_buff_casterinfo(BufferId),
									%% 被杀害了	
									role_op:player_be_killed(EnemyId,EnemyName),
									deading;																		
								true->					
									StateName					
							end;
						_->
							StateName
					end
			end;									
		_Any -> 
			NextState = StateName
	end,
	{next_state, NextState, State};

handle_info({hprecover_interval,HpRecInt}, StateName, State)->
	CurrAttributes = get(current_attribute),
	RoleInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(RoleInfo),
	CurHp = get_life_from_roleinfo(RoleInfo),
	case buffer_op:do_hprecover(HpRecInt,CurHp,CurrAttributes) of
		{hp,0}	-> o ;
		{hp,ChangeValue}->
			if 	
				CurHp > 0->					%%死亡状态不能进行回复,虽然有cancel,为了防止cancel失败,此处多判断一次
					HP = CurHp + ChangeValue,
					put(creature_info, set_life_to_roleinfo(get(creature_info), HP)),
					role_op:update_role_info(RoleID,get(creature_info)),		
					role_op:self_update_and_broad([{hp,HP}]);
				true->
					nothing
			end
	end,
	{next_state, StateName, State};

handle_info({mprecover_interval,MpRecInt}, StateName, State)->
	CurrAttributes = get(current_attribute),
	RoleInfo = get(creature_info),
	CurMp = creature_op:get_mana_from_creature_info(RoleInfo),
	case buffer_op:do_mprecover(MpRecInt,CurMp,CurrAttributes) of
		{mp,0}	-> o ;

		{mp,ChangeValue}->
			MP = erlang:max(CurMp + ChangeValue, 0),		%%防止战士掉蓝会掉到负值 
			case (CurMp =/= MP) of
				true ->
					put(creature_info, set_mana_to_roleinfo(get(creature_info), MP)),
					role_op:self_update_and_broad([{mp,MP}]);
				false ->
					do_not_do_any_thing
			end
	end,
	{next_state, StateName, State};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				组队相关的内部通信信息			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
handle_info({group_invite_you,InviterInfo}, StateName, State)->
	group_handle:handle_group_invite_you(InviterInfo),
	{next_state, StateName, State};

handle_info({group_apply_you,RemoteRoleInfo}, StateName, State)->
	group_handle:handle_group_apply_you(RemoteRoleInfo),
	{next_state, StateName, State};
	
handle_info({group_apply_to_leader,RemoteRoleInfo}, StateName, State)->
	group_handle:handle_group_apply_to_leader(RemoteRoleInfo),
	{next_state, StateName, State};	

handle_info({group_accept_you,RemoteRoleInfo}, StateName, State)->
	group_handle:handle_group_accept_you(RemoteRoleInfo),
	{next_state, StateName, State};	

handle_info({insert_new_teamer,RoleInfo}, StateName, State)->
	group_handle:handle_insert_new_teamer(RoleInfo),
	{next_state, StateName, State};

handle_info({update_group_list,NewGroupInfo}, StateName, State)->
	group_handle:handle_update_group_list(NewGroupInfo),
	{next_state, StateName, State};

handle_info({remove_teamer,Roleid}, StateName, State)->
	group_handle:handle_remove_teamer(Roleid),
	{next_state, StateName, State};
		
handle_info({group_destroy,GroupId}, StateName, State)->
	group_handle:handle_group_destroy(GroupId),
	{next_state, StateName, State};

handle_info({regist_member_info,{Roleid,Info}}, StateName, State)->
	group_handle:handle_regist_member_info(Roleid,Info),
	{next_state, StateName, State};	
	
handle_info({group_update_timer}, StateName, State)->
	group_op:update_by_timer(),
	{next_state, StateName, State};

handle_info({delete_invite,Roleid}, StateName, State)->
	group_handle:handle_delete_invite(Roleid),
	{next_state, StateName, State};	

%%招募
handle_info({group_instance_start,Info}, StateName, State)->
	group_handle:handle_group_instance_start(Info),
	{next_state, StateName, State};		

handle_info({instance_leader_join_c2s}, StateName, State)->
	group_handle:handle_group_instance_join(),
	{next_state, StateName, State};	

handle_info({instance_exit_c2s}, StateName, State)->
	instance_op:proc_player_instance_exit(),
	{next_state, StateName, State};
	
handle_info({chat_c2s,Msg}, StateName, State) ->	
	chat_op:proc_chat_msg(Msg),
	{next_state, StateName, State};	
	
%%handle_info({chat_interview,Msg}, StateName, State) ->	
%%	chat_interview:chat_interview(Msg),
%%	{next_state, StateName, State};	

handle_info({chat_loudspeaker_queue_num_c2s}, StateName, State) ->	
	RoleId = get(roleid),
	loudspeaker_manager:loudspeaker_queue_num(RoleId),
	{next_state, StateName, State};	
		
handle_info({fatigue,Msg}, StateName, State) ->
	case get(is_adult) of
		false->	fatigue:fatigue_message(Msg);
		true-> ignor
	end,
	{next_state, StateName, State};
	
handle_info({fatigue_ver2,Msg}, StateName, State) ->
	case get(is_adult) of
		false->	fatigue_ver2:fatigue_message(Msg);
		true-> ignor
	end,
	{next_state, StateName, State};		

%%任务
handle_info({questgiver_accept_quest_c2s,NpcId,QuestId}, StateName, State) ->	
	quest_handle:handle_questgiver_accept_quest_c2s(NpcId,QuestId),
	{next_state, StateName, State};	
	
handle_info({questgiver_hello_c2s,NpcId}, StateName, State) ->	
	quest_handle:handle_questgiver_hello_c2s(NpcId),
	{next_state, StateName, State};	
	
handle_info({quest_quit_c2s,QuestId}, StateName, State) ->	
	quest_handle:handle_quest_quit_c2s(QuestId),
	{next_state, StateName, State};		

handle_info({questgiver_complete_quest_c2s,Npcid,QuestId,ChoiceItem}, StateName, State) ->	
	quest_handle:handle_questgiver_complete_quest_c2s(QuestId,Npcid,ChoiceItem),
	{next_state, StateName, State};	
	
handle_info({quest_details_c2s,QuestId}, StateName, State) ->	
	quest_handle:handle_quest_details_c2s(QuestId),
	{next_state, StateName, State};	

handle_info( {questgiver_states_update_c2s,Npcids}, StateName, State) ->	
	quest_handle:handle_questgiver_states_update_c2s(Npcids),
	{next_state, StateName, State};		

handle_info( {quest_timeover,QuestId}, StateName, State) ->	
	quest_handle:handle_quest_timeover(QuestId),
	{next_state, StateName, State};		
	
handle_info( {update_quest_state,Info}, StateName, State) ->	
	quest_special_msg:proc_specail_msg(Info),
	{next_state, StateName, State};	


handle_info({quest_script_msg,Mod,Args}, StateName, State)->	
 	apply(Mod,proc_script_msg,Args),
	{next_state, StateName, State};

handle_info( {role_game_timer}, StateName, State) ->	
	role_op:do_role_game_interval(),
	{next_state, StateName, State};	


%%
%%guild
%%

handle_info({guild_message,Message},StateName, State)->
	guild_packet:process_message(Message),
	{next_state, StateName, State};
handle_info({guildmanager_msg,Message},StateName, State)->													
	guild_packet:process_proc_message(Message),
	{next_state, StateName, State};
handle_info({guildcreate_msg, {guildname, Name}}, StateName, State) ->
  broadcast_op:guild_create(Name),
  {next_state, StateName, State};

handle_info({other_login,RoleId}, StateName, State) ->
	role_op:handle_other_login(RoleId),
	{next_state, StateName, State};	

%%GM接口 
handle_info({gm_kick_you}, StateName, State) ->
	slogger:msg("kick_out, yanzengyan, role_processor, gm_kick_you~n"),
	role_op:kick_out(get(roleid)),
	{next_state, StateName, State};

handle_info({gm_move_you,MapId,PosX,PosY}, StateName, State) ->
	role_op:transport(get(creature_info),get(map_info),get_lineid_from_mapinfo(get(map_info)),MapId,{PosX,PosY}),
	{next_state, StateName, State};

handle_info({gm_block_talk,Duration}, StateName, State) ->
	chat_op:set_block(Duration),
	{next_state, StateName, State};
	
handle_info({gm_set_attr}, StateName, State) ->			%%for crash_test
	todo,
	{next_state, StateName, State};	

handle_info({power_gather}, StateName, State) ->			%%for crash_test
	Power = get_power_from_roleinfo(get(creature_info)),
	Class = get_class_from_roleinfo(get(creature_info)),
	gm_logger_role:role_power_gather(get(roleid),Power,Class,get(level)),
	{next_state, StateName, State};

handle_info({line_change,LineId}, StateName, State) ->
	role_op:change_line(LineId),
	{next_state, StateName, State};					
%%  
%%完成注册
%%  
handle_info({finish_visitor,AccountName}, StateName, State) ->
	RoleId = get(roleid),
	RoleInfoInDB1 = role_db:put_account(role_db:get_role_info(RoleId),AccountName),
	role_db:flush_role(RoleInfoInDB1),
	gm_logger_role:role_visitor_register(RoleId,AccountName),
	NewAccount = {account,AccountName,[RoleId],0},
	dal:write_rpc(NewAccount),
	gm_logger_role:role_visitor_register(RoleId,AccountName),
	put(account_id,AccountName),
	{next_state, StateName, State};		
					
handle_info({kick_from_instance,MapProcName}, StateName, State) ->
	instance_op:back_home(MapProcName),		
	{next_state, StateName, State};			

handle_info({kick_instance_by_reason,Creation}, StateName, State) ->
	instance_op:kick_instance_by_reason(Creation),
	{next_state, StateName, State};

handle_info({block_training_c2s}, StateName, State) ->
	case (StateName=:= gaming) or (StateName=:= moving) of
		true-> 
			block_training_op:start_training();
		_->
			nothing
	end,			
	{next_state, StateName, State};		

handle_info({block_training,Info}, StateName, State) ->
	block_training_op:training_heartbeat(Info),		
	{next_state, StateName, State};				
%%邮件	
handle_info(#mail_status_query_c2s{},StateName,State)->
	mail_op:mail_status_query_c2s(),
	{next_state, StateName, State};				
handle_info(#mail_query_detail_c2s{mailid=MailId},StateName,State)->
	mail_op:mail_query_detail_c2s(MailId),
	{next_state, StateName, State};				
handle_info(#mail_send_c2s{toi=ToId,
						   title=Title,
						   content=Content,
						   add_silver=Add_Silver,
						   add_item=Add_Item
						   },StateName,State)->
	mail_op:mail_send_c2s(ToId,Title,Content,Add_Item,Add_Silver),
	{next_state, StateName, State};				
handle_info(#mail_get_addition_c2s{mailid=MailId},StateName,State)->
	mail_op:mail_get_addition_c2s(MailId),
	{next_state, StateName, State};				
handle_info(#mail_delete_c2s{mailid=MailId},StateName,State)->
	mail_op:mail_delete_c2s(MailId),
	{next_state, StateName, State};	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                      称号
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_info({title_condition_change, Type, Value}, StateName, State) ->
	role_op:title_condition_change(Type, Value),
	{next_state, StateName, State};			

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						交易
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%						
handle_info({trade_role_apply_c2s,RoleId},StateName,State)->
	trade_role_handle:handle_trade_role_apply_c2s(RoleId),
	{next_state, StateName, State};		
	
handle_info({trade_role_accept_c2s,RoleId},StateName,State)->
	trade_role_handle:handle_trade_role_accept_c2s(RoleId),
	{next_state, StateName, State};		
	
handle_info({trade_role_decline_c2s,RoleId},StateName,State)->
	trade_role_handle:handle_trade_role_decline_c2s(RoleId),
	{next_state, StateName, State};		
	
handle_info({set_trade_money_c2s,MoneyType,MoneyCount},StateName,State)->
	trade_role_handle:handle_set_trade_money_c2s(MoneyType,MoneyCount),
	{next_state, StateName, State};		
	
handle_info({set_trade_item_c2s,Trade_slot,Package_slot},StateName,State)->
	trade_role_handle:handle_set_trade_item_c2s(Trade_slot,Package_slot),
	{next_state, StateName, State};						

handle_info({trade_role_lock_c2s},StateName,State)->
	trade_role_handle:handle_trade_role_lock_c2s(),
	{next_state, StateName, State};	

handle_info({trade_role_dealit_c2s},StateName,State)->
	trade_role_handle:handle_trade_role_dealit_c2s(),
	{next_state, StateName, State};	
	
handle_info({cancel_trade_c2s},StateName,State)->
	trade_role_handle:handle_cancel_trade_c2s(),
	{next_state, StateName, State};		

handle_info({trade_role_apply,RoleId},StateName,State)->
	trade_role_handle:handle_trade_role_apply(RoleId),
	{next_state, StateName, State};		

handle_info({trade_role_accept,RoleId},StateName,State)->
	trade_role_handle:handle_trade_role_accept(RoleId),
	{next_state, StateName, State};

handle_info({trade_role_accept1,RoleId},StateName,State)->
	trade_role_handle:handle_trade_role_accept1(RoleId),
	{next_state, StateName, State};

handle_info(other_lock,StateName,State)->
	trade_role_handle:handle_other_lock(),
	{next_state, StateName, State};

handle_info(other_deal,StateName,State)->
	trade_role_handle:handle_other_deal(),
	{next_state, StateName, State};

handle_info(cancel_trade,StateName,State)->
	trade_role_handle:handle_cancel_trade(),
	{next_state, StateName, State};

handle_info(trade_error,StateName,State)->
	trade_role_handle:handle_trade_error(),
	{next_state, StateName, State};

handle_info({clear_crime_c2s,Type},StateName,State)->
	pvp_packet:clear_crime_name(Type),
	{next_state, StateName, State};
	
handle_info({change_role_crime,Msg},StateName,State)->
	pvp_packet:process_msg(Msg),
	{next_state, StateName, State};
	
handle_info({set_pkmodel_c2s,PkModel},StateName,State)->
	pvp_handle:handle_set_pkmodel_c2s(PkModel),
	{next_state, StateName, State};	

handle_info({quest_get_adapt_c2s}, StateName, State) ->
	quest_op:quest_get_adapt_c2s(),
	{next_state, StateName, State};

handle_info({quest_direct_complete_c2s,QuestId}, StateName, State) ->
	quest_handle:quest_direct_complete_c2s(QuestId),
	{next_state, StateName, State};

handle_info({role_quest_status_c2s, Quests}, StateName, State) ->
	quest_handle:role_quest_status_c2s(Quests),
	{next_state, StateName, State};

handle_info({npc_start_everquest_c2s,EverQId,NpcId}, StateName, State) ->
	everquest_handle:handle_npc_start_everquest(EverQId,NpcId),
	{next_state, StateName, State};

handle_info({npc_everquests_enum_c2s,NpcId}, StateName, State) ->
	everquest_handle:handle_npc_everquests_enum_c2s(NpcId),
	{next_state, StateName, State};

handle_info({refresh_everquest_c2s,EverId,Type, MaxQuality, MaxTimes}, StateName, State) ->
	everquest_handle:handle_refresh_everquest(EverId,Type, MaxQuality, MaxTimes),	
	{next_state, StateName, State};
	
handle_info({identify_verify_result,Code},StateName, State) ->
	case Code of
		1->
			put(is_adult,true),
			fatigue:set_adult(),
			Msg = #identify_verify_s2c{code=Code},
			MsgBin = login_pb:encode_identify_verify_s2c(Msg),
			role_op:send_data_to_gate(MsgBin);
		_-> 
			Msg = #identify_verify_s2c{code=Code},
			MsgBin = login_pb:encode_identify_verify_s2c(Msg),
			role_op:send_data_to_gate(MsgBin)
	end,
	{next_state, StateName, State};

handle_info({camp_battle,Message},StateName,State)->
	    camp_battle_packet:process_msg(Message),
		    {next_state, StateName, State};

handle_info({battle_join_c2s,Type}, StateName, State) ->
	battle_ground_op:handle_join(Type),	
	{next_state, StateName, State};

handle_info({tangle_records_c2s,Date,Class}, StateName, State) ->
	battle_ground_op:handle_tangle_records(Date,Class),
	{next_state, StateName, State};

handle_info({tangle_more_records_c2s}, StateName, State) ->
	battle_ground_op:handle_tangle_more_records(),
	{next_state, StateName, State};

handle_info({battle_leave_c2s}, StateName, State) ->
	battle_ground_op:handle_battle_leave(),	
	{next_state, StateName, State};			

handle_info({battle_reward_c2s}, StateName, State) ->
	battle_ground_op:handle_battle_reward(),
	{next_state, StateName, State};

handle_info({battle_reward_by_records_c2s,Date,BattleType,BattleId}, StateName, State) ->
	battle_ground_op:handle_battle_reward_by_records_c2s(Date,BattleType,BattleId),
	{next_state, StateName, State};
	
%% get tangle kill info
handle_info({tangle_kill_info_request_c2s,Date,BattleType,BattleId}, StateName, State) ->
	battle_ground_op:handle_tangle_kill_info_request(Date,BattleType,BattleId),
	{next_state, StateName, State};
	 
handle_info({battle_reward_from_manager,Info},StateName, State) ->
	battle_ground_op:battle_reward_from_manager(Info),
	{next_state, StateName, State};

handle_info({battle_intive_to_join,Info}, StateName, State) ->
	battle_ground_op:battle_intive_to_join(Info),
	{next_state, StateName, State};

handle_info({clean_battle_info}, StateName, State) ->
	battle_ground_op:clean_battle_info(),
	{next_state, StateName, State};
	
handle_info({join_yhzq_c2s,_},StateName,State) ->
	battle_ground_op:handle_join(?YHZQ_BATTLE),
	{next_state, StateName, State};

handle_info({notify_to_join_yhzq,Camp,Node,Proc,MapProc},StateName,State) ->
	battle_ground_op:handle_notify_to_join_yhzq(Camp,Node,Proc,MapProc),
	{next_state, StateName, State};
	
handle_info({leave_yhzq_c2s},StateName,State) ->
	%%io:format(" ~p leave_yhzq_c2s ~n",[?MODULE]),
	battle_ground_op:handle_leave_yhzq_c2s(),
	{next_state, StateName, State};
	
handle_info({notify_yhzq_reward,Winner,Honor,AddExp,JoinTime,LeaveTime},StateName,State) ->
	battle_ground_op:handle_notify_yhzq_reward(Winner,Honor,AddExp,JoinTime,LeaveTime),
	{next_state, StateName, State};
	
handle_info({yhzq_award_c2s},StateName,State)->
	battle_ground_op:handle_yhzq_award_c2s(),
	{next_state, StateName, State};

handle_info({get_instance_log_c2s}, StateName, State) ->
	instance_op:get_my_instance_count(),	
	{next_state, StateName, State};

handle_info({call_test,NpcId}, StateName, State) ->
	creature_op:call_creature_spawns(NpcId,{?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM}),
	{next_state, StateName, State};
	
handle_info({remove_test,NpcId}, StateName, State) ->	
	creature_op:unload_npc_from_map(get_proc_from_mapinfo(get(map_info)),NpcId),
	{next_state, StateName, State};

%% treasure_chest_v2
handle_info({treasure_chest_v2,{Type,Times,ConsumeType}},StateName,State)->
	treasure_chest_v2_op:process_treasure_chest(Type,Times,ConsumeType),
	{next_state, StateName, State};	

handle_info({smashed_egg,Message},StateName,State)->
	smashed_egg_op:process_message(Message),
	{next_state, StateName, State};

handle_info({god_tree,Message},StateName,State)->
	god_tree_op:process_message(Message),
	{next_state, StateName, State};	

handle_info({god_tree_storage,Message},StateName,State)->
	god_tree_storage_op:process_message(Message),
	{next_state, StateName, State};	

handle_info({congratulations,Message},StateName,State)->
	case (StateName=:= gaming) or (StateName=:= moving) of
		true->
			congratulations_packet:process_congratulations(Message);
		_->
			nothing
	end,	
	{next_state, StateName, State};
	
%%offline_exp
handle_info({offline_exp,Message},StateName,State)->
	offline_exp_packet:process_offline_exp(Message),
	{next_state, StateName, State};	
	

handle_info({other_role_levelup,Info},StateName,State)->
	case Info of
		{congratulations,Msg}->
			congratulations_op:hook_on_other_role_levelup(Msg);
		_->
			nothing
	end,
	{next_state, StateName, State};
%%
%%限时礼包
%%
handle_info({get_timelimit_gift_c2s},StateName,State)->
	timelimit_gift_op:handle_get_timelimit_gift(),
	{next_state, StateName, State};

handle_info({direct_show_gift,NpcId,NpcProtoId,GenLootInfo,Pos},StateName,State)->
	role_op:item_show_with_lootinfo(NpcId,NpcProtoId,GenLootInfo,Pos),
	{next_state, StateName, State};
	
%%handle_info({timelimit_gift_reset,Time},StateName,State)->
%%	timelimit_gift_op:reset_today_gift(Time),
%%	{next_state, StateName, State};
	
handle_info({clear_crime,Value},StateName,State)->
	pvp_op:clear_crime_by_value(Value),
	{next_state, StateName, State};

%%
%%答题奖励
%%
handle_info({answer_reward,Score,Rank},StateName,State)->
	answer_op:answer_reward(Score,Rank),
	{next_state, StateName, State};

%%新手卡
handle_info({gift_card_apply_c2s,Key,Type},StateName,State)->
	case Type of
		1 ->
			role_giftcard_op:gift_card_apply_c2s(Key, Type);
		_ ->
			media_card_op:media_card_apply_c2s(Key,Type)
	end,
	{next_state, StateName, State};

%%摆摊
handle_info({auction_packet,Message},StateName,State)->
	auction_handle:handle(Message),
	{next_state, StateName, State};

%%升级操作
handle_info({levelup_opt_c2s,Level},StateName,State)->
	role_levelup_opt:levelup_opt_c2s(Level),
	{next_state, StateName, State};
	
handle_info({dragon_fight_num_c2s,NpcId},StateName,State)->
	Mapid = get_mapid_from_mapinfo(get(map_info)), 
	npc_function_frame:do_action(Mapid,get(creature_info),NpcId,npc_dragon_fight_action,[get_num,NpcId]),
	{next_state, StateName, State};

handle_info({dragon_fight_faction_c2s,NpcId},StateName,State)->
	Mapid = get_mapid_from_mapinfo(get(map_info)), 
	npc_function_frame:do_action(Mapid,get(creature_info),NpcId,npc_dragon_fight_action,[change_faction,NpcId]),
	{next_state, StateName, State};	
	
handle_info(dragon_fight_join_c2s,StateName,State)->
	role_dragon_fight:handle_dragon_fight_join(),
	{next_state, StateName, State};	
	
handle_info({dragon_fight_stop,Info,Faction},StateName,State)->
	role_dragon_fight:dragon_fight_stop(Info,Faction),
	{next_state, StateName, State};	
	
handle_info({npc_chess_spirit,Info},StateName,State)->
	role_chess_spirits:handle_message(Info),
	{next_state, StateName, State};
	
%% venation	
handle_info({venation,Message},StateName,State)->
	venation_op:process_message(Message),
	{next_state, StateName, State};
	
%%ridepet_identify	
handle_info({item_identify,Message},StateName,State)->
	item_identify_op:process_message(Message),
	{next_state, StateName, State};
	
handle_info({ride_pet_synthesis,Message},StateName,State)->
	ride_pet_synthesis_op:process_message(Message),
	{next_state, StateName, State};
	
handle_info({ride_opt_c2s,Op},StateName,State)->
	case (StateName=:= gaming) or (StateName=:= moving) or (StateName=:=sitting) of
		true->
			role_ride_op:proc_role_ride(Op);
		_->
			nothing
	end,		
	{next_state, StateName, State};
	
%%
%%activity_value
%%
handle_info({activity_value,Message},StateName,State)->
	activity_value_op:process_message(Message),
	{next_state, StateName, State};
%%活动面板相关
handle_info({continuous_logging,Message},StateName,State)->
	continuous_logging_op:process_message(Message),
	{next_state, StateName, State};

handle_info({instance_entrust,Message},StateName,State)->
	instance_op:process_message(Message),
	{next_state, StateName, State};

%% 免费委托
%% handle_info({instance_entrust_free,Message},StateName,State)->
%% 	instance_op:process_message(Message),
%% 	{next_state, StateName, State};
	
handle_info({active_board,Mod,Message},StateName,State)->
	erlang:apply(Mod,process_message,[Message]),
	{next_state, StateName, State};
	
handle_info({role_game_rank,Info},StateName,State)->
	role_game_rank:handle_info(Info),
	{next_state, StateName, State};	
	
handle_info({treasure_storage,Message},StateName,State)->
	treasure_storage_op:process_message(Message),
	{next_state, StateName, State};	

%%facebook 
handle_info({facebook_bind_check},StateName,State)->
	facebook:facebook_bind_check(),
	{next_state, StateName, State};	
	
%%welfare_activity

handle_info({welfare_activity,Msg},StateName,State)->
	welfare_activity_packet:handle_message(Msg),
	{next_state, StateName, State};	

handle_info({pet_base_msg,Message},StateName,State)->
	NewState = pet_handle:process_base_message(Message, State),
	{next_state, StateName, NewState};	

%%chat_private
handle_info({chat_private,Msg},StateName,State)->
	chat_private:process_message(Msg),
	{next_state, StateName, State};	
	
%%refine_system
handle_info({refine_system,Message},StateName,State)->
	refine_system_packet:handle_message(Message),
	{next_state, StateName, State};	
	
%%golden_plume_awards
handle_info({serialnumber_activity_result,Message},StateName,State)->
	welfare_activity_op:serialnumber_activity_result(Message),
	{next_state, StateName, State};	
	
handle_info({treasure_transport,Message},StateName,State)->
	treasure_transport_packet:handle_message(Message),
	{next_state, StateName, State};
	
handle_info({mainline_client_msg,Message},StateName,State)->
	role_mainline:process_client_message(Message),
	{next_state, StateName, State};
	
handle_info({mainline_internal_msg,Message},StateName,State)->
	role_mainline:process_internal_message(Message),
	{next_state, StateName, State};
	
%%country
handle_info({country_client_msg,Message},StateName,State)->
	country_op:process_client_message(Message),
	{next_state, StateName, State};
	
handle_info({country_proc_msg,Message},StateName,State)->
	country_op:process_proc_message(Message),
	{next_state, StateName, State};
	
%%guild battle
handle_info({guildbattle_client_msg,Message},StateName,State)->
	guildbattle_op:process_client_message(Message),
	{next_state, StateName, State};
	
	
handle_info({guildbattle_proc_msg,Message},StateName,State)->
	guildbattle_op:process_proc_message(Message),
	{next_state, StateName, State};
	
%%festival 
handle_info({festival_msg,Message},StateName,State)->
	festival_packet:process_proc_message(Message),
	{next_state, StateName, State};

handle_info({christmas_activity,Message},StateName,State)->
	christmac_activity_packet:process_message(Message),
	{next_state, StateName, State};
	
handle_info({role_mall_integral,Message},StateName,State)->
	mall_op:proc_msg(Message),
	{next_state, StateName, State};
	
handle_info({loop_instance_client,Message},StateName,State)->
	loop_instance_op:proc_client_msg(Message),
	{next_state,StateName,State};
handle_info({loop_instance_node,Message},StateName,State)->
	loop_instance_op:proc_node_msg(Message),
	{next_state,StateName,State};

handle_info({battle_ground,Message},StateName,State)->
	battle_ground_packet:process_msg(Message),
	{next_state,StateName,State};
	
%%honor store	
handle_info({honor_stores_msg,Message},StateName,State)->
	honor_stores_packet:process_msg(Message),
	{next_state,StateName,State};
	
%%quest	
handle_info({quest_scripts,Message},StateName,State)->
	quest_packet:process_msg(Message),
	{next_state,StateName,State};

handle_info({test_function,Module,Func,ParamList},StateName,State)->
	slogger:msg("~p ~n",[erlang:apply(Module,Func,ParamList)]),
	{next_state, StateName, State};

%% 礼包相关
handle_info({charge_package_init}, StateName, State) ->
	charge_package_op:charge_package_init(),
	{next_state, StateName, State};
handle_info({get_charge_package, Id}, StateName, State) ->
	try
		charge_package_op:get_charge_package(Id)
	catch
		E:R -> slogger:msg("get_charge_package id:~p  E:~p Reason:~p ~n",[Id,E,R])
	end,
	{next_state, StateName, State};	

%% 礼包相关
handle_info({charge_reward_init}, StateName, State) ->
	charge_reward_op:charge_reward_init(),
	{next_state, StateName, State};
handle_info({get_charge_reward, Id}, StateName, State) ->
	try
		charge_reward_op:get_charge_reward(Id)
	catch
		E:R -> slogger:msg("get_charge_reward id:~p  E:~p Reason:~p ~n",[Id,E,R])
	end,
	{next_state, StateName, State};
	
% 升级加元宝
handle_info({levelgold_msg, Message}, StateName, State) ->
	levelgold_packet:process_msg(Message),
	{next_state, StateName, State};

% 连续登陆
handle_info({login_continuously_msg, Message}, StateName, State) ->
	login_continuously_packet:process_msg(Message),
	{next_state, StateName, State};

% 等级奖励物品
handle_info({levelitem_msg, Message}, StateName, State) ->
  levelitem_packet:process_msg(Message),
  {next_state, StateName, State};

handle_info({timeout, _TimerRef, pet_shop_refresh}, StateName, State) ->
	% EndTime = util:now_sec() + ?PET_SHOP_REFRESH_TIME,
	% PetShopGoodsList = pet_shop_db:random_pet_goods(),
	% NewState = State#role_state{pet_shop_end_time = EndTime, pet_shop_goods_list = PetShopGoodsList, buy_pet = []},
	% 保存数据库
	pet_shop_db:save_data(),	
	% dal:write_rpc(#pet_shop{role_id = get(roleid), end_time = EndTime, pet_goods_list = PetShopGoodsList, buy_pet = []}),
	% 更新计时器
	% PetShopTimer = erlang:start_timer(?PET_SHOP_REFRESH_TIME * 1000, self(), pet_shop_refresh),
	% TimerRefList = pet_shop_op:cancel_pet_shop_timer(NewState#role_state.timer_ref),
	% NewTimerRefList = pet_shop_op:add_pet_shop_timer(TimerRefList, PetShopTimer),
	{next_state, StateName, State};

handle_info({battlefield_reward, BattlefirldType, Reward}, StateName, State) ->
	if
		BattlefirldType =:= ?TANGLE_BATTLE ->
			battle_ground_op:tangle_battlefield(Reward);
		true ->
			ok
	end,
	{next_state, StateName, State};

handle_info({rejoin_tangle_honor, Honor}, StateName, State) ->
	battle_ground_op:rejoin_tangle_battlefield(Honor),
	{next_state, StateName, State};

handle_info(duplicate_prize_item, StateName, State) ->
	NewState = duplicate_prize_op:duplicate_prize_item(State),
	{next_state, StateName, NewState};

handle_info({duplicate_prize_get,Message}, StateName, State) ->
	NewState = duplicate_prize_op:duplicate_prize_get(Message,State),
	{next_state, StateName, NewState};

handle_info({bdyy_next_show}, StateName, State) ->
	bdyy_handle:process_msg({bdyy_next_show}),
	{next_state, StateName, State};

handle_info({bdyy_time_end}, StateName, State) ->
	bdyy_handle:process_msg({bdyy_time_end}),
	{next_state, StateName, State};

handle_info({bdyy_from_client, Message}, StateName, State) ->
	bdyy_handle:process_msg(Message),
	{next_state, StateName, State};

handle_info({stop_dancing}, StateName, State) ->
	banquet_op:stop_dancing(),
	{next_state, gaming, State};

handle_info({dancing_start,RoleId}, StateName, StateData) ->
    case banquet_op:can_companion_dancing() of
    	true ->
			banquet_op:companion_dancing_start(RoleId);
		_ -> 
			nothing
	end,
	{next_state, StateName, StateData};

handle_info({check_pet_heart,PetId}, State, StateData) ->
    pet_op:check_pet_heart(PetId),
	{next_state, State, StateData};

handle_info({top_bar_item_from_client,Msg}, State, StateData) ->
    top_bar_item_handle:process_msg(Msg),
	{next_state, State, StateData};
	
handle_info(Info, StateName, State) ->
	slogger:msg("role_process:receive unkonwn message:(~p,~p,~p)~n", [Info, StateName, State]),
	{next_state, StateName, State}.

%% --------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% --------------------------------------------------------------------
terminate(Reason, StateName,StateData) ->    
	slogger:msg("terminate Reason ~p ~n",[Reason]),  
	role_op:crash_store(),
	{ok, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% --------------------------------------------------------------------
code_change(OldVsn, StateName, StateData, Extra) ->
	{ok, StateName, StateData}.
