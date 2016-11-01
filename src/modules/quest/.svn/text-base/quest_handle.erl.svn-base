-module(quest_handle).

-compile(export_all).

-include("npc_struct.hrl").
-include("common_define.hrl").
-include("quest_define.hrl").
-include("error_msg.hrl").
-include("map_info_struct.hrl").
-include("everquest_define.hrl").

%%TODO:各种检测	undefined 等等
handle_questgiver_hello_c2s(NpcId)->
	Mapid = get_mapid_from_mapinfo(get(map_info)),
	npc_function_frame:do_enum(Mapid,get(creature_info),NpcId,quest_action).
	
handle_questgiver_accept_quest_c2s(NpcId,QuestId)->
	case role_op:is_dead() of
		false->
			case quest_op:is_in_start_quest(QuestId) of 		%%一些任务是不基于npc的,比如物品触发和直接弹出的
				true->				
					npc_function_frame:do_action_without_check(0,get(creature_info),NpcId,quest_action,[accept,NpcId,QuestId]);						
				false->					
					Mapid = get_mapid_from_mapinfo(get(map_info)),
					npc_function_frame:do_action(Mapid,get(creature_info),NpcId,quest_action,[accept,NpcId,QuestId])
			end;		
		_->
			nothing
	end.

handle_questgiver_complete_quest_c2s(QuestId,NpcId,ChoiceItem)->
	case role_op:is_dead() of
		false->
			Mapid = get_mapid_from_mapinfo(get(map_info)),
			npc_function_frame:do_action(Mapid,get(creature_info),NpcId,quest_action,[compelet,QuestId,ChoiceItem,NpcId]);
		_->
			nothing
	end.

handle_quest_details_c2s(QuestId)->
	not_use.

handle_quest_quit_c2s(QuestId)->
	quest_op:proc_role_quest_quit(QuestId).
	
handle_questgiver_states_update_c2s(Npcids)->
	States = lists:map(fun(Npcid)->
		case creature_op:what_creature(Npcid) of
			npc->
				case creature_op:get_creature_info(Npcid) of
					undefined ->						
						?QUEST_STATUS_UNAVAILABLE;
					CreatureInfo->
						AccList = get_acc_quest_list_from_npcinfo(CreatureInfo),
						ComList = get_com_quest_list_from_npcinfo(CreatureInfo), 
						quest_op:calculate_questgiver_state(AccList,ComList)
				end;
			role->
				?QUEST_STATUS_UNAVAILABLE
		end	
	end,Npcids),
	Message = quest_packet:encode_questgiver_states_update_s2c(Npcids,States),
	role_op:send_data_to_gate(Message).
				
handle_quest_timeover(Questid)->
	case quest_op:get_quest_accept_time(Questid) of
		false->					%%已经交完
			nothing;			
		StartTime ->
			QuestInfo = quest_db:get_info(Questid),
			LimitTime = quest_db:get_limittime(QuestInfo ),
			case timer:now_diff(timer_center:get_correct_now(),StartTime) >= LimitTime*1000 of
				true->				%%时间已到,任务失败
					quest_op:delete_from_list(Questid),
					Message = quest_packet:encode_quest_complete_failed_s2c(Questid,?QUEST_TIMEOUT),
					role_op:send_data_to_gate(Message),
					Message2 = quest_packet:encode_quest_list_remove_s2c(Questid),
					role_op:send_data_to_gate(Message2);
				false->				%%中途放弃,又新接了,会导致到此处
					nothing
			end
	end.
	
quest_direct_complete_c2s(QuestId)->
	case quest_op:has_quest(QuestId) of
		true->
			QuestInfo = quest_db:get_info(QuestId),
			case quest_db:get_direct_com_disable(QuestInfo) of
				0->
					slogger:msg("quest_direct_complete_c2s direct complete disable QuestId ~p ~n",[QuestId]);
				Gold->
					EverQuestId = quest_db:get_isactivity(QuestInfo),
					RoundCheck = 
					case everquest_op:get_cur_everquest_info(EverQuestId) of
						[]->
							true;
						EverQuestInfo->
							case everquest_db:get_rounds_num(everquest_db:get_info(EverQuestId)) of
								0->			%%无限循环任务,超过10轮则不让再刷
									everquest_op:get_cur_round_by_info(EverQuestInfo) =< ?DIRECT_COMPLETE_MAX_ROUND;
								_->
									true
							end	
					end,	
					if
						RoundCheck->
							case role_op:check_money(?MONEY_GOLD, Gold) of
								true->
									role_op:money_change(?MONEY_GOLD,-Gold,lost_by_complete_quest),
									quest_op:set_quest_finished(QuestId);
								_->
									nothing
							end;
						true->
							nothing
					end	
			end;
		_->
			nothing
	end.

role_quest_status_c2s(Quests) ->
	QuestsStatus = [get_status(QuestId) || QuestId <- Quests],
	Msg = quest_packet:encode_role_quest_status_s2c(QuestsStatus),
	role_op:send_data_to_gate(Msg).

get_status(QuestId) ->
	% 0 没被触发
	% 1 被触发
	case quest_op:has_been_finished(QuestId) of
	true -> 1;
	_ -> case quest_op:get_quest_state(QuestId) of
		 1 -> 1;  % 完成
		 2 -> 1;  % 领取
		 _ -> 0   % 其他情况全部忽视
		 end
	end.