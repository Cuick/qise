%% Author: adrian
%% Created: 2010-7-7
%% Description: TODO: Add description to mnesia_table_def

-record(npc_drop,{npcid,rate,ruleids}).		%%set, rate = percent
-record(drop_rule,{ruleid,name,roleflag,itemsdroprate}).

-record(quest_role,{roleid,quest_list}).
-record(quest_npc,{npcid,quest_action}).

-record(quests,{id,isactivity,
				level,limittime,required,prevquestid,nextquestid,
				rewrules,rewitem,choiceitemid,rewxp,reworreqmoney,
				reqmob,reqmobitem,objectivemsg,objectivetext,acc_script,on_acc_script,com_script,on_com_script,direct_com_disable}).

-record(roleattr,{roleid,account,name,sex,class,level,exp,hp,
				  mana,currencygold,currencygift,silver,boundsilver,mapid,coord,
				  bufflist,training,packagesize,groupid,guildid,pvpinfo,pet,offline,soulpower,stallname,honor,fightforce,spouse,pet_skill}).		%%set

-record(classbase,{classid,level,strength,agile,intelligence,stamina,power,magicdefense,rangedefense,meleedefense,hprecover,hprecoverinterval,mprecover,mprecoverinterval,commoncool}). %% bag

-record(rolepro,{roleid,rolename,playerid,image,vocation,bluename}).
-record(transports, {mapid,tranportid,coord,transid,description}).
-record(skills,{id,level,name,
	       type,rate,target_type,max_distance,
	       isaoe,aoeradius,interrupt,aoe_max_target,
	       target_destroy,aoe_target_destroy,self_destroy,
	       cooldown,cast_type,cast_time,addtion_threat,
	       target_buff,caster_buff,remove_buff,cost,flyspeed,learn_level,class,script,money,required_skills,hit_addition,soulpower,creature,items,addtion_power}).%%bag
	       
	       
-record(skillinfo,{skillid,skilllevel,casttime}).	
-record(role_skill,{roleid,skillinfo}). %% set

-record(quickbarinfo,{bar_pos,classid,objectid}).
-record(role_quick_bar,{roleid,quickbarinfo}). %% set

%% for items
-record(item_template,{
		entry,					% 模版id
		name,					% 中文名
		class,					% 类id
		displayed,				% 资源id
		equipmentset,
		level,					%
		qualty,
		requiredlevel,			% 穿戴等级
		stackable,maxdurability,inventorytype,sockettype,allowableclass,useable,sellprice,damage,defense,states,
		spellid,				% 对应技能id,加buffer药品不是直接加buffer，而是通过技能加buffer
		spellcategory,spellcooldown,bonding,maxsoket,scriptname,questid,baserepaired,overdue_type,overdue_args,overdue_transform,enchant_ext, 
		use_condition			% 额外使用条件
	}).
-record(equipmentset,{id,num,states,includeids}).
-record(playeritems,{id,ownerguid,entry,enchantments,count,slot,isbond,sockets,duration,cooldowninfo,enchant,overdueinfo}). %% set index[ownerguid]

-record(creature_proto,{
					id,  				%%模板id
					name,	
					level,
					npcflags,			%%npc类型
					hpmax,
					mpmax,
					attacktype,	
					power,		
					commoncool,			%%公共冷却
					immunes,			%%免疫{近，远，魔}
					hitrate,			%%命中
					dodge,			    %%闪避
					criticalrate,		%%暴击
					criticaldestroyrate,%%暴击伤害
					toughness,			%%韧性
					debuff_resist,		%%debuff免疫{imprisonment_resist,silence_resist,daze_resist,poison_resist,normal_resist}
					walkspeed,			%%行走速度
					runspeed,			%%跑动速度
					exp,				%%携带经验
					min_money,		    %%掉落最小金币
					max_money,		    %%掉落最大金币
					skills,				%%技能[]
					skillrates,			%%技能释放几率,0为条件触发[]
					defense,			%%防御力{近，远，魔}
					hatredratio,		%%仇恨比率
					alert_radius,		%%警戒区域半径
					bounding_radius,	%%领土范围半径
					script_hatred,		%%仇恨函数
					script_skill,		%%技能释放脚本
					displayid,
					walkdelaytime,		%%行走停留					
					faction,			%%种族
					death_share,		%%是否是任务共享怪
					script_baseattr,	%%基础属性计算脚本
					team_share          %%队伍分享
					}).

