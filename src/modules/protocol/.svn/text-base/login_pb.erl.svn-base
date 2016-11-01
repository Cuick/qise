-module(login_pb).
-include("login_pb.hrl").
-compile(export_all).
-export([create/0,init/0]).

-behaviour(ets_operater_mod).

create()->
	ets:new(proto_msg_id_record_map,[set,named_table]).

get_record_name(ID)->
	case ets:lookup(proto_msg_id_record_map,ID) of
		[]->error;
		[{_Id,Rec}]->Rec
	end.

init()->
	ets:insert(proto_msg_id_record_map,{5,'player_role_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{6,'role_line_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{7,'role_line_query_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{9,'role_change_line_c2s'}),
	ets:insert(proto_msg_id_record_map,{10,'player_select_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{13,'map_complete_c2s'}),
	ets:insert(proto_msg_id_record_map,{14,'role_map_change_s2c'}),
	ets:insert(proto_msg_id_record_map,{15,'npc_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{16,'other_role_map_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{22,'role_change_map_c2s'}),
	ets:insert(proto_msg_id_record_map,{23,'role_change_map_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{24,'role_change_map_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{25,'role_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{26,'heartbeat_c2s'}),
	ets:insert(proto_msg_id_record_map,{27,'other_role_move_s2c'}),
	ets:insert(proto_msg_id_record_map,{28,'role_move_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{29,'role_attack_c2s'}),
	ets:insert(proto_msg_id_record_map,{31,'role_attack_s2c'}),
	ets:insert(proto_msg_id_record_map,{32,'role_cancel_attack_s2c'}),
	ets:insert(proto_msg_id_record_map,{33,'be_attacked_s2c'}),
	ets:insert(proto_msg_id_record_map,{34,'be_killed_s2c'}),
	ets:insert(proto_msg_id_record_map,{35,'other_role_into_view_s2c'}),
	ets:insert(proto_msg_id_record_map,{36,'npc_into_view_s2c'}),
	ets:insert(proto_msg_id_record_map,{37,'creature_outof_view_s2c'}),
	ets:insert(proto_msg_id_record_map,{38,'debug_c2s'}),
	ets:insert(proto_msg_id_record_map,{39,'use_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{40,'auto_equip_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{41,'change_item_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{42,'use_item_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{43,'buff_immune_s2c'}),
	ets:insert(proto_msg_id_record_map,{53,'role_attribute_s2c'}),
	ets:insert(proto_msg_id_record_map,{54,'npc_attribute_s2c'}),
	ets:insert(proto_msg_id_record_map,{55,'role_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{56,'guild_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{57,'rename_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{61,'role_map_change_c2s'}),
	ets:insert(proto_msg_id_record_map,{62,'npc_map_change_c2s'}),
	ets:insert(proto_msg_id_record_map,{63,'map_change_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{70,'skill_panel_c2s'}),
	ets:insert(proto_msg_id_record_map,{71,'learned_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{72,'display_hotbar_s2c'}),
	ets:insert(proto_msg_id_record_map,{73,'update_hotbar_c2s'}),
	ets:insert(proto_msg_id_record_map,{74,'update_hotbar_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{75,'update_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{81,'quest_list_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{82,'quest_list_remove_s2c'}),
	ets:insert(proto_msg_id_record_map,{83,'quest_list_add_s2c'}),
	ets:insert(proto_msg_id_record_map,{84,'quest_statu_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{85,'questgiver_hello_c2s'}),
	ets:insert(proto_msg_id_record_map,{86,'questgiver_quest_details_s2c'}),
	ets:insert(proto_msg_id_record_map,{87,'questgiver_accept_quest_c2s'}),
	ets:insert(proto_msg_id_record_map,{88,'quest_quit_c2s'}),
	ets:insert(proto_msg_id_record_map,{89,'questgiver_complete_quest_c2s'}),
	ets:insert(proto_msg_id_record_map,{90,'quest_complete_s2c'}),
	ets:insert(proto_msg_id_record_map,{91,'quest_complete_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{92,'questgiver_states_update_c2s'}),
	ets:insert(proto_msg_id_record_map,{93,'questgiver_states_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{94,'quest_details_c2s'}),
	ets:insert(proto_msg_id_record_map,{95,'quest_details_s2c'}),
	ets:insert(proto_msg_id_record_map,{96,'quest_get_adapt_c2s'}),
	ets:insert(proto_msg_id_record_map,{97,'quest_get_adapt_s2c'}),
	ets:insert(proto_msg_id_record_map,{98,'quest_accept_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{99,'quest_direct_complete_c2s'}),
	ets:insert(proto_msg_id_record_map,{101,'add_buff_s2c'}),
	ets:insert(proto_msg_id_record_map,{102,'del_buff_s2c'}),
	ets:insert(proto_msg_id_record_map,{103,'buff_affect_attr_s2c'}),
	ets:insert(proto_msg_id_record_map,{104,'move_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{105,'loot_s2c'}),
	ets:insert(proto_msg_id_record_map,{106,'loot_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{107,'loot_response_s2c'}),
	ets:insert(proto_msg_id_record_map,{108,'loot_pick_c2s'}),
	ets:insert(proto_msg_id_record_map,{109,'loot_remove_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{110,'loot_release_s2c'}),
	ets:insert(proto_msg_id_record_map,{111,'player_level_up_s2c'}),
	ets:insert(proto_msg_id_record_map,{112,'cancel_buff_c2s'}),
	ets:insert(proto_msg_id_record_map,{113,'money_from_monster_s2c'}),
	ets:insert(proto_msg_id_record_map,{120,'update_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{121,'add_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{122,'add_item_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{123,'destroy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{124,'delete_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{125,'split_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{126,'swap_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{127,'init_onhands_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{128,'npc_storage_items_c2s'}),
	ets:insert(proto_msg_id_record_map,{129,'npc_storage_items_s2c'}),
	ets:insert(proto_msg_id_record_map,{130,'arrange_items_c2s'}),
	ets:insert(proto_msg_id_record_map,{131,'arrange_items_s2c'}),
	ets:insert(proto_msg_id_record_map,{140,'chat_c2s'}),
	ets:insert(proto_msg_id_record_map,{141,'chat_s2c'}),
	ets:insert(proto_msg_id_record_map,{142,'chat_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{143,'loudspeaker_queue_num_c2s'}),
	ets:insert(proto_msg_id_record_map,{144,'loudspeaker_queue_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{145,'loudspeaker_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{146,'chat_private_c2s'}),
	ets:insert(proto_msg_id_record_map,{147,'chat_private_s2c'}),
	ets:insert(proto_msg_id_record_map,{150,'group_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{151,'group_agree_c2s'}),
	ets:insert(proto_msg_id_record_map,{152,'group_create_c2s'}),
	ets:insert(proto_msg_id_record_map,{153,'group_invite_c2s'}),
	ets:insert(proto_msg_id_record_map,{154,'group_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{155,'group_decline_c2s'}),
	ets:insert(proto_msg_id_record_map,{156,'group_kickout_c2s'}),
	ets:insert(proto_msg_id_record_map,{157,'group_setleader_c2s'}),
	ets:insert(proto_msg_id_record_map,{158,'group_disband_c2s'}),
	ets:insert(proto_msg_id_record_map,{159,'group_depart_c2s'}),
	ets:insert(proto_msg_id_record_map,{160,'group_invite_s2c'}),
	ets:insert(proto_msg_id_record_map,{161,'group_decline_s2c'}),
	ets:insert(proto_msg_id_record_map,{162,'group_destroy_s2c'}),
	ets:insert(proto_msg_id_record_map,{163,'group_list_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{164,'group_cmd_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{165,'group_member_stats_s2c'}),
	ets:insert(proto_msg_id_record_map,{166,'group_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{167,'recruite_c2s'}),
	ets:insert(proto_msg_id_record_map,{168,'recruite_cancel_c2s'}),
	ets:insert(proto_msg_id_record_map,{169,'recruite_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{170,'recruite_query_s2c'}),
	ets:insert(proto_msg_id_record_map,{171,'recruite_cancel_s2c'}),
	ets:insert(proto_msg_id_record_map,{172,'role_recruite_c2s'}),
	ets:insert(proto_msg_id_record_map,{173,'role_recruite_cancel_c2s'}),
	ets:insert(proto_msg_id_record_map,{174,'role_recruite_cancel_s2c'}),
	ets:insert(proto_msg_id_record_map,{175,'aoi_role_group_c2s'}),
	ets:insert(proto_msg_id_record_map,{176,'aoi_role_group_s2c'}),
	ets:insert(proto_msg_id_record_map,{300,'npc_fucnction_common_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{301,'npc_function_c2s'}),
	ets:insert(proto_msg_id_record_map,{302,'npc_function_s2c'}),
	ets:insert(proto_msg_id_record_map,{310,'enum_shoping_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{311,'enum_shoping_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{312,'enum_shoping_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{313,'buy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{314,'buy_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{315,'sell_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{316,'sell_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{317,'repair_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{340,'fatigue_prompt_with_type_s2c'}),
	ets:insert(proto_msg_id_record_map,{341,'fatigue_login_disabled_s2c'}),
	ets:insert(proto_msg_id_record_map,{350,'fatigue_prompt_s2c'}),
	ets:insert(proto_msg_id_record_map,{351,'fatigue_alert_s2c'}),
	ets:insert(proto_msg_id_record_map,{352,'finish_register_s2c'}),
	ets:insert(proto_msg_id_record_map,{353,'object_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{354,'guild_monster_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{355,'upgrade_guild_monster_c2s'}),
	ets:insert(proto_msg_id_record_map,{357,'change_smith_need_contribution_c2s'}),
	ets:insert(proto_msg_id_record_map,{358,'leave_guild_instance_c2s'}),
	ets:insert(proto_msg_id_record_map,{359,'join_guild_instance_c2s'}),
	ets:insert(proto_msg_id_record_map,{360,'guild_create_c2s'}),
	ets:insert(proto_msg_id_record_map,{361,'guild_disband_c2s'}),
	ets:insert(proto_msg_id_record_map,{362,'guild_member_invite_c2s'}),
	ets:insert(proto_msg_id_record_map,{363,'guild_member_decline_c2s'}),
	ets:insert(proto_msg_id_record_map,{364,'guild_member_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{365,'guild_member_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{366,'guild_member_depart_c2s'}),
	ets:insert(proto_msg_id_record_map,{367,'guild_member_kickout_c2s'}),
	ets:insert(proto_msg_id_record_map,{368,'guild_set_leader_c2s'}),
	ets:insert(proto_msg_id_record_map,{369,'guild_member_promotion_c2s'}),
	ets:insert(proto_msg_id_record_map,{370,'guild_member_demotion_c2s'}),
	ets:insert(proto_msg_id_record_map,{371,'guild_log_normal_c2s'}),
	ets:insert(proto_msg_id_record_map,{372,'guild_log_event_c2s'}),
	ets:insert(proto_msg_id_record_map,{373,'guild_notice_modify_c2s'}),
	ets:insert(proto_msg_id_record_map,{374,'guild_facilities_accede_rules_c2s'}),
	ets:insert(proto_msg_id_record_map,{375,'guild_facilities_upgrade_c2s'}),
	ets:insert(proto_msg_id_record_map,{376,'guild_facilities_speed_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{377,'guild_rewards_c2s'}),
	ets:insert(proto_msg_id_record_map,{378,'guild_recruite_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{379,'guild_member_contribute_c2s'}),
	ets:insert(proto_msg_id_record_map,{380,'guild_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{381,'guild_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{382,'guild_base_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{383,'guild_member_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{384,'guild_facilities_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{385,'guild_member_delete_s2c'}),
	ets:insert(proto_msg_id_record_map,{386,'guild_member_add_s2c'}),
	ets:insert(proto_msg_id_record_map,{387,'guild_destroy_s2c'}),
	ets:insert(proto_msg_id_record_map,{388,'guild_member_decline_s2c'}),
	ets:insert(proto_msg_id_record_map,{389,'guild_member_invite_s2c'}),
	ets:insert(proto_msg_id_record_map,{391,'guild_recruite_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{392,'guild_log_normal_s2c'}),
	ets:insert(proto_msg_id_record_map,{393,'guild_log_event_s2c'}),
	ets:insert(proto_msg_id_record_map,{394,'guild_get_application_c2s'}),
	ets:insert(proto_msg_id_record_map,{395,'guild_get_application_s2c'}),
	ets:insert(proto_msg_id_record_map,{396,'guild_application_op_c2s'}),
	ets:insert(proto_msg_id_record_map,{397,'guild_change_nickname_c2s'}),
	ets:insert(proto_msg_id_record_map,{398,'guild_change_chatandvoicegroup_c2s'}),
	ets:insert(proto_msg_id_record_map,{399,'guild_update_log_s2c'}),
	ets:insert(proto_msg_id_record_map,{400,'create_role_request_c2s'}),
	ets:insert(proto_msg_id_record_map,{401,'create_role_sucess_s2c'}),
	ets:insert(proto_msg_id_record_map,{402,'create_role_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{403,'inspect_c2s'}),
	ets:insert(proto_msg_id_record_map,{404,'inspect_s2c'}),
	ets:insert(proto_msg_id_record_map,{405,'inspect_faild_s2c'}),
	ets:insert(proto_msg_id_record_map,{410,'user_auth_c2s'}),
	ets:insert(proto_msg_id_record_map,{411,'user_auth_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{412,'enum_skill_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{413,'enum_skill_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{414,'enum_skill_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{415,'skill_learn_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{2055,'skill_auto_learn_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{416,'skill_learn_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{417,'feedback_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{418,'feedback_info_ret_s2c'}),
	ets:insert(proto_msg_id_record_map,{419,'role_respawn_c2s'}),
	ets:insert(proto_msg_id_record_map,{420,'other_login_s2c'}),
	ets:insert(proto_msg_id_record_map,{421,'block_s2c'}),
	ets:insert(proto_msg_id_record_map,{422,'is_jackaroo_s2c'}),
	ets:insert(proto_msg_id_record_map,{423,'is_visitor_c2s'}),
	ets:insert(proto_msg_id_record_map,{425,'is_finish_visitor_c2s'}),
	ets:insert(proto_msg_id_record_map,{426,'visitor_rename_s2c'}),
	ets:insert(proto_msg_id_record_map,{427,'visitor_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{428,'visitor_rename_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{429,'mall_item_list_c2s'}),
	ets:insert(proto_msg_id_record_map,{430,'mall_item_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{438,'init_mall_item_list_c2s'}),
	ets:insert(proto_msg_id_record_map,{439,'init_mall_item_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{431,'buy_mall_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{432,'init_hot_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{433,'init_latest_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{434,'mall_item_list_special_c2s'}),
	ets:insert(proto_msg_id_record_map,{435,'mall_item_list_special_s2c'}),
	ets:insert(proto_msg_id_record_map,{436,'mall_item_list_sales_c2s'}),
	ets:insert(proto_msg_id_record_map,{437,'mall_item_list_sales_s2c'}),
	ets:insert(proto_msg_id_record_map,{440,'change_role_mall_integral_s2c'}),
	ets:insert(proto_msg_id_record_map,{450,'query_player_option_c2s'}),
	ets:insert(proto_msg_id_record_map,{451,'query_player_option_s2c'}),
	ets:insert(proto_msg_id_record_map,{452,'replace_player_option_c2s'}),
	ets:insert(proto_msg_id_record_map,{453,'info_back_c2s'}),
	ets:insert(proto_msg_id_record_map,{469,'revert_black_c2s'}),
	ets:insert(proto_msg_id_record_map,{470,'revert_black_s2c'}),
	ets:insert(proto_msg_id_record_map,{471,'init_signature_s2c'}),
	ets:insert(proto_msg_id_record_map,{472,'add_signature_c2s'}),
	ets:insert(proto_msg_id_record_map,{473,'get_friend_signature_c2s'}),
	ets:insert(proto_msg_id_record_map,{474,'get_friend_signature_s2c'}),
	ets:insert(proto_msg_id_record_map,{475,'set_black_c2s'}),
	ets:insert(proto_msg_id_record_map,{476,'set_black_s2c'}),
	ets:insert(proto_msg_id_record_map,{477,'delete_black_c2s'}),
	ets:insert(proto_msg_id_record_map,{478,'delete_black_s2c'}),
	ets:insert(proto_msg_id_record_map,{479,'black_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{480,'myfriends_c2s'}),
	ets:insert(proto_msg_id_record_map,{481,'myfriends_s2c'}),
	ets:insert(proto_msg_id_record_map,{482,'add_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{1500091,'add_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{1500092,'add_friend_respond_c2s'}),
	ets:insert(proto_msg_id_record_map,{1500093,'add_friend_respond_s2c'}),
	ets:insert(proto_msg_id_record_map,{1500094,'delete_friend_beidong_s2c'}),
	ets:insert(proto_msg_id_record_map,{483,'add_friend_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{484,'add_friend_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{485,'becare_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{486,'delete_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{487,'delete_friend_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{488,'delete_friend_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{489,'online_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{490,'offline_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{491,'detail_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{492,'detail_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{493,'detail_friend_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{494,'position_friend_c2s'}),
	ets:insert(proto_msg_id_record_map,{495,'position_friend_s2c'}),
	ets:insert(proto_msg_id_record_map,{496,'position_friend_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{498,'add_black_s2c'}),
	ets:insert(proto_msg_id_record_map,{501,'lottery_lefttime_s2c'}),
	ets:insert(proto_msg_id_record_map,{502,'lottery_leftcount_s2c'}),
	ets:insert(proto_msg_id_record_map,{504,'lottery_clickslot_c2s'}),
	ets:insert(proto_msg_id_record_map,{505,'lottery_clickslot_s2c'}),
	ets:insert(proto_msg_id_record_map,{506,'lottery_otherslot_s2c'}),
	ets:insert(proto_msg_id_record_map,{507,'lottery_notic_s2c'}),
	ets:insert(proto_msg_id_record_map,{508,'lottery_clickslot_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{509,'lottery_querystatus_c2s'}),
	ets:insert(proto_msg_id_record_map,{510,'start_block_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{511,'start_block_training_s2c'}),
	ets:insert(proto_msg_id_record_map,{512,'end_block_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{513,'end_block_training_s2c'}),
	ets:insert(proto_msg_id_record_map,{530,'mail_status_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{531,'mail_status_query_s2c'}),
	ets:insert(proto_msg_id_record_map,{532,'mail_arrived_s2c'}),
	ets:insert(proto_msg_id_record_map,{533,'mail_query_detail_c2s'}),
	ets:insert(proto_msg_id_record_map,{534,'mail_query_detail_s2c'}),
	ets:insert(proto_msg_id_record_map,{535,'mail_get_addition_c2s'}),
	ets:insert(proto_msg_id_record_map,{536,'mail_get_addition_s2c'}),
	ets:insert(proto_msg_id_record_map,{537,'mail_send_c2s'}),
	ets:insert(proto_msg_id_record_map,{538,'mail_delete_c2s'}),
	ets:insert(proto_msg_id_record_map,{539,'mail_delete_s2c'}),
	ets:insert(proto_msg_id_record_map,{540,'mail_operator_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{541,'mail_sucess_s2c'}),
	ets:insert(proto_msg_id_record_map,{560,'trade_role_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{561,'trade_role_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{562,'trade_role_decline_c2s'}),
	ets:insert(proto_msg_id_record_map,{563,'set_trade_money_c2s'}),
	ets:insert(proto_msg_id_record_map,{564,'set_trade_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{565,'cancel_trade_c2s'}),
	ets:insert(proto_msg_id_record_map,{566,'trade_role_lock_c2s'}),
	ets:insert(proto_msg_id_record_map,{567,'trade_role_dealit_c2s'}),
	ets:insert(proto_msg_id_record_map,{570,'trade_role_errno_s2c'}),
	ets:insert(proto_msg_id_record_map,{571,'trade_begin_s2c'}),
	ets:insert(proto_msg_id_record_map,{572,'update_trade_status_s2c'}),
	ets:insert(proto_msg_id_record_map,{573,'trade_role_lock_s2c'}),
	ets:insert(proto_msg_id_record_map,{574,'trade_role_dealit_s2c'}),
	ets:insert(proto_msg_id_record_map,{575,'trade_role_decline_s2c'}),
	ets:insert(proto_msg_id_record_map,{576,'trade_role_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{577,'cancel_trade_s2c'}),
	ets:insert(proto_msg_id_record_map,{578,'trade_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{600,'equipment_riseup_c2s'}),
	ets:insert(proto_msg_id_record_map,{601,'equipment_riseup_s2c'}),
	ets:insert(proto_msg_id_record_map,{602,'equipment_riseup_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{603,'equipment_sock_c2s'}),
	ets:insert(proto_msg_id_record_map,{604,'equipment_sock_s2c'}),
	ets:insert(proto_msg_id_record_map,{605,'equipment_sock_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{606,'equipment_inlay_c2s'}),
	ets:insert(proto_msg_id_record_map,{607,'equipment_inlay_s2c'}),
	ets:insert(proto_msg_id_record_map,{608,'equipment_inlay_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{609,'equipment_stone_remove_c2s'}),
	ets:insert(proto_msg_id_record_map,{610,'equipment_stone_remove_s2c'}),
	ets:insert(proto_msg_id_record_map,{611,'equipment_stone_remove_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{612,'equipment_stonemix_c2s'}),
     %%批量合成%%
    ets:insert(proto_msg_id_record_map,{599,'equipment_stonemix_bat_c2s'}),
    ets:insert(proto_msg_id_record_map,{595,'equipment_stonemix_bat_result_s2c'}),

	ets:insert(proto_msg_id_record_map,{613,'equipment_stonemix_s2c'}),
	ets:insert(proto_msg_id_record_map,{614,'equipment_stonemix_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{615,'equipment_upgrade_c2s'}),
	ets:insert(proto_msg_id_record_map,{616,'equipment_upgrade_s2c'}),
	ets:insert(proto_msg_id_record_map,{617,'equipment_enchant_c2s'}),
	ets:insert(proto_msg_id_record_map,{618,'equipment_enchant_s2c'}),
	ets:insert(proto_msg_id_record_map,{619,'equipment_recast_c2s'}),
	ets:insert(proto_msg_id_record_map,{620,'equipment_recast_s2c'}),
	ets:insert(proto_msg_id_record_map,{621,'equipment_recast_confirm_c2s'}),
	ets:insert(proto_msg_id_record_map,{622,'equipment_convert_c2s'}),
	ets:insert(proto_msg_id_record_map,{623,'equipment_convert_s2c'}),
	ets:insert(proto_msg_id_record_map,{624,'equipment_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{625,'equipment_move_s2c'}),
	ets:insert(proto_msg_id_record_map,{626,'equipment_remove_seal_s2c'}),
	ets:insert(proto_msg_id_record_map,{627,'equipment_remove_seal_c2s'}),
	ets:insert(proto_msg_id_record_map,{628,'equipment_fenjie_c2s'}),
	ets:insert(proto_msg_id_record_map,{629,'equip_fenjie_optresult_s2c'}),
	ets:insert(proto_msg_id_record_map,{630,'achieve_open_c2s'}),
	ets:insert(proto_msg_id_record_map,{631,'achieve_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{632,'achieve_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{633,'achieve_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{634,'achieve_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{640,'goals_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{641,'goals_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{642,'goals_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{643,'goals_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{644,'goals_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{650,'loop_tower_enter_c2s'}),
	ets:insert(proto_msg_id_record_map,{651,'loop_tower_enter_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{652,'loop_tower_masters_c2s'}),
	ets:insert(proto_msg_id_record_map,{653,'loop_tower_masters_s2c'}),
	ets:insert(proto_msg_id_record_map,{654,'loop_tower_enter_s2c'}),
	ets:insert(proto_msg_id_record_map,{655,'loop_tower_challenge_c2s'}),
	ets:insert(proto_msg_id_record_map,{656,'loop_tower_challenge_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{657,'loop_tower_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{658,'loop_tower_challenge_again_c2s'}),
	ets:insert(proto_msg_id_record_map,{659,'loop_tower_enter_higher_s2c'}),
	ets:insert(proto_msg_id_record_map,{670,'vip_ui_c2s'}),
	ets:insert(proto_msg_id_record_map,{671,'vip_ui_s2c'}),
	ets:insert(proto_msg_id_record_map,{672,'vip_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{673,'vip_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{674,'vip_level_up_s2c'}),
	ets:insert(proto_msg_id_record_map,{675,'vip_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{676,'vip_npc_enum_s2c'}),
	ets:insert(proto_msg_id_record_map,{677,'login_bonus_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{678,'vip_role_use_flyshoes_s2c'}),
	ets:insert(proto_msg_id_record_map,{679,'join_vip_map_c2s'}),
	ets:insert(proto_msg_id_record_map,{700,'query_system_switch_c2s'}),
	ets:insert(proto_msg_id_record_map,{701,'system_status_s2c'}),
	ets:insert(proto_msg_id_record_map,{710,'duel_invite_c2s'}),
	ets:insert(proto_msg_id_record_map,{711,'duel_decline_c2s'}),
	ets:insert(proto_msg_id_record_map,{712,'duel_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{720,'duel_invite_s2c'}),
	ets:insert(proto_msg_id_record_map,{721,'duel_decline_s2c'}),
	ets:insert(proto_msg_id_record_map,{722,'duel_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{723,'duel_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{730,'set_pkmodel_c2s'}),
	ets:insert(proto_msg_id_record_map,{731,'set_pkmodel_faild_s2c'}),
	ets:insert(proto_msg_id_record_map,{733,'clear_crime_c2s'}),
	ets:insert(proto_msg_id_record_map,{734,'clear_crime_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{740,'query_time_c2s'}),
	ets:insert(proto_msg_id_record_map,{741,'query_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{742,'stop_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{800,'identify_verify_c2s'}),
	ets:insert(proto_msg_id_record_map,{801,'identify_verify_s2c'}),
	ets:insert(proto_msg_id_record_map,{809,'mp_package_s2c'}),
	ets:insert(proto_msg_id_record_map,{810,'fly_shoes_c2s'}),
	ets:insert(proto_msg_id_record_map,{811,'hp_package_s2c'}),
	ets:insert(proto_msg_id_record_map,{812,'npc_swap_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{813,'use_target_item_c2s'}),
    ets:insert(proto_msg_id_record_map,{817,'battle_totleadd_honor_s2c'}),
	ets:insert(proto_msg_id_record_map,{818,'join_battle_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{819,'tangle_battlefield_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{820,'battle_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{821,'battle_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{822,'battle_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{823,'battle_self_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{824,'tangle_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{825,'tangle_remove_s2c'}),
	ets:insert(proto_msg_id_record_map,{826,'battle_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{827,'battle_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{828,'battle_other_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{829,'battle_waiting_s2c'}),
	ets:insert(proto_msg_id_record_map,{830,'instance_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{831,'get_instance_log_c2s'}),
	ets:insert(proto_msg_id_record_map,{832,'get_instance_log_s2c'}),
	ets:insert(proto_msg_id_record_map,{833,'tangle_records_s2c'}),
	ets:insert(proto_msg_id_record_map,{834,'tangle_records_c2s'}),
	ets:insert(proto_msg_id_record_map,{835,'tangle_topman_pos_s2c'}),
	ets:insert(proto_msg_id_record_map,{836,'tangle_more_records_c2s'}),
	ets:insert(proto_msg_id_record_map,{837,'tangle_more_records_s2c'}),
	ets:insert(proto_msg_id_record_map,{838,'instance_exit_c2s'}),
	ets:insert(proto_msg_id_record_map,{840,'instance_leader_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{841,'instance_leader_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{850,'start_everquest_s2c'}),
	ets:insert(proto_msg_id_record_map,{851,'update_everquest_s2c'}),
	ets:insert(proto_msg_id_record_map,{852,'refresh_everquest_c2s'}),
	ets:insert(proto_msg_id_record_map,{853,'refresh_everquest_s2c'}),
	ets:insert(proto_msg_id_record_map,{854,'npc_start_everquest_c2s'}),
	ets:insert(proto_msg_id_record_map,{855,'npc_everquests_enum_c2s'}),
	ets:insert(proto_msg_id_record_map,{856,'npc_everquests_enum_s2c'}),
	ets:insert(proto_msg_id_record_map,{857,'everquest_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{858,'instance_end_seconds_s2c'}),
	ets:insert(proto_msg_id_record_map,{900,'init_pets_s2c'}),
	ets:insert(proto_msg_id_record_map,{901,'create_pet_s2c'}),
	ets:insert(proto_msg_id_record_map,{902,'summon_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{903,'pet_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{977,'car_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{904,'pet_stop_move_c2s'}),
	ets:insert(proto_msg_id_record_map,{905,'pet_attack_c2s'}),
	ets:insert(proto_msg_id_record_map,{906,'pet_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{907,'pet_present_s2c'}),
	ets:insert(proto_msg_id_record_map,{908,'pet_present_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{909,'pet_present_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{910,'pet_up_reset_c2s'}),
	ets:insert(proto_msg_id_record_map,{911,'pet_up_reset_s2c'}),
	ets:insert(proto_msg_id_record_map,{912,'pet_up_growth_c2s'}),
	ets:insert(proto_msg_id_record_map,{913,'pet_up_stamina_growth_c2s'}),
	ets:insert(proto_msg_id_record_map,{914,'pet_up_growth_s2c'}),
	ets:insert(proto_msg_id_record_map,{915,'pet_up_stamina_growth_s2c'}),
	ets:insert(proto_msg_id_record_map,{916,'pet_opt_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{917,'pet_learn_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{918,'pet_up_exp_c2s'}),
	ets:insert(proto_msg_id_record_map,{919,'pet_forget_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{920,'pet_delete_s2c'}),
	ets:insert(proto_msg_id_record_map,{921,'pet_swap_slot_c2s'}),
	ets:insert(proto_msg_id_record_map,{922,'inspect_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{923,'inspect_pet_s2c'}),
	ets:insert(proto_msg_id_record_map,{924,'pet_riseup_c2s'}),
	ets:insert(proto_msg_id_record_map,{925,'pet_riseup_s2c'}),
	ets:insert(proto_msg_id_record_map,{926,'pet_skill_slot_lock_c2s'}),
	ets:insert(proto_msg_id_record_map,{927,'update_pet_skill_slot_s2c'}),
	ets:insert(proto_msg_id_record_map,{928,'update_pet_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{929,'learned_pet_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{930,'init_pet_skill_slots_s2c'}),
	ets:insert(proto_msg_id_record_map,{931,'pet_learn_skill_cover_best_s2c'}),
	ets:insert(proto_msg_id_record_map,{940,'buy_pet_slot_c2s'}),
	ets:insert(proto_msg_id_record_map,{941,'update_pet_slot_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{942,'pet_feed_c2s'}),
	ets:insert(proto_msg_id_record_map,{950,'pet_training_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{951,'pet_start_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{952,'pet_stop_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{953,'pet_speedup_training_c2s'}),
	ets:insert(proto_msg_id_record_map,{954,'pet_training_init_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{960,'explore_storage_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{961,'explore_storage_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{962,'explore_storage_init_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{963,'explore_storage_getitem_c2s'}),
	ets:insert(proto_msg_id_record_map,{964,'explore_storage_getallitems_c2s'}),
	ets:insert(proto_msg_id_record_map,{965,'explore_storage_updateitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{966,'explore_storage_additem_s2c'}),
	ets:insert(proto_msg_id_record_map,{967,'explore_storage_delitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{968,'explore_storage_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{970,'pet_explore_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{971,'pet_explore_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{972,'pet_explore_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{973,'pet_explore_speedup_c2s'}),
	ets:insert(proto_msg_id_record_map,{974,'pet_explore_stop_c2s'}),
	ets:insert(proto_msg_id_record_map,{975,'pet_explore_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{976,'pet_explore_gain_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{981,'treasure_chest_flush_c2s'}),
	ets:insert(proto_msg_id_record_map,{982,'treasure_chest_flush_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{983,'treasure_chest_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{984,'treasure_chest_raffle_c2s'}),
	ets:insert(proto_msg_id_record_map,{985,'treasure_chest_raffle_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{986,'treasure_chest_obtain_c2s'}),
	ets:insert(proto_msg_id_record_map,{987,'treasure_chest_obtain_ok_s2c'}),
	ets:insert(proto_msg_id_record_map,{989,'treasure_chest_query_c2s'}),
	ets:insert(proto_msg_id_record_map,{990,'treasure_chest_query_s2c'}),
	ets:insert(proto_msg_id_record_map,{991,'treasure_chest_broad_s2c'}),
	ets:insert(proto_msg_id_record_map,{992,'treasure_chest_disable_c2s'}),
	ets:insert(proto_msg_id_record_map,{995,'beads_pray_request_c2s'}),
	ets:insert(proto_msg_id_record_map,{4001,'smashed_egg_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{4002,'smashed_egg_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{4003,'smashed_egg_tamp_c2s'}),
	ets:insert(proto_msg_id_record_map,{4004,'smashed_egg_tamp_s2c'}),
	ets:insert(proto_msg_id_record_map,{4005,'smashed_egg_refresh_c2s'}),
	ets:insert(proto_msg_id_record_map,{4006,'smashed_egg_refresh_s2c'}),
	ets:insert(proto_msg_id_record_map,{4007,'god_tree_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{4008,'god_tree_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{4009,'god_tree_rock_c2s'}),
	ets:insert(proto_msg_id_record_map,{4010,'god_tree_rock_s2c'}),
	ets:insert(proto_msg_id_record_map,{4011,'god_tree_init_storage_c2s'}),
	ets:insert(proto_msg_id_record_map,{4012,'god_tree_storage_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{4013,'god_tree_storage_init_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{4014,'god_tree_storage_updateitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{4015,'god_tree_storage_additem_s2c'}),
	ets:insert(proto_msg_id_record_map,{4016,'god_tree_storage_getitem_c2s'}),
	ets:insert(proto_msg_id_record_map,{4017,'god_tree_storage_delitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{4018,'god_tree_storage_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{4019,'god_tree_storage_getallitems_c2s'}),
	ets:insert(proto_msg_id_record_map,{4020,'god_tree_broad_s2c'}),
	ets:insert(proto_msg_id_record_map,{996,'beads_pray_response_s2c'}),
	ets:insert(proto_msg_id_record_map,{997,'beads_pray_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{1001,'enum_exchange_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1002,'enum_exchange_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{1003,'enum_exchange_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1004,'exchange_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1005,'exchange_item_fail_s2c'}),
	ets:insert(proto_msg_id_record_map,{1010,'battle_reward_by_records_c2s'}),
	ets:insert(proto_msg_id_record_map,{1020,'timelimit_gift_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1021,'get_timelimit_gift_c2s'}),
	ets:insert(proto_msg_id_record_map,{1022,'timelimit_gift_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1023,'timelimit_gift_over_s2c'}),
	ets:insert(proto_msg_id_record_map,{1030,'stall_sell_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1031,'stall_recede_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1033,'stalls_search_c2s'}),
	ets:insert(proto_msg_id_record_map,{1034,'stall_detail_c2s'}),
	ets:insert(proto_msg_id_record_map,{1035,'stall_buy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1036,'stall_rename_c2s'}),
	ets:insert(proto_msg_id_record_map,{1037,'stalls_search_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1040,'stall_detail_s2c'}),
	ets:insert(proto_msg_id_record_map,{1041,'stalls_search_s2c'}),
	ets:insert(proto_msg_id_record_map,{1042,'stall_log_add_s2c'}),
	ets:insert(proto_msg_id_record_map,{1043,'stall_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1044,'stall_role_detail_c2s'}),
	ets:insert(proto_msg_id_record_map,{1045,'stalls_search_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1087,'guild_battlefield_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1088,'battlefield_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{1089,'battlefield_info_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1090,'battlefield_totle_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1091,'yhzq_battlefield_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1098,'yhzq_all_battle_over_s2c'}),
	ets:insert(proto_msg_id_record_map,{1099,'yhzq_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1105,'notify_to_join_yhzq_s2c'}),
	ets:insert(proto_msg_id_record_map,{1106,'join_yhzq_c2s'}),
	ets:insert(proto_msg_id_record_map,{1107,'leave_yhzq_c2s'}),
	ets:insert(proto_msg_id_record_map,{1108,'yhzq_award_s2c'}),
	ets:insert(proto_msg_id_record_map,{1109,'yhzq_award_c2s'}),
	ets:insert(proto_msg_id_record_map,{1110,'yhzq_camp_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1111,'yhzq_zone_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1114,'yhzq_battle_self_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{1115,'yhzq_battle_other_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{1116,'yhzq_battle_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1117,'yhzq_battle_remove_s2c'}),
	ets:insert(proto_msg_id_record_map,{1118,'yhzq_battle_player_pos_s2c'}),
	ets:insert(proto_msg_id_record_map,{1119,'yhzq_battle_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1120,'init_random_rolename_s2c'}),
	ets:insert(proto_msg_id_record_map,{1121,'reset_random_rolename_c2s'}),
	ets:insert(proto_msg_id_record_map,{1122,'answer_sign_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1123,'answer_sign_request_c2s'}),
	ets:insert(proto_msg_id_record_map,{1124,'answer_sign_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{1125,'answer_start_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1126,'answer_question_c2s'}),
	ets:insert(proto_msg_id_record_map,{1127,'answer_question_s2c'}),
	ets:insert(proto_msg_id_record_map,{1128,'answer_question_ranklist_s2c'}),
	ets:insert(proto_msg_id_record_map,{1129,'answer_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1130,'answer_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1131,'offline_exp_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1132,'offline_exp_quests_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1133,'offline_exp_exchange_c2s'}),
	ets:insert(proto_msg_id_record_map,{1134,'offline_exp_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1135,'offline_exp_exchange_gold_c2s'}),
	ets:insert(proto_msg_id_record_map,{1140,'congratulations_levelup_remind_s2c'}),
	ets:insert(proto_msg_id_record_map,{1141,'congratulations_levelup_c2s'}),
	ets:insert(proto_msg_id_record_map,{1142,'congratulations_levelup_s2c'}),
	ets:insert(proto_msg_id_record_map,{1143,'congratulations_receive_s2c'}),
	ets:insert(proto_msg_id_record_map,{1144,'congratulations_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1145,'congratulations_received_c2s'}),
	ets:insert(proto_msg_id_record_map,{1160,'treasure_buffer_s2c'}),
	ets:insert(proto_msg_id_record_map,{1161,'gift_card_state_s2c'}),
	ets:insert(proto_msg_id_record_map,{1162,'gift_card_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1163,'gift_card_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{1170,'chess_spirit_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1171,'chess_spirit_role_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1172,'chess_spirit_update_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1173,'chess_spirit_update_skill_s2c'}),
	ets:insert(proto_msg_id_record_map,{1174,'chess_spirit_update_chess_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1175,'chess_spirit_skill_levelup_c2s'}),
	ets:insert(proto_msg_id_record_map,{1176,'chess_spirit_cast_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{1177,'chess_spirit_cast_chess_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{1178,'chess_spirit_opt_result_s2s'}),
	ets:insert(proto_msg_id_record_map,{1179,'chess_spirit_log_c2s'}),
	ets:insert(proto_msg_id_record_map,{1180,'chess_spirit_log_s2c'}),
	ets:insert(proto_msg_id_record_map,{1181,'chess_spirit_get_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1182,'chess_spirit_quit_c2s'}),
	ets:insert(proto_msg_id_record_map,{1183,'chess_spirit_game_over_s2c'}),
	ets:insert(proto_msg_id_record_map,{1184,'chess_spirit_prepare_s2c'}),
	ets:insert(proto_msg_id_record_map,{1200,'guild_get_shop_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1201,'guild_get_shop_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1202,'guild_shop_buy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1203,'guild_get_treasure_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1204,'guild_get_treasure_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1205,'guild_treasure_buy_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1206,'guild_treasure_set_price_c2s'}),
	ets:insert(proto_msg_id_record_map,{1207,'guild_treasure_update_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1208,'publish_guild_quest_c2s'}),
	ets:insert(proto_msg_id_record_map,{1209,'update_guild_quest_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1210,'update_guild_apply_state_s2c'}),
	ets:insert(proto_msg_id_record_map,{1211,'update_guild_update_apply_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1212,'guild_update_apply_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1213,'get_guild_notice_c2s'}),
	ets:insert(proto_msg_id_record_map,{1214,'send_guild_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1215,'guild_shop_update_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{1216,'change_guild_battle_limit_c2s'}),
	ets:insert(proto_msg_id_record_map,{1217,'change_guild_right_limit_s2c'}),
	ets:insert(proto_msg_id_record_map,{1218,'guild_have_guildbattle_right_s2c'}),
	ets:insert(proto_msg_id_record_map,{1219,'guild_bonfire_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1220,'add_levelup_opt_levels_s2c'}),
	ets:insert(proto_msg_id_record_map,{1221,'levelup_opt_c2s'}),
	ets:insert(proto_msg_id_record_map,{1222,'guild_bonfire_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1230,'activity_forecast_begin_s2c'}),
	ets:insert(proto_msg_id_record_map,{1231,'activity_forecast_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1235,'system_broadcast_s2c'}),
	ets:insert(proto_msg_id_record_map,{1240,'moneygame_left_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1241,'moneygame_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1242,'moneygame_prepare_s2c'}),
	ets:insert(proto_msg_id_record_map,{1243,'moneygame_cur_sec_s2c'}),
	ets:insert(proto_msg_id_record_map,{1245,'guild_mastercall_s2c'}),
	ets:insert(proto_msg_id_record_map,{1246,'guild_mastercall_accept_c2s'}),
	ets:insert(proto_msg_id_record_map,{1247,'guild_mastercall_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{1248,'guild_member_pos_c2s'}),
	ets:insert(proto_msg_id_record_map,{1249,'guild_member_pos_s2c'}),
	ets:insert(proto_msg_id_record_map,{1250,'sitdown_c2s'}),
	ets:insert(proto_msg_id_record_map,{1251,'stop_sitdown_c2s'}),
	ets:insert(proto_msg_id_record_map,{1252,'companion_sitdown_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1253,'companion_sitdown_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{1254,'companion_sitdown_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{1255,'companion_sitdown_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1256,'companion_reject_c2s'}),
	ets:insert(proto_msg_id_record_map,{1257,'companion_reject_s2c'}),
	ets:insert(proto_msg_id_record_map,{1258,'dragon_fight_faction_s2c'}),
	ets:insert(proto_msg_id_record_map,{1259,'dragon_fight_left_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1260,'dragon_fight_state_s2c'}),
	ets:insert(proto_msg_id_record_map,{1261,'dragon_fight_num_c2s'}),
	ets:insert(proto_msg_id_record_map,{1262,'dragon_fight_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{1263,'dragon_fight_faction_c2s'}),
	ets:insert(proto_msg_id_record_map,{1264,'dragon_fight_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1265,'dragon_fight_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1266,'dragon_fight_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{1267,'star_spawns_section_s2c'}),
	ets:insert(proto_msg_id_record_map,{1276,'venation_advanced_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{1277,'venation_advanced_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1278,'venation_advanced_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1280,'venation_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1281,'venation_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1282,'venation_shareexp_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1283,'venation_active_point_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{1284,'venation_active_point_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1285,'venation_active_point_end_c2s'}),
	ets:insert(proto_msg_id_record_map,{1286,'venation_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1287,'venation_time_countdown_s2c'}),
	ets:insert(proto_msg_id_record_map,{1288,'other_venation_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1290,'server_travel_tag_s2c'}),
	ets:insert(proto_msg_id_record_map,{1300,'continuous_logging_gift_c2s'}),
	ets:insert(proto_msg_id_record_map,{1301,'continuous_logging_board_c2s'}),
	ets:insert(proto_msg_id_record_map,{1302,'continuous_days_clear_c2s'}),
	ets:insert(proto_msg_id_record_map,{1303,'continuous_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1304,'continuous_logging_board_s2c'}),
	ets:insert(proto_msg_id_record_map,{1310,'treasure_storage_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1311,'treasure_storage_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1312,'treasure_storage_init_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1313,'treasure_storage_getitem_c2s'}),
	ets:insert(proto_msg_id_record_map,{1314,'treasure_storage_getallitems_c2s'}),
	ets:insert(proto_msg_id_record_map,{1315,'treasure_storage_updateitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{1316,'treasure_storage_additem_s2c'}),
	ets:insert(proto_msg_id_record_map,{1317,'treasure_storage_delitem_s2c'}),
	ets:insert(proto_msg_id_record_map,{1318,'treasure_storage_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1400,'activity_value_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1401,'activity_value_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1402,'activity_value_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1403,'activity_value_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1404,'activity_value_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1410,'activity_state_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1411,'activity_state_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1412,'activity_state_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1413,'activity_boss_born_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1414,'activity_boss_born_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1415,'activity_boss_born_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1416,'first_charge_gift_state_s2c'}),
	ets:insert(proto_msg_id_record_map,{1417,'first_charge_gift_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1418,'first_charge_gift_reward_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1428,'rank_get_rank_c2s'}),
	ets:insert(proto_msg_id_record_map,{1429,'rank_get_rank_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{1430,'rank_loop_tower_s2c'}),
	ets:insert(proto_msg_id_record_map,{1431,'rank_killer_s2c'}),
	ets:insert(proto_msg_id_record_map,{1432,'rank_moneys_s2c'}),
	ets:insert(proto_msg_id_record_map,{1433,'rank_melee_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1434,'rank_range_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1435,'rank_magic_power_s2c'}),
	ets:insert(proto_msg_id_record_map,{1436,'rank_loop_tower_num_s2c'}),
	ets:insert(proto_msg_id_record_map,{1437,'rank_level_s2c'}),
	ets:insert(proto_msg_id_record_map,{1438,'rank_answer_s2c'}),
	ets:insert(proto_msg_id_record_map,{1439,'rank_get_rank_role_s2c'}),
	ets:insert(proto_msg_id_record_map,{1440,'rank_disdain_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{1441,'rank_praise_role_c2s'}),
	ets:insert(proto_msg_id_record_map,{1442,'rank_judge_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1443,'rank_chess_spirits_single_s2c'}),
	ets:insert(proto_msg_id_record_map,{1444,'rank_chess_spirits_team_s2c'}),
	ets:insert(proto_msg_id_record_map,{1445,'facebook_bind_check_c2s'}),
	ets:insert(proto_msg_id_record_map,{1446,'facebook_bind_check_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1447,'guild_clear_nickname_c2s'}),
	ets:insert(proto_msg_id_record_map,{1448,'everyday_show_s2c'}),
	ets:insert(proto_msg_id_record_map,{1450,'rank_judge_to_other_s2c'}),
	ets:insert(proto_msg_id_record_map,{1451,'rank_talent_score_s2c'}),
	ets:insert(proto_msg_id_record_map,{1452,'rank_mail_line_s2c'}),
	ets:insert(proto_msg_id_record_map,{1453,'rank_get_main_line_rank_c2s'}),
	ets:insert(proto_msg_id_record_map,{1454,'rank_fighting_force_s2c'}),
	ets:insert(proto_msg_id_record_map,{1460,'welfare_panel_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1461,'welfare_panel_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1462,'welfare_gifepacks_state_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1463,'welfare_gold_exchange_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1464,'welfare_gold_exchange_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1465,'welfare_gold_exchange_c2s'}),
	ets:insert(proto_msg_id_record_map,{1466,'ride_opt_c2s'}),
	ets:insert(proto_msg_id_record_map,{1467,'ride_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1480,'item_identify_c2s'}),
	ets:insert(proto_msg_id_record_map,{1481,'item_identify_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1482,'ride_pet_synthesis_c2s'}),
	ets:insert(proto_msg_id_record_map,{1483,'ridepet_synthesis_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1484,'ridepet_synthesis_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1485,'pet_random_talent_c2s'}),
	ets:insert(proto_msg_id_record_map,{1486,'pet_change_talent_c2s'}),
	ets:insert(proto_msg_id_record_map,{1487,'pet_random_talent_s2c'}),
	ets:insert(proto_msg_id_record_map,{1488,'item_identify_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1489,'pet_evolution_c2s'}),
	ets:insert(proto_msg_id_record_map,{1500,'pet_upgrade_quality_c2s'}),
	ets:insert(proto_msg_id_record_map,{1501,'pet_upgrade_quality_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{1502,'pet_add_attr_c2s'}),
	ets:insert(proto_msg_id_record_map,{1503,'pet_wash_attr_c2s'}),
	ets:insert(proto_msg_id_record_map,{1504,'pet_upgrade_quality_s2c'}),
	ets:insert(proto_msg_id_record_map,{1505,'pet_upgrade_quality_up_s2c'}),
	ets:insert(proto_msg_id_record_map,{1510,'update_item_for_pet_s2c'}),
	ets:insert(proto_msg_id_record_map,{1511,'equip_item_for_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{1512,'unequip_item_for_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{1513,'pet_item_opt_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1520,'refine_system_c2s'}),
	ets:insert(proto_msg_id_record_map,{1521,'refine_system_s2c'}),
	ets:insert(proto_msg_id_record_map,{1530,'welfare_activity_update_c2s'}),
	ets:insert(proto_msg_id_record_map,{1531,'welfare_activity_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1540,'designation_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1541,'designation_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1542,'inspect_designation_s2c'}),
	ets:insert(proto_msg_id_record_map,{1550,'treasure_transport_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1551,'treasure_transport_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{1552,'start_guild_transport_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{1553,'rob_treasure_transport_s2c'}),
	ets:insert(proto_msg_id_record_map,{1554,'server_treasure_transport_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1555,'server_treasure_transport_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1556,'role_treasure_transport_time_check_c2s'}),
	ets:insert(proto_msg_id_record_map,{1557,'guild_transport_left_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1558,'start_guild_treasure_transport_c2s'}),
	ets:insert(proto_msg_id_record_map,{1559,'treasure_transport_call_guild_help_s2c'}),
	ets:insert(proto_msg_id_record_map,{1560,'mainline_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1561,'mainline_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1562,'mainline_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1563,'mainline_start_entry_c2s'}),
	ets:insert(proto_msg_id_record_map,{1564,'mainline_start_entry_s2c'}),
	ets:insert(proto_msg_id_record_map,{1565,'mainline_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{1566,'mainline_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1567,'mainline_end_c2s'}),
	ets:insert(proto_msg_id_record_map,{1568,'mainline_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1569,'mainline_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1570,'mainline_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1571,'mainline_lefttime_s2c'}),
	ets:insert(proto_msg_id_record_map,{1572,'mainline_timeout_c2s'}),
	ets:insert(proto_msg_id_record_map,{1573,'mainline_remain_monsters_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1574,'mainline_kill_monsters_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1575,'mainline_section_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1576,'mainline_protect_npc_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1577,'mainline_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1578,'mainline_reward_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{1600,'banquet_start_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1601,'banquet_request_banquetlist_c2s'}),
	ets:insert(proto_msg_id_record_map,{1602,'banquet_request_banquetlist_s2c'}),
	ets:insert(proto_msg_id_record_map,{1603,'banquet_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{1604,'banquet_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{1605,'banquet_dancing_s2c'}),
	ets:insert(proto_msg_id_record_map,{1607,'banquet_cheering_c2s'}),
	ets:insert(proto_msg_id_record_map,{1608,'banquet_cheering_s2c'}),
	ets:insert(proto_msg_id_record_map,{1610,'banquet_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1611,'banquet_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{1612,'banquet_leave_s2c'}),
	ets:insert(proto_msg_id_record_map,{1613,'banquet_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1614,'banquet_dancing_c2s'}),
	ets:insert(proto_msg_id_record_map,{1615,'banquet_update_count_s2c'}),
	ets:insert(proto_msg_id_record_map,{1620,'treasure_tran csport_call_guild_help_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1621,'treasure_transport_call_guild_help_c2s'}),
	ets:insert(proto_msg_id_record_map,{1630,'server_version_c2s'}),
	ets:insert(proto_msg_id_record_map,{1631,'server_version_s2c'}),
	ets:insert(proto_msg_id_record_map,{1640,'country_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1641,'change_country_notice_c2s'}),
	ets:insert(proto_msg_id_record_map,{1642,'change_country_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1643,'change_country_transport_c2s'}),
	ets:insert(proto_msg_id_record_map,{1644,'change_country_transport_s2c'}),
	ets:insert(proto_msg_id_record_map,{1645,'country_leader_promotion_c2s'}),
	ets:insert(proto_msg_id_record_map,{1646,'country_leader_demotion_c2s'}),
	ets:insert(proto_msg_id_record_map,{1647,'country_leader_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1648,'country_block_talk_c2s'}),
	ets:insert(proto_msg_id_record_map,{1649,'country_change_crime_c2s'}),
	ets:insert(proto_msg_id_record_map,{1650,'country_leader_online_s2c'}),
	ets:insert(proto_msg_id_record_map,{1651,'country_leader_get_itmes_c2s'}),
	ets:insert(proto_msg_id_record_map,{1652,'country_leader_ever_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1653,'guild_battle_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{1654,'entry_guild_battle_c2s'}),
	ets:insert(proto_msg_id_record_map,{1655,'entry_guild_battle_s2c'}),
	ets:insert(proto_msg_id_record_map,{1656,'leave_guild_battle_c2s'}),
	ets:insert(proto_msg_id_record_map,{1657,'leave_guild_battle_s2c'}),
	ets:insert(proto_msg_id_record_map,{1658,'guild_battle_score_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1659,'guild_battle_score_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1660,'guild_battle_status_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1661,'guild_battle_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1662,'country_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1663,'guild_battle_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1664,'guild_battle_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1665,'country_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1666,'guild_battle_ready_s2c'}),
	ets:insert(proto_msg_id_record_map,{1667,'apply_guild_battle_c2s'}),
	ets:insert(proto_msg_id_record_map,{1668,'guild_battle_start_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{1669,'guild_battle_stop_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{1680,'init_open_service_activities_s2c'}),
	ets:insert(proto_msg_id_record_map,{1681,'open_sercice_activities_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1682,'open_service_activities_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1683,'init_open_service_activities_c2s'}),
	ets:insert(proto_msg_id_record_map,{1690,'activity_tab_isshow_s2c'}),
	ets:insert(proto_msg_id_record_map,{1691,'festival_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1692,'festival_recharge_s2c'}),
	ets:insert(proto_msg_id_record_map,{1693,'festival_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1694,'festival_recharge_exchange_c2s'}),
	ets:insert(proto_msg_id_record_map,{1695,'festival_recharge_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1696,'festival_recharge_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1700,'jszd_start_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{1701,'jszd_join_c2s'}),
	ets:insert(proto_msg_id_record_map,{1702,'jszd_join_s2c'}),
	ets:insert(proto_msg_id_record_map,{1703,'jszd_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{1704,'jszd_leave_s2c'}),
	ets:insert(proto_msg_id_record_map,{1705,'jszd_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1706,'jszd_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{1707,'jszd_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1708,'jszd_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1709,'jszd_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1710,'jszd_battlefield_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1720,'guild_contribute_log_c2s'}),
	ets:insert(proto_msg_id_record_map,{1721,'guild_contribute_log_s2c'}),
	ets:insert(proto_msg_id_record_map,{1722,'guild_impeach_c2s'}),
	ets:insert(proto_msg_id_record_map,{1723,'guild_impeach_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{1724,'guild_impeach_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{1725,'guild_impeach_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1726,'guild_impeach_vote_c2s'}),
	ets:insert(proto_msg_id_record_map,{1727,'guild_impeach_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{1728,'guild_join_lefttime_s2c'}),
	ets:insert(proto_msg_id_record_map,{1729,'sync_bonfire_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{1730,'spiritspower_state_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1731,'spiritspower_reset_c2s'}),
	ets:insert(proto_msg_id_record_map,{1740,'christmas_tree_grow_up_c2s'}),
	ets:insert(proto_msg_id_record_map,{1741,'christmas_activity_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1742,'christmas_tree_hp_s2c'}),
	ets:insert(proto_msg_id_record_map,{1743,'play_effects_s2c'}),
	ets:insert(proto_msg_id_record_map,{1751,'tangle_kill_info_request_c2s'}),
	ets:insert(proto_msg_id_record_map,{1752,'tangle_kill_info_request_s2c'}),
	ets:insert(proto_msg_id_record_map,{1760,'get_guild_monster_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1761,'call_guild_monster_c2s'}),
	ets:insert(proto_msg_id_record_map,{1762,'callback_guild_monster_c2s'}),
	ets:insert(proto_msg_id_record_map,{1764,'get_guild_monster_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{1800,'entry_loop_instance_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{1801,'entry_loop_instance_vote_s2c'}),
	ets:insert(proto_msg_id_record_map,{1802,'entry_loop_instance_vote_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{1803,'entry_loop_instance_vote_c2s'}),
	ets:insert(proto_msg_id_record_map,{1804,'entry_loop_instance_c2s'}),
	ets:insert(proto_msg_id_record_map,{1805,'entry_loop_instance_s2c'}),
	ets:insert(proto_msg_id_record_map,{1806,'leave_loop_instance_c2s'}),
	ets:insert(proto_msg_id_record_map,{1807,'leave_loop_instance_s2c'}),
	ets:insert(proto_msg_id_record_map,{1808,'loop_instance_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1809,'loop_instance_reward_s2c'}),
	ets:insert(proto_msg_id_record_map,{1810,'loop_instance_remain_monsters_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1811,'loop_instance_kill_monsters_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{1812,'loop_instance_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{1813,'loop_instance_kill_monsters_info_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1821,'honor_stores_buy_items_c2s'}),
	ets:insert(proto_msg_id_record_map,{1822,'buy_honor_item_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{1823,'monster_section_update_s2c'}),
    ets:insert(proto_msg_id_record_map,{1824,'guild_dice_c2s'}),
    ets:insert(proto_msg_id_record_map,{1825,'guild_dice_s2c'}),

    %%zhangting邀请好友送礼
    ets:insert(proto_msg_id_record_map,{2301,'invite_friend_gift_get_c2s'}),
    ets:insert(proto_msg_id_record_map,{2302,'invite_friend_gift_get_ret_s2c'}),
    ets:insert(proto_msg_id_record_map,{2303,'role_shift_pos_c2s'}),
    ets:insert(proto_msg_id_record_map,{2304,'role_pull_objects_c2s'}),
    ets:insert(proto_msg_id_record_map,{2305,'role_push_objects_c2s'}),
     
	%%zhangting 收藏送礼
    ets:insert(proto_msg_id_record_map,{1890,'collect_page_c2s'}),
    ets:insert(proto_msg_id_record_map,{1891,'collect_page_s2c'}),
	
	%% 经验台刷品
	ets:insert(proto_msg_id_record_map, {1952, 'init_instance_quality_c2s'}),
	ets:insert(proto_msg_id_record_map, {1950, 'refresh_instance_quality_c2s'}),
	
	%%副本元宝委托送礼
	ets:insert(proto_msg_id_record_map,{1900,'instance_entrust_c2s'}),
	ets:insert(proto_msg_id_record_map,{1875,'qz_get_balance_c2s'}),
	
	%% 青囊协议
    %% 	ets:insert(proto_msg_id_record_map,{2034,'green_capsule_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{2035,'green_capsule_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{2036,'green_capsule_add_c2s'}),
	ets:insert(proto_msg_id_record_map,{2037,'green_capsule_add_s2c'}),
	ets:insert(proto_msg_id_record_map,{2038,'green_capsule_start_auto_upgrade_c2s'}),
	ets:insert(proto_msg_id_record_map,{2039,'green_capsule_start_auto_upgrade_s2c'}),
	ets:insert(proto_msg_id_record_map,{2040,'green_capsule_end_auto_upgrade_c2s'}),
	ets:insert(proto_msg_id_record_map,{2041,'green_capsule_end_auto_upgrade_s2c'}),
	ets:insert(proto_msg_id_record_map,{2042,'green_capsule_upgrade_c2s'}),
	ets:insert(proto_msg_id_record_map,{2043,'green_capsule_upgrade_s2c'}),
	ets:insert(proto_msg_id_record_map,{2044,'green_capsule_active_c2s'}),
	ets:insert(proto_msg_id_record_map,{2045,'green_capsule_active_s2c'}), 
   %%宠物进阶升级
    ets:insert(proto_msg_id_record_map,{3000,'pet_grade_riseup_c2s'}),
	ets:insert(proto_msg_id_record_map,{3001,'pet_grade_riseup_s2c'}),
	%%add buff info in battle
	ets:insert(proto_msg_id_record_map,{3020, 'add_buff_in_battle_s2c'}),
    %%pet quality quality rise up
	ets:insert(proto_msg_id_record_map, {2070,'pet_quality_riseup_c2s'}),
	ets:insert(proto_msg_id_record_map, {2071,'pet_quality_riseup_s2c'}),
	%%悟性提升
	ets:insert(proto_msg_id_record_map, {2078, 'pet_savvy_up_c2s'}),
	ets:insert(proto_msg_id_record_map, {2079, 'pet_savvy_up_s2c'}),
	
	%% 宠物资质
	ets:insert(proto_msg_id_record_map,{2048,'pet_qualification_upgrade_c2s'}),
	ets:insert(proto_msg_id_record_map,{2049,'pet_qualification_upgrade_s2c'}),
	
	ets:insert(proto_msg_id_record_map,{1842,'role_shift_pos_s2c'}),
	ets:insert(proto_msg_id_record_map,{1840,'role_pull_objects_s2c'}),
	ets:insert(proto_msg_id_record_map,{1841,'role_push_objects_s2c'}),
	ets:insert(proto_msg_id_record_map,{1845,'trade_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{1843,'skill_cooldown_reset_s2c'}),
	% 6重礼包
	ets:insert(proto_msg_id_record_map,{1880, 'charge_package_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1881, 'charge_package_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1882, 'get_charge_package_c2s'}),
	ets:insert(proto_msg_id_record_map,{1883, 'get_charge_package_s2c'}),
	ets:insert(proto_msg_id_record_map,{1884, 'charge_package_gold_change_s2c'}),
    ets:insert(proto_msg_id_record_map,{2007, 'query_travel_server_status_c2s'}),
    ets:insert(proto_msg_id_record_map,{2005, 'query_travel_server_status_s2c'}),
    ets:insert(proto_msg_id_record_map,{2003, 'temp_activity_reward_c2s'}),

    ets:insert(proto_msg_id_record_map,{1885, 'charge_reward_init_c2s'}),
	ets:insert(proto_msg_id_record_map,{1886, 'charge_reward_init_s2c'}),
	ets:insert(proto_msg_id_record_map,{1887, 'get_charge_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{1888, 'get_charge_reward_s2c'}),

	%%阵营战
    ets:insert(proto_msg_id_record_map,{1850,'camp_battle_start_s2c'}),
    ets:insert(proto_msg_id_record_map,{1851,'camp_battle_stop_s2c'}),
    ets:insert(proto_msg_id_record_map,{1852,'camp_battle_entry_c2s'}),
    ets:insert(proto_msg_id_record_map,{1853,'camp_battle_entry_s2c'}),
    ets:insert(proto_msg_id_record_map,{1854,'camp_battle_leave_c2s'}),
    ets:insert(proto_msg_id_record_map,{1855,'camp_battle_leave_s2c'}),
    ets:insert(proto_msg_id_record_map,{1856,'camp_battle_init_s2c'}),
    ets:insert(proto_msg_id_record_map,{1857,'camp_battle_otherrole_update_s2c'}),
    ets:insert(proto_msg_id_record_map,{1858,'camp_battle_otherrole_init_s2c'}),
    ets:insert(proto_msg_id_record_map,{1859,'camp_battle_otherrole_leave_s2c'}),
    ets:insert(proto_msg_id_record_map,{1860,'camp_battle_info_update_s2c'}),
    ets:insert(proto_msg_id_record_map,{1861,'camp_battle_record_init_s2c'}),
    ets:insert(proto_msg_id_record_map,{1862,'camp_battle_record_update_s2c'}),
    ets:insert(proto_msg_id_record_map,{1863,'camp_battle_result_s2c'}),
    ets:insert(proto_msg_id_record_map,{1864,'camp_battle_player_num_c2s'}),
    ets:insert(proto_msg_id_record_map,{1865,'camp_battle_player_num_s2c'}),
    ets:insert(proto_msg_id_record_map,{1866,'camp_battle_last_record_c2s'}),
    ets:insert(proto_msg_id_record_map,{1867,'camp_battle_last_record_s2c'}),
    ets:insert(proto_msg_id_record_map,{1868,'camp_battle_opt_s2c'}),
	ets:insert(proto_msg_id_record_map,{30003, 'pet_shop_goods_s2c'}),
	ets:insert(proto_msg_id_record_map,{33333, 'send_error_s2c'}),
	ets:insert(proto_msg_id_record_map,{30002, 'pet_shop_goods_c2s'}),
	ets:insert(proto_msg_id_record_map,{30004, 'buy_pet_c2s'}),
	ets:insert(proto_msg_id_record_map,{30005, 'refresh_remain_time_c2s'}),
	ets:insert(proto_msg_id_record_map,{30006, 'pet_type_change_c2s'}),
	ets:insert(proto_msg_id_record_map,{30007, 'pet_type_change_s2c'}),
	ets:insert(proto_msg_id_record_map,{30008, 'pet_reset_type_attr_c2s'}),
	ets:insert(proto_msg_id_record_map,{30009, 'pet_inherit_c2s'}),
	ets:insert(proto_msg_id_record_map,{30011, 'pet_inherit_s2c'}),
	ets:insert(proto_msg_id_record_map,{30012, 'get_prize_holiday_c2s'}),
    ets:insert(proto_msg_id_record_map,{30013, 'pet_reset_type_attr_s2c'}),
	ets:insert(proto_msg_id_record_map,{30014, 'get_gold_by_level_c2s'}),
	ets:insert(proto_msg_id_record_map,{30015, 'goldlevel_show_s2c'}),
	ets:insert(proto_msg_id_record_map,{30016, 'role_quest_status_c2s'}),
	ets:insert(proto_msg_id_record_map,{30017, 'role_quest_status_s2c'}),
	% 连续登陆礼品
	ets:insert(proto_msg_id_record_map,{30018, 'login_continuously_show_s2c'}),
	ets:insert(proto_msg_id_record_map,{30019, 'login_continuously_reward_c2s'}),
	ets:insert(proto_msg_id_record_map,{30020, 'login_continuously_reward_s2c'}),
	  % 市场
    ets:insert(proto_msg_id_record_map,{30031, 'market_sell_item_c2s'}),
    ets:insert(proto_msg_id_record_map,{30032, 'market_buy_item_c2s'}),
    ets:insert(proto_msg_id_record_map,{30033, 'market_search_item_c2s'}),
    ets:insert(proto_msg_id_record_map,{30034, 'market_sell_item_s2c'}),
    ets:insert(proto_msg_id_record_map,{30035, 'market_self_items_c2s'}),
    ets:insert(proto_msg_id_record_map,{30036, 'market_self_items_s2c'}),
    ets:insert(proto_msg_id_record_map,{30037, 'market_feedback_signal_s2c'}),
	% 副本奖励
	ets:insert(proto_msg_id_record_map,{30021, 'duplicate_prize_notify_s2c'}),
	ets:insert(proto_msg_id_record_map,{30022, 'duplicate_prize_item_c2s'}),
	ets:insert(proto_msg_id_record_map,{30023, 'duplicate_prize_item_s2c'}),
	ets:insert(proto_msg_id_record_map,{30024, 'duplicate_prize_get_c2s'}),
	% 等级奖励
	ets:insert(proto_msg_id_record_map,{30051,'get_level_award_c2s'}),
	ets:insert(proto_msg_id_record_map,{30052,'level_award_show_s2c'}),

	%% bang da Yuanyang
	ets:insert(proto_msg_id_record_map,{2100,'bdyy_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{2101,'bdyy_item_show_s2c'}),
	ets:insert(proto_msg_id_record_map,{2102,'bdyy_item_hit_c2s'}),
	ets:insert(proto_msg_id_record_map,{2103,'bdyy_item_hit_s2c'}),
	ets:insert(proto_msg_id_record_map,{2104,'bdyy_item_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{2105,'bdyy_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{2106,'bdyy_end_c2s'}),
	ets:insert(proto_msg_id_record_map,{20000,'companion_dancing_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{20001,'companion_dancing_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{20002,'companion_dancing_start_c2s'}),
	ets:insert(proto_msg_id_record_map,{20003,'companion_dancing_reject_c2s'}),
	ets:insert(proto_msg_id_record_map,{20004,'companion_dancing_reject_s2c'}),
	ets:insert(proto_msg_id_record_map,{20005,'companion_dancing_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{20006,'companion_dancing_stop_s2c'}),
	ets:insert(proto_msg_id_record_map,{19999,'banquet_pet_swanking_s2c'}),
	ets:insert(proto_msg_id_record_map,{19998,'banquet_pets_s2c'}),

	ets:insert(proto_msg_id_record_map,{20008,'travel_battle_query_role_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{20009,'travel_battle_query_role_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{20010,'travel_battle_register_c2s'}),
	ets:insert(proto_msg_id_record_map,{20011,'travel_battle_register_s2c'}),
	ets:insert(proto_msg_id_record_map,{20013,'travel_battle_section_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{20014,'travel_battle_stage_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{20015,'travel_battle_open_shop_c2s'}),
	ets:insert(proto_msg_id_record_map,{20016,'travel_battle_open_shop_s2c'}),
	ets:insert(proto_msg_id_record_map,{20017,'travel_battle_shop_buy_c2s'}),
	ets:insert(proto_msg_id_record_map,{20018,'travel_battle_shop_buy_s2c'}),
	ets:insert(proto_msg_id_record_map,{20019,'travel_battle_show_rank_page_c2s'}),
	ets:insert(proto_msg_id_record_map,{20020,'travel_battle_show_rank_page_s2c'}),
	ets:insert(proto_msg_id_record_map,{20021,'travel_battle_lottery_c2s'}),
	ets:insert(proto_msg_id_record_map,{20022,'travel_battle_lottery_s2c'}),
	ets:insert(proto_msg_id_record_map,{20024,'travel_battle_register_wait_s2c'}),
	ets:insert(proto_msg_id_record_map,{20025,'travel_battle_cancel_match_c2s'}),
	ets:insert(proto_msg_id_record_map,{20026,'travel_battle_cancel_match_s2c'}),
	ets:insert(proto_msg_id_record_map,{20027,'travel_battle_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{20029,'travel_battle_forecast_begin_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{20030,'travel_battle_forecast_end_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{20031,'travel_battle_open_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{20032,'travel_battle_close_notice_s2c'}),
	ets:insert(proto_msg_id_record_map,{20033,'travel_battle_prepare_s2c'}),
	ets:insert(proto_msg_id_record_map,{20034,'travel_battle_role_skills_s2c'}),
	ets:insert(proto_msg_id_record_map,{20035,'travel_battle_change_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{20036,'travel_battle_change_skill_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{20037,'travel_battle_change_skill_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{20038,'travel_battle_upgrade_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{20039,'travel_battle_upgrade_skill_success_s2c'}),
	ets:insert(proto_msg_id_record_map,{20040,'travel_battle_upgrade_skill_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{20041,'travel_battle_cast_skill_c2s'}),
	ets:insert(proto_msg_id_record_map,{20046,'travel_battle_leave_c2s'}),

	ets:insert(proto_msg_id_record_map,{2130,'wedding_apply_c2s'}),
	ets:insert(proto_msg_id_record_map,{2131,'wedding_apply_s2c'}),
	ets:insert(proto_msg_id_record_map,{2132,'wedding_apply_agree_c2s'}),
	ets:insert(proto_msg_id_record_map,{2133,'wedding_apply_refused_c2s'}),
	ets:insert(proto_msg_id_record_map,{2134,'wedding_apply_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{2135,'wedding_ceremony_time_available_c2s'}),
	ets:insert(proto_msg_id_record_map,{2136,'wedding_ceremony_time_available_s2c'}),
	ets:insert(proto_msg_id_record_map,{2137,'wedding_ceremony_select_c2s'}),
	ets:insert(proto_msg_id_record_map,{2138,'wedding_ceremony_select_s2c'}),
	ets:insert(proto_msg_id_record_map,{2139,'wedding_ceremony_notify_s2c'}),
	ets:insert(proto_msg_id_record_map,{2140,'wedding_ceremony_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{2141,'wedding_ceremony_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{2142,'friend_send_flowers_c2s'}),
	ets:insert(proto_msg_id_record_map,{2143,'friend_send_flowers_s2c'}),
	ets:insert(proto_msg_id_record_map,{2144,'friend_add_intimacy_s2c'}),
	ets:insert(proto_msg_id_record_map,{2145,'friend_send_flowers_notify_s2c'}),

	ets:insert(proto_msg_id_record_map,{21000,'pet_shop_c2s'}),
	ets:insert(proto_msg_id_record_map,{21001,'pet_cur_heart_s2c'}),
	ets:insert(proto_msg_id_record_map,{21002,'pet_room_s2c'}),
	ets:insert(proto_msg_id_record_map,{21003,'pet_room_c2s'}),
	ets:insert(proto_msg_id_record_map,{21004,'pet_open_room_c2s'}),
	ets:insert(proto_msg_id_record_map,{21005,'pet_into_room_c2s'}),
	ets:insert(proto_msg_id_record_map,{21006,'pet_room_balance_c2s'}),
	ets:insert(proto_msg_id_record_map,{21007,'pet_opend_room_s2c'}),
	ets:insert(proto_msg_id_record_map,{21014,'pet_open_room_s2c'}),
	ets:insert(proto_msg_id_record_map,{21015,'pet_into_room_s2c'}),
	ets:insert(proto_msg_id_record_map,{21016,'pet_room_balance_s2c'}),
	ets:insert(proto_msg_id_record_map,{21008,'gold_get_exp_s2c'}),

	ets:insert(proto_msg_id_record_map,{22000,'pet_shop_rfresh_s2c'}),
	ets:insert(proto_msg_id_record_map,{22001,'pet_shop_account_s2c'}),
	ets:insert(proto_msg_id_record_map,{22002,'pet_shop_luck_s2c'}),
	ets:insert(proto_msg_id_record_map,{22003,'pet_shop_times_s2c'}),

	ets:insert(proto_msg_id_record_map,{23000,'pet_skill_fuse_c2s'}),
	ets:insert(proto_msg_id_record_map,{23001,'pet_skill_fuse_s2c'}),

	ets:insert(proto_msg_id_record_map,{23002,'pet_skill_buy_slot_c2s'}),
	ets:insert(proto_msg_id_record_map,{23003,'pet_skill_buy_slot_s2c'}),

	ets:insert(proto_msg_id_record_map,{24000,'pet_egg_use_c2s'}),
	ets:insert(proto_msg_id_record_map,{24001,'pet_sex_change_c2s'}),
	ets:insert(proto_msg_id_record_map,{24002,'pet_sex_change_s2c'}),
	ets:insert(proto_msg_id_record_map,{24003,'pet_exp_use_c2s'}),
	ets:insert(proto_msg_id_record_map,{24004,'pet_swank_c2s'}),
	ets:insert(proto_msg_id_record_map,{25000,'icon_show_list_c2s'}),

	ets:insert(proto_msg_id_record_map,{20070,'query_open_charge_feedback_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{20071,'query_open_charge_feedback_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{20072,'query_open_charge_feedback_info_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{20073,'open_charge_feedback_lottery_c2s'}),
	ets:insert(proto_msg_id_record_map,{20074,'open_charge_feedback_lottery_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{20075,'open_charge_feedback_lottery_s2c'}),

	ets:insert(proto_msg_id_record_map,{20076,'query_open_service_aution_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{20077,'query_open_service_auction_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{20078,'query_open_service_auction_info_failed_s2c'}),
	ets:insert(proto_msg_id_record_map,{20079,'open_service_aution_bid_c2s'}),
	ets:insert(proto_msg_id_record_map,{20080,'open_service_auction_bid_s2c'}),
	ets:insert(proto_msg_id_record_map,{20081,'open_service_auction_info_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{20082,'open_charge_feedback_get_award_c2s'}),
	ets:insert(proto_msg_id_record_map,{20083,'open_charge_feedback_get_award_s2c'}),
	ets:insert(proto_msg_id_record_map,{24005,'holiday_activity_s2c'}),
	ets:insert(proto_msg_id_record_map,{23004,'pet_skill_fuse_del_c2s'}),
	ets:insert(proto_msg_id_record_map,{24006,'top_bar_show_items_s2c'}),
	ets:insert(proto_msg_id_record_map,{24007,'top_bar_hide_items_s2c'}),
	ets:insert(proto_msg_id_record_map,{24008,'temp_activity_contents_c2s'}),
	ets:insert(proto_msg_id_record_map,{24009,'temp_activity_contents_s2c'}),
	ets:insert(proto_msg_id_record_map,{24010,'temp_activity_get_award_c2s'}),
	ets:insert(proto_msg_id_record_map,{24011,'temp_activity_get_award_s2c'}),
	ets:insert(proto_msg_id_record_map,{20084,'query_open_service_time_c2s'}),
	ets:insert(proto_msg_id_record_map,{20085,'query_open_service_time_s2c'}),
	ets:insert(proto_msg_id_record_map,{4021,'tangle_battle_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{4022,'pet_inherit_preview_c2s'}),
	ets:insert(proto_msg_id_record_map,{4023,'pet_inherit_preview_s2c'}),
	
	%% travel match
	ets:insert(proto_msg_id_record_map,{2200,'travel_match_register_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{2201,'travel_match_register_forecast_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{2202,'travel_match_register_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{2203,'travel_match_query_role_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{2204,'travel_match_query_role_info_s2c'}),
	ets:insert(proto_msg_id_record_map,{2205,'travel_match_register_c2s'}),
	ets:insert(proto_msg_id_record_map,{2206,'travel_match_register_s2c'}),
	ets:insert(proto_msg_id_record_map,{2207,'travel_match_enter_wait_map_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{2208,'travel_match_enter_wait_map_forecast_end_s2c'}),
	ets:insert(proto_msg_id_record_map,{2209,'travel_match_enter_wait_map_c2s'}),
	ets:insert(proto_msg_id_record_map,{2210,'travel_match_battle_start_s2c'}),
	ets:insert(proto_msg_id_record_map,{2211,'travel_match_section_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{2212,'travel_match_battle_awards_s2c'}),
	ets:insert(proto_msg_id_record_map,{2213,'travel_match_query_unit_player_list_c2s'}),
	ets:insert(proto_msg_id_record_map,{2214,'travel_match_leave_wait_map_c2s'}),
	ets:insert(proto_msg_id_record_map,{2215,'travel_match_stage_result_s2c'}),
	ets:insert(proto_msg_id_record_map,{2216,'travel_match_query_unit_player_list_s2c'}),
	ets:insert(proto_msg_id_record_map,{2217,'travel_match_query_session_data_c2s'}),
	ets:insert(proto_msg_id_record_map,{2218,'travel_match_query_session_data_s2c'}),

	%% dead valley
	ets:insert(proto_msg_id_record_map,{2400,'dead_valley_start_forecast_s2c'}),
	ets:insert(proto_msg_id_record_map,{2401,'dead_valley_start_nofity_s2c'}),
	ets:insert(proto_msg_id_record_map,{2402,'dead_valley_end_forecast_s2c'}),
	ets:insert(proto_msg_id_record_map,{2403,'dead_valley_end_notify_s2c'}),
	ets:insert(proto_msg_id_record_map,{2404,'dead_valley_enter_c2s'}),
	ets:insert(proto_msg_id_record_map,{2405,'dead_valley_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{2406,'dead_valley_points_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{2407,'dead_valley_boss_hp_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{2408,'dead_valley_trap_touch_c2s'}),
	ets:insert(proto_msg_id_record_map,{2409,'dead_valley_trap_leave_c2s'}),
	ets:insert(proto_msg_id_record_map,{2410,'dead_valley_force_leave_s2c'}),
	ets:insert(proto_msg_id_record_map,{2411,'dead_valley_exp_update_s2c'}),
	ets:insert(proto_msg_id_record_map,{2412,'dead_valley_query_zone_info_c2s'}),
	ets:insert(proto_msg_id_record_map,{2413,'dead_valley_query_zone_info_s2c'}),
	
	ok.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
encode_pet_savvy_up_s2c(Term) ->    
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).	
encode_pet_savvy_up_c2s(Term) ->
	T2 = erlang:setelement(1,Term, []),
	erlang:term_to_binary(T2).
encode_player_role_list_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_line_query_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_line_query_ok_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_change_line_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_player_select_role_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_map_complete_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_map_change_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_other_role_map_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_change_map_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_change_map_ok_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_change_map_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_move_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_heartbeat_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_other_role_move_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_move_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_attack_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_attack_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_cancel_attack_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_be_attacked_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_be_killed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_other_role_into_view_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_into_view_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_creature_outof_view_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_debug_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_use_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_auto_equip_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_item_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_use_item_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_buff_immune_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_attribute_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_attribute_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_rename_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_rename_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rename_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_map_change_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_map_change_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_map_change_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_skill_panel_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_learned_skill_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_display_hotbar_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_hotbar_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_hotbar_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_skill_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_list_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_list_remove_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_list_add_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_statu_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_questgiver_hello_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_questgiver_quest_details_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_questgiver_accept_quest_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_quit_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_questgiver_complete_quest_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_complete_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_complete_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_questgiver_states_update_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_questgiver_states_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_details_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_details_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_get_adapt_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_get_adapt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_accept_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_quest_direct_complete_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_buff_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_del_buff_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_buff_affect_attr_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_move_stop_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loot_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loot_query_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loot_response_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loot_pick_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loot_remove_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loot_release_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_player_level_up_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_cancel_buff_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_money_from_monster_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_item_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_destroy_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_delete_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_split_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_swap_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_onhands_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_storage_items_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_storage_items_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_arrange_items_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_arrange_items_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chat_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chat_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chat_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loudspeaker_queue_num_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loudspeaker_queue_num_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loudspeaker_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chat_private_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chat_private_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_apply_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_agree_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_create_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_invite_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_accept_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_decline_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_kickout_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_setleader_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_disband_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_depart_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_invite_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_decline_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_destroy_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_list_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_cmd_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_member_stats_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_group_apply_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_recruite_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_recruite_cancel_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_recruite_query_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_recruite_query_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_recruite_cancel_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_recruite_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_recruite_cancel_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_recruite_cancel_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_aoi_role_group_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_aoi_role_group_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_fucnction_common_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_function_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_function_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_shoping_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_shoping_item_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_shoping_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_buy_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_buy_item_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_sell_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_sell_item_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_repair_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_fatigue_prompt_with_type_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_fatigue_login_disabled_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_fatigue_prompt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_fatigue_alert_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_finish_register_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_object_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_monster_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_upgrade_guild_monster_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_smith_need_contribution_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_leave_guild_instance_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_join_guild_instance_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_create_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_disband_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_invite_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_decline_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_accept_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_apply_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_depart_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_kickout_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_set_leader_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_promotion_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_demotion_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_log_normal_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_log_event_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_notice_modify_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_facilities_accede_rules_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_facilities_upgrade_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_facilities_speed_up_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_rewards_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_recruite_info_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_contribute_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_base_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_facilities_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_delete_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_add_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_destroy_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_decline_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_invite_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_recruite_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_log_normal_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_log_event_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_get_application_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_get_application_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_application_op_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_change_nickname_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_change_chatandvoicegroup_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_update_log_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_create_role_request_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_create_role_sucess_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_create_role_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_inspect_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_inspect_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_inspect_faild_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_user_auth_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_user_auth_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_skill_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_skill_item_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_skill_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_skill_learn_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_skill_auto_learn_item_c2s(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_skill_learn_item_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_feedback_info_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_feedback_info_ret_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_respawn_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_other_login_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_block_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_is_jackaroo_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_is_visitor_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_is_finish_visitor_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_visitor_rename_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_visitor_rename_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_visitor_rename_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mall_item_list_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mall_item_list_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_mall_item_list_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_mall_item_list_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_buy_mall_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_hot_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_latest_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mall_item_list_special_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mall_item_list_special_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mall_item_list_sales_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mall_item_list_sales_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_role_mall_integral_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_query_player_option_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_query_player_option_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_replace_player_option_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_info_back_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_revert_black_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_revert_black_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_signature_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_signature_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_get_friend_signature_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_get_friend_signature_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_set_black_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_set_black_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_delete_black_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_delete_black_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_black_list_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_myfriends_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_myfriends_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_friend_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_friend_success_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_friend_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_becare_friend_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_delete_friend_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_delete_friend_success_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_delete_friend_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_online_friend_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_offline_friend_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_detail_friend_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_detail_friend_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_detail_friend_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_position_friend_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_position_friend_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_position_friend_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_black_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_black_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_lottery_lefttime_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_lottery_leftcount_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_lottery_clickslot_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_lottery_clickslot_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_lottery_otherslot_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_lottery_notic_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_lottery_clickslot_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_lottery_querystatus_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_start_block_training_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_start_block_training_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_end_block_training_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_end_block_training_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_status_query_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_status_query_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_arrived_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_query_detail_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_query_detail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_get_addition_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_get_addition_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_send_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_delete_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_delete_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_operator_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mail_sucess_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_apply_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_accept_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_decline_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_set_trade_money_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_set_trade_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_cancel_trade_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_lock_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_dealit_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_errno_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_begin_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_trade_status_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_lock_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_dealit_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_decline_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_role_apply_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_cancel_trade_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_trade_success_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_riseup_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_riseup_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_riseup_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_sock_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_sock_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_sock_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_inlay_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_inlay_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_inlay_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_stone_remove_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_stone_remove_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_stone_remove_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_equipment_stonemix_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

%%批量合成 zhangting
encode_equipment_stonemix_bat_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).


encode_equipment_stonemix_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).


encode_equipment_stonemix_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_upgrade_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_upgrade_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_enchant_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_enchant_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_recast_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_recast_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_recast_confirm_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_convert_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_convert_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_move_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_move_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_remove_seal_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_remove_seal_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equipment_fenjie_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equip_fenjie_optresult_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_achieve_open_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_achieve_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_achieve_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_achieve_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_achieve_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_goals_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_goals_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_goals_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_goals_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_goals_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_enter_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_enter_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_masters_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_masters_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_enter_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_challenge_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_challenge_success_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_challenge_again_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_tower_enter_higher_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_vip_ui_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_vip_ui_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_vip_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_vip_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_vip_level_up_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_vip_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_vip_npc_enum_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_login_bonus_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_vip_role_use_flyshoes_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_join_vip_map_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_query_system_switch_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_system_status_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_duel_invite_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_duel_decline_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_duel_accept_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_duel_invite_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_duel_decline_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_duel_start_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_duel_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_set_pkmodel_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_set_pkmodel_faild_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_clear_crime_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_clear_crime_time_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_query_time_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_query_time_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stop_move_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_identify_verify_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_identify_verify_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mp_package_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_fly_shoes_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_hp_package_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_swap_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_use_target_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_join_battle_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_battlefield_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_start_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_join_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_leave_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_self_join_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_remove_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_other_join_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_waiting_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_instance_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_get_instance_log_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_get_instance_log_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_records_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_records_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_topman_pos_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_more_records_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_more_records_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_instance_exit_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_instance_leader_join_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_instance_leader_join_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_start_everquest_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_everquest_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_refresh_everquest_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_refresh_everquest_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_start_everquest_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_everquests_enum_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_npc_everquests_enum_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_everquest_list_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_instance_end_seconds_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_pets_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_create_pet_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_summon_pet_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_move_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_stop_move_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_attack_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_rename_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_present_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_present_apply_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_present_apply_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_up_reset_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_up_reset_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_up_growth_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_up_stamina_growth_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_up_growth_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_up_stamina_growth_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_opt_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_learn_skill_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_up_exp_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_forget_skill_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_delete_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_swap_slot_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_inspect_pet_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_inspect_pet_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_riseup_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_riseup_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_skill_slot_lock_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_pet_skill_slot_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_pet_skill_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_learned_pet_skill_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_pet_skill_slots_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_learn_skill_cover_best_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_buy_pet_slot_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_pet_slot_num_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_feed_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_training_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_start_training_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_stop_training_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_speedup_training_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_training_init_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_init_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_getitem_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_getallitems_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_updateitem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_additem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_delitem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_explore_storage_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_explore_info_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_explore_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_explore_start_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_explore_speedup_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_explore_stop_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_explore_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_explore_gain_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_flush_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_flush_ok_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_raffle_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_raffle_ok_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_obtain_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_obtain_ok_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_query_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_query_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_broad_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_chest_disable_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_smashed_egg_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_smashed_egg_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_smashed_egg_tamp_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_smashed_egg_tamp_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_smashed_egg_refresh_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_smashed_egg_refresh_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).	
encode_god_tree_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_god_tree_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_god_tree_rock_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_god_tree_rock_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_god_tree_init_storage_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).	
encode_god_tree_storage_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).	
encode_god_tree_storage_init_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).	
encode_god_tree_storage_updateitem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).	
encode_god_tree_storage_additem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).	
encode_god_tree_storage_getitem_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_god_tree_storage_delitem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_god_tree_storage_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_god_tree_storage_getallitems_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_god_tree_broad_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_beads_pray_request_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_beads_pray_response_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_beads_pray_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_exchange_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_exchange_item_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_enum_exchange_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_exchange_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_exchange_item_fail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battle_reward_by_records_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_timelimit_gift_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_get_timelimit_gift_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_timelimit_gift_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_timelimit_gift_over_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_sell_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_recede_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stalls_search_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_detail_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_buy_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_rename_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stalls_search_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_detail_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stalls_search_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_log_add_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stall_role_detail_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stalls_search_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battlefield_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battlefield_info_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battlefield_info_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_battlefield_totle_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_battlefield_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_all_battle_over_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_notify_to_join_yhzq_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_join_yhzq_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_leave_yhzq_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_award_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_award_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_camp_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_zone_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_battle_self_join_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_battle_other_join_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_battle_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_battle_remove_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_battle_player_pos_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_yhzq_battle_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_random_rolename_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_reset_random_rolename_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_sign_notice_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_sign_request_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_sign_success_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_start_notice_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_question_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_question_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_question_ranklist_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_answer_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_offline_exp_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_offline_exp_quests_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_offline_exp_exchange_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_offline_exp_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_offline_exp_exchange_gold_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_congratulations_levelup_remind_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_congratulations_levelup_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_congratulations_levelup_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_congratulations_receive_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_congratulations_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_congratulations_received_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_buffer_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_gift_card_state_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_gift_card_apply_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_gift_card_apply_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_role_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_update_power_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_update_skill_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_update_chess_power_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_skill_levelup_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_cast_skill_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_cast_chess_skill_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_opt_result_s2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_log_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_log_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_get_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_quit_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_game_over_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_chess_spirit_prepare_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_get_shop_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_get_shop_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_shop_buy_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_get_treasure_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_get_treasure_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_treasure_buy_item_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_treasure_set_price_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_treasure_update_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_publish_guild_quest_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_guild_quest_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_guild_apply_state_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_guild_update_apply_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_update_apply_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_get_guild_notice_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_send_guild_notice_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_shop_update_item_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_guild_battle_limit_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_guild_right_limit_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_have_guildbattle_right_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_bonfire_start_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_levelup_opt_levels_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_levelup_opt_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_bonfire_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_forecast_begin_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_forecast_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_system_broadcast_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_moneygame_left_time_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_moneygame_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_moneygame_prepare_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_moneygame_cur_sec_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_mastercall_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_mastercall_accept_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_mastercall_success_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_pos_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_member_pos_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_sitdown_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_stop_sitdown_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_companion_sitdown_apply_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_companion_sitdown_apply_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_companion_sitdown_start_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_companion_sitdown_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_companion_reject_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_companion_reject_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_faction_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_left_time_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_state_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_num_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_num_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_faction_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_start_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_dragon_fight_join_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_star_spawns_section_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_advanced_start_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_advanced_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_advanced_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_shareexp_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_active_point_start_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_active_point_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_active_point_end_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_venation_time_countdown_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_other_venation_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_server_travel_tag_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_continuous_logging_gift_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_continuous_logging_board_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_continuous_days_clear_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_continuous_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_continuous_logging_board_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_init_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_getitem_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_getallitems_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_updateitem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_additem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_delitem_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_storage_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_value_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_value_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_value_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_value_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_value_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_state_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_state_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_state_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_boss_born_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_boss_born_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_boss_born_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_first_charge_gift_state_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_first_charge_gift_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_first_charge_gift_reward_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_get_rank_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_get_rank_role_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_loop_tower_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_killer_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_moneys_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_melee_power_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_range_power_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_magic_power_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_loop_tower_num_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_level_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_answer_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_get_rank_role_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_disdain_role_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_praise_role_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_judge_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_chess_spirits_single_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_chess_spirits_team_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_facebook_bind_check_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_facebook_bind_check_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_clear_nickname_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_everyday_show_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_judge_to_other_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_talent_score_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_mail_line_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_get_main_line_rank_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rank_fighting_force_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_welfare_panel_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_welfare_panel_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_welfare_gifepacks_state_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_welfare_gold_exchange_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_welfare_gold_exchange_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_welfare_gold_exchange_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_ride_opt_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_ride_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_item_identify_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_item_identify_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_ride_pet_synthesis_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_ridepet_synthesis_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_ridepet_synthesis_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_random_talent_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_change_talent_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_random_talent_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_item_identify_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_evolution_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_upgrade_quality_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_upgrade_quality_up_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_add_attr_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_wash_attr_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_upgrade_quality_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_upgrade_quality_up_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_update_item_for_pet_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_equip_item_for_pet_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_unequip_item_for_pet_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_pet_item_opt_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_refine_system_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_refine_system_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_welfare_activity_update_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_welfare_activity_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_designation_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_designation_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_inspect_designation_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_transport_time_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_transport_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_start_guild_transport_failed_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_rob_treasure_transport_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_server_treasure_transport_start_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_server_treasure_transport_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_role_treasure_transport_time_check_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_transport_left_time_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_start_guild_treasure_transport_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_transport_call_guild_help_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_start_entry_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_start_entry_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_start_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_start_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_end_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_lefttime_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_timeout_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_remain_monsters_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_kill_monsters_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_section_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_protect_npc_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_mainline_reward_success_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_start_notice_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_request_banquetlist_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_request_banquetlist_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_join_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_join_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_dancing_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_cheering_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_cheering_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_leave_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_leave_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_stop_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_dancing_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_banquet_update_count_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_transport_call_guild_help_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_treasure_transport_call_guild_help_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_server_version_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_server_version_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_country_notice_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_country_notice_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_country_transport_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_change_country_transport_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_leader_promotion_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_leader_demotion_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_leader_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_block_talk_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_change_crime_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_leader_online_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_leader_get_itmes_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_leader_ever_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_start_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_entry_guild_battle_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_entry_guild_battle_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_leave_guild_battle_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_leave_guild_battle_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_score_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_score_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_status_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_stop_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_country_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_ready_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_apply_guild_battle_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_start_apply_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_battle_stop_apply_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_open_service_activities_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_open_sercice_activities_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_open_service_activities_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_init_open_service_activities_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_activity_tab_isshow_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_festival_init_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_festival_recharge_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_festival_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_festival_recharge_exchange_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_festival_recharge_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_festival_recharge_notice_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_start_notice_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_join_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_join_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_leave_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_leave_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_end_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_stop_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_jszd_battlefield_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_contribute_log_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_contribute_log_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_impeach_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_impeach_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_impeach_info_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_impeach_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_impeach_vote_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_impeach_stop_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_guild_join_lefttime_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_sync_bonfire_time_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_spiritspower_state_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_spiritspower_reset_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_christmas_tree_grow_up_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_christmas_activity_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_christmas_tree_hp_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_play_effects_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_kill_info_request_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_tangle_kill_info_request_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_get_guild_monster_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_call_guild_monster_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_callback_guild_monster_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_get_guild_monster_info_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_entry_loop_instance_apply_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_entry_loop_instance_vote_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_entry_loop_instance_vote_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_entry_loop_instance_vote_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_entry_loop_instance_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_entry_loop_instance_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_leave_loop_instance_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_leave_loop_instance_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_instance_reward_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_instance_reward_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_instance_remain_monsters_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_instance_kill_monsters_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_instance_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_loop_instance_kill_monsters_info_init_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_honor_stores_buy_items_c2s(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_buy_honor_item_error_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_monster_section_update_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_favorite_gift_info_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_tgw_gateway_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).


encode_refresh_instance_quality_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_refresh_instance_quality_opt_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_refresh_instance_quality_result_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_refresh_everquest_result_s2c(Term) ->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

%%pet quailty rise up
encode_pet_quality_riseup_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).		
%%宠物进阶
encode_pet_grade_riseup_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
    
%% 宠物资质编码
encode_pet_qualification_upgrade_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).

%% --------------------------------------------------------------------------------
%% 6重礼包相关
%%---------------------------------------------------------------------------------
% 发送玩家6重礼包状态
encode_charge_package_init_s2c(Term) ->
	Term2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(Term2).
%% 发送玩家6重礼包领取结果
encode_get_charge_package_s2c(Term) ->
	Term2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(Term2).
%% 充值金额改变
encode_charge_package_gold_change_s2c(Term) ->
	Term2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(Term2).
	
encode_yellow_vip_init_s2c(Term) ->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_yellow_vip_level_reward_result_s2c(Term) ->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_pet_shop_goods_s2c(Term) ->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_send_error_s2c(Term) ->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_pet_type_change_s2c(Term) ->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_pet_inherit_s2c(Term) ->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_pet_inherit_preview_s2c(Term) ->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).

encode_charge_reward_init_s2c(Term) ->
	Term2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(Term2).

encode_get_charge_reward_s2c(Term) ->
	Term2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(Term2).

%%阵营战
encode_camp_battle_start_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_stop_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_entry_c2s(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_entry_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_leave_c2s(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_leave_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_init_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_otherrole_update_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_otherrole_init_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_otherrole_leave_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_info_update_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_record_init_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_record_update_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_result_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_player_num_c2s(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_player_num_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_last_record_c2s(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_last_record_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_camp_battle_opt_s2c(Term)->
    T2 = erlang:setelement(1,Term,[]),
    erlang:term_to_binary(T2).
encode_battle_totleadd_honor_s2c(Term)->
	T2 = erlang:setelement(1,Term,[]),
	erlang:term_to_binary(T2).
encode_add_buff_in_battle_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

%% 宠物精炼
encode_pet_reset_type_attr_s2c(Term) ->
    T2 = erlang:setelement(1, Term, []),
    erlang:term_to_binary(T2).

encode_guild_dice_c2s(Term) ->
    T2 = erlang:setelement(1, Term, []),
    erlang:term_to_binary(T2).
encode_guild_dice_s2c(Term) ->
    T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

% 升级加元宝
encode_goldlevel_show_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

% 查询任务状态
encode_role_quest_status_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_login_continuously_show_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_login_continuously_reward_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_sale_opt_result_s2c(Term) ->
  T2 = erlang:setelement(1, Term, []),
  erlang:term_to_binary(T2).
encode_sale_search_result_s2c(Term) ->
  T2 = erlang:setelement(1, Term, []),
  erlang:term_to_binary(T2).

encode_level_award_item_s2c(Term) ->
  T2 = erlang:setelement(1, Term, []),
  erlang:term_to_binary(T2).

encode_duplicate_prize_notify_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_duplicate_prize_item_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_bdyy_item_show_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_bdyy_item_hit_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_bdyy_item_end_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_companion_dancing_apply_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_companion_dancing_result_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_companion_dancing_reject_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_companion_dancing_stop_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

%% travel battle

encode_travel_battle_query_role_info_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_register_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_section_result_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_stage_result_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_open_shop_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_shop_buy_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_show_rank_page_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_lottery_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_forecast_begin_notice_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_forecast_end_notice_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_open_notice_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_close_notice_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_prepare_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_role_skills_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_change_skill_success_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_change_skill_failed_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_upgrade_skill_success_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_upgrade_skill_failed_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_register_wait_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_cancel_match_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_battle_notice_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_wedding_apply_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_wedding_apply_result_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_wedding_ceremony_time_available_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_wedding_ceremony_select_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_wedding_ceremony_notify_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_wedding_ceremony_start_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_wedding_ceremony_end_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_add_friend_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_add_friend_respond_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_delete_friend_beidong_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_friend_send_flowers_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_cur_heart_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_room_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_opend_room_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_open_room_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_into_room_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_shop_rfresh_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_room_balance_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_gold_get_exp_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_shop_account_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_shop_luck_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_skill_fuse_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).
	
encode_pet_skill_buy_slot_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).
encode_banquet_pet_swanking_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).
encode_banquet_pets_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_friend_add_intimacy_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_pet_shop_time_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_friend_send_flowers_notify_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).
encode_pet_sex_change_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_query_open_charge_feedback_info_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_query_open_charge_feedback_info_failed_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_open_charge_feedback_lottery_failed_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_open_charge_feedback_lottery_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_query_open_service_auction_info_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_query_open_service_auction_info_failed_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_open_service_auction_bid_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_open_service_auction_info_update_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_open_charge_feedback_get_award_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).


% client
encode_pet_egg_use_c2s(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).
encode_pet_quality_riseup_c2s(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).
encode_pet_grade_riseup_c2s(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).
encode_bdyy_start_c2s(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).
encode_holiday_activity_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_top_bar_show_items_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_top_bar_hide_items_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_temp_activity_contents_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_temp_activity_get_award_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_role_shift_pos_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_role_pull_objects_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_role_push_objects_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_query_open_service_time_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_tangle_battle_end_s2c(Term)->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

%% travel match

encode_travel_match_register_start_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_register_forecast_end_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_register_end_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_register_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_enter_wait_map_start_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_enter_wait_map_forecast_end_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_battle_start_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_section_result_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_battle_awards_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_rank_awards_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_query_role_info_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_skill_cooldown_reset_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_stage_result_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_query_unit_player_list_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_travel_match_query_session_data_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_query_travel_server_status_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

%% dead valley
encode_dead_valley_start_forecast_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_dead_valley_start_nofity_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_dead_valley_end_forecast_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_dead_valley_end_notify_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_dead_valley_points_update_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_dead_valley_boss_hp_update_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_dead_valley_force_leave_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_dead_valley_exp_update_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).

encode_dead_valley_query_zone_info_s2c(Term) ->
	T2 = erlang:setelement(1, Term, []),
	erlang:term_to_binary(T2).