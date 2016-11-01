-module(guild_packet).

-compile(export_all).
-export([
		process_message/1,	
		process_proc_message/1,		
		handle/2,
		encode_guild_opt_result_s2c/1,
		encode_guild_info_s2c/9,
		encode_guild_member_update_s2c/1,
		encode_guild_member_add_s2c/1,
		encode_guild_member_invite_s2c/4,
		encode_guild_member_decline_s2c/1,
		encode_guild_member_delete_s2c/2,
		encode_guild_destroy_s2c/1,
		encode_guild_base_update_s2c/7,
		encode_guild_facilities_update_s2c/1,
		encode_guild_recruite_info_s2c/1,
		encode_guild_mastercall_success_s2c/0,
		encode_guild_mastercall_s2c/6,
		encode_sync_bonfire_time_s2c/1,
		make_roleinfo/1,
		make_facilityinfo/1,
		make_recruiteinfo/11
		]).
%%
%% Include files
%%

-include("login_pb.hrl").
-include("data_struct.hrl").	


handle(Message,RolePid)->
	RolePid ! {guild_message,Message}.

process_message(#guild_create_c2s{name=Name,type=Type}) ->	
	guild_handle:handle_guild_create_c2s(Name,Type);
	
process_message(#guild_disband_c2s{}) ->	
	guild_handle:handle_guild_disband_c2s();
	
process_message(#guild_member_invite_c2s{name=Name}) ->	
	guild_handle:handle_guild_member_invite_c2s(Name);
	
process_message(#guild_member_decline_c2s{roleid=Roleid}) ->	
	guild_handle:handle_guild_member_decline_c2s(Roleid);
	
process_message(#guild_member_accept_c2s{roleid=Roleid}) ->	
	guild_handle:handle_guild_member_accept_c2s(Roleid);
	
process_message(#guild_member_apply_c2s{guildlid=Guildlid,guildhid = Guildhid}) ->	
	guild_handle:handle_guild_member_apply_c2s({Guildlid,Guildhid});
	
process_message(#guild_member_depart_c2s{}) ->	
	guild_handle:handle_guild_member_depart_c2s();
	
process_message(#guild_member_kickout_c2s{roleid=Roleid})->	
	guild_handle:handle_guild_member_kickout_c2s(Roleid);
	
process_message(#guild_set_leader_c2s{roleid=Roleid})->	
	guild_handle:handle_guild_set_leader_c2s(Roleid);
	
process_message(#guild_member_promotion_c2s{roleid=Roleid})->
	guild_handle:handle_guild_member_promotion_c2s(Roleid);
	
process_message(#guild_member_demotion_c2s{roleid=Roleid})->	
	guild_handle:handle_guild_member_demotion_c2s(Roleid);
	 
process_message(#guild_log_normal_c2s{type = Type}) ->	
	guild_handle:handle_guild_log_normal_c2s(Type);
	 
process_message(#guild_log_event_c2s{}) ->	
	guild_handle:handle_guild_log_event_c2s();
	 
process_message(#guild_notice_modify_c2s{notice = Notice}) ->	
	guild_handle:handle_guild_notice_modify_c2s(Notice);
	 
process_message(#guild_facilities_accede_rules_c2s{facilityid=FacilityId,requirevalue = RequiredValue}) ->	
	guild_handle:handle_guild_facilities_accede_rules_c2s(FacilityId,RequiredValue);
	 	
process_message(#guild_facilities_upgrade_c2s{facilityid=FacilityId}) ->	
	guild_handle:handle_guild_facilities_upgrade_c2s(FacilityId);
	 
process_message(#guild_facilities_speed_up_c2s{facilityid=FacilityId,slotnum =SlotNum}) ->	
	guild_handle:handle_guild_facilities_speed_up_c2s(FacilityId,SlotNum);
	 
process_message(#guild_rewards_c2s{}) ->	
	guild_handle:handle_guild_rewards_c2s();
	 
process_message(#guild_recruite_info_c2s{}) ->	
	guild_handle:handle_guild_recruite_info_c2s();

process_message(#join_guild_instance_c2s{type=Type}) ->	
	guild_instance:on_join_instance(Type);
 
process_message(#get_guild_monster_info_c2s{})->
	guild_monster:get_guild_monster_info();

process_message(#upgrade_guild_monster_c2s{monsterid = MonsterId}) ->	
	guild_monster:upgrade_guild_monster(MonsterId);

process_message(#call_guild_monster_c2s{monsterid = MonsterId}) ->	
	guild_monster:call_guild_monster(MonsterId);
 
process_message(#callback_guild_monster_c2s{monsterid = MonsterId}) ->	
	guild_monster:callback_guild_monster(MonsterId); 

process_message(#change_smith_need_contribution_c2s{contribution = Contribution}) ->	
	guild_facility:change_smith_need_contribution(Contribution);
	  
process_message(#guild_member_contribute_c2s{moneytype=Moneytype,moneycount = Moneycount}) ->	
	guild_handle:handle_guild_member_contribute_c2s(Moneytype,Moneycount);
%%			
process_message(#guild_member_pos_c2s{})->
	guild_util:get_members_pos();
	 
process_message(#guild_clear_nickname_c2s{roleid = RoleId})->
	guild_op:clear_nickname(RoleId);													
	
process_message(#guild_get_application_c2s{})->
	guild_handle:handle_guild_get_application();
	
process_message(#guild_application_op_c2s{roleid = RoleId,reject = Reject})->
	guild_handle:handle_guild_application_op(RoleId,Reject);
	 
process_message(#guild_change_nickname_c2s{roleid = RoleId,nickname = NickName})->
	guild_handle:handle_guild_change_nickname(RoleId,NickName);
	 	
process_message(#guild_change_chatandvoicegroup_c2s{chatgroup = ChatGroup,voicegroup = VoiceGroup})->
	guild_handle:handle_guild_change_chatandvoicegroup(ChatGroup,VoiceGroup);
	 						
%% process_message(#guild_get_shop_item_c2s{shoptype = ShopType})->
%% 	guild_handle:handle_guild_get_shop_item(ShopType);
	 		
%% process_message(#guild_shop_buy_item_c2s{shoptype = ShopType,itemid = ItemId,id = Id,count = Count})->
%% 	guild_handle:handle_guild_shop_buy_item(ShopType,Id,ItemId,Count);
	 	
process_message(#guild_get_treasure_item_c2s{treasuretype = ShopType})->
	guild_handle:handle_guild_get_treasure_item(ShopType);
	 		
process_message(#guild_treasure_buy_item_c2s{treasuretype = ShopType,itemid = ItemId,id = Id,count = Count})->
	guild_handle:handle_guild_treasure_buy_item(ShopType,Id,ItemId,Count);
	 	
process_message(#guild_treasure_set_price_c2s{treasuretype = ShopType,id = Id,price = Price,itemid = ItemId})->
	guild_handle:handle_guild_treasure_set_price(ShopType,Id,Price,ItemId);
	 	
process_message(#publish_guild_quest_c2s{})->
	guild_handle:handle_publish_guild_quest();
	 	
process_message(#get_guild_notice_c2s{guildlid=Guildlid,guildhid = Guildhid})->	
	guild_handle:handle_get_guild_notice({Guildlid,Guildhid});

process_message(#guild_mastercall_accept_c2s{})->
	guild_handle:handle_mastercall_accept_c2s();

process_message(#guild_contribute_log_c2s{})->
	guild_handle:handle_guild_contribute_log_c2s();

process_message(#guild_impeach_c2s{notice = Notice})->
	guild_handle:handle_guild_impeach_c2s(Notice);

process_message(#guild_impeach_info_c2s{})->
	guild_handle:handle_guild_impeach_info_c2s();

process_message(#guild_impeach_vote_c2s{type = Type})->
	guild_handle:handle_guild_impeach_vote_c2s(Type);

process_message(#change_guild_battle_limit_c2s{fightforce = FightForce})->
	guild_op:change_guild_battle_limit(FightForce);

process_message({guild_instance_start})->
	guild_instance:on_activity_start();

process_message({guild_instance_end})->
	guild_instance:on_activity_end();

process_message(#guild_dice_c2s{}) ->
    guild_op:guild_dice();

process_message(_Message)->
	slogger:msg("~p process_message unknown msg ~p ~n",[?MODULE,_Message]).

process_proc_message({update_guild_info,Info}) ->	
	guild_handle:handle_update_guild_info(Info);	
	
process_proc_message({guild_add_member,NewComerId}) ->	
	guild_handle:handle_add_member(NewComerId);			

process_proc_message({guild_delete_member,KickId}) ->	
	guild_handle:handle_delete_member(KickId);	

process_proc_message({guild_destroy}) ->	
	guild_handle:handle_guild_destroy();
		
process_proc_message({guild_invite_you,{RemoteRoleInfo,GuildId,GuildName}}) ->	
	guild_handle:handle_guild_invite_you(RemoteRoleInfo,GuildId,GuildName);		
		
process_proc_message({update_facility_info,{Facilityid,FaciltiyInfo}}) ->	
	guild_handle:handle_update_facility_info(Facilityid,FaciltiyInfo);

process_proc_message({update_guild_base_info,BaseInfo}) ->	
	guild_handle:handle_update_guild_base_info(BaseInfo);	
	
process_proc_message({guild_mastercall,CallsInfo})->
	guild_handle:handle_guild_mastercall(CallsInfo);

process_proc_message(_Message)->
	slogger:msg("~p handle_proc_message unknown msg ~p ~n",[?MODULE,_Message]).

encode_guild_opt_result_s2c(Errno)->
	login_pb:encode_guild_opt_result_s2c(#guild_opt_result_s2c{errno= Errno}).

encode_guild_info_s2c(Guildname, Level, Silver, Gold, Notice, Roleinfos, Facinfos,ChatGroup,VoiceGroup)->
	login_pb:encode_guild_info_s2c(#guild_info_s2c{ 
									guildname =Guildname,
									level = Level,
									silver = Silver, 
									gold = Gold, 
									notice = Notice, 
									roleinfos = Roleinfos, 
									facinfos = Facinfos,
									chatgroup = ChatGroup,
									voicegroup = VoiceGroup}).
									
encode_guild_member_update_s2c(RoleInfo)->
	login_pb:encode_guild_member_update_s2c(#guild_member_update_s2c{
								roleinfo = RoleInfo}). 	
								
encode_guild_member_add_s2c(RoleInfo)->
	login_pb:encode_guild_member_add_s2c(#guild_member_add_s2c{
								roleinfo = RoleInfo}).		
								
encode_guild_member_invite_s2c(Roleid,RoleName,{GuildlId,GuildhId},GuildName)->
	login_pb:encode_guild_member_invite_s2c(#guild_member_invite_s2c{
									roleid = Roleid,
									rolename =RoleName,
									guildlid = GuildlId,
									guildhid = GuildhId,
									guildname = GuildName 
						}).							

encode_guild_member_decline_s2c(RoleName)->
	login_pb:encode_guild_member_decline_s2c(#guild_member_decline_s2c{
								rolename = RoleName 
				}).					
																							
encode_guild_member_delete_s2c(KickRoleId,Reason)->
	login_pb:encode_guild_member_delete_s2c(#guild_member_delete_s2c{
								roleid = KickRoleId,reason = Reason 
				}).

encode_guild_destroy_s2c(Reason)->
	login_pb:encode_guild_destroy_s2c(#guild_destroy_s2c{reason = Reason}).
	
encode_guild_base_update_s2c(Name,Level,Silver,Gold,Notice,ChatGroup,VoiceGroup)->
	login_pb:encode_guild_base_update_s2c(#guild_base_update_s2c{
								guildname= Name,
								level = Level,
								silver = Silver,
								gold = Gold,
								notice = Notice,
								chatgroup = ChatGroup,
								voicegroup = VoiceGroup
							}).	
							
encode_guild_facilities_update_s2c(FicilityInfo)->
	login_pb:encode_guild_facilities_update_s2c(#guild_facilities_update_s2c{facinfo=FicilityInfo}). 
	
encode_guild_recruite_info_s2c(FicilityInfo)->
	login_pb:encode_guild_recruite_info_s2c(#guild_recruite_info_s2c{recinfos=FicilityInfo}).	
							
encode_guild_get_application_s2c(RoleList)->
	login_pb:encode_guild_get_application_s2c(#guild_get_application_s2c{roles=RoleList}).

encode_guild_log_normal_s2c(LogList)->
	login_pb:encode_guild_log_normal_s2c(#guild_log_normal_s2c{logs=LogList}).

encode_guild_update_log_s2c(Log)->
	login_pb:encode_guild_update_log_s2c(#guild_update_log_s2c{log=Log}).

encode_guild_get_shop_item_s2c(ShopType,ItemList)->
	login_pb:encode_guild_get_shop_item_s2c(#guild_get_shop_item_s2c{shoptype = ShopType,itemlist = ItemList}).

encode_guild_get_treasure_item_s2c(ShopType,ItemList)->
	login_pb:encode_guild_get_treasure_item_s2c(#guild_get_treasure_item_s2c{treasuretype = ShopType,itemlist = ItemList}).

encode_guild_treasure_update_item_s2c(ShopType,Item)->
	login_pb:encode_guild_treasure_update_item_s2c(#guild_treasure_update_item_s2c{treasuretype = ShopType,item = Item}).

encode_guild_shop_update_item_s2c(ShopType,Item)->
	%%io:format("guild_shop_update_item_s2c ~p ~n",[Item]),
	login_pb:encode_guild_shop_update_item_s2c(#guild_shop_update_item_s2c{shoptype = ShopType,item = Item}).

encode_update_guild_quest_info_s2c(LeftTime)->
	login_pb:encode_update_guild_quest_info_s2c(#update_guild_quest_info_s2c{lefttime = LeftTime}).

encode_update_guild_apply_state_s2c({GuildLId,GuildHId},ApplyFlag)->
	login_pb:encode_update_guild_apply_state_s2c(#update_guild_apply_state_s2c{guildlid = GuildLId,guildhid = GuildHId,applyflag = ApplyFlag}).

encode_update_guild_update_apply_info_s2c(Role,Type)->
	login_pb:encode_update_guild_update_apply_info_s2c(#update_guild_update_apply_info_s2c{role = Role,type = Type}).

encode_guild_update_apply_result_s2c({GuildLId,GuildHId},Result)->
	login_pb:encode_guild_update_apply_result_s2c(#guild_update_apply_result_s2c{guildlid = GuildLId,guildhid = GuildHId,result = Result}).
	
encode_send_guild_notice_s2c({GuildLId,GuildHId},Notice)->
	login_pb:encode_send_guild_notice_s2c(#send_guild_notice_s2c{guildlid = GuildLId,guildhid = GuildHId,notice = Notice}).

encode_guild_mastercall_s2c(Posting,Name,LineId,MapId,{PosX,PosY},Reason)->
	login_pb:encode_guild_mastercall_s2c(#guild_mastercall_s2c{posting = Posting,name = Name,lineid = LineId
										,mapid = MapId,posx = PosX,posy = PosY,reasonid = Reason}).
encode_guild_mastercall_success_s2c()->
	login_pb:encode_guild_mastercall_success_s2c(#guild_mastercall_success_s2c{}).

encode_guild_bonfire_start_s2c(LeftTime)->
	login_pb:encode_guild_bonfire_start_s2c(#guild_bonfire_start_s2c{lefttime=LeftTime}).

encode_sync_bonfire_time_s2c(LeftTime)->
	login_pb:encode_sync_bonfire_time_s2c(#sync_bonfire_time_s2c{lefttime=LeftTime}). 

make_roleinfo(MemberInfoList)->
	make_roleinfo(MemberInfoList, []).
%	make_roleinfo({Roleid, Rolename, Gender,Rolelevel, Class, Posting, Contribution, TContribution,OnlineValue,NickName,FightForce});

make_roleinfo([], GList) ->
	GList;
make_roleinfo([H|T], GList)->
	{Roleid, Rolename, Gender,Rolelevel, Class, Posting, Contribution, TContribution, OnlineValue, NickName, _, _, FightForce} = H,
%%	calendar:time_difference( Datetime1,calendar:now_to_local_time(now())).
	if
		is_integer(OnlineValue)->
			Online = -1;
		true->
			Online = erlang:trunc(timer:now_diff(now(),OnlineValue)/(1000*1000))
	end,
	make_roleinfo(T, GList ++ [#g{roleid = Roleid, rolename = Rolename, rolelevel = Rolelevel, gender = Gender, classtype = Class, posting = Posting, contribution = Contribution, tcontribution = TContribution, online = Online, nickname = NickName, fightforce = FightForce}]).
					
make_facilityinfo({Facilityid,FaLevel,Upgrade_Start_Time,Upgrade_Full_Time,Required_Contribution_Or_Level,SmithNC})->
	if
		Upgrade_Start_Time =:= 0->
			LeftTime = 0; 
		true->
			Left = erlang:trunc(Upgrade_Full_Time - timer:now_diff(now(),Upgrade_Start_Time)/(1000*1000)),
			LeftTime  = erlang:max(Left,0) 	%%秒 
	end,
	#f{
					id = Facilityid,
					level = FaLevel,
					lefttime = LeftTime,
					fulltime = Upgrade_Full_Time,
					requirevalue = Required_Contribution_Or_Level,
					contribution = SmithNC
					}.	
		
make_recruiteinfo({GuildLid,GuildHid},Guildname, Level, Membernum,Formalnum,Leader, Restrict, Facslevel,ApplyFlag,{Year,Month,Day},SortIndex)->
		#gr{
						guildlid = GuildLid,
						guildhid = GuildHid,
						guildname = Guildname, 
						level = Level, 
						membernum = Membernum,
						formalnum = Formalnum, 
						leader = Leader, 
						restrict = Restrict, 
						facslevel = Facslevel,
						applyflag = ApplyFlag,
						createyear = Year,
						createmonth	= Month,
						createday = Day,
						sort = SortIndex
						}.

make_guildlog(LogType,LogId,KeyStrList,{{Year,Month,Day},{H,M,S}})->
		#guildlog{
						type = LogType,
						id = LogId,
						keystr = KeyStrList,				
						year = Year,
						month = Month,
						day = Day,
						hour = H,
						min = M,
						sec = S			
				}.

make_guildshopitem(Id,ShowIndex,RealPrice,BuyNum)->
		#gsi{
					id = Id,
					showindex = ShowIndex,
					realprice =  RealPrice,
					buynum = BuyNum
			}.

make_guildtreasureitem(Id,ShowIndex,RealPrice,BuyNum)->
		#gti{
					id = Id,
					showindex = ShowIndex,
					realprice =  RealPrice,
					buynum = BuyNum
			}.

get_guildshopitemshowindex(ShopItem)->
	element(#gsi.showindex,ShopItem).

get_guildtreasureitemshowindex(ShopItem)->
	element(#gti.showindex,ShopItem).

make_gmp(RoleId,LineId,MapId)->
	#gmp{roleid = RoleId,lineid = LineId,mapid = MapId}.

encode_guild_member_pos_s2c(MembersPosInfo)->
	login_pb:encode_guild_member_pos_s2c(#guild_member_pos_s2c{posinfo = MembersPosInfo}).
	


make_rcs(RoleId,TodayCount,TotalCount)->
	#rcs{roleid = RoleId,
		 today_count = TodayCount,
		 total_count = TotalCount }.

encode_guild_contribute_log_s2c(RolesInfo)->
	login_pb:encode_guild_contribute_log_s2c(#guild_contribute_log_s2c{roles = RolesInfo}).

encode_guild_impeach_result_s2c(Result)->
	login_pb:encode_guild_impeach_result_s2c(#guild_impeach_result_s2c{result = Result}).

encode_guild_impeach_info_s2c(RoleId,Notice,Support,Opposite,Vote,LeftTime_S)->
	login_pb:encode_guild_impeach_info_s2c(
	  	#guild_impeach_info_s2c{
								roleid = RoleId,
								notice = Notice,
								support = Support,
								opposite = Opposite,
								vote = Vote,
								lefttime_s = LeftTime_S}).

encode_guild_impeach_stop_s2c()->
	login_pb:encode_guild_impeach_stop_s2c(#guild_impeach_stop_s2c{}).

encode_guild_join_lefttime_s2c(LeftTime)->
	login_pb:encode_guild_join_lefttime_s2c(#guild_join_lefttime_s2c{lefttime = LeftTime}).

encode_get_guild_monster_info_s2c(MonsterInfo,LeftTimes,Call_CD)->  
	login_pb:encode_get_guild_monster_info_s2c(#get_guild_monster_info_s2c{monster = MonsterInfo,lefttimes = LeftTimes,call_cd = Call_CD}).

encode_guild_monster_opt_result_s2c(Result)->
	login_pb:encode_guild_monster_opt_result_s2c(#guild_monster_opt_result_s2c{result = Result}).

make_guild_monster_param(MonsterList)->
	lists:map(fun({MonsterId,State})->
					  #gm{monsterid=MonsterId,state=State}
			  end,MonsterList). 
													
encode_change_guild_right_limit_s2c(SmithLimit,BattleLimit)->
	login_pb:encode_change_guild_right_limit_s2c(#change_guild_right_limit_s2c{smith=SmithLimit,battle=BattleLimit}).

encode_guild_have_guildbattle_right_s2c(Right)->
	login_pb:encode_guild_have_guildbattle_right_s2c(#guild_have_guildbattle_right_s2c{right=Right}).  

encode_guild_bonfire_end_s2c()-> 
	login_pb:encode_guild_bonfire_end_s2c(#guild_bonfire_end_s2c{}).

encode_guild_dice_s2c(RoleId, Rand) ->
    login_pb:encode_guild_dice_s2c(#guild_dice_s2c{roleid=RoleId, rand=Rand}).