-record(creature_spawns,{
					id,
					protoid,
					mapid,
					bornposition,
					movetype,
					waypoint,					
					respawntime,
					actionlist,
					hatreds_list,
					born_with_map
					}).

					
-record(buffers,{id,level,name,description,class,resist_type,duration,effect_interval,addition_threat,effectlist,effect_argument,deadcancel,can_active_cancel}).

-record(role_pos,{roleid, lineid, mapid , rolename, rolenode,roleproc,gatenode,gateproc}). %% set ram
-record(chat_condition,{id, items,level}).

-record(groups,{groupid,isrecruite,leaderid,instance,members,description}). %% set [isrecruite]

-record(idmax,{idtype,maxvalue}). %% set

%%
%% npc functions
%%
-record(npc_functions,{npcid,function}).%% set


%%物品价格 currencytype: 1-> 银  2->金  3->礼金
-record(itemprice,{currencytype,price}).

%%售卖列表,{物品id,一捆的个数,价格：为物品价格的列表}
-record(sellitem,{itemid,prices}).
%%ipc售卖列表
-record(npc_sell_list,{npcid,sellitems}). 
-record(npc_exchange_list,{npcid,exchangeitems}).

-record(npc_quest_accept,{npcid,questid}).	%%bag

-record(npc_quest_submit,{npcid,questid}).	%%bag

-record(transport_channel,{id,mapid,coord,type,level,items,money,viplevel}). %%set

-record(npc_trans_list,{npcid,id}). %%set

-record(fatigue,{userid,fatigue,offline,relex}).

-record(levelitem, {level, prices}).

-record(skillitem,{skillid,levelitems}). 

%%npc技能学习
-record(everquest_list,{npcid,everlist}). %set


%%gm封禁表
-record(gm_blockade,{roleid_type,start_time,duration_time}).

%%gm 通知管理
-record(gm_notice,{id,ntype,left_count,begin_time,end_time,interval_time,notice_content,last_notice_time}).
-record(gm_role_privilege,{roleid,privilege}).

-record(player_option,{roleid,options}).

%%商城
-record(mall_item_info,{id,ntype,special_type,ishot,name,sort,price,discount,tips,displayid,restrict,bodcast}).
-record(mall_sales_item_info,{id,ntype,name,sort,price,discount,duration,sales_time,restrict,bodcast}).
-record(mall_up_sales_table,{id,ntype,name,sort,price,discount,duration,uptime,restrict,bodcast}).
-record(role_buy_mall_item,{roleid,buylog}).%%buylog{id,time,count}
-record(role_buy_log,{roleid,buylog}).%%buylog[{latest,tuple},{something,tuple},{something,tuple}......] 
-record(role_mall_integral,{roleid,charge_integral,consumption_integral}).
%%账号，充值
-record(account,{username,roleids,gold,flag}).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%				副本
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%副本模板表
-record(instance_proto,{protoid,type,create_leadertag,create_item,level,membernum,dateline,
						quests,item_need,can_direct_exit,datetimes,restrict_items,level_mapid,duration_time,nextproto}).	%%set
