-record(mail_query_detail_c2s, {msgid=533,mailid}).
-record(equipment_sock_c2s, {msgid=603,equipment,sock}).
-record(item_identify_error_s2c, {msgid=1481,error}).
-record(loop_tower_enter_s2c, {msgid=654,layer,trans}).
-record(get_instance_log_s2c, {msgid=832,instance_id,times,type,exp,entrusttimes}).
-record(apply_guild_battle_c2s, {msgid=1667}).
-record(treasure_chest_query_s2c, {msgid=990,items,slots}).
-record(system_status_s2c, {msgid=701,sysid,status}).


-record(npc_function_s2c, {msgid=302,npcid,values,quests,queststate,everquests}).
-record(object_update_s2c, {msgid=353,create_attrs,change_attrs,deleteids}).
-record(ip, {moneytype,price}).
-record(init_hot_item_s2c, {msgid=432,lists}).
-record(chess_spirit_cast_chess_skill_c2s, {msgid=1177}).
-record(welfare_gifepacks_state_update_s2c, {msgid=1462,typenumber,time_state,complete_state}).
-record(vip_init_s2c, {msgid=675,vip,type,type2}).
-record(rm, {roleid,rolename,guildname,classtype,serverid,money}).
-record(stall_opt_result_s2c, {msgid=1043,errno}).
-record(heartbeat_c2s, {msgid=26,beat_time}).
-record(continuous_opt_result_s2c, {msgid=1303,result}).
-record(add_signature_c2s, {msgid=472,signature}).
-record(loop_tower_challenge_success_s2c, {msgid=656,layer,bonus}).
-record(rank_killer_s2c, {msgid=1431,param}).
-record(enum_shoping_item_fail_s2c, {msgid=311,reason}).
-record(guild_member_kickout_c2s, {msgid=367,roleid}).
-record(loop_tower_reward_c2s, {msgid=657,bonus}).
-record(guild_notice_modify_c2s, {msgid=373,notice}).
-record(banquet_join_s2c, {msgid=1604,banquetid,cheering,dancing,peting,lefttime,cheeringtime,dancingtime,petingtime}).
-record(npc_init_s2c, {msgid=15,npcs}).
-record(guild_mastercall_success_s2c, {msgid=1247}).
-record(role_cancel_attack_s2c, {msgid=32,roleid,reason}).
-record(timelimit_gift_over_s2c, {msgid=1023}).
-record(i, {itemid_low,itemid_high,protoid,enchantments,count,slot,isbonded,socketsinfo,duration,enchant,lefttime_s}).
-record(guild_member_decline_c2s, {msgid=363,roleid}).
-record(mainline_opt_s2c, {msgid=1577,errno}).
-record(mainline_start_s2c, {msgid=1566,chapter,stage,difficulty,opcode}).
-record(npc_storage_items_c2s, {msgid=128,npcid}).
-record(join_battle_error_s2c, {msgid=818,errno}).
-record(npc_attribute_s2c, {msgid=54,npcid,attrs}).
-record(treasure_transport_time_s2c, {msgid=1550,left_time}).
-record(sell_item_fail_s2c, {msgid=316,reason}).
-record(sell_item_c2s, {msgid=315,npcid,slot}).
-record(end_block_training_s2c, {msgid=513,roleid}).
-record(stagetop, {serverid,roleid,name,bestscore}).
-record(jszd, {id,name,score,rank,peoples}).
-record(treasure_chest_flush_c2s, {msgid=981,slot}).
-record(use_target_item_c2s, {msgid=813,targetid,slot}).
-record(stall_recede_item_c2s, {msgid=1031,itemlid,itemhid}).
-record(recruite_cancel_c2s, {msgid=168}).
-record(lottery_clickslot_s2c, {msgid=505,lottery_slot,item}).
-record(mainline_protect_npc_info_s2c, {msgid=1576,npcprotoid,maxhp,curhp}).
-record(guild_battle_result_s2c, {msgid=1661,index}).
-record(stalls_search_item_s2c, {msgid=1045,index,totalnum,serchitems}).
-record(swap_item_c2s, {msgid=126,srcslot,desslot}).
-record(exchange_item_fail_s2c, {msgid=1005,reason}).
-record(visitor_rename_s2c, {msgid=426}).
-record(server_travel_tag_s2c, {msgid=1290,istravel}).
-record(debug_c2s, {msgid=38,msg}).
-record(trade_role_dealit_s2c, {msgid=574,roleid}).
-record(mainline_result_s2c, {msgid=1569,chapter,stage,difficulty,result,reward,bestscore,score,duration}).
-record(query_player_option_c2s, {msgid=450,key}).
-record(offline_exp_quests_init_s2c, {msgid=1132,questinfos}).
-record(gti, {id,showindex,realprice,buynum}).
-record(yhzq_all_battle_over_s2c, {msgid=1098}).
-record(guild_get_treasure_item_s2c, {msgid=1204,treasuretype,itemlist}).
-record(update_pet_skill_s2c, {msgid=928,petid,skills}).
-record(aoi_role_group_s2c, {msgid=176,groups_role}).
-record(chess_spirit_log_s2c, {msgid=1180,type,lastsec,lasttime,bestsec,bestsectime,canreward,rewardexp,rewarditems}).
-record(explore_storage_init_end_s2c, {msgid=962}).
-record(gbt, {index,name,yhzqscore,jszdscore,score}).
-record(ach, {isreward,chapter,part,cur,target}).
-record(treasure_chest_obtain_c2s, {msgid=986}).
-record(guild_facilities_update_s2c, {msgid=384,facinfo}).
-record(buff_affect_attr_s2c, {msgid=103,roleid,attrs}).
-record(npc_swap_item_c2s, {msgid=812,npcid,srcslot,desslot}).
-record(lottery_leftcount_s2c, {msgid=502,leftcount}).
-record(activity_boss_born_init_s2c, {msgid=1414,bslist}).
-record(first_charge_gift_reward_opt_s2c, {msgid=1418,code}).
-record(get_friend_signature_c2s, {msgid=473,fn}).
-record(is_finish_visitor_c2s, {msgid=425,t,f,u}).
-record(query_time_s2c, {msgid=741,time_async}).
-record(pp, {protoid,quality,strength,agile,intelligence,stamina,growth,stamina_growth,class_type,talents}).
-record(mainline_reward_success_s2c, {msgid=1578,chapter,stage}).
-record(role_line_query_ok_s2c, {msgid=7,lines}).
-record(update_guild_update_apply_info_s2c, {msgid=1211,role,type}).
-record(beads_pray_request_c2s, {msgid=995,type,times,consume_type}).
-record(smashed_egg_init_c2s, {msgid=4001}).
-record(smashed_egg_init_s2c, {msgid=4002,item_list}).
-record(smashed_egg_tamp_c2s, {msgid=4003,place}).
-record(smashed_egg_tamp_s2c, {msgid=4004,item_list}).
-record(smashed_egg_refresh_c2s, {msgid=4005}).
-record(smashed_egg_refresh_s2c, {msgid=4006,result}).
-record(god_tree_init_c2s, {msgid=4007}).
-record(god_tree_init_s2c, {msgid=4008,result}).
-record(god_tree_rock_c2s, {msgid=4009,times}).
-record(god_tree_rock_s2c, {msgid=4010,itemlist}).
-record(god_tree_init_storage_c2s, {msgid=4011}).
-record(god_tree_storage_info_s2c, {msgid=4012,items}).
-record(god_tree_storage_init_end_s2c, {msgid=4013}).
-record(god_tree_storage_updateitem_s2c, {msgid=4014,itemlist}).
-record(god_tree_storage_additem_s2c, {msgid=4015,items}).
-record(god_tree_storage_getitem_c2s, {msgid=4016,slot,itemsign}).
-record(god_tree_storage_delitem_s2c, {msgid=4017,start,length}).
-record(god_tree_storage_opt_s2c, {msgid=4018,code}).
-record(god_tree_storage_getallitems_c2s, {msgid=4019}).
-record(god_tree_broad_s2c, {msgid=4020,rolename,item}).
-record(treasure_transport_call_guild_help_c2s, {msgid=1621}).
-record(end_block_training_c2s, {msgid=512}).
-record(group_kickout_c2s, {msgid=156,roleid}).
-record(equip_item_for_pet_c2s, {msgid=1511,petid,slot}).
-record(guild_base_update_s2c, {msgid=382,guildname,level,silver,gold,notice,chatgroup,voicegroup}).
-record(av, {id,completed}).
-record(treasure_chest_raffle_ok_s2c, {msgid=985,slot}).
-record(login_bonus_reward_c2s, {msgid=677}).
-record(buy_pet_slot_c2s, {msgid=940}).
-record(vip_reward_c2s, {msgid=672}).
-record(dragon_fight_faction_c2s, {msgid=1263,npcid}).
-record(npc_everquests_enum_s2c, {msgid=856,everquests,npcid}).
-record(timelimit_gift_info_s2c, {msgid=1020,nextindex,nexttime,itmes}).
-record(dragon_fight_faction_s2c, {msgid=1258,newfaction}).
-record(activity_forecast_begin_s2c, {msgid=1230,type,beginhour,beginmin,beginsec,endhour,endmin,endsec}).
-record(role_change_map_ok_s2c, {msgid=23}).
-record(other_role_into_view_s2c, {msgid=35,other}).
-record(guild_rename_c2s, {msgid=56,slot,newname}).
-record(auto_equip_item_c2s, {msgid=40,slot}).
-record(pet_upgrade_quality_s2c, {msgid=1504,result,value}).
-record(guild_battle_stop_s2c, {msgid=1664}).
-record(guild_log_event_c2s, {msgid=372}).
-record(timelimit_gift_error_s2c, {msgid=1022,reason}).
-record(chat_private_c2s, {msgid=146,serverid,roleid}).
-record(guild_member_promotion_c2s, {msgid=369,roleid}).
-record(stall_rename_c2s, {msgid=1036,stall_name}).
-record(continuous_logging_board_c2s, {msgid=1301}).
-record(companion_sitdown_result_s2c, {msgid=1255,result}).
-record(country_leader_online_s2c, {msgid=1650,post,postindex,name}).
-record(role_move_fail_s2c, {msgid=28,pos}).
-record(clear_crime_time_s2c, {msgid=734,lefttime,type}).
-record(pet_up_stamina_growth_s2c, {msgid=915,result,next}).
-record(pet_up_exp_c2s, {msgid=918,petid,needs}).
-record(rc, {rolename,args}).
-record(banquet_cheering_c2s, {msgid=1607,roleid}).
-record(banquet_dancing_s2c, {msgid=1605,name,bename,remain}).
-record(rank_melee_power_s2c, {msgid=1433,param}).
-record(explore_storage_info_s2c, {msgid=961,items}).
-record(identify_verify_c2s, {msgid=800,truename,card}).
-record(be_attacked_s2c, {msgid=33,enemyid,skill,units,flytime}).
-record(quest_quit_c2s, {msgid=88,questid}).
-record(money_from_monster_s2c, {msgid=113,npcid,npcproto,money}).
-record(server_version_s2c, {msgid=1631,v}).
-record(welfare_gold_exchange_c2s, {msgid=1465}).
-record(revert_black_c2s, {msgid=469,fn}).
-record(enum_shoping_item_c2s, {msgid=310,npcid}).
-record(delete_friend_c2s, {msgid=486,fn}).
-record(role_attack_c2s, {msgid=29,skillid,creatureid}).
-record(start_guild_treasure_transport_c2s, {msgid=1558}).
-record(guild_member_update_s2c, {msgid=383,roleinfo}).
-record(questgiver_states_update_s2c, {msgid=93,npcid,queststate}).
-record(unequip_item_for_pet_c2s, {msgid=1512,petid,slot}).
-record(stalls_search_item_c2s, {msgid=1037,searchstr,index}).
-record(answer_question_ranklist_s2c, {msgid=1128,ranklist}).
-record(server_version_c2s, {msgid=1630}).
-record(buff_immune_s2c, {msgid=43,enemyid,immune_buffs,flytime}).
-record(rank_disdain_role_c2s, {msgid=1440,roleid}).
-record(lottery_lefttime_s2c, {msgid=501,leftseconds}).
-record(mail_get_addition_s2c, {msgid=536,mailid}).
-record(pet_up_growth_c2s, {msgid=912,petid,needs,protect}).
-record(entry_loop_instance_vote_c2s, {msgid=1803,state}).
-record(country_change_crime_c2s, {msgid=1649,name,type}).
-record(activity_forecast_end_s2c, {msgid=1231,type}).
-record(mall_item_list_s2c, {msgid=430,mitemlists}).
-record(battle_reward_c2s, {msgid=827}).
-record(banquet_leave_s2c, {msgid=1612}).
-record(congratulations_levelup_c2s, {msgid=1141,roleid,level,type}).
-record(battle_leave_c2s, {msgid=822}).
-record(guild_change_nickname_c2s, {msgid=397,roleid,nickname}).
-record(battle_reward_by_records_c2s, {msgid=1010,year,month,day,battletype,battleid}).
-record(set_pkmodel_c2s, {msgid=730,pkmodel}).
-record(treasure_storage_init_end_s2c, {msgid=1312}).
-record(position_friend_s2c, {msgid=495,posfr}).
-record(fatigue_login_disabled_s2c, {msgid=341,lefttime,prompt}).
-record(group_apply_c2s, {msgid=150,username}).
-record(battle_other_join_s2c, {msgid=828,commer}).
 %% 原来是int，现在[int]  from jianhua.zhu  zhangting
