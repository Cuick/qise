%% Author: adrianx
%% Created: 2010-10-11
%% Description: TODO: Add description to gm_logger_role
-module(gm_logger_role).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("mnesia_table_def.hrl").
-include("welfare_activity_define.hrl").
%%
%% API Functions
%%

%% @doc by xiaodya
%% invoke write/1( KeyValueList::string() ) This is default function
%% invoke write/2(KeyValueList::string(),Type::atom()) has a special param
%% buffer|directly|merge|nodb These are atom()
%% write/1 == write/2 Type=buffer

role_vip(RoleId,Type,RoleLevel)->
	LineKeyValue = [{"cmd","role_vip"},
					{"roleid",RoleId},
					{"type",Type},
					{"rolelevel",RoleLevel}		
		 ],
	gm_msgwrite:write(role_vip,LineKeyValue).

role_exchange_item(RoleId,Level,ItemId,ItemCount,ConsumeItem,ConsumeCount)->
	LineKeyValue = [{"cmd","role_exchange_item"},
					{"roleid",RoleId},
					{"level",Level},
					{"itemid",ItemId},
					{"itemcount",ItemCount},
					{"consumeitem",ConsumeItem},
					{"consumecount",ConsumeCount}
		 ],
	gm_msgwrite:write(role_exchange_item,LineKeyValue).

role_offline_exp(RoleId,Level,Hours,Exp,Multi)->
	LineKeyValue = [{"cmd","role_offline_exp"},
					{"roleid",RoleId},
					{"level",Level},
					{"hours",Hours},
					{"exp",Exp},
					{"multi",Multi}
		 ],
	gm_msgwrite:write(role_offline_exp,LineKeyValue).

role_offline_everquest(RoleId,EverQuestId,Level,Multi)->
	LineKeyValue = [{"cmd","role_offline_everquest"},
					{"roleid",RoleId},
					{"everquestid",EverQuestId},
					{"level",Level},
					{"multi",Multi}
		 ],
	gm_msgwrite:write2(role_offline_everquest,LineKeyValue,nodb).

role_venation(RoleId,Venation,Point,Opt,RoleLevel)->		
	LineKeyValue = [{"cmd","role_venation"},
					{"roleid",RoleId},
					{"venation",Venation},
					{"point",Point},
					{"opt",Opt},
					{"rolelevel",RoleLevel}],
	gm_msgwrite:write(role_venation,LineKeyValue).

role_venation_advanced(RoleId,Venation,Bone,Opt,UseItem,ConsumeItem,Money)->
	LineKeyValue = [{"cmd","role_venation_advanced"},
					{"roleid",RoleId},
					{"venation",Venation},
					{"point",Bone},
					{"opt",Opt},
					{"useitem",UseItem},
					{"consumeitem",ConsumeItem},
					{"money",Money}
		 ],
	gm_msgwrite:write(role_venation_advanced,LineKeyValue).

role_soulpower(RoleId,Consume,Remain,RoleLevel)->	
	LineKeyValue = [{"cmd","role_soulpower"},
					{"roleid",RoleId},
					{"consume",Consume},
					{"remain",Remain},
					{"rolelevel",RoleLevel}   
		 ],
	gm_msgwrite:write(role_soulpower,LineKeyValue).

pet_level_up(RoleId,PetId,PetProtoId,RoleLevel,PetLevel)->
	LineKeyValue = [{"cmd","pet_level_up"}, 
					{"roleid",RoleId},
					{"petid",PetId},
					{"pet_protoid",PetProtoId},
					{"rolelevel",RoleLevel},
					{"petlevel",PetLevel}
		 ],
	gm_msgwrite:write(pet_level_up,LineKeyValue).

pet_change(RoleId,FromPet,FromPetId,ToPet,ToPetId)->	
	LineKeyValue = [{"cmd","pet_change"},
					{"roleid",RoleId},
					{"frompetidid",FromPetId},
					{"from_pet",FromPet},
					{"to_pet",ToPet},
					{"to_petid",ToPetId}
		 ],
	gm_msgwrite:write(pet_change,LineKeyValue).


pet_delete(RoleId,PetId,Flag,PetProto)->	
	LineKeyValue = [{"cmd","pet_delete"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"petproto",PetProto},
					{"flag",Flag}
		 ],
	gm_msgwrite:write(pet_delete,LineKeyValue).

pet_feed(RoleId,PetId,Happiness,PetProto)->
	LineKeyValue = [{"cmd","pet_feed"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"petproto",PetProto},
					{"happiness",Happiness}
		 ],
	gm_msgwrite:write(pet_feed,LineKeyValue).

role_trad_log(MyRoleId,ToRoleId,Money,PlayerItems)->
	ItemString = player_items_to_string(playeritems_union(PlayerItems)),
	LineKeyValue = [{"cmd","role_trad_log"},
					{"my_roleid",MyRoleId},
					{"to_roleid",ToRoleId},
					{"money",Money},
					{"items",ItemString}
		 ],
	gm_msgwrite:write(role_trad_log,LineKeyValue).

role_new_trad_log(MyRoleId,OtherRoleId,MyMoney,MyPlayerItems,OtherMoney,OtherPlayerItems)->
	MyItemString = player_items_to_string(playeritems_union(MyPlayerItems)),
	OtherItemString = player_items_to_string(playeritems_union(OtherPlayerItems)),
	LineKeyValue = [{"cmd","role_new_trad_log"},
					{"my_roleid",MyRoleId},
					{"other_roleid",OtherRoleId},
					{"mymoney",MyMoney},
					{"myitems",MyItemString},
					{"othermoney",OtherMoney},
					{"otheritems",OtherItemString}
		 ],
	gm_msgwrite:write(role_new_trad_log,LineKeyValue).

ever_quest_completed(RoleId,EverQuestId,QuestId,CurrentRound,CurrentCount,RoleLevel)->		
	LineKeyValue = [{"cmd","ever_quest_completed"},
					{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"questid",QuestId},
					{"current_round",CurrentRound},
					{"current_count",CurrentCount},
					{"rolelevel",RoleLevel}   
		 ],
	gm_msgwrite:write(ever_quest_completed,LineKeyValue).

