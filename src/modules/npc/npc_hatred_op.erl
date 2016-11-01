-module(npc_hatred_op).
-compile(export_all).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("common_define.hrl").
-include("ai_define.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 返回值:
%% reset（重置）/update_attack（查询 仇恨列表和攻击）/nothing_todo(保持目前状态)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%普通怪不主动攻击
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init()->
	put(npc_enemys_list,[]),
	hatred_op:init().
	
clear()->
	put(npc_enemys_list,[]),
	hatred_op:clear().	
	
insert_to_enemys_list(CreatureId)->
	case lists:member(CreatureId,get(npc_enemys_list)) of
		true->
			nothing;
		_->
			put(npc_enemys_list,[CreatureId|get(npc_enemys_list)])
	end.
	
get_all_enemys()->
	get(npc_enemys_list).	

get_target()->
	hatred_op:get_highest_enemyid().
	
nothing_hatred(_,_)->			%%从不还手的怪物
	nothing_todo.	

normal_hatred_update(other_into_view,_EnemyId)-> %%普通怪物没有inview的仇恨
	nothing_todo;  
	
normal_hatred_update(call_help,	AttackerId)->  
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%当前没有任何攻击仇恨，则设置并攻击
			hatred_op:insert(AttackerId,?HELP_HATRED), 
			update_attack;
		false ->   			%%当前有攻击仇恨，加入新仇恨
			case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
				true -> 
					hatred_op:insert(AttackerId,?HELP_HATRED),
					nothing_todo;
				false ->		%%这人已经在攻击的仇恨列表里了
					nothing_todo
					
			end
	end; 
	
normal_hatred_update(is_attacked,{AttackerId,_HATRED})->  %%EnemyIds为组队中所有玩家id,攻击者最高，其他均低,TODO:要判断距离？
		insert_to_enemys_list(AttackerId),
		case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
			true ->    			%%当前没有任何攻击仇恨，则设置并攻击
				hatred_op:insert(AttackerId,?ATTACKER_HATRED), 
				update_attack;
			false ->   			%%当前有攻击仇恨，加入新仇恨，并且旧仇恨加1,以此决定攻击顺序
				case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
					true -> 
						lists:foreach(fun({ID,Value})->hatred_op:change(ID,Value + 1) end,hatred_op:get_hatred_list()),
						hatred_op:insert(AttackerId,?ATTACKER_HATRED),
						nothing_todo;
					false ->		%%这人已经在攻击的仇恨列表里了
						nothing_todo
				end
		end; 

normal_hatred_update(other_dead,PlayerId)-> 
	case PlayerId =:= get(targetid) of
		true  -> 
			hatred_op:delete(PlayerId),				%%目标死了,从仇恨列表中删除
			case hatred_op:get_hatred_list() of
				[] ->  reset;						%%仇恨列表空了，重置npc
			 	 _ -> update_attack					%%还有目标，去攻击其他人
			end;
		false ->									%%偷着乐
				hatred_op:delete(PlayerId),
			 	nothing_todo
	end; 
	
normal_hatred_update(other_outof_bound,EnemyId)->
	case  EnemyId =:= get(targetid) of 		
		true ->  	 %%目标从攻击中逃跑了
				hatred_op:delete(EnemyId),
				case hatred_op:get_hatred_list() of
					[] ->  reset;						%%仇恨列表空了，重置npc
					_ -> update_attack					%%还有小组队友，去攻击其队友
				end;
		false -> 	
				hatred_op:delete(EnemyId),
			 	nothing_todo
	end;
	
normal_hatred_update(_Other,_EnemyId)->
	nothing_todo.  
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%主动怪物
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
active_hatred_update(other_into_view,EnemyId)->
	case hatred_op:get_hatred_list() of
		[] ->
			insert_into_view_hatred(EnemyId),
			update_attack; 
		_ ->  %%当前有仇恨，不再被其他玩家的移动吸引
			nothing_todo
	end;

active_hatred_update(call_help,AttackerId)->  
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%当前没有任何攻击仇恨，则设置并攻击
			hatred_op:insert(AttackerId,?HELP_HATRED), 
			update_attack;
		false ->   			%%当前有攻击仇恨，加入新仇恨
			case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
				true -> 
					hatred_op:insert(AttackerId,?HELP_HATRED),
					nothing_todo;
				false ->		%%这人已经在攻击的仇恨列表里了
					nothing_todo
			end
	end; 

active_hatred_update(is_attacked,{AttackerId,_HATRED})->
	insert_to_enemys_list(AttackerId),
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%当前没有任何攻击仇恨，则设置并攻击
			hatred_op:clear(),				%%清除当前勾引你但是没攻击的人的仇恨
			hatred_op:insert(AttackerId,?ATTACKER_HATRED), 
			update_attack;
		false ->   			%%当前有攻击仇恨，加入新仇恨，并且旧仇恨加1,以此决定攻击顺序
			case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
				true -> 
					lists:foreach(fun({ID,Value})->hatred_op:change(ID,Value + 1) end,hatred_op:get_hatred_list()),
					hatred_op:insert(AttackerId,?ATTACKER_HATRED),
					nothing_todo;
				false ->		%%这人已经在攻击的仇恨列表里了
					nothing_todo
					
			end
	end; 

active_hatred_update(other_dead,PlayerId)-> 
	case hatred_op:get_value(PlayerId) of
		0 -> nothing_todo;
		_ -> 
			hatred_op:delete(PlayerId),			%%玩家死了,从仇恨列表中删除
			case hatred_op:get_hatred_list() =:= [] of 
				true ->  reset;						%%仇恨列表空了，重置npc
			 	false -> update_attack							%%还有小组队友，去攻击其队友
			 end
	end;
	
active_hatred_update(other_outof_bound,PlayerId)-> 
	case PlayerId =:= get(targetid) of 
				false ->  
							hatred_op:delete(PlayerId),
							nothing_todo;
				true ->  			%%被打的玩家从攻击中逃跑了
							hatred_op:delete(PlayerId),  
							case hatred_op:get_hatred_list() =:= [] of 
								true ->  reset;						%%仇恨列表空了，重置npc
							 	false -> update_attack							%%还有别人，去攻击别人
							end
	end;
		
active_hatred_update(_Other,_EnemyId)->
	todo. 
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Boss仇恨计算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
active_boss_hatred_update(other_into_view,EnemyId) ->
	case hatred_op:get_hatred_list() of
		[] ->
			insert_into_view_hatred(EnemyId),
			update_attack; 
		_ -> 
			insert_into_view_hatred(EnemyId),
			nothing_todo
	end;

active_boss_hatred_update(call_help,AttackerId)->  
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%当前没有任何攻击仇恨，则设置并攻击
			hatred_op:insert(AttackerId,?HELP_HATRED), 
			update_attack;
		false ->   			%%当前有攻击仇恨，加入新仇恨
			case hatred_op:get_value(AttackerId) < ?ATTACKER_HATRED of 
				true -> 
					hatred_op:insert(AttackerId,?HELP_HATRED),
					nothing_todo;
				false ->		%%这人已经在攻击的仇恨列表里了
					nothing_todo
			end
	end; 

active_boss_hatred_update(is_attacked,{AttackerId,HATRED}) ->
	insert_to_enemys_list(AttackerId),
	case hatred_op:get_highest_value() < ?ATTACKER_HATRED of        
		true ->    			%%当前没有任何攻击仇恨，则设置并攻击
			hatred_op:insert(AttackerId,?ATTACKER_HATRED+HATRED),			%%攻击仇恨基数+实际仇恨值 
			update_attack;
		false ->   			%%当前有攻击仇恨，加入仇恨，并且计算仇恨是否超过当前目标的110%
			NowHatred = hatred_op:get_value(AttackerId),
			case  NowHatred < ?ATTACKER_HATRED of			 %%这人是否已未在攻击仇恨里
				true -> 									
					case hatred_op:get_value_back(AttackerId) of		%%这是否在备份仇恨里
						0-> NewHatred = ?ATTACKER_HATRED+HATRED;		
						BackValue -> 
							NewHatred = BackValue +	HATRED,				%%在备份仇恨里,从备份中删除
							hatred_op:delete_back(AttackerId)
					end;
				false ->
					NewHatred = HATRED + NowHatred
			end,
			hatred_op:insert(AttackerId,NewHatred),
			case AttackerId =:= get(targetid) of						%%攻击者是否是当前攻击目标
				false ->
					Targethatred = hatred_op:get_value(get(targetid)),							
					case NewHatred*100 >= Targethatred*110 of				%%判断是否超过当前目标仇恨值110%，是则更新目标
						true ->	
							%%更新染红目标
							npc_op:update_touchred_into_selfinfo(AttackerId),
							npc_op:broad_attr_changed([{touchred,AttackerId}]),
							update_attack;
						false ->
							nothing_todo
					end;
				true ->
					nothing_todo
			end
	end; 

active_boss_hatred_update(other_dead,PlayerId)-> 
	case hatred_op:get_value(PlayerId) of
		0 -> nothing_todo;
		_ -> 
			hatred_op:delete_to_back(PlayerId),			%%玩家死了,删除到备份列表
			case hatred_op:get_hatred_list() =:= [] of 
				true -> 
					reset;						%%仇恨列表空了，重置npc
			 	false -> 
			 		update_attack				%%还有其他人，去攻击其他人
			 end
	end;

active_boss_hatred_update(other_outof_bound,PlayerId)-> 
	case PlayerId =:= get(targetid) of 
		false ->  
			case hatred_op:get_value(PlayerId) =< ?INVIEW_ROLE_HATRED of
				true-> nothing_todo;
				_ ->
					hatred_op:delete_to_back(PlayerId),
					nothing_todo
			end;
		true ->  			%%被打的玩家从攻击中逃跑了
			hatred_op:delete_to_back(PlayerId),  
			case hatred_op:get_hatred_list() =:= [] of 
				true ->   
					reset;						%%仇恨列表空了，重置npc
			 	false ->
			 		update_attack							%%还有别人，去攻击别人
			end
	end;
		
active_boss_hatred_update(_Other,_EnemyId)->
	todo.
	
%%local
insert_into_view_hatred(EnemyId)->
	case creature_op:what_creature(EnemyId) of
		npc->
			hatred_op:insert(EnemyId,?INVIEW_NPC_HATRED); 
		role->
			hatred_op:insert(EnemyId,?INVIEW_ROLE_HATRED);
		_->
			nothing
	end.

	
	
	