-record(equipment_fenjie_c2s, {msgid=628,equipment}).
-record(yhzq_battle_player_pos_s2c, {msgid=1118,players}).
-record(treasure_chest_failed_s2c, {msgid=983,reason}).
-record(guildlog, {type,id,keystr,year,month,day,hour,min,sec}).
-record(entry_guild_battle_c2s, {msgid=1654}).
-record(country_init_s2c, {msgid=1640,leaders,notice,tp_start,tp_stop,bestguildlid,bestguildhid,bestguildname}).
-record(equip_fenjie_optresult_s2c, {msgid=629,result}).
-record(beads_pray_response_s2c, {msgid=996,type,times,itemslist}).
-record(hp_package_s2c, {msgid=811,itemidl,itemidh,buffid}).
-record(cancel_buff_c2s, {msgid=112,buffid}).
-record(venation_active_point_end_c2s, {msgid=1285}).
-record(get_guild_monster_info_c2s, {msgid=1764}).
-record(trade_role_apply_s2c, {msgid=576,roleid}).
-record(equipment_remove_seal_c2s, {msgid=627,equipment,reseal}).
-record(treasure_storage_init_c2s, {msgid=1310}).
%%旧的单一合成功能，前端叫equipment_stonemix_single_c2s
-record(equipment_stonemix_c2s, {msgid=612,stonelist}). 
-record(equipment_stonemix_failed_s2c, {msgid=614,reason}).
 %%原来接口不变  zhangting from zhu.jianhua
-record(equipment_stonemix_s2c, {msgid=613,newstone}). 

%%批量合成功能,前端叫equipment_stonemix_c2s
-record(equipment_stonemix_bat_c2s, {msgid=599,stoneSlot,numRequire,numMix}). 
  %% 批量合成返回   zhangting from zhu.jianhua
-record(equipment_stonemix_bat_result_s2c, {msgid=595,succ_times,fau_times,used_stones,moneys}).

-record(add_buff_s2c, {msgid=101,targetid,buffers}).
-record(g, {roleid,rolename,rolelevel,gender,classtype,posting,contribution,tcontribution,online,nickname,fightforce}).
-record(mail_arrived_s2c, {msgid=532,mail_status}).
-record(update_pet_slot_num_s2c, {msgid=941,num}).
-record(equipment_riseup_c2s, {msgid=600,equipment,riseup,protect,lucky}).
-record(guild_recruite_info_s2c, {msgid=391,recinfos}).
-record(pet_start_training_c2s, {msgid=951,petid,totaltime,type}).
-record(mall_item_list_special_c2s, {msgid=434,ntype2}).
-record(quest_accept_failed_s2c, {msgid=98,errno}).
-record(lottery_clickslot_c2s, {msgid=504,clickslot}).
-record(companion_reject_s2c, {msgid=1257,rolename}).
-record(dragon_fight_state_s2c, {msgid=1260,npcid,faction,state}).
-record(summon_pet_c2s, {msgid=902,type,petid}).
-record(change_role_mall_integral_s2c, {msgid=440,charge_integral,by_item_integral}).
-record(explore_storage_getitem_c2s, {msgid=963,slot,itemsign}).
-record(loot_release_s2c, {msgid=110,packetid}).
-record(group_cmd_result_s2c, {msgid=164,roleid,username,reslut}).
-record(equipment_riseup_s2c, {msgid=601,result,star}).
-record(guild_disband_c2s, {msgid=361}).
-record(delete_item_s2c, {msgid=124,itemid_low,itemid_high,reason}).
-record(pet_delete_s2c, {msgid=920,petid}).
-record(inspect_pet_c2s, {msgid=922,serverid,rolename,petid}).
-record(chess_spirit_role_info_s2c, {msgid=1171,power,chesspower,max_power,max_chesspower,share_skills,self_skills,chess_skills,type}).
-record(o, {objectid,objecttype,attrs}).
-record(festival_recharge_s2c, {msgid=1692,festival_id,state,starttime,endtime,award_limit_time,lefttime,today_charge_num,exchange_info,gift}).
-record(guild_member_accept_c2s, {msgid=364,roleid}).
-record(role_recruite_cancel_c2s, {msgid=173}).
-record(gps, {typenumber,time_state,complete_state}).
-record(guild_facilities_upgrade_c2s, {msgid=375,facilityid}).
-record(everquest_list_s2c, {msgid=857,everquests}).
-record(equipment_inlay_s2c, {msgid=607}).
-record(start_block_training_c2s, {msgid=510}).
-record(pet_move_c2s, {msgid=903,petid,time,posx,posy,path}).
-record(car_move_c2s, {msgid=977,carid,time,posx,posy,path}).
-record(achieve_open_c2s, {msgid=630}).
-record(other_login_s2c, {msgid=420}).
-record(venation_advanced_start_c2s, {msgid=1276,venationid,bone,useitem,type}).
-record(questgiver_hello_c2s, {msgid=85,npcid}).
-record(stop_sitdown_c2s, {msgid=1251}).
-record(treasure_storage_getitem_c2s, {msgid=1313,slot,itemsign}).
-record(mail_operator_failed_s2c, {msgid=540,reason}).
-record(tangle_battlefield_info_s2c, {msgid=819,killnum,honor,battleinfo}).
-record(ms, {mailid,from,titile,status,type,has_add,leftseconds,month,day}).
-record(stall_detail_s2c, {msgid=1040,ownerid,stallid,stallname,stallitems,logs,isonline}).
-record(banquet, {banquetid,join_count,limit}).
-record(guild_battle_status_update_s2c, {msgid=1660,state,lefttime,guildindex,roleid,rolename,roleclass,rolegender}).
-record(banquet_request_banquetlist_c2s, {msgid=1601}).
-record(enum_skill_item_fail_s2c, {msgid=413,reason}).
-record(stall_buy_item_c2s, {msgid=1035,stallid,itemlid,itemhid}).
-record(leave_guild_battle_s2c, {msgid=1657,result}).
-record(tangle_kill_info_request_c2s, {msgid=1751,year,month,day,battletype,battleid}).
-record(treasure_storage_delitem_s2c, {msgid=1317,start,length}).
-record(imi, {mitemid,price,discount}).
-record(pet_explore_error_s2c, {msgid=975,error}).
-record(group_agree_c2s, {msgid=151,roleid}).
-record(star_spawns_section_s2c, {msgid=1267,section}).
-record(role_rename_c2s, {msgid=55,slot,newname}).
-record(activity_state_init_s2c, {msgid=1411,aslist}).
-record(map_complete_c2s, {msgid=13}).
-record(monster_section_update_s2c, {msgid=1823,mapid,section}).
-record(init_open_service_activities_c2s, {msgid=1683,activeid}).
-record(kmi, {npcproto,neednum}).
-record(guild_facilities_speed_up_c2s, {msgid=376,facilityid,slotnum}).
-record(stop_move_c2s, {msgid=742,time,posx,posy}).
-record(guild_battle_start_s2c, {msgid=1653}).
-record(tp, {roleid,x,y}).
-record(stage, {chapter,stageindex,state,bestscore,rewardflag,entrytime,topone}).
-record(entry_loop_instance_vote_s2c, {msgid=1801,state}).
-record(loop_tower_enter_failed_s2c, {msgid=651,reason}).
-record(gm, {monsterid,state}).
-record(get_guild_notice_c2s, {msgid=1213,guildlid,guildhid}).
-record(b, {creatureid,damagetype,damage}).
-record(guild_treasure_set_price_c2s, {msgid=1206,treasuretype,id,itemid,price}).
-record(honor_stores_buy_items_c2s, {msgid=1821,type,itemid,count}).
-record(tangle_remove_s2c, {msgid=825,roleid}).
-record(npc_into_view_s2c, {msgid=36,npc}).
-record(questgiver_complete_quest_c2s, {msgid=89,questid,npcid,choiceslot}).
-record(mid, {midlow,midhigh}).
-record(trade_role_lock_s2c, {msgid=573,roleid}).
-record(display_hotbar_s2c, {msgid=72,things}).
-record(fly_shoes_c2s, {msgid=810,mapid,posx,posy,slot}).
-record(br, {id,fn,classid,gender,status}).
-record(equipment_recast_c2s, {msgid=619,equipment,recast,type,lock_arr}).
-record(t, {roleid,level,life,maxhp,mana,maxmp,posx,posy,mapid,lineid,cloth,arm}).
-record(questgiver_states_update_c2s, {msgid=92,npcid}).
-record(loop_instance_remain_monsters_info_s2c, {msgid=1810,kill_num,remain_num,type,layer}).
-record(battlefield_info_c2s, {msgid=1088,battle}).
-record(role_change_line_c2s, {msgid=9,lineid}).
-record(mail_get_addition_c2s, {msgid=535,mailid}).
-record(battlefield_info_error_s2c, {msgid=1089,error}).
-record(treasure_storage_updateitem_s2c, {msgid=1315,itemlist}).
-record(is_visitor_c2s, {msgid=423,t,f}).
-record(equipment_stone_remove_failed_s2c, {msgid=611,reason}).
-record(venation_advanced_opt_result_s2c, {msgid=1278,result,bone}).
-record(chat_private_s2c, {msgid=147,roleid,level,roleclass,rolegender,signature,guildname,guildlid,guildhid,viptag,rolename,serverid}).
-record(chess_spirit_info_s2c, {msgid=1170,cur_section,used_time_s,next_sec_time_s,spiritmaxhp,spiritcurhp}).
-record(query_player_option_s2c, {msgid=451,kv}).
-record(rank_get_rank_c2s, {msgid=1428,type}).
-record(enum_exchange_item_s2c, {msgid=1003,npcid,dhs}).
-record(system_broadcast_s2c, {msgid=1235,id,param}).
-record(role_attribute_s2c, {msgid=53,roleid,attrs}).
-record(welfare_activity_update_s2c, {msgid=1531,typenumber,state,result}).
-record(other_role_move_s2c, {msgid=27,other_id,time,posx,posy,path}).
-record(loop_tower_challenge_c2s, {msgid=655,type}).
-record(delete_black_c2s, {msgid=477,fn}).
-record(trade_role_apply_c2s, {msgid=560,roleid}).
-record(jszd_update_s2c, {msgid=1705,roleid,score,lefttime,guilds}).
-record(upgrade_guild_monster_c2s, {msgid=355,monsterid}).
-record(trade_role_lock_c2s, {msgid=566}).
-record(guild_treasure_update_item_s2c, {msgid=1207,treasuretype,item}).
-record(banquet_leave_c2s, {msgid=1611}).
-record(charge, {id,awarddate,charge_num,state}).
-record(offline_friend_s2c, {msgid=490,fn}).
-record(quest_complete_failed_s2c, {msgid=91,questid,errno}).
-record(quest_details_s2c, {msgid=95,npcid,questid,queststate}).
-record(enum_skill_item_s2c, {msgid=414,npcid}).
-record(yhzq_camp_info_s2c, {msgid=1110,redplayernum,blueplayernum,redscore,bluescore,redguild,blueguild}).
-record(bf, {bufferid,bufferlevel,durationtime}).
-record(use_item_c2s, {msgid=39,slot}).
-record(change_guild_battle_limit_c2s, {msgid=1216,fightforce}).
-record(leave_yhzq_c2s, {msgid=1107}).
-record(rank_get_main_line_rank_c2s, {msgid=1453,type,chapter,festival,difficulty}).
-record(npc_everquests_enum_c2s, {msgid=855,npcid}).
-record(yhzq_battle_update_s2c, {msgid=1116,camp,role}).
-record(guild_treasure_buy_item_c2s, {msgid=1205,treasuretype,id,itemid,count}).
-record(fr, {id,fn,classid,gender,online,sign,intimacy,status}).
-record(dragon_fight_num_s2c, {msgid=1262,npcid,faction,num}).
-record(equipment_sock_s2c, {msgid=604,result,sock}).
-record(equipment_inlay_failed_s2c, {msgid=608,reason}).
-record(player_role_list_s2c, {msgid=5,roles}).
-record(myfriends_s2c, {msgid=481,friendinfos}).
-record(start_block_training_s2c, {msgid=511,roleid,lefttime}).
-record(continuous_days_clear_c2s, {msgid=1302}).
-record(ride_opt_c2s, {msgid=1466,opcode}).
-record(welfare_panel_init_s2c, {msgid=1461,packs_state}).
-record(ri, {leader_id,leader_line,instance,members,description}).
-record(open_service_activities_reward_c2s, {msgid=1682,id,part}).
-record(be_killed_s2c, {msgid=34,creatureid,murderer,deadtype,posx,posy,series_kills}).

