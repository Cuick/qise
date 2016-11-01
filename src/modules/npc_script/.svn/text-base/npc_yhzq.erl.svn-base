%% Author: Administrator
%% Created: 2011-3-24
%% Description: TODO: Add description to npc_yhzq
-module(npc_yhzq).

%%
%% Exported Functions
%%
-export([proc_special_msg/1]).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("battle_define.hrl").
-include("common_define.hrl").

%%
%% API Functions
%%
proc_special_msg({special_attack,Info})->
%%	io:format("proc_special_msg ~p ~n",[Info]),
	handle_attack(Info);
	
proc_special_msg({change_faction,Info})->
	handle_change_faction(Info);
		
proc_special_msg(_)->
	nothing.

%%
%% Local Functions
%%
handle_attack({EnemyId,{BattleNode,BattleProc}})->
	case creature_op:what_creature(EnemyId) of
		role->			
			EnemyInfo = creature_op:get_creature_info(EnemyId),
			if
				EnemyInfo =:= undefined ->
					nothing;
				true->
					EnemyCamp = get_camp_from_roleinfo(EnemyInfo),
					SelfInfo = get(creature_info),
					SelfFac = get_battle_state_from_npcinfo(SelfInfo),
					case get(yhzq_npc_last_faction) of
						undefined->
							NewLastFaction = ?ZONEIDLE;
						LastFaction->
							NewLastFaction = LastFaction
					end,
%%					io:format("RoleCamp ~p SelfFac ~p last faction ~p ~n",[EnemyCamp,SelfFac,NewLastFaction]),
					if
						EnemyCamp =:= SelfFac ->	%% 同一阵营 不允许争夺
							NextFaction = ?ZONEIDLE;
						EnemyCamp =:= ?YHZQ_CAMP_RED,SelfFac =:= ?REDGETFROMBLUE ->
							NextFaction = ?ZONEIDLE;
						EnemyCamp =:= ?YHZQ_CAMP_BLUE,SelfFac =:= ?BLUEGETFROMRED ->
							NextFaction = ?ZONEIDLE;
						EnemyCamp =:= NewLastFaction-> %% 抢到了被对方抢走一半的旗
							if
								NewLastFaction =:= ?ZONEIDLE -> %%上次是白旗
									NextFaction = NewLastFaction;
								true->
									NextFaction = EnemyCamp
							end;	
						NewLastFaction =:= ?ZONEIDLE -> %% 夺取到一个未被占领过的旗
							if
								EnemyCamp =:= ?YHZQ_CAMP_RED ->
									NextFaction = ?REDGETFROMBLUE;
								true->
									NextFaction = ?BLUEGETFROMRED
							end;
						EnemyCamp =/= SelfFac->		%%夺取到一个对方的旗帜
							if
								EnemyCamp =:= ?YHZQ_CAMP_RED ->
									NextFaction = ?REDGETFROMBLUE;
								true->
									NextFaction = ?BLUEGETFROMRED
							end;
						true->
							NextFaction = ?ZONEIDLE
					end,	
%%					io:format("NextFaction ~p ~n",[NextFaction]),		
					if
						NextFaction =:= ?ZONEIDLE ->			%%状态转换错误的不处理
							nothing;
						true->
							case get(change_faction_timer) of
								undefined->
									nothing;
							ChangeTimer->
								timer:cancel(ChangeTimer)
						end,
						case yhzq_battle_db:get_npcproto(get(id),NextFaction) of
							[]->
%%								io:format("get_npcproto nothing ~n"),
								nothing;
							DisPlayId->
								%%改变自身阵营
								if
									NewLastFaction =:= ?ZONEIDLE->
										put(yhzq_npc_last_faction,?ZONEIDLE);
									true->
										put(yhzq_npc_last_faction,NextFaction)
								end,
								put(creature_info, set_battle_state_to_npcinfo(get(creature_info),NextFaction)),						
								%%改变自身显示				
								%%ProtoInfo = npc_db:get_proto_info_by_id(NewProtoId),
								put(creature_info, set_displayid_to_npcinfo(get(creature_info),DisPlayId)),
%%								io:format("id ~p displayid ~p ~n",[get(id),DisPlayId]),
								npc_op:broad_attr_changed([{displayid,DisPlayId}]),
								npc_op:update_npc_info(get(id),get(creature_info)),
								%%通知Battle 某个旗帜的状态已改变
								battle_ground_processor:take_a_zone(BattleNode,BattleProc,{NextFaction,get(id),EnemyId})
						end,
						case (NextFaction =:= ?TAKEBYRED) or (NextFaction =:= ?TAKEBYBLUE) of
							true->%%不需要主动改变自身模板
								nothing;		
							_-> %%需改变自身模板
	%%							io:format("change state after ~p s ~n",[?YHZQ_CHANGE_STATE_TIME_S]),
								{ok, NewChangeTimer} = timer:send_after(?YHZQ_CHANGE_STATE_TIME_S*1000,self(),{change_faction,{NextFaction,BattleNode,BattleProc,EnemyId}}),
								put(change_faction_timer,NewChangeTimer)
						end
					end
			end;
		_->
			nothing
	end.

handle_change_faction({CurFaction,BattleNode,BattleProc,PlayerId})->
%%	io:format("~p handle_change_faction ~p ~n",[get(id),CurFaction]),
	SelfInfo = get(creature_info),
	SelfFac = get_battle_state_from_npcinfo(SelfInfo),
	RealCurFaction = get_battle_state_from_npcinfo(SelfInfo),
	if
		CurFaction =/= RealCurFaction ->
			nothing;
		true->
			case CurFaction of
				?REDGETFROMBLUE->
					NextFaction = ?TAKEBYRED;	
				?BLUEGETFROMRED->
					NextFaction = ?TAKEBYBLUE;
				_->
					NextFaction = ?ZONEIDLE
			end,
			if
				NextFaction =:= ?ZONEIDLE ->
					nothing;
				true->		
					case yhzq_battle_db:get_npcproto(get(id),NextFaction) of
						[]->
							nothing;
						DisPlayId->
							%%改变自身阵营
							put(yhzq_npc_last_faction,CurFaction),
							put(creature_info, set_battle_state_to_npcinfo(get(creature_info),NextFaction)),						
							%%改变自身显示
							%%ProtoInfo = npc_db:get_proto_info_by_id(NewProtoId),
							put(creature_info, set_displayid_to_npcinfo(get(creature_info),DisPlayId)),
							npc_op:broad_attr_changed([{displayid,DisPlayId}]),
							npc_op:update_npc_info(get(id),get(creature_info)),
							%%通知Battle 某个旗帜的状态已改变
							battle_ground_processor:take_a_zone(BattleNode,BattleProc,{NextFaction,get(id),PlayerId})
					end
			end
	end.