ever_quest_accepted(RoleId,EverQuestId,QuestId,CurrentRound,CurrentCount,RoleLevel)->	
	LineKeyValue = [{"cmd","ever_quest_accepted"},
					{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"questid",QuestId},
					{"current_round",CurrentRound},
					{"current_count",CurrentCount},
					{"rolelevel",RoleLevel}   
		 ],
	gm_msgwrite:write(ever_quest_accepted,LineKeyValue).

refresh_ever_quest(RoleId,EverQuestId,RefreshType,Quality,RoleLevel)->	
	LineKeyValue = [{"cmd","refresh_ever_quest"},
					{"roleid",RoleId},
					{"ever_questid",EverQuestId},
					{"refresh_type",RefreshType},
					{"quality",Quality},
					{"rolelevel",RoleLevel} 
		 ],
	gm_msgwrite:write(refresh_ever_quest,LineKeyValue).

role_power_gather(RoleId,Power,Class,RoleLevel)->			
	LineKeyValue = [{"cmd","role_power_gather"},
					{"roleid",RoleId},
					{"power",Power},
					{"class",Class},
					{"rolelevel",RoleLevel}   
		 ],
	gm_msgwrite:write2(role_power_gather,LineKeyValue,nodb).

role_batter(RoleId,Batter,RoleLevel)->		
	LineKeyValue = [{"cmd","role_batter"},
					{"roleid",RoleId},
					{"batter",Batter},
					{"rolelevel",RoleLevel}   
		 ],
	gm_msgwrite:write(role_batter,LineKeyValue).

role_ranks_info(RankList)->
	lists:foreach(fun({RoleId,Kills})->
		LineKeyValue = [{"cmd","role_ranks_info"},
						{"roleid",RoleId},
						{"kills",Kills}
					   ],
		gm_msgwrite:write(role_ranks_info,LineKeyValue) 
				  end, RankList).

create_role(UserName,UserId,RoleName,RoleId,Class,Gender,Pf,IpAddress,IsRobot)->
	LineKeyValue = [{"cmd","create_role"},
					{"username",list_to_binary(mysql_util:escape(UserName))},
					{"userid",UserId},
					{"rolename",list_to_binary(mysql_util:escape(RoleName))},
					{"roleid",RoleId},
					{"roleclass",Class},
					{"gender",Gender},
					{"ipaddress",IpAddress},
					{"pf",Pf},
					{"is_robot", IsRobot}
		 ],
	gm_msgwrite:write2(create_role,LineKeyValue,directly).
		 
role_visitor_register(RoleId,NewUserName)->
	LineKeyValue = [{"cmd","role_visitor_register"},
					{"roleid",RoleId},
					{"username",list_to_binary(mysql_util:escape(NewUserName))}
		 ],
	gm_msgwrite:write(role_visitor_register,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									   [{"username",
										 mysql_util:escape(NewUserName)}]).
	
role_rename(RoleId,OldName,NewName,IpAddress)->
	LineKeyValue = [{"cmd","role_rename"},
					{"roleid",RoleId},
					{"oldname",list_to_binary(mysql_util:escape(OldName))},
					{"newname",list_to_binary(mysql_util:escape(NewName))},
					{"ipaddress",IpAddress}],
	gm_msgwrite:write(role_rename,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, [{"rolename", mysql_util:escape(NewName)}]).

role_login(RoleId,IpAddress,Level)->
	LineKeyValue = [{"cmd","role_login"},
					{"roleid",RoleId},
					{"ipaddress",IpAddress},
					{"rolelevel",Level}],
	gm_msgwrite:write(role_login,LineKeyValue),
    {MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
    TimeSeconds = Secs+MegaSecs*1000000,
    gm_msgwrite_mysql:update_db_merge_roleuser(RoleId,
            [{"lastLoginIp",integer_to_list(gm_msgwrite_mysql:convert_ip2int(IpAddress))},
             {"lastLoginTime",integer_to_list(TimeSeconds)}
            ]).

role_logout(RoleId,IpAddress,TimeOnLine,Level)->
    LineKeyValue = [{"cmd","role_logout"},
                                    {"roleid",RoleId},
                                    {"ipaddress",IpAddress},
                                    {"timeonline",TimeOnLine},
                                    {"rolelevel",Level}],
	gm_msgwrite:write(role_logout,LineKeyValue),
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									   [{"lastLogoutTime",
										 integer_to_list(TimeSeconds)}]).

role_level_up(RoleId,NewLevel)->
	LineKeyValue = [{"cmd","role_leve_up"},
					{"roleid",RoleId},
					{"level",NewLevel}],
	gm_msgwrite:write(role_leve_up,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
										[{"level",integer_to_list(NewLevel)}]). 

role_map_change(RoleId,FromMap,ToMap)->
	LineKeyValue = [{"cmd","role_map_change"},
					{"roleid",RoleId},
					{"frommap",FromMap},
					{"tomap",ToMap}],
	gm_msgwrite:write2(role_map_change,LineKeyValue,nodb).

invite_friend_log(AllReceiverIds) ->
    Log = [
                    {"receivers",AllReceiverIds}
         ].

invite_friend_gift(Amount) ->
    ok.


 %% Action = "accept" | "compelete" | "quit" | "submit"
role_quest_log(RoleId,QuestId,Action,RoleLevel)->			
	LineKeyValue = [{"cmd","role_quest_log"},
					{"roleid",RoleId},
					{"action",Action},
					{"quest",QuestId},
					{"rolelevel",RoleLevel}   
				   ],
	gm_msgwrite:write(role_quest_log,LineKeyValue).

role_skill_learn(RoleId,SkillId,SkillLevel,RoleLevel)-> 		
	LineKeyValue = [{"cmd","role_skill_learn"},
					{"roleid",RoleId},
					{"skill",SkillId},
					{"level",SkillLevel},
					{"rolelevel",RoleLevel}   
				   ],
	gm_msgwrite:write(role_skill_learn,LineKeyValue).