-record(recruite_query_c2s, {msgid=169,instance}).
-record(role_attack_s2c, {msgid=31,result,skillid,enemyid,creatureid}).
-record(guild_get_application_c2s, {msgid=394}).
-record(gift_card_apply_s2c, {msgid=1163,errno}).
-record(guild_mastercall_accept_c2s, {msgid=1246}).
-record(companion_sitdown_apply_s2c, {msgid=1253,roleid}).
-record(npc_fucnction_common_error_s2c, {msgid=300,reasonid}).
-record(replace_player_option_c2s, {msgid=452,kv}).
-record(detail_friend_s2c, {msgid=492,defr}).
-record(npc_map_change_c2s, {msgid=62,npcid,id}).
-record(mainline_lefttime_s2c, {msgid=1571,chapter,stage,lefttime}).
-record(feedback_info_ret_s2c, {msgid=418,reason}).
-record(buy_mall_item_c2s, {msgid=431,mitemid,count,price,type}).
-record(guild_member_apply_c2s, {msgid=365,guildlid,guildhid}).
-record(guild_member_demotion_c2s, {msgid=370,roleid}).
-record(quest_list_add_s2c, {msgid=83,quest}).
-record(christmas_tree_grow_up_c2s, {msgid=1740,npcid,slot}).
-record(start_everquest_s2c, {msgid=850,everqid,questid,free_fresh_times,round,section,quality,npcid,resettime}).
-record(pet_up_reset_c2s, {msgid=910,petid,reset,protect,locked,pattr,lattr}).
-record(trade_begin_s2c, {msgid=571,roleid}).
-record(pet_skill_slot_lock_c2s, {msgid=926,petid,slot,status}).
-record(explore_storage_getallitems_c2s, {msgid=964}).
-record(achieve_init_s2c, {msgid=632,parts}).
-record(guild_bonfire_start_s2c, {msgid=1219,lefttime}).
-record(si, {item,money,gold,silver}).
-record(ki, {roleid,rolename,roleclass,rolelevel,times}).
-record(update_hotbar_c2s, {msgid=73,clsid,entryid,pos}).
-record(facebook_bind_check_result_s2c, {msgid=1446,fbid}).
-record(equipment_recast_confirm_c2s, {msgid=621,equipment}).
-record(christmas_activity_reward_c2s, {msgid=1741,type}).
-record(rank_judge_to_other_s2c, {msgid=1450,type,othername}).
-record(call_guild_monster_c2s, {msgid=1761,monsterid}).
-record(mainline_remain_monsters_info_s2c, {msgid=1573,kill_num,remain_num,chapter,stage}).
-record(explore_storage_init_c2s, {msgid=960}).
-record(loop_tower_masters_c2s, {msgid=652,master}).
-record(vb, {id,bone}).
-record(cl, {post,postindex,roleid,name,gender,roleclass}).
-record(npc_start_everquest_c2s, {msgid=854,npcid,everqid}).
-record(li, {lineid,rolecount}).
-record(dh, {itemclsid,consume,money}).
-record(guild_member_pos_c2s, {msgid=1248}).
-record(ride_opt_result_s2c, {msgid=1467,errno}).
-record(c, {x,y}).
-record(guild_bonfire_end_s2c, {msgid=1222}).
-record(rank_talent_score_s2c, {msgid=1451,param}).
-record(treasure_storage_opt_s2c, {msgid=1318,code}).
-record(guild_get_shop_item_s2c, {msgid=1201,shoptype,itemlist}).
-record(rcs, {roleid,today_count,total_count}).
-record(country_opt_s2c, {msgid=1662,code}).
-record(add_item_s2c, {msgid=121,item_attr}).
-record(instance_leader_join_c2s, {msgid=841}).
-record(group_setleader_c2s, {msgid=157,roleid}).
-record(ag, {roleid,leaderid,leadername,leaderlevel,member_num}).
-record(rank_moneys_s2c, {msgid=1432,param}).
-record(init_onhands_item_s2c, {msgid=127,item_attrs}).
-record(del_buff_s2c, {msgid=102,buffid,target}).
-record(guild_member_decline_s2c, {msgid=388,rolename}).
-record(group_destroy_s2c, {msgid=162}).
-record(offline_exp_error_s2c, {msgid=1134,reason}).
-record(festival_error_s2c, {msgid=1693,error}).
-record(visitor_rename_c2s, {msgid=427,n}).
-record(get_instance_log_c2s, {msgid=831}).
-record(companion_sitdown_start_c2s, {msgid=1254,roleid}).
-record(loop_instance_reward_s2c, {msgid=1809,layer,type,curlayer}).
-record(rl, {roleid,name,x,y,friendly,attrs}).
-record(vip_error_s2c, {msgid=673,reason}).
-record(guild_shop_update_item_s2c, {msgid=1215,shoptype,item}).
-record(rob_treasure_transport_s2c, {msgid=1553,othername,rewardmoney}).
-record(mainline_section_info_s2c, {msgid=1575,cur_section,next_section_s}).
-record(activity_boss_born_init_c2s, {msgid=1413}).
-record(leave_guild_instance_c2s, {msgid=358}).
-record(facebook_bind_check_c2s, {msgid=1445}).
-record(guild_shop_buy_item_c2s, {msgid=1202,shoptype,id,itemid,count}).
-record(add_friend_failed_s2c, {msgid=484,reason}).
-record(tsi, {itemprotoid,solt,count,itemsign}).
-record(is_jackaroo_s2c, {msgid=422}).
-record(loop_tower_masters_s2c, {msgid=653,ltms}).
-record(eq, {everqid,questid,free_fresh_times,round,section,quality}).
-record(loudspeaker_queue_num_c2s, {msgid=143}).
-record(pet_stop_training_c2s, {msgid=952,petid}).
-record(pet_change_talent_c2s, {msgid=1486,petid}).
-record(position_friend_c2s, {msgid=494,fn}).
-record(tangle_more_records_c2s, {msgid=836,year,month,day,type,battleid}).
-record(rp, {petid,petname,rolename,args}).
-record(trade_role_decline_s2c, {msgid=575,roleid}).
-record(join_guild_instance_c2s, {msgid=359,type}).
-record(jszd_start_notice_s2c, {msgid=1700,lefttime}).
-record(equipment_riseup_failed_s2c, {msgid=602,reason}).
-record(mall_item_list_sales_c2s, {msgid=436,ntype}).
-record(banquet_update_count_s2c, {msgid=1615,dancing,cheering,swanking}).
-record(rank_mail_line_s2c, {msgid=1452,chapter,festival,difficulty,param}).
-record(enum_exchange_item_c2s, {msgid=1001,npcid}).
-record(join_vip_map_c2s, {msgid=679,transid}).
-record(guild_log_event_s2c, {msgid=393}).
-record(vip_ui_s2c, {msgid=671,vip,gold,endtime}).
-record(mail_delete_c2s, {msgid=538,mailid}).
-record(chess_spirit_update_chess_power_s2c, {msgid=1174,newpower}).
-record(chess_spirit_update_skill_s2c, {msgid=1173,update_skills}).
-record(gsi, {id,showindex,realprice,buynum}).
-record(battle_join_c2s, {msgid=821,type}).
-record(congratulations_levelup_s2c, {msgid=1142,exp,soulpower,remain}).
-record(tangle_records_s2c, {msgid=833,year,month,day,type,totalbattle,mybattleid}).
-record(group_depart_c2s, {msgid=159}).
-record(equipment_move_c2s, {msgid=624,fromslot,toslot}).
-record(guild_battlefield_info_s2c, {msgid=1087,rankinfo}).
-record(stall_sell_item_c2s, {msgid=1030,slot,silver,gold,ticket}).
-record(init_latest_item_s2c, {msgid=433,lists}).
-record(aoi_role_group_c2s, {msgid=175}).
-record(mall_item_list_sales_s2c, {msgid=437,mitemlists}).
-record(chess_spirit_skill_levelup_c2s, {msgid=1175,skillid}).
-record(pet_up_stamina_growth_c2s, {msgid=913,petid,needs,protect}).
-record(companion_sitdown_apply_c2s, {msgid=1252,roleid}).
-record(update_hotbar_fail_s2c, {msgid=74}).
-record(moneygame_prepare_s2c, {msgid=1242,second}).
-record(explore_storage_opt_s2c, {msgid=968,code}).
-record(ridepet_synthesis_opt_result_s2c, {msgid=1483,pettmpid,resultattr}).
-record(guild_impeach_info_c2s, {msgid=1724}).
-record(create_pet_s2c, {msgid=901,pet}).
-record(explore_storage_additem_s2c, {msgid=966,items}).
-record(add_black_s2c, {msgid=498,blackinfo}).
-record(loop_instance_kill_monsters_info_init_s2c, {msgid=1813,info,type,layer}).
-record(ltm, {layer,rolename,time}).
-record(init_mall_item_list_s2c, {msgid=439,mitemlists}).
-record(update_pet_skill_slot_s2c, {msgid=927,petid,slot}).
-record(loot_remove_item_s2c, {msgid=109,packetid,slot_num}).
-record(fatigue_prompt_s2c, {msgid=350,prompt}).
-record(detail_friend_failed_s2c, {msgid=493,reason}).
-record(inspect_s2c, {msgid=404,roleid,rolename,classtype,gender,guildname,level,cloth,arm,maxhp,maxmp,power,magic_defense,range_defense,melee_defense,stamina,strength,intelligence,agile,hitrate,criticalrate,criticaldamage,dodge,toughness,meleeimmunity,rangeimmunity,magicimmunity,imprisonment_resist,silence_resist,daze_resist,poison_resist,normal_resist,vip_tag,items_attr,guildpost,exp,levelupexp,soulpower,maxsoulpower,guildlid,guildhid,role_crime,fighting_force,curhp,curmp}).
-record(guild_battle_ready_s2c, {msgid=1666,remaintime}).
-record(jszd_reward_c2s, {msgid=1707}).
-record(vip_role_use_flyshoes_s2c, {msgid=678,leftnum,totlenum}).
-record(answer_sign_notice_s2c, {msgid=1122,lefttime}).
-record(creature_outof_view_s2c, {msgid=37,creature_id}).
-record(ssi, {item,stallid,ownerid,ownername,itemnum,isonline}).
-record(add_item_failed_s2c, {msgid=122,errno}).
-record(mainline_kill_monsters_info_s2c, {msgid=1574,npcprotoid,neednum,chapter,stage}).
-record(pet_present_apply_c2s, {msgid=908,slot}).
-record(treasure_chest_obtain_ok_s2c, {msgid=987}).
-record(role_recruite_c2s, {msgid=172,instanceid}).
-record(f, {id,level,lefttime,fulltime,requirevalue,contribution,tcontribution}).
-record(guild_get_treasure_item_c2s, {msgid=1203,treasuretype}).
-record(tr, {roleid,rolename,rolegender,roleclass,rolelevel,kills,score}).
-record(guild_impeach_info_s2c, {msgid=1725,roleid,notice,support,opposite,vote,lefttime_s}).
-record(add_levelup_opt_levels_s2c, {msgid=1220,levels}).
-record(delete_black_s2c, {msgid=478,target_name}).
-record(time_struct, {year,month,day,hour,minute,second}).
-record(equipment_remove_seal_s2c, {msgid=626}).
-record(mail_status_query_s2c, {msgid=531,mail_status}).
-record(chess_spirit_cast_skill_c2s, {msgid=1176,skillid}).
-record(duel_accept_c2s, {msgid=712,roleid}).
-record(inspect_pet_s2c, {msgid=923,rolename,petattr,skillinfo,slot}).
-record(loot_s2c, {msgid=105,packetid,npcid,posx,posy}).
-record(join_yhzq_c2s, {msgid=1106,reject}).
-record(loot_query_c2s, {msgid=106,packetid}).
-record(quest_get_adapt_s2c, {msgid=97,questids,everqids}).
-record(acs, {id,state}).
-record(m, {roleid,rolename,level,classtype,gender}).
-record(feedback_info_c2s, {msgid=417,type,title,content,contactway}).
-record(venation_init_s2c, {msgid=1280,venation,venationbone,attr,remaintime,totalexp}).
-record(refresh_everquest_s2c, {msgid=853,everqid,questid,quality,free_fresh_times,resettime}).
-record(rank_magic_power_s2c, {msgid=1435,param}).
-record(yhzq_award_s2c, {msgid=1108,winner,honor,exp}).
-record(guild_contribute_log_s2c, {msgid=1721,roles}).
-record(rank_range_power_s2c, {msgid=1434,param}).
-record(questgiver_quest_details_s2c, {msgid=86,npcid,quests,queststate}).
-record(lottery_clickslot_failed_s2c, {msgid=508,reason}).
-record(rank_praise_role_c2s, {msgid=1441,roleid}).
-record(gr, {guildlid,guildhid,guildname,level,membernum,formalnum,leader,restrict,facslevel,applyflag,createyear,createmonth,createday,sort}).
-record(guild_change_chatandvoicegroup_c2s, {msgid=398,chatgroup,voicegroup}).
-record(ride_pet_synthesis_c2s, {msgid=1482,slot_a,slot_b,itemslot,type}).
-record(change_smith_need_contribution_c2s, {msgid=357,contribution}).
-record(guild_rewards_c2s, {msgid=377}).
-record(skill_learn_item_c2s, {msgid=415,skillid}).
-record(skill_auto_learn_item_c2s, {msgid=2055, skilllist}).
-record(slv, {skillid,level}).
-record(explore_storage_delitem_s2c, {msgid=967,start,length}).
-record(answer_end_s2c, {msgid=1129,exp}).
-record(guild_get_application_s2c, {msgid=395,roles}).
-record(mall_item_list_special_s2c, {msgid=435,mitemlists}).
-record(guild_mastercall_s2c, {msgid=1245,posting,name,lineid,mapid,posx,posy,reasonid}).
-record(yhzq_battle_self_join_s2c, {msgid=1114,redroles,blueroles,battleid,lefttime}).
-record(k, {key,value}).
-record(player_select_role_c2s, {msgid=10,roleid,lineid}).
-record(rank_get_rank_role_s2c, {msgid=1439,roleid,rolename,classtype,gender,guildname,level,cloth,arm,vip_tag,items_attr,be_disdain,be_praised,left_judge}).
-record(venation_shareexp_update_s2c, {msgid=1282,remaintime,totalexp}).
-record(init_pets_s2c, {msgid=900,pets,max_pet_num,present_slot}).
-record(pet_rename_c2s, {msgid=906,petid,newname}).
-record(chess_spirit_prepare_s2c, {msgid=1184,time_s}).
-record(pet_item_opt_result_s2c, {msgid=1513,errno}).
-record(sync_bonfire_time_s2c, {msgid=1729,lefttime}).
-record(guild_battle_start_apply_s2c, {msgid=1668,lefttime}).
-record(r, {roleid,name,lastmapid,classtype,gender,level}).
-record(activity_value_init_c2s, {msgid=1400}).
-record(gift_card_state_s2c, {msgid=1161,weburl,state}).
-record(oqe, {questid,addition}).
-record(inspect_faild_s2c, {msgid=405,errno}).
-record(votestate, {roleid,state}).
-record(lottery_notic_s2c, {msgid=507,rolename,item}).
-record(tab_state, {id,state}).
-record(pet_explore_info_s2c, {msgid=971,petid,remaintimes,siteid,explorestyle,lefttime}).
-record(companion_reject_c2s, {msgid=1256,roleid}).
-record(everyday_show_s2c, {msgid=1448}).
-record(loop_tower_enter_c2s, {msgid=650,layer,enter,convey}).
-record(equipment_move_s2c, {msgid=625}).
-record(group_invite_s2c, {msgid=160,roleid,username}).
-record(notify_to_join_yhzq_s2c, {msgid=1105,battle_id,camp}).
-record(battle_end_s2c, {msgid=826,honor,exp}).
-record(arrange_items_s2c, {msgid=131,type,items,lowids,highids}).
-record(set_pkmodel_faild_s2c, {msgid=731,errno}).
-record(use_item_error_s2c, {msgid=42,errno}).
-record(buy_item_fail_s2c, {msgid=314,reason}).
-record(item_identify_c2s, {msgid=1480,slot,itemslot,type}).
-record(jszd_error_s2c, {msgid=1708,reason}).
-record(goals_init_s2c, {msgid=640,parts}).
-record(guild_transport_left_time_s2c, {msgid=1557,left_time}).
-record(mainline_start_entry_c2s, {msgid=1563,chapter,stage,difficulty}).
-record(guild_create_c2s, {msgid=360,name,type}).
-record(congratulations_receive_s2c, {msgid=1143,exp,soulpower,type,rolename,level,roleid}).
-record(tangle_records_c2s, {msgid=834,year,month,day,type}).
-record(treasure_chest_broad_s2c, {msgid=991,rolename,item}).
-record(yhzq_zone_info_s2c, {msgid=1111,zonelist}).
-record(open_sercice_activities_update_s2c, {msgid=1681,id,part,state}).
-record(ridepet_synthesis_error_s2c, {msgid=1484,error}).
-record(trade_role_dealit_c2s, {msgid=567}).
-record(pfr, {fn,lineid,mapid,posx,posy}).
-record(vip_level_up_s2c, {msgid=674}).
-record(guild_member_add_s2c, {msgid=386,roleinfo}).
-record(query_time_c2s, {msgid=740}).
-record(guild_get_shop_item_c2s, {msgid=1200,shoptype}).
-record(pet_evolution_c2s, {msgid=1489,petid,itemslot}).
-record(gift_card_apply_c2s, {msgid=1162,key,type}).
-record(group_disband_c2s, {msgid=158}).
-record(nl, {npcid,name,x,y,friendly,attrs}).
-record(map_change_failed_s2c, {msgid=63,reasonid}).
-record(answer_question_c2s, {msgid=1126,id,answer,flag}).
-record(visitor_rename_failed_s2c, {msgid=428,reason}).
-record(set_black_s2c, {msgid=476,target_name}).
-record(pet_present_s2c, {msgid=907,present_pets}).
-record(update_trade_status_s2c, {msgid=572,roleid,silver,gold,ticket,slot_infos}).
-record(guild_facilities_accede_rules_c2s, {msgid=374,facilityid,requirevalue}).
-record(rank_judge_opt_result_s2c, {msgid=1442,roleid,disdainnum,praisednum,leftnum}).
-record(jszd_battlefield_info_s2c, {msgid=1710,score,killnum,honor,gbinfo}).
-record(guild_battle_stop_apply_s2c, {msgid=1669}).
-record(loudspeaker_queue_num_s2c, {msgid=144,num}).
-record(quest_direct_complete_c2s, {msgid=99,questid}).
-record(equipment_stone_remove_s2c, {msgid=610}).
-record(trade_role_decline_c2s, {msgid=562,roleid}).
-record(country_leader_promotion_c2s, {msgid=1645,post,postindex,name}).
-record(recharge, {id,state}).
%% -record(equipment_stone_remove_c2s, {msgid=609,equipment,remove,socknum}).
-record(equipment_stone_remove_c2s, {msgid=609,equipment,socknum}).
-record(fatigue_alert_s2c, {msgid=351,alter}).
-record(publish_guild_quest_c2s, {msgid=1208}).
-record(stalls_search_s2c, {msgid=1041,index,totalnum,stalls}).
-record(treasure_chest_query_c2s, {msgid=989}).
-record(refine_system_s2c, {msgid=1521,result}).
-record(chat_s2c, {msgid=141,type,serverid,privateflag,desroleid,desrolename,msginfo,details,identity}).
-record(answer_sign_success_s2c, {msgid=1124}).
-record(welfare_gold_exchange_init_c2s, {msgid=1463}).
-record(country_leader_get_itmes_c2s, {msgid=1651}).
-record(offline_exp_exchange_c2s, {msgid=1133,type,hours}).
-record(sp, {itemclsid,price}).
-record(kl, {key,value}).
-record(stall_detail_c2s, {msgid=1034,stallid}).
-record(pet_forget_skill_c2s, {msgid=919,petid,slot,skillid}).
-record(guild_impeach_c2s, {msgid=1722,notice}).
-record(item_identify_opt_result_s2c, {msgid=1488,itemtmpid}).
-record(country_init_c2s, {msgid=1665}).
-record(jszd_end_s2c, {msgid=1706,myrank,guilds,honor,exp}).
-record(instance_info_s2c, {msgid=830,protoid,times,left_time}).
-record(pet_add_attr_c2s, {msgid=1502,petid,power_add,hitrate_add,criticalrate_add,stamina_add}).
-record(activity_state_init_c2s, {msgid=1410}).
-record(jszd_stop_s2c, {msgid=1709}).
-record(info_back_c2s, {msgid=453,type,info,version}).
-record(position_friend_failed_s2c, {msgid=496,reason}).
-record(instance_leader_join_s2c, {msgid=840,instanceid}).
-record(l, {itemprotoid,count}).
-record(di, {disctype,count}).
-record(activity_boss_born_update_s2c, {msgid=1415,updatebs}).
-record(init_mall_item_list_c2s, {msgid=438,ntype}).
-record(delete_friend_failed_s2c, {msgid=488,reason}).
-record(answer_sign_request_c2s, {msgid=1123}).
-record(get_friend_signature_s2c, {msgid=474,signature}).
-record(send_guild_notice_s2c, {msgid=1214,guildlid,guildhid,notice}).
-record(achieve_update_s2c, {msgid=633,part}).
-record(equipment_convert_c2s, {msgid=622,equipment,convert,type}).
-record(ic, {itemid_low,itemid_high,attrs,ext_enchant}).
-record(quest_complete_s2c, {msgid=90,questid}).
-record(yhzq_battle_remove_s2c, {msgid=1117,camp,roleid}).
-record(pet_upgrade_quality_up_s2c, {msgid=1505,type,result,value}).
-record(banquet_join_c2s, {msgid=1603,banquetid}).
-record(pet_wash_attr_c2s, {msgid=1503,petid,type}).
-record(welfare_panel_init_c2s, {msgid=1460}).
-record(recruite_c2s, {msgid=167,instance,description}).
-record(block_s2c, {msgid=421,type,time}).
-record(online_friend_s2c, {msgid=489,fn}).
-record(role_line_query_c2s, {msgid=6,mapid}).
-record(update_skill_s2c, {msgid=75,creatureid,skillid,level}).
-record(equipment_upgrade_s2c, {msgid=616}).
-record(guild_opt_result_s2c, {msgid=381,errno}).
-record(bs, {bossid,state}).
-record(moneygame_result_s2c, {msgid=1241,result,use_time,section}).
-record(instance_exit_c2s, {msgid=838}).
-record(loop_instance_kill_monsters_info_s2c, {msgid=1811,npcprotoid,neednum,type,layer}).
-record(pet_learn_skill_c2s, {msgid=917,petid,slot,force}).
-record(gbr, {guildname,score,rank}).
-record(update_item_for_pet_s2c, {msgid=1510,petid,items}).
-record(lottery_querystatus_c2s, {msgid=509}).
-record(achieve_error_s2c, {msgid=634,reason}).
-record(answer_question_s2c, {msgid=1127,id,score,rank,continu}).
-record(battle_waiting_s2c, {msgid=829,waitingtime}).
-record(change_item_failed_s2c, {msgid=41,itemid_low,itemid_high,errno}).
-record(init_random_rolename_s2c, {msgid=1120,bn,gn}).
-record(pet_explore_stop_c2s, {msgid=974,petid}).
-record(jszd_leave_s2c, {msgid=1704}).
-record(dragon_fight_end_s2c, {msgid=1265,rednum,bluenum,winfaction}).
-record(battlefield_totle_info_s2c, {msgid=1090,gbinfo}).
-record(battle_start_s2c, {msgid=820,type,lefttime}).
-record(identify_verify_s2c, {msgid=801,code}).
-record(venation_update_s2c, {msgid=1281,venation,point,attr}).
-record(duel_invite_s2c, {msgid=720,roleid}).
-record(tbi, {msgid,battleid,curnum,totlenum}).
-record(play_effects_s2c, {msgid=1743,type,optroleid,effectid}).
-record(duel_invite_c2s, {msgid=710,roleid}).
-record(chess_spirit_log_c2s, {msgid=1179,type}).
-record(role_move_c2s, {msgid=25,time,posx,posy,path}).
-record(answer_error_s2c, {msgid=1130,reason}).
-record(npc_storage_items_s2c, {msgid=129,npcid,item_attrs}).
-record(stall_log_add_s2c, {msgid=1042,stallid,logs}).
-record(get_guild_monster_info_s2c, {msgid=1760,monster,lefttimes,call_cd}).
-record(rr, {id,name,level,classid,instance}).
-record(psk, {slot,skillid,level}).
-record(pet_stop_move_c2s, {msgid=904,petid,time,posx,posy}).
-record(mi, {mitemid,ntype,ishot,sort,price,discount}).
-record(change_country_transport_c2s, {msgid=1643,tp_start}).
-record(repair_item_c2s, {msgid=317,npcid,slot}).
-record(mainline_start_c2s, {msgid=1565,chapter,stage}).
-record(beads_pray_fail_s2c, {msgid=997,type}).
-record(guild_update_log_s2c, {msgid=399,log}).
-record(mainline_timeout_c2s, {msgid=1572,chapter,stage}).
-record(vip_ui_c2s, {msgid=670}).
-record(rkv, {kv,kv_plus,color}).
-record(split_item_c2s, {msgid=125,slot,split_num}).
-record(group_invite_c2s, {msgid=153,username}).
-record(yhzq_award_c2s, {msgid=1109}).
-record(callback_guild_monster_c2s, {msgid=1762,monsterid}).
-record(loop_instance_reward_c2s, {msgid=1808}).
-record(init_pet_skill_slots_s2c, {msgid=930,pslots}).
-record(jszd_join_s2c, {msgid=1702,lefttime,guilds}).
-record(moneygame_cur_sec_s2c, {msgid=1243,cursec,maxsec}).
-record(goals_error_s2c, {msgid=643,reason}).
-record(group_member_stats_s2c, {msgid=165,state}).
-record(banquet_stop_s2c, {msgid=1613}).
-record(dragon_fight_start_s2c, {msgid=1264,duration}).
-record(sitdown_c2s, {msgid=1250}).
-record(group_accept_c2s, {msgid=154,roleid}).
-record(set_trade_money_c2s, {msgid=563,moneytype,moneycount}).
-record(quest_list_remove_s2c, {msgid=82,questid}).
-record(recruite_cancel_s2c, {msgid=171,reason}).
-record(equipment_enchant_s2c, {msgid=618,enchants}).
-record(guild_member_invite_c2s, {msgid=362,name}).
-record(rank_fighting_force_s2c, {msgid=1454,param}).
-record(leave_loop_instance_s2c, {msgid=1807,layer,result}).
-record(quest_statu_update_s2c, {msgid=84,quests}).
-record(hc, {clsid,entryid,pos}).
-record(welfare_activity_update_c2s, {msgid=1530,typenumber,serial_number}).
-record(congratulations_error_s2c, {msgid=1144,reason}).
-record(s, {skillid,level,lefttime}).
-record(mail_status_query_c2s, {msgid=530}).
-record(tangle_update_s2c, {msgid=824,trs}).
-record(continuous_logging_board_s2c, {msgid=1304,normalawardday,vipawardday,days}).
-record(continuous_logging_gift_c2s, {msgid=1300,type,nowawardday}).
-record(pet_training_info_s2c, {msgid=950,petid,totaltime,remaintime}).
-record(role_recruite_cancel_s2c, {msgid=174,reason}).
-record(banquet_start_notice_s2c, {msgid=1600,level}).
-record(chat_c2s, {msgid=140,type,desserverid,desrolename,msginfo,details}).
-record(revert_black_s2c, {msgid=470,friendinfo}).
-record(equipment_inlay_c2s, {msgid=606,equipment,inlay,socknum}).
-record(treasure_storage_info_s2c, {msgid=1311,items}).
-record(entry_loop_instance_s2c, {msgid=1805,layer,result,lefttime,besttime}).
-record(equipment_recast_s2c, {msgid=620,enchants}).
-record(zoneinfo, {zoneid,state}).
-record(welfare_gold_exchange_init_s2c, {msgid=1464,consume_gold}).
-record(spiritspower_reset_c2s, {msgid=1731}).
-record(duel_result_s2c, {msgid=723,winner}).
-record(guild_impeach_result_s2c, {msgid=1723,result}).
-record(npc_function_c2s, {msgid=301,npcid}).
-record(pet_up_reset_s2c, {msgid=911,petid,strength,agile,intelligence}).
-record(entry_loop_instance_c2s, {msgid=1804,layer}).
-record(pet_learn_skill_cover_best_s2c, {msgid=931,petid,slot,skillid,oldlevel,newlevel}).
-record(create_role_request_c2s, {msgid=400,role_name,gender,classtype}).
-record(aqrl, {rolename,score}).
-record(first_charge_gift_reward_c2s, {msgid=1417}).
-record(country_leader_demotion_c2s, {msgid=1646,post,postindex}).
-record(role_map_change_c2s, {msgid=61,seqid,transid}).
-record(quest_details_c2s, {msgid=94,questid}).
-record(rank_chess_spirits_team_s2c, {msgid=1444,param}).
-record(arrange_items_c2s, {msgid=130,type}).
-record(psl, {petid,slots}).
-record(mainline_end_s2c, {msgid=1568}).
-record(guild_impeach_stop_s2c, {msgid=1727}).
-record(entry_loop_instance_vote_update_s2c, {msgid=1802,state}).
-record(first_charge_gift_state_s2c, {msgid=1416,state}).
-record(venation_advanced_update_s2c, {msgid=1277,attr}).
-record(other_venation_info_s2c, {msgid=1288,roleid,venation,attr,remaintime,totalexp,venationbone}).
-record(battle_self_join_s2c, {msgid=823,trs,battletype,battleid,lefttime}).
-record(festival_recharge_notice_s2c, {msgid=1696}).
-record(quest_list_update_s2c, {msgid=81,quests}).
-record(spiritspower_state_update_s2c, {msgid=1730,state,lefttime,curvalue}).
-record(equipment_convert_s2c, {msgid=623,enchants}).
-record(treasure_chest_raffle_c2s, {msgid=984}).
-record(recruite_query_s2c, {msgid=170,instance,rec_infos,role_rec_infos,usedtimes,isaddtime,lefttime}).
-record(pet_speedup_training_c2s, {msgid=953,petid,speeduptime}).
-record(treasure_transport_call_guild_help_result_s2c, {msgid=1620,result}).
-record(create_role_sucess_s2c, {msgid=401,role_id}).
-record(mainline_update_s2c, {msgid=1562,st,type}).
-record(loot_response_s2c, {msgid=107,packetid,slots}).
-record(delete_friend_success_s2c, {msgid=487,fn}).
-record(treasure_storage_additem_s2c, {msgid=1316,items}).
-record(change_country_notice_s2c, {msgid=1642,notice}).
-record(designation_init_s2c, {msgid=1540,designationid}).
-record(pet_feed_c2s, {msgid=942,petid,slot}).
-record(q, {questid,status,values,lefttime}).
-record(guild_contribute_log_c2s, {msgid=1720}).
-record(buy_honor_item_error_s2c, {msgid=1822,error}).
-record(rank_answer_s2c, {msgid=1438,param}).
-record(guild_have_guildbattle_right_s2c, {msgid=1218,right}).
-record(chess_spirit_opt_result_s2s, {msgid=1178,errno}).
-record(goals_update_s2c, {msgid=641,part}).
-record(yhzq_battle_end_s2c, {msgid=1119,honor,exp}).
-record(pet_attack_c2s, {msgid=905,petid,skillid,creatureid}).
-record(vp, {id,points}).
-record(guild_log_normal_s2c, {msgid=392,logs}).
-record(rank_get_rank_role_c2s, {msgid=1429,roleid}).
-record(activity_value_opt_s2c, {msgid=1404,code}).
-record(offline_exp_init_s2c, {msgid=1131,hour,totalexp}).
-record(role_change_map_c2s, {msgid=22}).
-record(trade_success_s2c, {msgid=578}).
-record(query_system_switch_c2s, {msgid=700,sysid}).
-record(venation_active_point_opt_s2c, {msgid=1284,reason}).
-record(guild_battle_opt_s2c, {msgid=1663,code}).
-record(country_leader_ever_reward_c2s, {msgid=1652}).
-record(fatigue_prompt_with_type_s2c, {msgid=340,prompt,type}).
-record(add_friend_success_s2c, {msgid=483,friendinfo}).
-record(activity_value_reward_c2s, {msgid=1403,itemid}).
-record(dragon_fight_join_c2s, {msgid=1266}).
-record(treasure_chest_flush_ok_s2c, {msgid=982,items}).
-record(jszd_leave_c2s, {msgid=1703}).
-record(mainline_end_c2s, {msgid=1567,chapter,stage}).
-record(gbs, {index,guildlid,guildhid,guildname}).
-record(questgiver_accept_quest_c2s, {msgid=87,npcid,questid}).
-record(treasure_buffer_s2c, {msgid=1160,buffs}).
-record(role_respawn_c2s, {msgid=419,type}).
-record(stall_role_detail_c2s, {msgid=1044,rolename}).
-record(tangle_more_records_s2c, {msgid=837,trs,year,month,day,type,myrank,battleid,has_reward}).
-record(guild_join_lefttime_s2c, {msgid=1728,lefttime}).
-record(treasure_storage_getallitems_c2s, {msgid=1314}).
-record(yhzq_error_s2c, {msgid=1099,reason}).
-record(p, {petid,protoid,level,name,gender,mana,quality,exp,power,dodge,hitrate,criticalrate,criticaldamage,life,defense,fighting_force,power_attr,hitrate_attr,dodge_attr,criticalrate_attr,criticaldamage_attr,life_attr,defense_attr,mpmax,class_type,state,pet_equips,trade_lock,grade,savvy,grade_riseup_lucky,quality_riseup_lucky,pet_stage, magic_defense, far_defense, near_defense, magic_immunity, far_immunity, near_immunity,happy,refresh_defense}).
-record(guild_recruite_info_c2s, {msgid=378}).
-record(mainline_init_s2c, {msgid=1561,st}).
-record(banquet_dancing_c2s, {msgid=1614,roleid,slot}).
-record(loop_instance_opt_s2c, {msgid=1812,code}).
-record(explore_storage_updateitem_s2c, {msgid=965,itemlist}).
-record(myfriends_c2s, {msgid=480,ntype}).
-record(treasure_chest_disable_c2s, {msgid=992,slots}).
-record(mainline_start_entry_s2c, {msgid=1564,chapter,stage,difficulty,opcode}).
-record(cancel_trade_s2c, {msgid=577}).
-record(update_everquest_s2c, {msgid=851,everqid,questid,free_fresh_times,round,section,quality}).
-record(group_apply_s2c, {msgid=166,roleid,username}).
-record(equipment_sock_failed_s2c, {msgid=605,reason}).
-record(rank_loop_tower_num_s2c, {msgid=1436,param}).
-record(mf, {creatureid,buffid,bufflevel}).
-record(pet_riseup_s2c, {msgid=925,result,next}).
-record(guild_battle_score_update_s2c, {msgid=1659,index,score}).
-record(enum_shoping_item_s2c, {msgid=312,npcid,sps}).
-record(skill_panel_c2s, {msgid=70}).
-record(trade_role_errno_s2c, {msgid=570,errno}).
-record(giftinfo, {needcharge,items}).
-record(duel_start_s2c, {msgid=722,roleid}).
-record(venation_opt_s2c, {msgid=1286,roleid,reason}).
-record(create_role_failed_s2c, {msgid=402,reasonid}).
-record(banquet_cheering_s2c, {msgid=1608,name,bename,remain}).
-record(activity_value_update_s2c, {msgid=1402,avlist,value,status}).
-record(mall_item_list_c2s, {msgid=429,ntype}).
-record(change_country_transport_s2c, {msgid=1644,tp_start,tp_stop}).
-record(role_change_map_fail_s2c, {msgid=24}).
-record(black_list_s2c, {msgid=479,friendinfos}).
-record(instance_end_seconds_s2c, {msgid=858,kicktime_s}).
-record(yhzq_battlefield_info_s2c, {msgid=1091,gbinfo}).
-record(update_guild_quest_info_s2c, {msgid=1209,lefttime}).
-record(guild_battle_score_init_s2c, {msgid=1658,guildlist}).
-record(pet_swap_slot_c2s, {msgid=921,petid,slot}).
-record(pet_training_init_info_s2c, {msgid=954,petid,totaltime,remaintime}).
-record(group_create_c2s, {msgid=152}).
-record(yhzq_battle_other_join_s2c, {msgid=1115,role,camp}).
-record(festival_init_c2s, {msgid=1691,festival_id}).
-record(refine_system_c2s, {msgid=1520,serial_number,times}).
-record(ti, {trade_slot,item_attrs}).
-record(mail_send_c2s, {msgid=537,toi,title,content,add_silver,add_item}).
-record(activity_state_update_s2c, {msgid=1412,updateas}).
-record(banquet_request_banquetlist_s2c, {msgid=1602,banquets}).
-record(rk, {roleid,rolename,guildname,classtype,serverid,args}).
-record(gbw, {index,name,score,winnum,losenum}).
-record(change_guild_right_limit_s2c, {msgid=1217,smith,battle}).
-record(stalls_search_c2s, {msgid=1033,index}).
-record(loop_tower_challenge_again_c2s, {msgid=658,type,again}).
-record(exchange_item_c2s, {msgid=1004,npcid,item_clsid,count,slots}).
-record(guild_set_leader_c2s, {msgid=368,roleid}).
-record(loot_pick_c2s, {msgid=108,packetid,slot_num}).
-record(change_country_notice_c2s, {msgid=1641,notice}).
-record(guild_member_invite_s2c, {msgid=389,roleid,rolename,guildlid,guildhid,guildname}).
-record(guild_member_contribute_c2s, {msgid=379,moneytype,moneycount}).
-record(guild_log_normal_c2s, {msgid=371,type}).
-record(equipment_enchant_c2s, {msgid=617,equipment,enchant}).
-record(treasure_transport_failed_s2c, {msgid=1551,reward}).
-record(ps, {petid,skills}).
-record(destroy_item_c2s, {msgid=123,slot}).
-record(gmp, {roleid,lineid,mapid}).
-record(pet_present_apply_s2c, {msgid=909,delete_slot}).
-record(rank_loop_tower_s2c, {msgid=1430,param}).
-record(enum_exchange_item_fail_s2c, {msgid=1002,reason}).
-record(moneygame_left_time_s2c, {msgid=1240,left_seconds}).
-record(skill_learn_item_fail_s2c, {msgid=416,reason}).
-record(guild_impeach_vote_c2s, {msgid=1726,type}).
-record(leave_loop_instance_c2s, {msgid=1806}).
-record(set_trade_item_c2s, {msgid=564,trade_slot,package_slot}).
-record(guild_update_apply_result_s2c, {msgid=1212,guildlid,guildhid,result}).
-record(server_treasure_transport_end_s2c, {msgid=1555}).
-record(psll, {slot,status}).
-record(role_treasure_transport_time_check_c2s, {msgid=1556}).
-record(move_stop_s2c, {msgid=104,id,x,y}).
-record(jszd_join_c2s, {msgid=1701}).
-record(inspect_designation_s2c, {msgid=1542,roleid,designationid}).
-record(pet_upgrade_quality_c2s, {msgid=1500,petid,needs,protect}).
-record(guild_info_s2c, {msgid=380,guildname,level,silver,gold,notice,roleinfos,facinfos,chatgroup,voicegroup}).
-record(activity_value_init_s2c, {msgid=1401,avlist,value,status}).
-record(trade_role_accept_c2s, {msgid=561,roleid}).
-record(activity_tab_isshow_s2c, {msgid=1690,ts}).
-record(tangle_topman_pos_s2c, {msgid=835,roleposes}).
-record(country_block_talk_c2s, {msgid=1648,name}).
-record(pet_riseup_c2s, {msgid=924,petid,needs,protect}).
-record(guild_clear_nickname_c2s, {msgid=1447,roleid}).
-record(mainline_reward_c2s, {msgid=1570,chapter,stage,reward}).
-record(group_decline_c2s, {msgid=155,roleid}).
-record(user_auth_c2s,{msgid=410,username,serverId,adult,pf,time,sign,flag}).
-record(guild_member_pos_s2c, {msgid=1249,posinfo}).
-record(finish_register_s2c, {msgid=352,gourl}).
-record(dragon_fight_left_time_s2c, {msgid=1259,left_seconds}).
-record(answer_start_notice_s2c, {msgid=1125,num,id,double,auto}).
-record(guild_monster_opt_result_s2c, {msgid=354,result}).
-record(rank_chess_spirits_single_s2c, {msgid=1443,param}).
-record(entry_guild_battle_s2c, {msgid=1655,result,lefttime}).
-record(goals_init_c2s, {msgid=644}).
-record(festival_recharge_exchange_c2s, {msgid=1694,id}).
-record(buy_item_c2s, {msgid=313,npcid,item_clsid,count}).
-record(mp_package_s2c, {msgid=809,itemidl,itemidh,buffid}).
-record(festival_recharge_update_s2c, {msgid=1695,id,state,today_charge_num}).
-record(group_decline_s2c, {msgid=161,roleid,username}).
-record(update_guild_apply_state_s2c, {msgid=1210,guildlid,guildhid,applyflag}).
-record(inspect_c2s, {msgid=403,serverid,rolename}).
-record(md, {mailid,content,add_silver,add_gold,add_item}).
-record(chess_spirit_get_reward_c2s, {msgid=1181,type}).
-record(duel_decline_c2s, {msgid=711,roleid}).
-record(duel_decline_s2c, {msgid=721,roleid}).
-record(refresh_everquest_c2s, {msgid=852,everqid,freshtype,maxquality,maxtimes}).
-record(mail_sucess_s2c, {msgid=541}).
-record(pet_up_growth_s2c, {msgid=914,result,next}).
-record(pet_opt_error_s2c, {msgid=916,reason}).
-record(levelup_opt_c2s, {msgid=1221,level}).
-record(country_leader_update_s2c, {msgid=1647,leader}).
-record(quest_get_adapt_c2s, {msgid=96}).
-record(loop_tower_enter_higher_s2c, {msgid=659,higher}).
-record(mail_query_detail_s2c, {msgid=534,mail_detail}).
-record(vip_npc_enum_s2c, {msgid=676,vip,bonus}).
-record(init_open_service_activities_s2c, {msgid=1680,activeid,partinfo,starttime,endtime,lefttime,info,state}).
-record(banquet_error_s2c, {msgid=1610,reason}).
-record(dragon_fight_num_c2s, {msgid=1261,npcid}).
-record(congratulations_levelup_remind_s2c, {msgid=1140,roleid,rolename,level}).
-record(venation_time_countdown_s2c, {msgid=1287,roleid,time}).
-record(guild_destroy_s2c, {msgid=387,reason}).
-record(achieve_reward_c2s, {msgid=631,chapter,part}).
-record(christmas_tree_hp_s2c, {msgid=1742,curhp,maxhp}).
-record(pet_random_talent_c2s, {msgid=1485,petid,type}).
-record(pet_upgrade_quality_up_c2s, {msgid=1501,type,petid,needs}).
-record(update_item_s2c, {msgid=120,items}).
-record(dfr, {fn,level,job,guildname,gender}).
-record(init_signature_s2c, {msgid=471,signature}).
-record(chess_spirit_quit_c2s, {msgid=1182}).
-record(chess_spirit_update_power_s2c, {msgid=1172,newpower}).
-record(offline_exp_exchange_gold_c2s, {msgid=1135,type,hours}).
-record(reset_random_rolename_c2s, {msgid=1121}).
-record(guild_application_op_c2s, {msgid=396,roleid,reject}).
-record(mail_delete_s2c, {msgid=539,mailid}).
-record(user_auth_fail_s2c, {msgid=411,reasonid}).
-record(chat_failed_s2c, {msgid=142,reasonid,cdtime}).
-record(rank_level_s2c, {msgid=1437,param}).
-record(cancel_trade_c2s, {msgid=565}).
-record(clear_crime_c2s, {msgid=733,type}).
-record(lottery_otherslot_s2c, {msgid=506,items}).
-record(add_friend_c2s, {msgid=482,target_name}).
-record(add_friend_s2c, {msgid=1500091,source_name}).
-record(add_friend_respond_c2s, {msgid=1500092,target_name,result}).
-record(add_friend_respond_s2c, {msgid=1500093,source_name,result}).
-record(delete_friend_beidong_s2c, {msgid=1500094,fname}).
-record(designation_update_s2c, {msgid=1541,designationid}).
-record(enum_skill_item_c2s, {msgid=412,npcid}).
-record(mainline_init_c2s, {msgid=1560}).
-record(venation_active_point_start_c2s, {msgid=1283,venation,point,itemnum}).
-record(guild_member_depart_c2s, {msgid=366}).
-record(server_treasure_transport_start_s2c, {msgid=1554,left_time}).
-record(pet_explore_start_c2s, {msgid=972,petid,explorestyle,siteid,lucky}).
-record(congratulations_received_c2s, {msgid=1145,level,rolename}).
-record(leave_guild_battle_c2s, {msgid=1656}).
-record(becare_friend_s2c, {msgid=485,fn,fid}).
-record(pet_explore_info_c2s, {msgid=970,petid}).
-record(equipment_upgrade_c2s, {msgid=615,equipment,upgrade}).
-record(other_role_map_init_s2c, {msgid=16,others}).
-record(role_map_change_s2c, {msgid=14,x,y,lineid,mapid}).
-record(start_guild_transport_failed_s2c, {msgid=1552,reason}).
-record(goals_reward_c2s, {msgid=642,days,part}).
-record(entry_loop_instance_apply_c2s, {msgid=1800,type}).
-record(chess_spirit_game_over_s2c, {msgid=1183,type,section,used_time_s,reason}).
-record(lti, {protoid,item_count}).
-record(tangle_kill_info_request_s2c, {msgid=1752,year,month,day,battletype,battleid,killinfo,bekillinfo}).
-record(set_black_c2s, {msgid=475,fn}).
-record(pet_random_talent_s2c, {msgid=1487,power,hitrate,criticalrate,stamina}).
-record(learned_skill_s2c, {msgid=71,creatureid,skills}).
-record(pet_explore_gain_info_s2c, {msgid=976,petid,gainitem}).
-record(player_level_up_s2c, {msgid=111,roleid,attrs}).
-record(loudspeaker_opt_s2c, {msgid=145,reasonid}).
-record(a, {id,name,ownerid,ownername,ownerlevel,itemnum}).
-record(smi, {mitemid,sort,uptime,mycount,price,discount}).
-record(pet_explore_speedup_c2s, {msgid=973,petid}).
-record(group_list_update_s2c, {msgid=163,leaderid,members}).
-record(get_timelimit_gift_c2s, {msgid=1021}).
-record(guild_member_delete_s2c, {msgid=385,roleid,reason}).
-record(rename_result_s2c, {msgid=57,errno}).
-record(treasure_transport_call_guild_help_s2c, {msgid=1559}).
-record(learned_pet_skill_s2c, {msgid=929,pskills}).
-record(detail_friend_c2s, {msgid=491,fn}).

