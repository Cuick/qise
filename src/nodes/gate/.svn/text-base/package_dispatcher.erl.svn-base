%% Author: adrian
%% Created: 2010-4-7
%% Description: TODO: Add description to package_dispatcher
-module(package_dispatcher).

%%
%% Include files
%%
-include("login_pb.hrl").

%%
%% Exported Functions
%%
-export([dispatch/3]).
%%
%%

%%
%% Local Functions
%%
dispatch(Message,FromProcName,RolePid)->
%	slogger:msg(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Message:~p~n", [Message]),
	case Message of
		#user_auth_c2s{}->  
			login_package:handle(Message, FromProcName, RolePid);
		#player_select_role_c2s{}->
			login_package:handle(Message, FromProcName, RolePid);
		#role_line_query_c2s{}->
			login_package:handle(Message, FromProcName, RolePid);
		#create_role_request_c2s{}-> 
			login_package:handle(Message, FromProcName, RolePid); 
%% 		#is_visitor_c2s{}->
%% 			login_package:handle(Message, FromProcName, RolePid);
%% 		#is_finish_visitor_c2s{}->
%% 			login_package:handle(Message, FromProcName, RolePid);
		#reset_random_rolename_c2s{}->
			login_package:handle(Message, FromProcName, RolePid);
		%%banquet
		#banquet_request_banquetlist_c2s{}->
			banquet_packet:handle(Message,RolePid);
		#banquet_join_c2s{}->
			banquet_packet:handle(Message,RolePid);
		#banquet_cheering_c2s{}->
			banquet_packet:handle(Message,RolePid);
		#banquet_dancing_c2s{}->
			banquet_packet:handle(Message,RolePid);
		#banquet_leave_c2s{}->
			banquet_packet:handle(Message,RolePid);
		%%jszd_battle
		#jszd_join_c2s{}->
			battle_jszd_packet:handle(Message,RolePid);
		#jszd_leave_c2s{}->
			battle_jszd_packet:handle(Message,RolePid);
		#jszd_reward_c2s{}->
			battle_jszd_packet:handle(Message,RolePid);
		%%mall
		#init_mall_item_list_c2s{}->
			mall_packet:handle(Message,RolePid);
		#mall_item_list_c2s{}->
			mall_packet:handle(Message,RolePid);
		#mall_item_list_special_c2s{}->
			mall_packet:handle(Message,RolePid);
		#mall_item_list_sales_c2s{}->
			mall_packet:handle(Message,RolePid);
		#buy_mall_item_c2s{}->
			mall_packet:handle(Message,RolePid);
		%%friend
		#myfriends_c2s{}->
			friend_packet:handle(Message,RolePid);
		#add_friend_c2s{}->
			friend_packet:handle(Message, RolePid);
		#add_friend_respond_c2s{}->
			friend_packet:handle(Message, RolePid);
		#delete_friend_c2s{}->
			friend_packet:handle(Message, RolePid);
		#detail_friend_c2s{}->
			friend_packet:handle(Message, RolePid);
		#position_friend_c2s{}->
			friend_packet:handle(Message, RolePid);
		#add_signature_c2s{}->
			friend_packet:handle(Message, RolePid);
		#get_friend_signature_c2s{}->
			friend_packet:handle(Message, RolePid);
		#set_black_c2s{}->
			friend_packet:handle(Message, RolePid);
		#revert_black_c2s{}->
			friend_packet:handle(Message, RolePid);
		#delete_black_c2s{}->
			friend_packet:handle(Message, RolePid);
		#answer_sign_request_c2s{}->
			answer_packet:handle(Message, RolePid);
		#answer_question_c2s{}->
			answer_packet:handle(Message, RolePid);
		#visitor_rename_c2s{}->
			role_packet:handle(Message, RolePid);
		#role_change_line_c2s{}->			
			role_packet:handle(Message,RolePid);
		#role_move_c2s{}->
			role_packet:handle(Message, RolePid);
		#heartbeat_c2s{}->
			Msg = login_pb:encode_heartbeat_c2s(Message),
			tcp_client:send_data(self(),Msg);
		#map_complete_c2s{} ->
			role_packet:handle(Message, RolePid);
		#role_attack_c2s{} ->			
			role_packet:handle(Message, RolePid);
		#role_shift_pos_c2s{} ->
			role_packet:handle(Message, RolePid);
		#role_pull_objects_c2s{} ->
			role_packet:handle(Message, RolePid);
		#role_push_objects_c2s{} ->
			role_packet:handle(Message, RolePid);
		#role_map_change_c2s{}->
			role_packet:handle(Message, RolePid);       
		#npc_function_c2s{}->
			role_packet:handle(Message, RolePid);
		#npc_map_change_c2s{}->
			role_packet:handle(Message, RolePid);
		#skill_panel_c2s{} ->
			role_packet:handle(Message, RolePid);
		#update_hotbar_c2s{} ->
			role_packet:handle(Message, RolePid);
		#loot_query_c2s{}->
			role_packet:handle(Message, RolePid);	
		#loot_pick_c2s{}->
			role_packet:handle(Message, RolePid);	
		#destroy_item_c2s{}->
			role_packet:handle(Message, RolePid);	
		#split_item_c2s{}->
			role_packet:handle(Message, RolePid);	
		#swap_item_c2s{}->	
			role_packet:handle(Message, RolePid);
		#auto_equip_item_c2s{}->	
			role_packet:handle(Message, RolePid);
		#enum_shoping_item_c2s{} ->
			role_packet:handle(Message, RolePid);
		#buy_item_c2s{} ->
			role_packet:handle(Message, RolePid);
		#sell_item_c2s{} ->
			role_packet:handle(Message, RolePid);
		#use_item_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_apply_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_agree_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_create_c2s{}->
			role_packet:handle(Message, RolePid);
		#aoi_role_group_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_invite_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_accept_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_decline_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_kickout_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_setleader_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_disband_c2s{}->
			role_packet:handle(Message, RolePid);
		#group_depart_c2s{}->
			role_packet:handle(Message, RolePid);
		#recruite_c2s{}->
			role_packet:handle(Message, RolePid);
		#recruite_cancel_c2s{}->
			role_packet:handle(Message, RolePid);
		#role_recruite_c2s{}->
			role_packet:handle(Message, RolePid);
		#role_recruite_cancel_c2s{}->
		  	role_packet:handle(Message, RolePid);
		#recruite_query_c2s{}->
			role_packet:handle(Message, RolePid);	
		#inspect_c2s{}->
			role_packet:handle(Message, RolePid);
		#inspect_pet_c2s{}->
			role_packet:handle(Message, RolePid);
		#role_respawn_c2s{}->
			role_packet:handle(Message, RolePid);			
		#repair_item_c2s{}->
			role_packet:handle(Message, RolePid);			
		#questgiver_hello_c2s{}->
			quest_packet:handle(Message,RolePid);
		#questgiver_accept_quest_c2s{}->
			quest_packet:handle(Message,RolePid);
		#quest_quit_c2s{}->
			quest_packet:handle(Message, RolePid);
		#questgiver_complete_quest_c2s{}->
			quest_packet:handle(Message, RolePid);
		#questgiver_states_update_c2s{}->
			quest_packet:handle(Message, RolePid);
		#quest_details_c2s{}->
			quest_packet:handle(Message, RolePid);		
		#quest_get_adapt_c2s{}->	
			quest_packet:handle(Message, RolePid);
		#refresh_everquest_c2s{}->
			quest_packet:handle(Message, RolePid);
		#npc_start_everquest_c2s{}->
			quest_packet:handle(Message, RolePid);
		#npc_everquests_enum_c2s{}->
		  	quest_packet:handle(Message, RolePid);
		#quest_direct_complete_c2s{}->
			quest_packet:handle(Message, RolePid);

		#role_quest_status_c2s{} ->
			quest_packet:handle(Message, RolePid);

		#enum_skill_item_c2s{}->
		  role_packet:handle(Message, RolePid);	 		
		#skill_learn_item_c2s{} ->
		   role_packet:handle(Message, RolePid);	 
		#skill_auto_learn_item_c2s{} ->
            role_packet:handle(Message, RolePid);
		#feedback_info_c2s{}->
		  role_packet:handle(Message, RolePid);	
		#role_rename_c2s{}->
		   role_packet:handle(Message, RolePid);	
		#guild_rename_c2s{}->
			role_packet:handle(Message, RolePid);
		#spiritspower_reset_c2s{}->
			role_packet:handle(Message, RolePid);
		
		%%guild 
		#change_guild_battle_limit_c2s{}->
			guild_packet:handle(Message, RolePid);
		#upgrade_guild_monster_c2s{}->
			guild_packet:handle(Message, RolePid);
		#get_guild_monster_info_c2s{}->
			guild_packet:handle(Message, RolePid);
		#call_guild_monster_c2s{}->
			guild_packet:handle(Message, RolePid);
		#callback_guild_monster_c2s{}->
			guild_packet:handle(Message, RolePid);
		#change_smith_need_contribution_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_create_c2s{}->
			guild_packet:handle(Message, RolePid);
		#join_guild_instance_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_disband_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_invite_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_decline_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_accept_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_apply_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_depart_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_kickout_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_set_leader_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_promotion_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_demotion_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_log_normal_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_log_event_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_notice_modify_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_facilities_accede_rules_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_facilities_upgrade_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_facilities_speed_up_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_rewards_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_recruite_info_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_member_contribute_c2s{}->
			guild_packet:handle(Message, RolePid);	
		
		%%guild add
		#guild_contribute_log_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_impeach_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_impeach_info_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_impeach_vote_c2s{}->
			guild_packet:handle(Message, RolePid);

        #guild_dice_c2s{} ->
            guild_packet:handle(Message, RolePid);
		
		#chat_c2s{}->
		 	chat_packet:handle(Message, RolePid);
%% 			Msg = #pet_quality_riseup_c2s{msgid=2070,petid=20000000000005},
%% 			dispatch(Msg,FromProcName,RolePid);
		#pet_quality_riseup_c2s{} ->
			pet_packet:handle(Message, RolePid);
			
		#pet_savvy_up_c2s{}->
			pet_packet:handle(Message, RolePid);
 		#chat_private_c2s{}->
 			chat_packet:handle(Message, RolePid);
			
		#loudspeaker_queue_num_c2s{}->
			chat_packet:handle(Message, RolePid);	
		
		#query_player_option_c2s{}->
			role_packet:handle(Message, RolePid);
		
		#replace_player_option_c2s{}->
			role_packet:handle(Message, RolePid);
		
		#info_back_c2s{}->
			role_packet:handle(Message, RolePid);
		
		#lottery_clickslot_c2s{}->
			role_packet:handle(Message, RolePid);
		#lottery_querystatus_c2s{}->
			role_packet:handle(Message, RolePid);
		#start_block_training_c2s{}->
			role_packet:handle(Message, RolePid);
		#end_block_training_c2s{}->
			role_packet:handle(Message, RolePid);
		#query_time_c2s{}->
			role_packet:handle(Message, RolePid);
		#stop_move_c2s{}->
			role_packet:handle(Message, RolePid);

		%%identify_verify
		#identify_verify_c2s{}->
			role_packet:handle(Message, RolePid);		
		
		#mail_status_query_c2s{}->
			mail_packet:handle(Message, RolePid);
		#mail_query_detail_c2s{}->
			mail_packet:handle(Message, RolePid);
		
		#mail_send_c2s{}->
			mail_packet:handle(Message, RolePid);
		
		#mail_get_addition_c2s{}->
			mail_packet:handle(Message, RolePid);
		
		#mail_delete_c2s{}->
			mail_packet:handle(Message, RolePid);

		%%trade
		#trade_role_apply_c2s{}->
			trade_role_packet:handle(Message, RolePid);
		#trade_role_accept_c2s{}->
			trade_role_packet:handle(Message, RolePid);
		#trade_role_decline_c2s{}->
			trade_role_packet:handle(Message, RolePid);
		#set_trade_money_c2s{}->
			trade_role_packet:handle(Message, RolePid);
		#set_trade_item_c2s{}->
			trade_role_packet:handle(Message, RolePid);
		#cancel_trade_c2s{}->
			trade_role_packet:handle(Message, RolePid);
		#trade_role_lock_c2s{}->
			trade_role_packet:handle(Message, RolePid);
		#trade_role_dealit_c2s{}->
			trade_role_packet:handle(Message, RolePid);
		
		%% equipment
		#equipment_riseup_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_sock_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_inlay_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_stone_remove_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_stonemix_c2s{}->
			equipment_packet:handle(Message,RolePid);
		
		#equipment_stonemix_bat_c2s{}->
			equipment_packet:handle(Message,RolePid);		
		
		
		#equipment_upgrade_c2s{}->
			equipment_packet:handle(Message,RolePid);		
		#equipment_enchant_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_recast_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_recast_confirm_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_convert_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_move_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_remove_seal_c2s{}->
			equipment_packet:handle(Message,RolePid);
		#equipment_fenjie_c2s{}->
			equipment_packet:handle(Message,RolePid);
		
		%% achieve
		#achieve_open_c2s{}->
			achieve_packet:handle(Message,RolePid);
		#achieve_reward_c2s{}->
			achieve_packet:handle(Message,RolePid);
		
		%% goals
		#goals_reward_c2s{}->
			goals_packet:handle(Message, RolePid);
		#goals_init_c2s{}->
			goals_packet:handle(Message, RolePid);
		
		%%loop_tower
		#loop_tower_enter_c2s{}->
			loop_tower_packet:handle(Message, RolePid);
		#loop_tower_challenge_c2s{}->
			loop_tower_packet:handle(Message, RolePid);
		#loop_tower_reward_c2s{}->
			loop_tower_packet:handle(Message, RolePid);
		#loop_tower_challenge_again_c2s{}->
			loop_tower_packet:handle(Message, RolePid);
		#loop_tower_masters_c2s{}->
			loop_tower_packet:handle(Message, RolePid);
		
		%%VIP
		#vip_ui_c2s{}->
			vip_packet:handle(Message, RolePid);
		#vip_reward_c2s{}->
			vip_packet:handle(Message, RolePid);
		#login_bonus_reward_c2s{}->
			vip_packet:handle(Message, RolePid); 
		#join_vip_map_c2s{}->
			vip_packet:handle(Message, RolePid);
		%%petup
		#pet_up_reset_c2s{}->
			petup_packet:handle(Message, RolePid);
		#pet_up_growth_c2s{}->
			petup_packet:handle(Message, RolePid);
		#pet_up_stamina_growth_c2s{}->
			petup_packet:handle(Message, RolePid);
		#pet_up_exp_c2s{}->
			petup_packet:handle(Message, RolePid);
		#pet_riseup_c2s{}->
			petup_packet:handle(Message, RolePid);
		%%PVP
		#set_pkmodel_c2s{}->
			pvp_packet:handle(Message,RolePid);
		#duel_invite_c2s{}->
			pvp_packet:handle(Message,RolePid);
		#duel_decline_c2s{}->
			pvp_packet:handle(Message,RolePid);
		#duel_accept_c2s{}->
			pvp_packet:handle(Message,RolePid);  
		#npc_storage_items_c2s{}->
			role_packet:handle(Message,RolePid);
		#arrange_items_c2s{}->
			role_packet:handle(Message,RolePid);
		#fly_shoes_c2s{}->
			role_packet:handle(Message,RolePid);
		#use_target_item_c2s{}->
			role_packet:handle(Message,RolePid);
		#npc_swap_item_c2s{}->
			role_packet:handle(Message,RolePid);
		#battle_join_c2s{}->
			battle_ground_packet:handle(Message,RolePid);
		#battle_leave_c2s{}->
			battle_ground_packet:handle(Message,RolePid);
		#battle_reward_c2s{}->
			battle_ground_packet:handle(Message,RolePid);
		#get_instance_log_c2s{}->
			battle_ground_packet:handle(Message,RolePid);
		#tangle_records_c2s{}->
			battle_ground_packet:handle(Message,RolePid);
		#tangle_more_records_c2s{}->
			battle_ground_packet:handle(Message,RolePid);
		#tangle_kill_info_request_c2s{}->
			battle_ground_packet:handle(Message,RolePid);
		#clear_crime_c2s{}->
			pvp_packet:handle(Message, RolePid);
		#summon_pet_c2s{}->
			pet_packet:handle(Message, RolePid);
		#pet_move_c2s{}->
			pet_packet:handle(Message, RolePid);
		#car_move_c2s{}->
			pet_packet:handle(Message, RolePid);
		#pet_stop_move_c2s{}->
			pet_packet:handle(Message, RolePid);
		#pet_attack_c2s{}->
			pet_packet:handle(Message, RolePid);
		#pet_rename_c2s{}->
			pet_packet:handle(Message, RolePid);
		#pet_learn_skill_c2s{}->
			pet_packet:handle(Message, RolePid);
		#pet_forget_skill_c2s{}->
			pet_packet:handle(Message, RolePid);
		#pet_start_training_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_stop_training_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_speedup_training_c2s{}->
			pet_packet:handle(Message,RolePid);
		%%pet explore 
		#pet_explore_info_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_explore_start_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_explore_speedup_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_explore_stop_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_swap_slot_c2s{}->
			pet_packet:handle(Message, RolePid);
		%%pet exlore storage 
		#explore_storage_init_c2s{}->
			pet_packet:handle(Message, RolePid);
		#explore_storage_getitem_c2s{}->
			pet_packet:handle(Message, RolePid);
		#explore_storage_getallitems_c2s{}->
			pet_packet:handle(Message, RolePid);
		%%treasure_chest
		#treasure_chest_flush_c2s{}->
			treasure_chest_packet:handle(Message,RolePid);
		
		#treasure_chest_raffle_c2s{}->
			treasure_chest_packet:handle(Message,RolePid);
		
		#treasure_chest_obtain_c2s{}->
			treasure_chest_packet:handle(Message,RolePid);
			
		#treasure_chest_query_c2s{}->
			treasure_chest_packet:handle(Message,RolePid);
		#treasure_chest_disable_c2s{}->
			treasure_chest_packet:handle(Message,RolePid);
		%%treasure_chest_v2
		#beads_pray_request_c2s{}->
			treasure_chest_v2_packet:handle(Message,RolePid);

		#smashed_egg_init_c2s{}->
			smashed_egg_packet:handle(Message,RolePid);
		
		#smashed_egg_tamp_c2s{}->
			smashed_egg_packet:handle(Message,RolePid);

		#smashed_egg_refresh_c2s{}->
			smashed_egg_packet:handle(Message,RolePid);

		#god_tree_init_c2s{}->
			god_tree_packet:handle(Message,RolePid);

		#god_tree_rock_c2s{}->
			god_tree_packet:handle(Message,RolePid);
		
		#god_tree_init_storage_c2s{}->
			god_tree_storage_packet:handle(Message,RolePid);

		#god_tree_storage_getitem_c2s{}->
			god_tree_storage_packet:handle(Message,RolePid);
			
		#god_tree_storage_getallitems_c2s{}->
			god_tree_storage_packet:handle(Message,RolePid);
		%%congratulations
		#congratulations_levelup_c2s{}->
			congratulations_packet:handle(Message, RolePid);
		#congratulations_received_c2s{}->
			congratulations_packet:handle(Message, RolePid);
		%%offline_exp
		#offline_exp_exchange_c2s{}->
			offline_exp_packet:handle(Message, RolePid);
		#offline_exp_exchange_gold_c2s{}->
			offline_exp_packet:handle(Message, RolePid);
		%%exchange item
		#enum_exchange_item_c2s{} ->
			exchange_packet:handle(Message, RolePid);
		#exchange_item_c2s{} ->
			exchange_packet:handle(Message, RolePid);
		#battle_reward_by_records_c2s{} ->
			battle_ground_packet:handle(Message, RolePid);

		#get_timelimit_gift_c2s{}->
			timelimit_gift_packet:handle(Message,RolePid);
		#join_yhzq_c2s{} ->
			battle_ground_packet:handle(Message, RolePid);
		#leave_yhzq_c2s{}->
			battle_ground_packet:handle(Message, RolePid);
		#yhzq_award_c2s{}->
			battle_ground_packet:handle(Message, RolePid);
		#gift_card_apply_c2s{}->
			giftcard_packet:handle(Message, RolePid);
		#stall_sell_item_c2s{}->
			auction_packet:handle(Message, RolePid);
		#stall_recede_item_c2s{}->
			auction_packet:handle(Message, RolePid);
		#stalls_search_c2s{}->
			auction_packet:handle(Message, RolePid);
		#stalls_search_item_c2s{}->
			auction_packet:handle(Message, RolePid);
		#stall_detail_c2s{}->
			auction_packet:handle(Message, RolePid);
		#stall_buy_item_c2s{}->
			auction_packet:handle(Message, RolePid);
		#stall_rename_c2s{}->
			auction_packet:handle(Message, RolePid);
		#stall_role_detail_c2s{}->
			auction_packet:handle(Message, RolePid);
		
		#guild_get_application_c2s{}->
			guild_packet:handle(Message, RolePid);	
		#guild_application_op_c2s{}->
			guild_packet:handle(Message, RolePid);	
		#guild_change_nickname_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_change_chatandvoicegroup_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_get_shop_item_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_shop_buy_item_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_get_treasure_item_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_treasure_buy_item_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_treasure_set_price_c2s{}->
			guild_packet:handle(Message, RolePid);	
		#guild_member_pos_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_clear_nickname_c2s{}->
			guild_packet:handle(Message, RolePid);
		#levelup_opt_c2s{}->
			role_level_packet:handle(Message, RolePid);
		#publish_guild_quest_c2s{}->
			guild_packet:handle(Message, RolePid);
		#get_guild_notice_c2s{}->
			guild_packet:handle(Message, RolePid);
		#guild_mastercall_accept_c2s{}->
			guild_packet:handle(Message, RolePid);
		#activity_value_init_c2s{}->
			activity_value_packet:handle(Message, RolePid);
		#activity_value_reward_c2s{}->
			activity_value_packet:handle(Message, RolePid);
		#activity_state_init_c2s{}->
			active_borad_packet:handle(Message, RolePid);
		#activity_boss_born_init_c2s{}->
			active_borad_packet:handle(Message, RolePid);
		#sitdown_c2s{}->
			sitdown_packet:handle(Message,RolePid);
		#stop_sitdown_c2s{}->
			sitdown_packet:handle(Message,RolePid);
		#companion_sitdown_apply_c2s{}->
			sitdown_packet:handle_companion_sitdown(Message,RolePid);
		#companion_sitdown_start_c2s{}->
			sitdown_packet:handle(Message,RolePid);
		#companion_reject_c2s{}->
			sitdown_packet:handle_companion_sitdown(Message,RolePid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% dancing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		#companion_dancing_apply_c2s{}->
			banquet_packet:handle(Message,RolePid);
		#companion_dancing_start_c2s{}->
			banquet_packet:handle(Message,RolePid);
		#companion_dancing_reject_c2s{}->
			banquet_packet:handle(Message,RolePid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		#dragon_fight_num_c2s{}->
			dragon_fight_packet:handle(Message,RolePid);
		#dragon_fight_faction_c2s{}->
			dragon_fight_packet:handle(Message,RolePid);
		#dragon_fight_join_c2s{}->
			dragon_fight_packet:handle(Message,RolePid);			
		#venation_active_point_start_c2s{}->
			venation_packet:handle(Message,RolePid);
		#venation_advanced_start_c2s{}->
			venation_packet:handle(Message,RolePid);
		
		%%连续登录送礼
		#continuous_logging_gift_c2s{}->
			continuous_logging_packet:handle(Message,RolePid);
		#continuous_logging_board_c2s{}->
			continuous_logging_packet:handle(Message,RolePid);
		#continuous_days_clear_c2s{}->
			continuous_logging_packet:handle(Message,RolePid);
		
		%%收藏送礼
       #collect_page_c2s{}->
			continuous_logging_packet:handle(Message,RolePid);
		
		%#activity_test01_recv_c2s{}->
		%	continuous_logging_packet:handle(Message,RolePid);
		
		#first_charge_gift_reward_c2s{}->
			active_borad_packet:handle(Message,RolePid);
		#treasure_storage_init_c2s{}->
			treasure_storage_packet:handle(Message,RolePid);
		#treasure_storage_getitem_c2s{}->
			treasure_storage_packet:handle(Message,RolePid);
		#treasure_storage_getallitems_c2s{}->
			treasure_storage_packet:handle(Message,RolePid);		
		#chess_spirit_skill_levelup_c2s{}->
			chess_spirit_packet:handle(Message, RolePid);
		#chess_spirit_cast_skill_c2s{}->
			chess_spirit_packet:handle(Message, RolePid);
		#chess_spirit_cast_chess_skill_c2s{}->
			chess_spirit_packet:handle(Message, RolePid);
		#chess_spirit_log_c2s{}->
			chess_spirit_packet:handle(Message, RolePid);
		#chess_spirit_get_reward_c2s{}->
			chess_spirit_packet:handle(Message, RolePid);
		#chess_spirit_quit_c2s{}->
			chess_spirit_packet:handle(Message, RolePid);
		#rank_get_rank_c2s{}->
			game_rank_packet:handle(Message, RolePid);
		#rank_get_rank_role_c2s{}->
			game_rank_packet:handle(Message, RolePid);
		#rank_disdain_role_c2s{}->
			game_rank_packet:handle(Message, RolePid);
		#rank_praise_role_c2s{}->
			game_rank_packet:handle(Message, RolePid);
		#facebook_bind_check_c2s{}->
			facebook:handle(Message,RolePid);
		#welfare_panel_init_c2s{}->
			welfare_activity_packet:handle(Message,RolePid);
		#welfare_gold_exchange_init_c2s{}->
			welfare_activity_packet:handle(Message,RolePid);
		#welfare_gold_exchange_c2s{}->
			welfare_activity_packet:handle(Message,RolePid);
		#welfare_activity_update_c2s{}->
				welfare_activity_packet:handle(Message,RolePid);
		#item_identify_c2s{}->  
			ride_pet_packet:handle(Message,RolePid);
		#ride_pet_synthesis_c2s{}-> 
			ride_pet_packet:handle(Message,RolePid);
		%%pet upgrade quality 
		#pet_upgrade_quality_c2s{}->
			pet_packet:handle(Message, RolePid);
		#pet_upgrade_quality_up_c2s{}->
			pet_packet:handle(Message,RolePid);
		%%pet add attr and wash attr point
		#pet_add_attr_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_wash_attr_c2s{}->
			pet_packet:handle(Message, RolePid);
		#ride_opt_c2s{}->
			ride_pet_packet:handle(Message,RolePid);
		#pet_random_talent_c2s{}-> 
			pet_packet:handle(Message,RolePid);
		#pet_change_talent_c2s{}-> 
			pet_packet:handle(Message,RolePid);
		#pet_evolution_c2s{}-> 
			pet_packet:handle(Message,RolePid);
		#equip_item_for_pet_c2s{}->
			pet_packet:handle(Message,RolePid);
		#unequip_item_for_pet_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_skill_slot_lock_c2s{}->
			pet_packet:handle(Message,RolePid);
		#buy_pet_slot_c2s{}->
			pet_packet:handle(Message,RolePid);
		#pet_feed_c2s{}->
			pet_packet:handle(Message,RolePid);
		#refine_system_c2s{}->
			refine_system_packet:handle(Message,RolePid);
		#instance_leader_join_c2s{}->
			instance_packet:handle(Message, RolePid);
		#instance_exit_c2s{}->
			instance_packet:handle(Message, RolePid);

       %%副本元宝委托%
	   #instance_entrust_c2s{}->
			instance_packet:handle(Message, RolePid);


		#cancel_buff_c2s{}->
			buffer_packet:handle(Message, RolePid);
		#role_treasure_transport_time_check_c2s{}->
			treasure_transport_packet:handle(Message, RolePid);
		#start_guild_treasure_transport_c2s{}->
			treasure_transport_packet:handle(Message, RolePid);	
		
		#mainline_init_c2s{}->
			mainline_packet:handle(Message, RolePid);
		#mainline_start_entry_c2s{}->
			mainline_packet:handle(Message, RolePid);
		#mainline_start_c2s{}->
			mainline_packet:handle(Message, RolePid);
		#mainline_end_c2s{}->
			mainline_packet:handle(Message, RolePid);
		#mainline_reward_c2s{}->
			mainline_packet:handle(Message, RolePid);
		#mainline_timeout_c2s{}->
			mainline_packet:handle(Message, RolePid);
		
		#country_init_c2s{}->
			country_packet:handle(Message, RolePid);
		#change_country_notice_c2s{}->
			country_packet:handle(Message, RolePid);
		#change_country_transport_c2s{}->
			country_packet:handle(Message, RolePid);		
		#country_leader_promotion_c2s{}->
			country_packet:handle(Message, RolePid);
		#country_leader_demotion_c2s{}->
			country_packet:handle(Message, RolePid);
		#country_block_talk_c2s{}->
			country_packet:handle(Message, RolePid);
		#country_change_crime_c2s{}->
			country_packet:handle(Message, RolePid);
		#country_leader_get_itmes_c2s{}->
			country_packet:handle(Message, RolePid);
		#country_leader_ever_reward_c2s{}->
			country_packet:handle(Message, RolePid);
		
		#entry_guild_battle_c2s{}->
			guildbattle_packet:handle(Message, RolePid);
		#leave_guild_battle_c2s{}->
			guildbattle_packet:handle(Message, RolePid);
		#apply_guild_battle_c2s{}->
			guildbattle_packet:handle(Message, RolePid);
		#rank_get_main_line_rank_c2s{}->
			game_rank_packet:handle(Message, RolePid);	
		#server_version_c2s{}->
			try
				Msg = version:make_version(),
				tcp_client:send_data(self(),Msg)
			catch
				_:_->nothing
			end;
		#treasure_transport_call_guild_help_c2s{}->
			treasure_transport_packet:handle(Message, RolePid);
		%%festival activity 		
		#festival_init_c2s{}->
			festival_packet:handle(Message,RolePid);
		#festival_recharge_exchange_c2s{}->
			festival_packet:handle(Message,RolePid);
			
		#christmas_tree_grow_up_c2s{}->
			christmac_activity_packet:handle(Message,RolePid);
		#christmas_activity_reward_c2s{}->
			christmac_activity_packet:handle(Message,RolePid);
		
		%% loop instance
		#entry_loop_instance_apply_c2s{}->
			loop_instance_packet:handle(Message,RolePid);
		#entry_loop_instance_vote_c2s{}->
			loop_instance_packet:handle(Message,RolePid);
		#entry_loop_instance_c2s{}->
			loop_instance_packet:handle(Message,RolePid);
		#leave_loop_instance_c2s{}->
			loop_instance_packet:handle(Message,RolePid);
		%%honor shop
		#honor_stores_buy_items_c2s{}->
			honor_stores_packet:handle(Message,RolePid);
		#battlefield_info_c2s{}->
			battle_ground_packet:handle(Message,RolePid);
		#init_instance_quality_c2s{} ->
			instance_packet:handle(Message, RolePid);
		#refresh_instance_quality_c2s{} ->
			instance_packet:handle(Message, RolePid);
		%%宠物进阶
        #pet_grade_riseup_c2s{}->
            pet_packet:handle(Message,RolePid);
		
		% 6重礼包相关
		#charge_package_init_c2s{} ->
			charge_package_packet:handle(Message, RolePid);
		#get_charge_package_c2s{} ->
			charge_package_packet:handle(Message, RolePid);
		% 6重礼包相关
		#charge_reward_init_c2s{} ->
			charge_reward_packet:handle(Message, RolePid);
		#get_charge_reward_c2s{} ->
			charge_reward_packet:handle(Message, RolePid);
		%% 宠物资质协议处理
		#pet_qualification_upgrade_c2s{}->
			pet_packet:handle(Message,RolePid);
			
		#camp_battle_entry_c2s{}->
			camp_battle_packet:handle(Message,RolePid);
	    #camp_battle_player_num_c2s{}->
	        camp_battle_packet:handle(Message,RolePid);
	    #camp_battle_leave_c2s{}->
	        camp_battle_packet:handle(Message,RolePid);
        #camp_battle_last_record_c2s{}->
			camp_battle_packet:handle(Message,RolePid);
		#pet_shop_goods_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#buy_pet_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#refresh_remain_time_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#pet_type_change_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#pet_reset_type_attr_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#pet_inherit_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#pet_inherit_preview_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#get_gold_by_level_c2s{} ->
			levelgold_packet:handle(Message, RolePid);

		% 连续登陆
		#login_continuously_reward_c2s{} ->
			login_continuously_packet:handle(Message, RolePid);
		% 等级奖励
		#get_level_award_c2s{} ->
			levelitem_packet:handle(Message, RolePid);

		% 副本奖励
		#duplicate_prize_item_c2s{} ->
			role_processor:duplicate_prize_item(RolePid);
		#duplicate_prize_get_c2s{} ->
			role_processor:duplicate_prize_get(Message,RolePid);

		%% travel battle
		#travel_battle_query_role_info_c2s{} ->
		    travel_battle_packet:handle(Message, RolePid);

		#travel_battle_open_shop_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);

		#travel_battle_register_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);

		#travel_battle_lottery_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);

		#travel_battle_shop_buy_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);

		#travel_battle_change_skill_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);

		#travel_battle_upgrade_skill_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);

		#travel_battle_cast_skill_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);

		#travel_battle_cancel_match_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);

		#travel_battle_show_rank_page_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);
			
		#travel_battle_leave_c2s{} ->
			travel_battle_packet:handle(Message, RolePid);
		% wedding
		#wedding_apply_c2s{} ->
			wedding_packet:handle(Message, RolePid);

		#wedding_apply_agree_c2s{} ->
			wedding_packet:handle(Message, RolePid);

		#wedding_apply_refused_c2s{} ->
			wedding_packet:handle(Message, RolePid);

		#wedding_ceremony_time_available_c2s{} ->
			wedding_packet:handle(Message, RolePid);

		#wedding_ceremony_select_c2s{} ->
			wedding_packet:handle(Message, RolePid);

		#friend_send_flowers_c2s{} ->
			friend_packet:handle(Message, RolePid);

		%pet new add
		#pet_shop_c2s{} ->
			pet_packet:handle(Message,RolePid);
			
		#pet_room_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#pet_open_room_c2s{} ->
			pet_packet:handle(Message,RolePid);

		#pet_into_room_c2s{} ->
		pet_packet:handle(Message,RolePid);

		#pet_room_balance_c2s{} ->
		pet_packet:handle(Message,RolePid);

		#pet_skill_fuse_c2s{} ->
		pet_packet:handle(Message,RolePid);

		#pet_skill_buy_slot_c2s{} ->
		pet_packet:handle(Message,RolePid);

		#pet_swank_c2s{} ->
		pet_packet:handle(Message,RolePid);

		#pet_egg_use_c2s{} ->
		pet_packet:handle(Message,RolePid);

		#pet_sex_change_c2s{} ->
		pet_packet:handle(Message,RolePid);

		#pet_exp_use_c2s{} ->
		pet_packet:handle(Message,RolePid);

		#pet_skill_fuse_del_c2s{} ->
		pet_packet:handle(Message,RolePid);
	
		#icon_show_list_c2s{} ->
		role_packet:handle(Message,RolePid);

		% bang da yuanyang
		#bdyy_start_c2s{} ->
			bdyy_packet:handle(Message, RolePid);
		#bdyy_item_hit_c2s{} ->
			bdyy_packet:handle(Message, RolePid);
		#bdyy_end_c2s{} ->
			bdyy_packet:handle(Message, RolePid);
			
		#query_system_switch_c2s{}->
			system_switch:handle(Message,RolePid);

		#query_open_service_aution_info_c2s{} ->
			open_service_auction_packet:handle(Message, RolePid);

		#open_service_aution_bid_c2s{} ->
			open_service_auction_packet:handle(Message, RolePid);
			
		#temp_activity_contents_c2s{} ->
			top_bar_item_packet:handle(Message, RolePid);

		#temp_activity_get_award_c2s{} ->
			top_bar_item_packet:handle(Message, RolePid);

		#open_charge_feedback_lottery_c2s{} ->
			open_charge_feedback_packet:handle(Message, RolePid);

		#open_charge_feedback_get_award_c2s{} ->
			open_charge_feedback_packet:handle(Message, RolePid);

		#query_open_service_time_c2s{} ->
			open_service_packet:handle(Message, RolePid);

		#trade_item_c2s{} ->
			role_packet:handle(Message, RolePid);

		%% travel match
		#travel_match_query_role_info_c2s{} ->
			travel_match_packet:handle(Message, RolePid);
			
		#travel_match_register_c2s{} ->
			travel_match_packet:handle(Message, RolePid);

		#travel_match_enter_wait_map_c2s{} ->
			travel_match_packet:handle(Message, RolePid);

		#travel_match_leave_wait_map_c2s{} ->
			travel_match_packet:handle(Message, RolePid);

		#travel_match_query_unit_player_list_c2s{} ->
			travel_match_packet:handle(Message, RolePid);

		#travel_match_query_session_data_c2s{} ->
			travel_match_packet:handle(Message, RolePid);

		#query_travel_server_status_c2s{} ->
			role_packet:handle(Message, RolePid);

		#dead_valley_enter_c2s{} ->
			dead_valley_packet:handle(Message, RolePid);

		#dead_valley_leave_c2s{} ->
			dead_valley_packet:handle(Message, RolePid);

		#dead_valley_trap_touch_c2s{} ->
			dead_valley_packet:handle(Message, RolePid);

		#dead_valley_trap_leave_c2s{} ->
			dead_valley_packet:handle(Message, RolePid);

		#dead_valley_query_zone_info_c2s{} ->
			dead_valley_packet:handle(Message, RolePid);

		_UnknMsg -> slogger:msg("get unknown message ~p\n",[Message])
	end.