%%玩家副本表
-record(role_instance,{roleid,starttime,instanceid,lastpostion,log}).	%%set
%%副本位置表
-record(instance_pos,{instance_id,creation,starttime,can_join,node,pid,mapid,protoid,members}).%% set ram

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				挂机
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(block_training,{level,growth,duration,spgrowth}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				地图信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(map_info, {mapid,map_name,is_instance,map_tag,restrict_items,script,can_flyshoes,linetag,serverdataname,pvptag
		, clear_buffer_list				% 离开该地图清除buffer列表
                , can_sitdown
                , can_ride
	}).

%%成就
-record(achieve,{achieveid,chapter,part,target,bonus,bonus2,type,script}).
-record(achieve_role,{roleid,achieves}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				个人pk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%战场日志表:日期,类型:1:30-49 2:50-69 3:70-89 4:90
-record(battlefield_proto,{protoid,args,start_line,duration,instance_proto,respawn_buff}).
-record(tangle_battle,{date_class,info,has_record}).
-record(tangle_reward_info,{rankedge,honor,exp,item}).
-record(role_tangle_battle,{roleid,selfinfo}).
-record(tangle_battle_role_killnum,{roleid,killnum}).
-record(yhzq_winner_raward,{type,score,honor,exp,item}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				轮回塔
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(loop_tower,{layer,consum_money,enter_prop,convey_prop,exp,bonus,instance_id,week_bonus,monsters,loop_prop}).
-record(role_loop_tower,{roleid,layertime,highest,log}).
-record(loop_tower_instance,{layer,roleid,rolename,time}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%					日常
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(everquests,{id,type,special_tag,required,datelines,guild_required,qualityrates,refresh_info,rounds_num,clear_time,quests,sections,section_counts,section_rewards,reward_exp_type,quality_extra_rewards,free_recover_interval,last_evquest}).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%				VIP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%　
-record(vip_level,{
	level,		% 级别
	gold,		% 消耗元宝
	addition,	% 该级别给玩家的物品
	bonus   	% 奖励
}).
%% 角色vip数据
-record(vip_role,{
	roleid, 		% 玩家角色id
	start_time,		% vip开始时间
	duration,		% 过期时间
	level,			% vip等级
	bonustime,		% 奖励时间
	logintime,		% 最后登录时间
	flyshoes        % 小飞鞋数据｛类型，次数｝::{1, X}|{0, 0} -> {1, X} 限制次数，X为次数。｛0， 0｝ 不限制次数使用
}).
-record(role_login_bonus,{roleid,bonustime}).
-record(role_sum_gold,{roleid,sum_gold,duration_sum_gold}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%			series_kill
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-record(series_kill,{level,kill_num,effect_time,buff_info,npc_level_diff,instance_power_effect}).

-record(role_petnum,{level,default_num,max_num,skill_slot}).	

-record(pet_up_reset,{protoid,main_growth_rate,consume,needs,protect,locked}).
-record(pet_up_abilities,{protoid_growth,rate,next,failure,consume,needs,protect}).
-record(pet_up_stamina,{protoid_growth,rate,next,failure,consume,needs,protect}).						
-record(pet_up_riseup,{protoid,rate,next,failure,consume,needs,protect}).						
-record(pet_explorer,{mapid,pet_level,normal_consume,special_consume,time,date_line,normal_drops,special_drops}).
-record(pet_present,{level,drop_rules}).

-record(role_level_soulpower,{level,maxpower,spreward}).
							
-record(faction_relations,{id,friendly,opposite}).

-record(ai_agents,{id,entry,type,events,conditions,chance,maxcount,skill,target,cooldown,msgs,script,next_ai}).

-record(auto_name,{id,last_name,first_name}).
-record(auto_name_used,{name,roleid,roleinfo}).
-record(activity,{id,start,duration,spec_info}).
-record(answer_option,{id,level,start,sign_before,nums,interval,vip_addtion,all_addtion,rewards,vip_props,base_exp}).
-record(answer,{id,correct,score,time}).
-record(answer_roleinfo,{roleid,roleinfo}).
-record(equipment_sysbrd,{id,itemlist,brdid}).
-record(congratulations,{level,notice_range,becount,bereward,reward,notice_count}).
-record(role_congratu_log,{roleid,log}).

-record(yhzq_battle,{id,spawnpos,npcproto,lamsterbuff}).
%%-record(yhzq_battle,{id,playersnum,spawnpos,npcproto}).
-record(yhzq_battle_record,{date_class,info,has_record,ext}).			%%永恒之旗战场记录

-record(timelimit_gift,{id,droplist}).

-record(role_timelimit_gift,{roleid,last_gift_index,last_gift_time,last_gift,ext}).

-record(treasure_spawns,{id,type,maps,interval,round_num,spawn_num,map_spawns}).
-record(loudspeaker,{id,loudspeaker_details}).
-record(facebook_bind,{roleid,fb_quest}).	%%fb_quest:[{fb_id,msgid}]

-record(refine_system,{serial_number,output_bond_item,output_unbond_item,need_items,rate,need_money,output_type}). %%need_items:[{[bond_protoid,unbond_protoid],count}];rate:100;needmoney:300;output_type:judge output_item_type

-record(jszd_rank_option,{rank,guild_money,guild_score,rolehonor,exp,bonus}).
-record(jszd_role_score_honor,{numedge,honor}).
-record(jszd_role_score_info,{roleid,score,killnum}).

-record(instance_quality_proto,{protoid,npclist,freetime,itemtype,gold,rate,addfac}).
-record(role_instance_quality, {roleid, info, ext, quality}).


%%连续登录送礼
%%-record(continuous_logging_gift,{day,normal_gift,vip_gift}).
-record(continuous_logging_gift,{day,reward}).
-record(role_continuous_logging_info,{roleid,info}).

%%元宝福利大放送
%%{activity_test01,1,1,[{{12,0},{12,30}},{{20,0},{20,30}}],2,200}.
-record(activity_test01,{id,enabled,limit_times,money_type,money_count}).
-record(activity_test01_role,{roleid,info}).

%%zhangting 收藏有礼
-record(role_favorite_gift_info,{roleid,awarded}).


%%é¦åç¤¼åé¢å
-record(role_first_charge_gift,{roleid,state,ext}).



%%副本元宝委托
%%{instance_entrust,10004,8,70,15000,[{13090011,8},{13110011,6},{13110021,2},{13110051,1},{19030011,1},{19000710,1}],250}.
-record(instance_entrust,{id,gold,level,fighting_force,gifts,unknown_val}).
% silver 铜钱委托
-record(instance_entrust_silver,{id,silver,level,fighting_force, gifts, unknown_val}).

%% 充值与消费
-record(recharge1, {datetime, uid, money, platform, vip_level}).
-record(consume, {id, billno, uid, datetime, bound_gold, platform_gold, vip_level, item, num, price, platform}).

%%阵营战
-record(yybattle_proto,{type,campplayernum,campabornarea,campbbornarea,winnerbaseexp,winerexpfactor,loserbaseexp,loserexpfactor,winnerward,loserward,winnerbasehonor,winnerhonorfactor,loserbasehonor,loserhonorfactor,instanceid}).
-record(yybattle_record,{battleid,playerinfo,deserterinfo,ascore,bscore,anum,bnum,ext}).
-record(yybattle_player_record,{roleid,battletype,battleid,killinfo,bekillinfo,ext}).

-record(broadcast, {type,condition,chatid}).

%% 跨服战
-record(travel_battle_proto,{id,time_line}).
-record(travel_battle_stage,{stage,level,cost,duration,map_id,pos_list,prepare_time,skills,skill_change_cost,interval,zone_list,
	person_num,points,npc_id}).
-record(travel_battle_section_awards,{stage,winner_score,losser_score}).
-record(travel_battle_stage_awards,{stage,rank,scores,money}).
-record(travel_battle_zone_count,{zone_id,max_count}).
-record(travel_battle_lottery,{id,cost,awards}).
-record(travel_battle_serial_win,{id,awards}).
-record(travel_battle_shop,{id,item_list}).
-record(travel_battle_month_awards,{stage,rank,awards}).
-record(travel_battle_buffers, {proto_id, buffers}).

-record(role_travel_battle_scores,{role_id,scores,total,total_win,serial_win,gold,ticket,silver,total_scores,month}).
-record(role_travel_battle_rank,{role_id,name,gender,class,scores}).
-record(role_travel_battle_rank_clear, {id, month}).

%% wedding
-record(wedding_ceremony,{id,time,next}).
-record(wedding_type,{type,cost,items,ring,fashion}).
-record(role_ceremony_info,{id,applicant,spouse,type,date}).

%% intimacy
-record(wedding_intimacy,{type,condition,value}).

-record(pet_hostel, {roleid,role_room}).

%% bang da yuanyang
-record(bdyy_proto, {id,duration,section_num}).
-record(bdyy_item, {id,show_rate,money}).
-record(bdyy_section, {section,show_time,next_show}).
-record(role_bdyy_info, {role_id, flag}).

%% open service charge feedback
-record(open_charge_feedback_proto, {id,duration,awards}).
-record(open_charge_feedback, {id,limit,feedback,items}).
-record(role_open_charge_feedback, {role_id,feedback}).

%% open service auction
-record(open_service_auction_proto, {id,duration,item_id,base,increment}).
-record(role_open_service_auction_info, {role_id,name,time,bid}).
-record(role_open_service_auction_max, {role_id,name,time,bid}).

%% top_bar_item
-record(top_bar_item, {id,type,pos,script,start_time,end_time}).
-record(temp_activity, {id,type,start_time,end_time,condition,awards,awards_type,awards_send_type,awards_time,bar_item,sid}).
-record(role_temp_activity_count, {role_id,count}).
-record(role_temp_activity_awards, {role_id,awards}).
-record(role_temp_activity_count2, {key,count}).

%% travel_match
-record(travel_match_proto,{type,duration,interval,start_date,default_point}).
-record(travel_match_level,{type,level,min_fight_force,cost,wait_map,
	transports,min_num,awards_rate,distribution,unit,limit}).
-record(travel_match_stage,{type,stage,time_line}).
-record(travel_match_zone_count,{zone_id,type,level,max_count}).
-record(travel_match_level_stage,{type,level,stage,qualified,awards,match_map,pos_list,section_num}).
-record(travel_match_rank_awards,{type,level,rank,awards}).

-record(role_travel_match_info,{role_id,role_name,gender,class,level,fight_force}).
-record(role_travel_match_result,{role_id,level,info}).
-record(role_travel_match_rank,{type,session,level_zone,role_id,role_name,gender,class,level,fight_force,rank,awards}).
-record(role_wait_map_zone,{type,level,unit,zone_id}).

%% title
-record(title_proto, {id,type,flag,condition,exclude,hpmax,magicpower,rangepower,meleepower,magicdefense,rangedefense,
	meleedefense,hitrate,dodge,criticalrate,criticaldestroyrate,toughness, magicimmunity,rangeimmunity,
	meleeimmunity}).
-record(role_title_info, {role_id,info}).
-record(title_role, {title,role_id}).

-record(duplicate_prize_map, {role_id,info}).

%% dead_valley
-record(dead_valley_proto,{id,time_lines,level,map_id,transports,points,equip_proto,expire,drop_rate,cooldown}).
-record(dead_valley_zone_count,{zone_id,max_count}).
-record(dead_valley_exp,{level,exp}).
-record(dead_valley_trap,{id,show,hide,buffer}).
-record(role_dead_valley_info,{role_id,leave_time,points,exp}).

-record(media_card_info, {role_id,info}).
-record(mystical_card_info, {role_id,info}).
-record(mystical2_card_info, {role_id,info}).
-record(mystical3_card_info, {role_id,info}).

-record(role_charge_reward,{roleid,chargeNum,state,time}).
-record(charge_reward_info,{id,gold,item_id}).