-record(role_shift_pos_c2s, {msgid=2303,posx,posy}).
-record(role_pull_objects_c2s, {msgid=2304,skill_id,objects}).
-record(role_push_objects_c2s, {msgid=2305,skill_id,objects}).
-record(role_shift_pos_s2c, {msgid=1842,role_id,sposx,sposy,posx,posy}).
-record(role_pull_objects_s2c, {msgid=1840,role_id,skill_id,pull_info}).
-record(role_push_objects_s2c, {msgid=1841,role_id,skill_id,push_info}).
-record(po, {target_id,posx,posy}).

%%收藏送礼%%
-record(collect_page_s2c,{msgid=1891}).
-record(collect_page_c2s,{msgid=1890}).

%%zengyan.yan增加的%%
-record(tgw_gateway_s2c,{msgid=2}).

%% 经验台刷品
-record(refresh_instance_quality_s2c, {msgid=1951, instanceid, freetime, totalfreetime, npclist}).
-record(refresh_instance_quality_result_s2c, {msgid=1953, freetimes, itemtimes, gold}).
-record(refresh_instance_quality_opt_s2c, {msgid=1954, errno}).
-record(refresh_instance_quality_c2s, {msgid=1950, maxqua, instanceid, usegold, auto}).
-record(init_instance_quality_c2s, {msgid=1952, instanceid}).