%% Reason = "got_systemgive" 
%%			"lost_function" | "lost_mall"
role_ticket_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)-> 		
	LineKeyValue = [{"cmd","role_ticket_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}		
				  ],
	gm_msgwrite:write(role_ticket_change,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									   [{"ticket",integer_to_list(NewCount)}]). 

%% Reason = "gm_got_charge"|"got_charge" | "got_giftplayer" | "got_tradplayer" 
%%          "lost_function" | "lost_mall" | "lost_tradplayer" | "lost_giftplayer" 
%% 			"lost_tosilver"|lost_respawn|treasure_chest_cost |"lost_pet_quality_up"		
role_gold_change(Account,RoleId,ChangeCount,NewCount,Reason)->
% role_gold_change(Account, PfGoldChange, LocalGoldChange, NewPfGold, NewLocalGold, NewGold, Reason) ->
	% RoleId = get(roleid),
    NewReason = case string:str(atom_to_list(Reason), "lost_mall") of
                    1 ->
                        lost_mall;
                    _ ->
                        Reason
                end,
	LineKeyValue = [{"cmd","role_gold_change"},
					{"account",Account},
					{"id",'default'},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",NewReason}
				   ],
	gm_msgwrite:write(role_gold_change,LineKeyValue),
	gm_msgwrite_mysql:update_db_buffer("role_user", ["gold"], 
								[integer_to_list(NewCount)], 
								"username='"++mysql_util:escape(Account)++"'").

%% Reason = "got_monster" | "got_quest" |"got_npctrad" | "got_tradplayer" | "got_giftplayer" |"got_fromgold" |"got_tangle_battle"
%%			"getmail" | "sendmail" | "stall_buy" |"got_down_stall" | "got_chess_spirit"
%%          "lost_function" | "lost_skill" | "lost_repaire" | "lost_npctrad" | "lost_tradplayer"| "lost_giftplayer"
%%			"lost_stall_buy" | "lost_up_stall" | "lost_over_due" | "lost_use_up" | "consume_up" | "role_destroy" "lost_swap_stack"
%%			"lost_pet_quality_up" 
role_silver_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->     
	LineKeyValue = [{"cmd","role_silver_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_silver_change,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									  [{"silver",integer_to_list(NewCount)}]).  

role_boundsilver_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->
	LineKeyValue = [{"cmd","role_boundsilver_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_boundsilver_change,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
									  [{"boundsilver",integer_to_list(NewCount)}]).

role_charge_integral_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->     
	LineKeyValue = [{"cmd","role_charge_integral_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_charge_integral_change,LineKeyValue).

role_consume_integral_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->     
	LineKeyValue = [{"cmd","role_consume_integral_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_consume_integral_change,LineKeyValue).

role_honor_change(RoleId,ChangeCount,NewCount,Reason,RoleLevel)->
	LineKeyValue = [{"cmd","role_honor_change"},
					{"roleid",RoleId},
					{"changecount",ChangeCount},
					{"newcount",NewCount},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_honor_change,LineKeyValue).

%%reason <= 45 bytes
%% reason:golden_plume_awards | refine_system
role_get_item(RoleId,ItemId,Count,ItemProto,Reason,RoleLevel)->	
	LineKeyValue = [{"cmd","role_get_item"},
					{"roleid",RoleId},
					{"item",ItemId},
					{"count",Count},
					{"proto",ItemProto},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_get_item,LineKeyValue).


role_release_item(RoleId,ItemId,ProtoId,OtherRoleId,Reason,RoleLevel)->			
	LineKeyValue = [{"cmd","role_release_item"},
					{"roleid",RoleId},
					{"protoid",ProtoId},
					{"item",ItemId},
					{"dstrole",OtherRoleId},
					{"reason",Reason},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_release_item,LineKeyValue).

%%Type = "star"| "socket"| "stone_mix" | "e_upgrade" | 
%%       "star_failed"| "socket_failed"| "stone_mix_failed" | "e_upgrade_failed"
role_enchantments_item(RoleId,ItemId,Type,ItemResult,RoleLevel)-> 
	LineKeyValue = [{"cmd","role_enchantments_item"},
					{"roleid",RoleId},
					{"item",ItemId},
					{"type",Type},
					{"result",ItemResult},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_enchantments_item,LineKeyValue).

%%Type = "growth"| "stamina"| "riseup" 
%%       "growth_failed"| "stamina_failed"| "riseup_failed" 
role_petup(RoleId,PetId,Type,Start,End,RoleLevel)-> 
	LineKeyValue = [{"cmd","role_petup"},
					{"roleid",RoleId},
					{"petId",PetId},
					{"type",Type},
					{"start",Start},
					{"end",End},
					{"rolelevel",RoleLevel}			
				   ],
	gm_msgwrite:write(role_petup,LineKeyValue).

role_join_guild(RoleId,GuildId)->
	LineKeyValue = [{"cmd","role_join_guild"},
					{"roleid",RoleId},
					{"guild",GuildId}
					],
	gm_msgwrite:write(role_join_guild,LineKeyValue),
	gm_msgwrite_mysql:update_db_merge_roleuser(RoleId, 
											   [{"guild",gm_msgwrite_mysql:value_to_list(GuildId)}]). 

role_leave_guild(RoleId,GuildId,Reason)->        
	LineKeyValue = [{"cmd","role_leave_guild"},
					{"roleid",RoleId},
					{"guild",GuildId},
				   	{"reason",Reason}
				   ],
	gm_msgwrite:write(role_leave_guild,LineKeyValue).

role_consume_item(RoleId,ItemId,ProtoId,Count,LeftCount)->
	LineKeyValue = [{"cmd","role_consume_item"},
					{"roleid",RoleId},
					{"itemid",ItemId},
					{"item",ProtoId},
					{"count",Count},
					{"leftcount",LeftCount}],
	gm_msgwrite:write(role_consume_item,LineKeyValue).

role_flush_items(RoleId,PlayerItems)->
	ItemString = player_items_to_string(player_items_union(PlayerItems)),
	LineKeyValue = [{"cmd","role_items"},
					{"roleid",RoleId},
					{"items",ItemString}
					],
	gm_msgwrite:write2(role_items,LineKeyValue,nodb).

role_chat(RoleId,RoleName,ToRole,Channel,Content)->
	LineKeyValue = [{"cmd","role_chat"},
					{"roleid",RoleId},
					{"rolename",list_to_binary(mysql_util:escape(RoleName))},
					{"torole",ToRole},
					{"channel",Channel},
					{"content",Content}  
					],
	gm_msgwrite:write2(role_chat,LineKeyValue,nodb).

role_buy_mall_item(RoleId,ItemId,Price,Count,PriceType,RoleLevel)-> 	
	LineKeyValue = [{"cmd","role_buy_mall_item"},
					{"roleid",RoleId},
					{"itemid",ItemId},
					{"price",Price},
					{"count",Count},
					{"pricetype",PriceType},
					{"rolelevel",RoleLevel}		
					],
	gm_msgwrite:write(role_buy_mall_item,LineKeyValue).

role_buy_guild_mall_item(RoleId,ItemId,Price,Count)->
	LineKeyValue = [{"cmd","role_buy_guild_mall_item"},
					{"roleid",RoleId},
					{"itemid",ItemId},
					{"price",Price},
					{"count",Count}
					],
	gm_msgwrite:write(role_buy_guild_mall_item,LineKeyValue).

role_guild_contribution_change(RoleId,GuildId,Contribution,Reason)->
	LineKeyValue = [{"cmd","role_guild_contribution_change"},
					{"roleid",RoleId},
					{"guildid",GuildId},
					{"contribution",Contribution},
					{"reason",Reason}
					],
	gm_msgwrite:write(role_guild_contribution_change,LineKeyValue).

role_loop_tower(RoleId,Layer,LayerTime)->		
	LineKeyValue = [{"cmd","role_loop_tower"},
					{"roleid",RoleId},
					{"layer",Layer},
					{"layertime",LayerTime}
					],
	gm_msgwrite:write(role_loop_tower,LineKeyValue).

role_loop_tower_detail(RoleId,Layer,LayerTime,Detail,RoleLevel)->		
	LineKeyValue = [{"cmd","role_loop_tower_detail"},
					{"roleid",RoleId},
					{"layer",Layer},
					{"layertime",LayerTime},
					{"detail",Detail},
					{"rolelevel",RoleLevel}	
					],
	gm_msgwrite:write(role_loop_tower_detail,LineKeyValue).

drop_rule(RuleId,ItemId,Count,RoleFlag)->
	LineKeyValue = [{"cmd","drop_rule"},
					{"ruleid",RuleId},
					{"itemid",ItemId},
					{"count",Count},
					{"roleflag",RoleFlag}
					],
	gm_msgwrite:write(drop_rule,LineKeyValue).

answer_log(RoleId,Score,Rank,Exp,RoleLevel)->
	LineKeyValue = [{"cmd","role_answer_log"},
					{"roleid",RoleId},
					{"score",Score},
					{"rank",Rank},
					{"exp",Exp},
					{"rolelevel",RoleLevel}		%%add
					],
	gm_msgwrite:write(role_answer_log,LineKeyValue).

answering_log(RoleId,Status,AnswerTime,Flag,Score)->
	LineKeyValue = [{"cmd","role_answering_log"},
					{"roleid",RoleId},
					{"status",Status},
					{"answer_time",AnswerTime},
					{"flag",Flag},
					{"score",Score}
					],
	gm_msgwrite:write(role_answering_log,LineKeyValue).

%%Status=1,join|2,
banquet_log(RoleId,RoleLevel,Status,Exp)->
	LineKeyValue = [{"cmd","role_banquet_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"status",Status},
					{"exp",Exp}
					],
	gm_msgwrite:write(role_banquet_log,LineKeyValue).

%%
%%Reset the number of consecutive login
%%
role_clear_continuous_days(RoleId,Days)->
	LineKeyValue = [{"cmd","role_continuous_log"},
					{"roleid",RoleId},
					{"days",Days}
					],
	gm_msgwrite:write(role_continuous_log,LineKeyValue).

role_continuous_days_reward(RoleId,Days,IsVip)->
	LineKeyValue = [{"cmd","role_continuous_reward_log"},
					{"roleid",RoleId},
					{"days",Days},
					{"isvip",IsVip}
					],
	gm_msgwrite:write(role_continuous_reward_log,LineKeyValue).

%%
%%Activity changes
%%
role_activity_value_change(RoleId,Type,RoleLevel,CompleteTimes,TotalTimes)->
	LineKeyValue = [{"cmd","role_activity_value_change_log"},
					{"roleid",RoleId},
					{"type",Type},
					{"rolelevel",RoleLevel},
					{"complete",CompleteTimes},
					{"total",TotalTimes}		
					],
	gm_msgwrite:write(role_activity_value_change_log,LineKeyValue).


role_activity_value(RoleId,AddValue,NewValue,Type,RoleLevel)->
	LineKeyValue = [{"cmd","role_activity_value_log"},
					{"roleid",RoleId},
					{"addvalue",AddValue},
					{"newvalue",NewValue},
					{"type",Type},
					{"rolelevel",RoleLevel}		
					],
	gm_msgwrite:write(role_activity_value_log,LineKeyValue).

%%
%%Redemption activity
%%
role_activity_value_reward(RoleId,Value,Id,Remain,RoleLevel)->
	LineKeyValue = [{"cmd","role_activity_value_reward_log"},
					{"roleid",RoleId},
					{"value",Value},
					{"itemid",Id},
					{"remain",Remain},
					{"rolelevel",RoleLevel}		
					],
	gm_msgwrite:write(role_activity_value_reward_log,LineKeyValue).
 
%%
%%first charge gift
%%Opt :has_get_reward 
%%
role_first_charge_gift(RoleId,Opt,RoleLevel)->
	LineKeyValue = [{"cmd","role_first_charge_gift_log"},
					{"roleid",RoleId},
					{"opt",Opt},
					{"rolelevel",RoleLevel}
					],
	gm_msgwrite:write(role_first_charge_gift_log,LineKeyValue).


role_join_instance(RoleId,RoleLevel,GroupMember,InstanceId,InstanceProtoId,Times)->
	GroupMemberStr = roleids_to_string(GroupMember),
	LineKeyValue = [{"cmd","role_join_instance"},
					{"roleid",RoleId},
					{"level",RoleLevel},
					{"groupmember",GroupMemberStr},
					{"instanceid",InstanceId},
					{"protoid",InstanceProtoId},
					{"times",Times}
					],
	gm_msgwrite:write(role_join_instance,LineKeyValue).

role_level_instance(RoleId,RoleLevel,GroupMember,InstanceId,InstanceProtoId)->
	GroupMemberStr = roleids_to_string(GroupMember),
	LineKeyValue = [{"cmd","role_level_instance"},
					{"roleid",RoleId},
					{"level",RoleLevel},
					{"groupmember",GroupMemberStr},
					{"instanceid",InstanceId},
					{"protoid",InstanceProtoId}
					],
	gm_msgwrite:write(role_level_instance,LineKeyValue).

role_send_mail(RoleId,ToRoleId,MailId,PlayerItems,Silver,Gold,Title,Content)->
	ItemsString = player_items_to_string(PlayerItems),
	LineKeyValue = [{"cmd","role_send_mail"},
					{"roleid",RoleId},
					{"toid",ToRoleId},
					{"mailid",MailId},
					{"items",ItemsString},
					{"silver",Silver},
					{"gold",Gold},
					{"title",Title},
					{"content",Content}
					],
	gm_msgwrite:write(role_send_mail,LineKeyValue).

role_read_mail(RoleId,MailId,PlayerItems,Silver,Gold)->
	ItemsString = player_items_to_string(playeritems_union(PlayerItems)),
	LineKeyValue = [{"cmd","role_read_mail"},
					{"roleid",RoleId},
					{"mailid",MailId},
					{"items",ItemsString},
					{"silver",Silver},
					{"gold",Gold}
					],
	gm_msgwrite:write(role_read_mail,LineKeyValue).

role_delete_mail(RoleId,MailId,ItemIds,Silver,Gold,Type)->
	LineKeyValue = [{"cmd","role_delete_mail"},
					{"roleid",RoleId},
					{"mailid",MailId},
					{"itemids",ItemIds},
					{"silver",Silver},
					{"gold",Gold},
					{"type",Type}
					],
	gm_msgwrite:write(role_delete_mail,LineKeyValue).

role_auction_log(SellerId,BuyerId,PlayerItems,Silver,Gold)->
	LineKeyValue = [{"cmd","role_auction_log"},
					{"sellid",SellerId},
					{"buyerid",BuyerId},
					{"items",PlayerItems},
					{"silver",Silver},
					{"gold",Gold}
					],
	gm_msgwrite:write(role_auction_log,LineKeyValue).


role_chess_spirits_reward(RoleId,Level,Type,PlayerItems,Exp)->
	ItemsString = player_items_to_string(playeritems_union(PlayerItems)),
	LineKeyValue = [{"cmd","role_chess_spirits_reward"},
					{"roleid",RoleId},
					{"level",Level},
					{"type",Type},
					{"items",ItemsString},
					{"exp",Exp}
					],
	gm_msgwrite:write(role_chess_spirits_reward,LineKeyValue).


%%role_npc_exchange(RoleId,NpcId,PlayerItems,)->
	
	
%% 	
%%treasure_chest  
%%
treasure_chest_lottery_items(RoleId,BeadType,ConsumeType,Gold,BindConsumeNum,NonBindConsumeNum,TreasureItems,RoleLevel)->
	ItemString = player_items_to_string(TreasureItems),
	LineKeyValue = [{"cmd","treasure_chest_lottery_items_log"},
					{"roleid",RoleId},
					{"bead_type",BeadType},
					{"consume_type",ConsumeType},
					{"gold",Gold},			
					{"bind_item_consume_num",BindConsumeNum},
					{"nonbind_item_consume_num",NonBindConsumeNum},
					{"lottery_items",ItemString},
					{"rolelevel",RoleLevel}		
		 ],
	gm_msgwrite:write(treasure_chest_lottery_items_log,LineKeyValue).


%% 
%%treasure_chest_package 
%% 
treasure_chest_package_get_items(RoleId,ItemList)->
	ItemString = player_items_to_string(ItemList),
	LineKeyValue = [{"cmd","treasure_chest_package_get_items_log"},
					{"roleid",RoleId},
					{"get",ItemString}
					],
	gm_msgwrite:write(treasure_chest_package_get_items_log,LineKeyValue).


%% 
%%facebook bind
%% 
facebook_bind(RoleId,FaceBookId,MsgId,Result)->
	LineKeyValue = [{"cmd","facebook_bind_log"},
					{"roleid",RoleId},
					{"facebookid",FaceBookId},
					{"msgid",MsgId},		
					{"result",Result}		
					],
	gm_msgwrite:write(facebook_bind_log,LineKeyValue).

%%
%%honor_stores
%%
role_buy_item_by_honor(RoleId,ItemId,Count,Price)->
	LineKeyValue = [{"cmd","role_buy_item_by_honor_log"},
					{"roleid",RoleId},
					{"itemid",ItemId},
					{"count",Count},
					{"price",Price}		
					],
	gm_msgwrite:write(role_buy_item_by_honor_log,LineKeyValue).

%%
%%chess spirit result 
%%Type:1:single 2:team
%%
chess_spirit_log(Type,RoleId,RoleLevel,ConsumeTime_S,SectionNum,Roleids)->
	GroupMemberStr = roleids_to_string(Roleids),
	LineKeyValue = [{"cmd","chess_spirit_log"},
					{"roleid",RoleId},
					{"type",Type},
					{"level",RoleLevel},
					{"use_time_s",ConsumeTime_S},
					{"section",SectionNum},
					{"roleids",GroupMemberStr},
					{"teamnum",erlang:length(Roleids)}
					],
	gm_msgwrite:write(chess_spirit_log,LineKeyValue).

%% 
%%welfare borad activity 
%% 
welfare_activity_log(RoleId,TypeNumber,SerialNumber)->
	LineKeyValue = [{"cmd","welfare_activity_log"},
					{"roleid",RoleId},
					{"typenumber",TypeNumber},		
					{"serialnumber",SerialNumber}	
					],
	gm_msgwrite:write(welfare_activity_log,LineKeyValue).

%%

%%pet_wash_attr_point
%%
pet_wash_attr_point_log(RoleId,RoleLevel,PetProtoId,PetId,Result)->
	LineKeyValue = [{"cmd","pet_wash_attr_point_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"result",Result}					%%noitem|sucess
					],
	gm_msgwrite:write(pet_wash_attr_point_log,LineKeyValue).

%%
%%pet_add_attr_point
%%
pet_add_attr_point_log(RoleId,RoleLevel,PetProtoId,PetId,Result,AddPoint,RemainPoint)->
	LineKeyValue = [{"cmd","pet_add_attr_point_log"},			
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"result",Result},					%%point_not_enough|sucess
					{"addpoint",AddPoint},
					{"remainpoint",RemainPoint}
					],
	gm_msgwrite:write(pet_add_attr_point_log,LineKeyValue).

%%
%%pet_grade_quality
%%
pet_grade_quality_log(RoleId,RoleLevel,PetProtoId,PetId,IsHasProtect,Result,Value)->
	LineKeyValue = [{"cmd","pet_grade_quality_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"pet_protoid",PetProtoId},
					{"petid",PetId},		
					{"ishasprotect",IsHasProtect},		%%noprotect|hasprotect
					{"result",Result},					%%failed|sucess
					{"value",Value}
					],
	gm_msgwrite:write(pet_grade_quality_log,LineKeyValue).

%%

%%pet_evolution
%%
pet_evolution_log(RoleId,PetId,PetTempId,Silver,ItemClass,Count,Result)->
	LineKeyValue = [{"cmd","pet_evolution_log"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"pettmpid",PetTempId},
					{"silver",Silver},
					{"itemclass",ItemClass},
					{"count",Count},
					{"result",Result}
				   ],
	gm_msgwrite:write(pet_evolution_log,LineKeyValue).

%%
%%pet_talent_log
%%
pet_talent_consume(RoleId,PetId,PetTempId,Type,Gold)->
	LineKeyValue = [{"cmd","pet_talent_consume"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"pettmpid",PetTempId},
					{"type",Type},
					{"gold",Gold}
				   ],
	gm_msgwrite:write(pet_talent_consume,LineKeyValue).

pet_talent_change(RoleId,PetId,T_Power,T_HitRate,T_Criticalrate,T_Stamina,PetProto)->
	LineKeyValue = [{"cmd","pet_talent_change"},
					{"roleid",RoleId},
					{"petid",PetId},
					{"power",T_Power},
					{"hitrate",T_HitRate},
					{"criticalrate",T_Criticalrate},
					{"stamina",T_Stamina},
					{"petproto",PetProto}
				   ],
	gm_msgwrite:write(pet_talent_change,LineKeyValue).

%%
%%ride_pet_synthesis_log
%%
ride_pet_synthesis_log(RoleId,RidePetA,RidePetB,ResultPet,AddAttr)->
	LineKeyValue = [{"cmd","ride_pet_synthesis_log"},
					{"roleid",RoleId},
					{"ridepeta",RidePetA},
					{"ridepetb",RidePetB},
					{"resultpet",ResultPet},
					{"addattr",AddAttr}
				   ],
	gm_msgwrite:write(ride_pet_synthesis_log,LineKeyValue).

%%role_crime
role_change_crime_log(RoleId,SelfModel,OtherModel,NewCrime,LastCrime,Ext)->
	LineKeyValue = [{"cmd","role_change_crime_log"},
					{"roleid",RoleId},
					{"selfmodel",SelfModel},
					{"othermodel",OtherModel},
					{"newcrime",NewCrime},
					{"lastcrime",LastCrime},
					{"ext",Ext}
				   ],
	gm_msgwrite:write2(role_change_crime_log,LineKeyValue,nodb).

%%golden_plume_awards_log
golden_plume_awards_log(RoleId,RoleLevel,Result,TmpReason,ActivityNumber)->
	Reason = if
				 TmpReason =:= ?ERROR_ACTIVITY_UPDATE_OK->
					 sucess;
				 TmpReason =:= ?ERROR_SERIAL_NUMBER_ERROR->
					 serial_number_error;
				 TmpReason =:= ?ERROR_USED_SERIAL_NUMBER->
					 used_serial_number;
				 TmpReason =:= ?ERROR_HAS_FINISHED->
					 has_finished;
				 true->
					 other_error
			 end,
	ActivityName = if
					   ActivityNumber =:= ?FIRST_PAY ->
						   first_pay;
					   ActivityNumber =:= ?NEW_BIRD ->
						   new_bird;
					   ActivityNumber =:= ?TW_MEMBER ->
						   tw_member;
					   ActivityNumber =:= ?TW_NEW_BIRD ->
						   tw_new_bird;
					   ActivityNumber =:= ?TW_FIRST_PAY ->
						   tw_first_pay;
					   ActivityNumber =:= ?GOLD_EXCHANGE_ACTIVITY ->
						   gold_exchange_ticket;
					   ActivityNumber =:= ?TW_OTHER->
						   tw_other;
					   ActivityNumber =:= ?GOLDEN_PLUME_AWARDS->
						   golden_plume_awards;
					   ActivityNumber =:= ?CONSUME_RETRURN ->
						   consume_return_gift
				   end,
	LineKeyValue = [{"cmd","golden_plume_awards_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"result",Result},
					{"reason",Reason},
					{"activityname",ActivityName}
				   ],
	gm_msgwrite:write(golden_plume_awards_log,LineKeyValue).


role_expand_package(RoleId,NewPackageSize,ExpandNum)->
	LineKeyValue = [{"cmd","role_expand_package_log"},
					{"roleid",RoleId},
					{"newpackagesize",NewPackageSize},
					{"expandsize",ExpandNum}
				   ],
	gm_msgwrite:write(role_expand_package_log,LineKeyValue).

role_expand_storage(RoleId,NewStorageSize,ExpandNum)->
	LineKeyValue = [{"cmd","role_expand_storage_log"},
					{"roleid",RoleId},
					{"newstoragesize",NewStorageSize},
					{"expandsize",ExpandNum}
				   ],
	gm_msgwrite:write(role_expand_storage_log,LineKeyValue).

%%refine_system_log
refine_system_log(RoleId,RoleLevel,SerilNumber,Times,Result)->
	LineKeyValue = [{"cmd","refine_system_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"serial_number",SerilNumber},
					{"times",Times},
					{"result",Result}
				   ],
	gm_msgwrite:write(refine_system_log,LineKeyValue).	

%%consume_return_activity
consume_return_activity_log(RoleId,RoleLevel,Times,RemainConsumeGold)->
	LineKeyValue = [{"cmd","consume_return_activity_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"times",Times},
					{"remain_consume_gold",RemainConsumeGold}
				   ],
	gm_msgwrite:write(consume_return_activity_log,LineKeyValue).	

%%
%%item_identify
%%
item_identify_log(RoleId,ResultItem,AddAttr)->
	LineKeyValue = [{"cmd","item_identify_log"},
					{"roleid",RoleId},
					{"resultitem",ResultItem},
					{"addattr",AddAttr}
				   ],
	gm_msgwrite:write(item_identify_log,LineKeyValue).

%%
%%treasure_transport
%%
treasure_transport_failed(RoleId,Quality,Bonusexp,Bonusmoney,Reason)->
	LineKeyValue = [{"cmd","treasure_transport_failed_log"},
					{"roleid",RoleId},
					{"quality",Quality},
					{"bonusexp",Bonusexp},
					{"bonusmoney",Bonusmoney},
					{"reason",Reason}
				   ],
	gm_msgwrite:write(treasure_transport_failed_log,LineKeyValue).

%%
%%goals
%%
goals_can_reward(RoleId,RoleLevel,Days,Part)->
	LineKeyValue = [{"cmd","goals_can_reward_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"days",Days},
					{"part",Part}
				   ],
	gm_msgwrite:write2(goals_can_reward_log,LineKeyValue,nodb).

goals_reward(RoleId,RoleLevel,Days,Part,Bonus)->
	LineKeyValue = [{"cmd","goals_reward_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"days",Days},
					{"part",Part},
					{"bonus",Bonus}
				   ],
	gm_msgwrite:write2(goals_reward_log,LineKeyValue,nodb).

%%pet explore 
pet_explore_log(RoleId,RoleLevel,SiteId,StyleId,Lucky,Key)->
	LineKeyValue = [{"cmd","pet_explore_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"siteid",SiteId},
					{"styleid",StyleId},
					{"lucky",Lucky},
					{"key",Key}
				   ],
	gm_msgwrite:write2(pet_explore_log,LineKeyValue,nodb).
	
%%pet explore get items
pet_explore_get_items_log(RoleId,RoleLevel,ItemList,Time,Key)->
	if
		ItemList =:= "stop"->
			ItemString = "stop";
		true->
			ItemString = player_items_to_string(ItemList)
	end,
	LineKeyValue = [{"cmd","pet_explore_get_items_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"get",ItemString},
					{"explore_end_time",Time},
					{"key",Key}
					],
	gm_msgwrite:write2(pet_explore_get_items_log,LineKeyValue,nodb).

country_leader_opt(LeaderId,Post,TargetId,Type)->
	LineKeyValue = [{"cmd","country_leader_opt_log"},
					{"leaderid",LeaderId},
					{"post",Post},
					{"targetid",TargetId},
					{"type",Type}
					],
	gm_msgwrite:write(country_leader_opt_log,LineKeyValue).

%%
%%mainline
%%opt  entry | start | success | leave | reward | faild |
%%remark 
%%
mainline_opt(RoleId,RoleLevel,Chapter,Stage,Difficult,Opt,Remark)->
	LineKeyValue = [{"cmd","mainline_opt_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"opt",Opt},
					{"remark",Remark}
					],
	gm_msgwrite:write2(mainline_opt_log,LineKeyValue,nodb).
%%
%%
%%
mainline_defend_monster(RoleId,RoleLevel,Chapter,Stage,Difficult,Section,MonstersList)->
	LineKeyValue = [{"cmd","mainline_defend_monster_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"section",Section},
					{"monsterslist",MonstersList}
					],
	gm_msgwrite:write2(mainline_defend_monster_log,LineKeyValue,nodb).

mainline_killmonster(RoleId,RoleLevel,Chapter,Stage,Difficult,MonsterProto)->
	LineKeyValue = [{"cmd","mainline_killmonster_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"chapter",Chapter},
					{"stage",Stage},
					{"difficult",Difficult},
					{"monsterproto",MonsterProto}
					],
	gm_msgwrite:write2(mainline_killmonster_log,LineKeyValue,nodb).

%%
%%festival_recharge_log
%% 
festival_recharge_log(RoleId,RoleLevel,Id,CrystalNum,ItemList)->
	ItemString = player_items_to_string(ItemList),
	LineKeyValue = [{"cmd","festival_recharge_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"id",Id},
					{"crystal_num",CrystalNum},
					{"itemlist",ItemString}
					],
	gm_msgwrite:write2(festival_recharge_log,LineKeyValue,nodb).
	
jszd_battle_log(RoleId,RoleLevel,State,Reward)->
	LineKeyValue = [{"cmd","log_jszd_battle_log"},
					{"roleid",RoleId},
					{"rolelevel",RoleLevel},
					{"state",State},
					{"reward",Reward}
					],
	gm_msgwrite:write2(log_jszd_battle_log,LineKeyValue,nodb).

get_battle_reward(RoleId,Battle,Honor,Exp,Item)->
	LineKeyValue = [{"cmd","get_battle_reward_log"},
					{"roleid",RoleId},
					{"honor",Honor},
					{"exp",Exp},
					{"battle",Battle},
					{"item",Item}],
	gm_msgwrite:write2(get_battle_reward_log,LineKeyValue,nodb).
game_charge_level(Account, RoleId, ServerId, Level, BillNo, Type, Money, Gold, FirstChargeFlag) ->
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	LineKeyValue = [{"cmd","game_charge_level"},
					{"id",'default'},
					{"pay_num", BillNo},
					{"pay_mode", Type},
					{"pay_to_user", Account},
					{"roleid", RoleId},
					{"server", ServerId},
					{"pay_gold", Gold},
					{"pay_money", Money},
					{"pay_time", TimeSeconds},
					{"status", 1},
					{"level", Level},
					{"is_first", FirstChargeFlag}
				   ],
	gm_msgwrite:write3(game_charge_level,LineKeyValue, directly).

refresh_fight_force_rank_log(RoleId, Value) ->
    LineKeyValue = [{"cmd","refresh_fight_force_rank_log"},
                    {"roleid", RoleId},
                    {"fightforce", Value}
                    ],
    gm_msgwrite:write(refresh_fight_force_rank_log,LineKeyValue).
	
%% Local Functions
%%
item_info_to_save(ItemInfo)->
	Item = erlang:element(2,ItemInfo),
	Entry = get_template_id_from_iteminfo(Item),
	Count = get_count_from_iteminfo(Item),
	{Entry,Count}.

playeritems_to_save(PlayerItem)->
	#playeritems{entry = Entry,count = Count} = PlayerItem,
	{Entry,Count}.

playeritems_union(ItemsInfos)->
	PlayerItems = lists:map(fun playeritems_to_save/1 , ItemsInfos),
	lists:foldl(fun({ProtoId,Count},OldItems)->
						case Count of
							0-> OldItems;
							_->
								case lists:keyfind(ProtoId, 1, OldItems) of
									false-> [{ProtoId,Count}|OldItems];
									{_,OldCount}-> 
										lists:keyreplace(ProtoId, 1, OldItems, {ProtoId,OldCount+Count})
								end
						end
				end,[], PlayerItems).

player_items_union(ItemsInfo)->
	PlayerItems = lists:map(fun item_info_to_save/1 , ItemsInfo),
	lists:foldl(fun({ProtoId,Count},OldItems)->
						case Count of
							0-> OldItems;
							_->
								case lists:keyfind(ProtoId, 1, OldItems) of
									false-> [{ProtoId,Count}|OldItems];
									{_,OldCount}-> 
										lists:keyreplace(ProtoId, 1, OldItems, {ProtoId,OldCount+Count})
								end
						end
				end,[], PlayerItems).

player_items_to_string(PlayerItems)->
	ItemString = lists:map(fun({ProtoId,Count})->
								   integer_to_list(ProtoId) ++ "," ++ integer_to_list(Count)
						   end, PlayerItems),
	string:join(ItemString, ";").

roleids_to_string([])->
	"";

roleids_to_string(RoleIdList)->
	ItemString = lists:map(fun(RoleId)->
								   integer_to_list(RoleId)
						   end, RoleIdList),
	string:join(ItemString, ";").

temp_activity_reward(RoleId, BigId, SmallId) ->
    Log = [{"roleid",RoleId},
                    {"bid",BigId},
                    {"sid",SmallId}
         ].

insert_roleposition(RoleId) ->
	LineKeyValue = [{"cmd","role_position"},
					{"roleid",RoleId},
					{"mapid",0},
					{"line", 0}
				   ],
	gm_msgwrite:write3(role_position,LineKeyValue, directly).

update_roleposition(RoleId, Mapid ,Line) ->
	gm_msgwrite_mysql:update_db("role_position",["mapid","line"],[integer_to_list(Mapid),integer_to_list(Line)],"roleid='"++integer_to_list(RoleId)++"'").

insert_log_pet_quality_riseup(FieldValue) ->
	[RoleId,RoleName,PetId,PetName,Flag,RiseupStatus,GmPetquality,MyPetStage,NewGmPetquality,NewMyPetStage] = FieldValue,
	% 进阶时间
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	RiseupTime = Secs+MegaSecs*1000000,
	% slogger:msg("bbbbbbbbbbbbRiseupTime~p~n", [TimeSeconds]),
	LineKeyValue = [{"cmd","log_pet_quality_riseup"},
					{"roleid",RoleId},
					{"rolename",RoleName},
					{"petid",PetId},
					{"petname",PetName},
					{"riseup_type",Flag},
					{"riseup_status",RiseupStatus},
					{"old_quality",GmPetquality},
					{"old_stage",MyPetStage},
					{"new_quality",NewGmPetquality},
					{"new_stage", NewMyPetStage},
					{"riseup_time", RiseupTime}
				   ],
	gm_msgwrite:write3(log_pet_quality_riseup,LineKeyValue, directly).

insert_log_pet_grade_riseup(FieldValue) ->
	[RoleId,RoleName,PetId,PetName,Flag,RiseupStatus,OldGrade,NewGrade] = FieldValue,
	% 进阶时间
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	RiseupTime = Secs+MegaSecs*1000000,
	LineKeyValue = [{"cmd","log_pet_grade_riseup"},
					{"roleid",RoleId},
					{"rolename",RoleName},
					{"petid",PetId},
					{"petname",PetName},
					{"riseup_type",Flag},
					{"riseup_status",RiseupStatus},
					{"old_grade",OldGrade},
					{"new_grade",NewGrade},
					{"riseup_time", RiseupTime}
				   ],
	gm_msgwrite:write3(log_pet_grade_riseup,LineKeyValue, directly).

insert_log_pet_alility_riseup(FieldValue) ->
	[RoleId,RoleName,PetId,PetName,Type,LockAttr,OldMagic,OldFar,OldNear,NewMagic,NewFar,NewNear] = FieldValue,
	% 进阶时间
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	RiseupTime = Secs+MegaSecs*1000000,
	LineKeyValue = [{"cmd","log_pet_alility_riseup"},
					{"roleid",RoleId},
					{"rolename",RoleName},
					{"petid",PetId},
					{"petname",PetName},
					{"riseup_type",Type},
					{"lock_attr",LockAttr},
					{"old_magic",OldMagic},
					{"old_far",OldFar},
					{"old_near",OldNear},
					{"new_magic",NewMagic},
					{"new_far",NewFar},
					{"new_near",NewNear},
					{"riseup_time", RiseupTime}
				   ],
	gm_msgwrite:write3(log_pet_alility_riseup,LineKeyValue, directly).

insert_log_pet_skill_riseup(RoleId,RoleName,PetId,PetName,Type,OldSkill,OldSkillLevel,NewSkill,NewSkillLevel,RiseupTime) ->
	% [RoleId,RoleName,PetId,PetName,Type,LockAttr,OldMagic,OldFar,OldNear,NewMagic,NewFar,NewNear] = FieldValue,
	% 进阶时间
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	RiseupTime = Secs+MegaSecs*1000000,
	LineKeyValue = [{"cmd","log_pet_skill_riseup"},
					{"roleid",RoleId},
					{"rolename",RoleName},
					{"petid",PetId},
					{"petname",PetName},
					{"lock_status",Type},
					{"old_skill",OldSkill},
					{"old_skill_level",OldSkillLevel},
					{"new_skill",NewSkill},
					{"new_skill_level",NewSkillLevel},
					{"riseup_time", RiseupTime}
				   ],
	gm_msgwrite:write3(log_pet_skill_riseup,LineKeyValue, directly).

insert_log_activity(RoleId,Type,Camp,Result,Ranking,Honour,Start_time,End_time) ->
% slogger:msg("RoleId~p,Type~p,Camp~p,Result~p,Ranking~p,Honour~p,Start_time~p,End_time~p~n",[RoleId,Type,Camp,Result,Ranking,Honour,Start_time,End_time]),
	LineKeyValue = [{"cmd","log_activity"},
					{"roleid",RoleId},
					{"type",Type},
					{"camp",Camp},
					{"result",Result},
					{"ranking",Ranking},
					{"honour",Honour},
					{"start_time",Start_time},
					{"end_time", End_time}
				   ],
	gm_msgwrite:write3(log_pet_skill_riseup,LineKeyValue, directly).