%%副本元宝委托%
-record(instance_entrust_c2s,{msgid=1900,instance_id,times,type}).


%% 试炼任务刷品新加接口
-record(refresh_everquest_result_s2c,{msgid=859,freetime,itemcount,sliver}).

%% QQ 币购买元宝箱
-record(qz_get_balance_c2s, {msgid=1875}).
-record(qz_get_balance_error_s2c, {msgid=1877, error}).
%%元宝福利大放送%%
-record(activity_test01_display_s2c,{msgid=3000,index}).
-record(activity_test01_hidden_s2c,{msgid=3001,index}).
-record(activity_test01_recv_c2s,{msgid=3002,index}).

-record(trade_item_c2s, {msgid=1845,npc_id,item_id,count}).
-record(skill_cooldown_reset_s2c, {msgid=1843}).
-record(yellow_vip_init_s2c, {msgid=1844, is_yellow_year_vip, vip_level, canreward, canrewardy, level_reward, gift_reward, ridepet_reward}).

%pet quality riseup record
-record(pet_quality_riseup_c2s,{msgid=2070,petid, flag, up_type}).
-record(pet_quality_riseup_s2c,{msgid=2071,is_success, petid, lucky}). % yz add petid lucky
%%宠物进阶
-record(pet_grade_riseup_c2s, {msgid=3000, petid, extitems, consum_type, up_type}).
-record(pet_grade_riseup_s2c, {msgid=3001, petid, is_success, luckly}).

-record(pet_savvy_up_c2s, {msgid = 2078, pet_id}).
-record(pet_savvy_up_s2c, {msgid = 2079,is_sucess, savvy, max_savvy}).

%% 宠物资质相关协议
-record(pet_qualification_upgrade_c2s, {msgid=2048, petid, index}).
-record(pet_qualification_upgrade_s2c, {msgid=2049, qualifications, max_qualifications, is_success}).
% 玩家6重礼包
-record(charge_package_init_c2s, {msgid=1880}).
-record(charge_reward_init_c2s, {msgid=1885}).
%% 玩家6重礼包状态
-record(charge_package_init_s2c, {
	msgid=1881,
	gold, % 充值金币
	info  % 礼包状态
}).
%% 玩家6重礼包状态
-record(charge_reward_init_s2c, {
	msgid=1886,
	chargenum, % 充值金币
	state  % 礼包状态
}).
%% 礼包领取信息
-record(get_charge_package_c2s, {
	msgid=1882,
	id % 领取6重礼包的id
}).
%% 礼包领取信息
-record(get_charge_reward_c2s, {
	msgid=1887,
	id % 领取6重礼包的id
}).

%% 礼包领取结果
-record(get_charge_package_s2c, {
	msgid=1883,
	res % 领取礼包结果
}).
%% 礼包领取结果
-record(get_charge_reward_s2c, {
	msgid=1888,
	res, % 领取礼包结果
	chargenum, % 充值金币
	state  % 礼包状态
}).

% 充值元宝数变化
-record(charge_package_gold_change,{
	msgid=1884,
	gold
}).

%% 专题活动
-record(query_travel_server_status_c2s, {msgid = 2007}).
-record(query_travel_server_status_s2c, {msgid = 2005, status}).
-record(delete_temp_activity_s2c, {msgid = 2002, bid, sid}).
-record(add_temp_activity_s2c, {msgid = 2006, acinfo}).
-record(temp_activity_reward_c2s, {msgid = 2003, bid, sid}).
-record(temp_activity_reward_s2c, {msgid = 2004, result}).
%%阵营战
-record(camp_battle_entry_c2s,{msgid=1852}).
-record(camp_battle_init_s2c, {msgid=1856,campascore, campbscore, campanum, campbnum, roles, deserters, lefttime_s}).
-record(camp_battle_otherrole_leave_s2c, {msgid=1859,roleid}).
-record(camp_battle_player_num_c2s, {msgid=1864}).
-record(camp_battle_player_num_s2c, {msgid=1865,playnum}).
-record(camp_battle_otherrole_init_s2c, {msgid=1858,role}).
-record(camp_battle_record_update_s2c, {msgid=1862,kill, bekill}).
-record(camp_battle_otherrole_update_s2c, {msgid=1857,roleid, newscore, camp, campscore}).
-record(camp_battle_start_s2c, {msgid=1850}).
-record(camp_battle_leave_c2s, {msgid=1854}).
-record(camp_battle_leave_s2c, {msgid=1855,result}).
-record(camp_battle_stop_s2c, {msgid=1851}).
-record(camp_battle_entry_s2c, {msgid=1853,result}).
-record(camp_battle_info_update_s2c, {msgid=1860,campascore, campbscore}).
-record(camp_battle_record_init_s2c, {msgid=1861,kill, bekilled}).
-record(camp_battle_result_s2c, {msgid=1863,winner, exp, honor, items}).
-record(camp_battle_last_record_c2s, {msgid=1866}).
-record(camp_battle_last_record_s2c, {msgid=1867,roles, deserters, kill, bekilled, campascore, campbscore, campanum, campbnum}).
-record(camp_battle_opt_s2c, {msgid=1868,errno}).
-record(battle_totleadd_honor_s2c, {msgid=817,num}).
-record(pet_shop_info, {
		pet_template_id,
		pet_price
	}).

-record(pet_shop_goods_c2s, {
		msgid = 30002
	}).

-record(pet_shop_goods_s2c, {
		msgid = 30003,
		remain_time,
		pet_goods
	}).

-record(buy_pet_c2s, {
		msgid = 30004,
		pet_template_id,
		buy_type
	}).

-record(send_error_s2c, {
		msgid = 33333,
		error_code
	}).

-record(refresh_remain_time_c2s, {
		msgid = 30005,
		gold,
		num
	}).

-record(pet_type_change_c2s, {
		msgid = 30006,
		pet_id,
		change_type,
		flag
	}).

-record(pet_type_change_s2c, {
		msgid = 30007,
		pet_id,
		new_type
	}).

-record(pet_reset_type_attr_c2s, {
		msgid = 30008,
		pet_id,
		type,
		attr_list
	}).

-record(pet_inherit_c2s, {
		msgid = 30009,
		main_pet_id,
		assistant_pet_id
	}).

-record(pet_inherit_preview_c2s, {
		msgid = 4022,
		main_pet_id,
		assistant_pet_id
	}).

-record(pet_inherit_preview_s2c, {
		msgid = 4023,
		new_pet_info
	}).

-record(pet_inherit_s2c, {
		msgid = 30011,
		main_pet_id
	}).

-record(get_prize_holiday_c2s, {
		msgid = 30012
	}).

-record(pet_reset_type_attr_s2c, {
	msgid = 30013,
	type,
	attrlist
}).

-record(guild_dice_c2s, {msgid=1824}).
-record(guild_dice_s2c, {msgid=1825, roleid, rand}). % rand 随机数1-100

-record(add_buff_in_battle_s2c, {
		msgid = 3020,
		value
}).

-record(get_gold_by_level_c2s, {msgid=30014, level}).
-record(goldlevel_show_s2c, {msgid=30015, roleid, hist}).

-record(role_quest_status_c2s, {msgid=30016, quests}).
-record(role_quest_status_s2c, {msgid=30017, quests}).

-record(login_continuously_show_s2c, {msgid=30018, counter, normal, pay, usertype}).
-record(login_continuously_reward_c2s, {msgid=30019, day, type}).
-record(login_continuously_reward_s2c, {msgid=30020, result}).

%%市场
-record(market_sell_item_c2s,{msgid=30031,sale_type,slot,num,buy_type,price,hour}).
-record(market_buy_item_c2s,{msgid=30032,sale_id}).
-record(market_search_item_c2s,{msgid=30033,sale_type,search_type,key_word,quality,class,lv_low,lv_high,page}).
-record(market_search_item_s2c,{msgid=30034,page,page_num,items}).
-record(sale_item,{sale_id,seller_name,item_name,quality,level,class,allowableclass,buy_type,price}).
-record(market_self_items_c2s,{msgid=30035,page}).
-record(market_self_items_s2c,{msgid=30036,page,page_num,items}).
-record(market_feedback_signal_s2c,{msgid=30037, msg}).

% 副本奖励
-record(duplicate_prize_notify_s2c, {msgid=30021, duplicate_id}).
-record(duplicate_prize_item_c2s, {msgid=30022}).
-record(duplicate_prize_item_s2c, {msgid=30023, prize_index}).
-record(duplicate_prize_get_c2s, {msgid=30024,tag}).

-record(get_level_award_c2s, {msgid=30051, id}).
-record(level_award_show_s2c,{msgid=30052, hist}).
-record(award_hist,{id,items,available}).
-record(item_hist,{template_id,num}).

%% bang da yuanyang protocal
-record(bdyy_start_c2s, {msgid = 2100}).
-record(bdyy_start_s2c, {msgid=2105, first_use}).
-record(bdyy_item_show_s2c, {msgid = 2101, item_id, show_time}).
-record(bdyy_item_hit_c2s, {msgid = 2102, item_id}).
-record(bdyy_item_hit_s2c, {msgid = 2103, result}).
-record(bdyy_item_end_s2c, {msgid = 2104, awards}).
-record(bdyy_end_c2s, {msgid = 2106}).

%% 夜宴跳舞
-record(companion_dancing_apply_c2s, {msgid=20000,roleid}).
-record(companion_dancing_apply_s2c, {msgid=20001,roleid}). 
-record(companion_dancing_start_c2s, {msgid=20002,roleid}). 
-record(companion_dancing_reject_c2s, {msgid=20003,roleid}).
-record(companion_dancing_reject_s2c, {msgid=20004,rolename}).
-record(companion_dancing_result_s2c, {msgid=20005,result}).
-record(companion_dancing_stop_s2c, {msgid=20006}).
-record(banquet_dancing_start_s2c, {msgid=20007,name,bename,remain}).
-record(banquet_pet_swanking_s2c, {msgid=19999,remain}).
-record(banquet_pets_s2c, {msgid=19998,name,pets}).

%% travel battle
-record(travel_battle_query_role_info_c2s, {msgid=20008}).
-record(travel_battle_query_role_info_s2c, {msgid=20009,score,total,total_win,serial_win,gold,ticket,silver,
	total_scores,rank}).
-record(travel_battle_register_c2s, {msgid=20010,stage}).
-record(travel_battle_register_s2c, {msgid=20011,state,person_num,points}).
-record(travel_battle_section_result_s2c, {msgid=20013,section,result,scores,total,total_win,serial_win,gold,
	ticket,silver,total_scores,points,serial_win_result,serial_win_awards,money_cost,points_cost,
	next_section_money_cost,next_section_points_cost,check_result}).
-record(travel_battle_stage_result_s2c, {msgid=20014,rank,scores,gold,ticket,silver,total_scores}).
-record(travel_battle_open_shop_c2s, {msgid=20015}).
-record(travel_battle_open_shop_s2c, {msgid=20016,item_list}).
-record(travel_battle_shop_buy_c2s, {msgid=20017,item_id,count}).
-record(travel_battle_shop_buy_s2c, {msgid=20018,total_scores}).
-record(travel_battle_show_rank_page_c2s, {msgid=20019,page}).
-record(travel_battle_show_rank_page_s2c, {msgid=20020,rank_list}).
-record(travel_battle_lottery_c2s, {msgid=20021}).
-record(travel_battle_lottery_s2c, {msgid=20022,item_list}).
-record(travel_battle_register_wait_s2c, {msgid=20024,state,person_num}).
-record(travel_battle_cancel_match_c2s, {msgid=20025}).
-record(travel_battle_cancel_match_s2c, {msgid=20026}).
-record(travel_battle_notice_s2c, {msgid=20027,type,param}).
-record(travel_battle_forecast_begin_notice_s2c, {msgid=20029}).
-record(travel_battle_forecast_end_notice_s2c, {msgid=20030}).
-record(travel_battle_open_notice_s2c, {msgid=20031}).
-record(travel_battle_close_notice_s2c, {msgid=20032}).
-record(travel_battle_prepare_s2c, {msgid=20033,seconds}).
-record(travel_battle_role_skills_s2c, {msgid=20034,skills}).
-record(travel_battle_change_skill_c2s, {msgid=20035,skill_id}).
-record(travel_battle_change_skill_success_s2c, {msgid=20036,skill_id}).
-record(travel_battle_change_skill_failed_s2c, {msgid=20037,reason}).
-record(travel_battle_upgrade_skill_c2s, {msgid=20038,skill_id}).
-record(travel_battle_upgrade_skill_success_s2c, {msgid=20039}).
-record(travel_battle_upgrade_skill_failed_s2c, {msgid=20040,reason}).
-record(travel_battle_cast_skill_c2s, {msgid=20041, skill_id,target_id}).
-record(travel_battle_leave_c2s, {msgid=20046}).

%% wedding
-record(wedding_apply_c2s, {msgid=2130,role_name}).
-record(wedding_apply_s2c, {msgid=2131,role_name}).
-record(wedding_apply_agree_c2s, {msgid=2132,role_name}).
-record(wedding_apply_refused_c2s, {msgid=2133,role_name}).
-record(wedding_apply_result_s2c, {msgid=2134,role_name,result}).
-record(wedding_ceremony_time_available_c2s, {msgid=2135}).
-record(wedding_ceremony_time_available_s2c, {msgid=2136,time_list}).
-record(wedding_ceremony_select_c2s, {msgid=2137,type,time}).
-record(wedding_ceremony_select_s2c, {msgid=2138,result}).
-record(wedding_ceremony_notify_s2c, {msgid=2139,spouse_1,spouse_2}).
-record(wedding_ceremony_start_s2c, {msgid=2140,spouse_1,spouse_2}).
-record(wedding_ceremony_end_s2c, {msgid=2141,spouse_1,spouse_2}).

-record(friend_send_flowers_c2s, {msgid=2142,target_name,num}).
-record(friend_send_flowers_s2c, {msgid=2143,result}).
-record(friend_add_intimacy_s2c, {msgid=2144,target_name,intimacy}).
-record(friend_send_flowers_notify_s2c, {msgid=2145,role_name,num}).
%% pet
-record(gold_get_exp_s2c, {msgid=21008,room_id,petid,gold,exp}).
-record(pet_opend_room_s2c, {msgid=21007,opend_rooms}).
-record(pet_room_balance_s2c, {msgid=21016,room_id,petid}).
-record(pet_room_balance_c2s, {msgid=21006,room_id,petid,gold}).
-record(pet_into_room_c2s, {msgid=21005,room_id,petid,duration}).
-record(pet_into_room_s2c, {msgid=21015,room_id,petid,star_time}).
-record(pet_open_room_s2c, {msgid=21014,room}).
-record(pet_room_c2s, {msgid=21003}).
-record(pet_room_s2c, {msgid=21002,petrooms}).
-record(pr, {pet_id,room_id,start_time,duration}).
-record(pet_shop_luck_s2c, {msgid=22002,value}).
-record(pet_cur_heart_s2c, {msgid=21001,petid,heart}).
-record(pet_shop_c2s, {msgid=21000}).
-record(pet_shop_rfresh_s2c, {msgid=22000,goods}).
-record(pet_shop_account_s2c, {msgid=22001,value}).
-record(pet_open_room_c2s, {msgid=21004,room_id}).
-record(pet_skill_fuse_c2s, {msgid=23000,types}).
-record(pet_skill_fuse_s2c, {msgid=23001,skillid}).
-record(pet_skill_buy_slot_s2c, {msgid=23003,petid,slot}).
-record(pet_skill_buy_slot_c2s, {msgid=23002,petid,slot}).
-record(pet_shop_times_s2c, {msgid=22003,times}).

-record(pet_egg_use_c2s, {msgid=24000,slot,sex}).
-record(pet_sex_change_c2s, {msgid=24001,petid,sex}).
-record(pet_sex_change_s2c, {msgid=24002,petid,sex}).

-record(pet_exp_use_c2s, {msgid=24003,petid,slot}).
-record(pet_swank_c2s, {msgid=24004}).
-record(icon_show_list_c2s, {msgid=25000,show_list}).
-record(holiday_activity_s2c, {msgid=24005,holidayid}).
-record(pet_skill_fuse_del_c2s, {msgid=23004}).

%% hot_bar

-record(top_bar_show_items_s2c, {msgid=24006,item_ids}).
-record(top_bar_hide_items_s2c, {msgid=24007,item_ids}).
-record(temp_activity_contents_c2s, {msgid=24008,item_id}).
-record(temp_activity_contents_s2c, {msgid=24009,item_id,contents}).
-record(temp_activity_get_award_c2s, {msgid=24010,activity_id}).
-record(temp_activity_get_award_s2c, {msgid=24011,result}).


%% open charge feedback
-record(query_open_charge_feedback_info_c2s, {msgid=20070}).
-record(query_open_charge_feedback_info_s2c, {msgid=20071,start_time,end_time,left_seconds}).
-record(query_open_charge_feedback_info_failed_s2c, {msgid=20072,reason}).
-record(open_charge_feedback_lottery_c2s, {msgid=20073}).
-record(open_charge_feedback_lottery_failed_s2c, {msgid=20074,reason}).
-record(open_charge_feedback_lottery_s2c, {msgid=20075,result}).
-record(open_charge_feedback_get_award_c2s, {msgid=20082}).
-record(open_charge_feedback_get_award_s2c, {msgid=20083,result}).

%% open service auction
-record(query_open_service_aution_info_c2s, {msgid=20076}).
-record(query_open_service_auction_info_s2c, {msgid=20077,start_time, end_time,left_seconds,base,increment,last_bid,info}).
-record(query_open_service_auction_info_failed_s2c, {msgid=20078,reason}).
-record(open_service_aution_bid_c2s, {msgid=20079,bid}).
-record(open_service_auction_bid_s2c, {msgid=20080,result}).
-record(open_service_auction_info_update_s2c, {msgid=20081,info}).

-record(query_open_service_time_c2s, {msgid=20084}).
-record(query_open_service_time_s2c, {msgid=20085,time}).

-record(tangle_battle_end_s2c, {msgid=4021}).

%% travel match
-record(travel_match_register_start_s2c, {msgid=2200,type}).
-record(travel_match_register_forecast_end_s2c, {msgid=2201,type}).
-record(travel_match_register_end_s2c, {msgid=2202,type}).
-record(travel_match_query_role_info_c2s, {msgid=2203,type}).
-record(travel_match_query_role_info_s2c, {msgid=2204,stage,status,
	rank,details,awards_gold,register_status}).
-record(travel_match_register_c2s, {msgid=2205,type}).
-record(travel_match_register_s2c, {msgid=2206}).
-record(travel_match_enter_wait_map_start_s2c, {msgid=2207,type,stage}).
-record(travel_match_enter_wait_map_forecast_end_s2c, {msgid=2208,type,stage}).
-record(travel_match_enter_wait_map_c2s, {msgid=2209,type}).
-record(travel_match_battle_start_s2c, {msgid=2210,type,stage}).
-record(travel_match_section_result_s2c, {msgid=2211,result,points}).
-record(travel_match_battle_awards_s2c, {msgid=2212,type,awards}).
-record(travel_match_query_unit_player_list_c2s, {msgid=2213,type}).
-record(travel_match_leave_wait_map_c2s, {msgid=2214}).
-record(travel_match_stage_result_s2c, {msgid=2215,result,points}).
-record(travel_match_query_unit_player_list_s2c,{msgid=2216,players}).
-record(travel_match_query_session_data_c2s, {msgid=2217,type,session,min_level,max_level}).
-record(travel_match_query_session_data_s2c, {msgid=2218,rank_data}).

%% dead_valley
-record (dead_valley_start_forecast_s2c, {msgid=2400}).
-record (dead_valley_start_nofity_s2c, {msgid=2401}).
-record (dead_valley_end_forecast_s2c, {msgid=2402}).
-record (dead_valley_end_notify_s2c, {msgid=2403}).
-record (dead_valley_enter_c2s, {msgid=2404,zone_id}).
-record (dead_valley_leave_c2s, {msgid=2405}).
-record (dead_valley_points_update_s2c, {msgid=2406,points}).
-record (dead_valley_boss_hp_update_s2c, {msgid=2407,npcid,hpmax,hp}).
-record (dead_valley_trap_touch_c2s, {msgid=2408,trap_id}).
-record (dead_valley_trap_leave_c2s, {msgid=2409,trap_id}).
-record (dead_valley_force_leave_s2c, {msgid=2410}).
-record (dead_valley_exp_update_s2c, {msgid=2411,exp}).
-record (dead_valley_query_zone_info_c2s, {msgid=2412}).
-record (dead_valley_query_zone_info_s2c, {msgid=2413,info}).
