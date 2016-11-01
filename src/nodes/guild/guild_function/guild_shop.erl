%% Author: Administrator
%% Created: 2011-4-16
%% Description: TODO: Add description to guild_shop
-module(guild_shop).

%%
%% Include files
%%
-include("error_msg.hrl").
-include("guild_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% member_shop_list {{guildid,memberid,id},guildid,member,count,time}
%%

%%
%% API Functions
%%
init()->
	ets:new(member_shop_list,[set,protected, named_table]),
	%%加载数据库
	AllMemberInfo = guild_spawn_db:get_allmembershopinfo(),
	lists:foreach(fun(Info)->		 
				Key = guild_spawn_db:get_membershopinfo_key(Info),
				GuildId = guild_spawn_db:get_membershopinfo_guildid(Info),
				MemberId = guild_spawn_db:get_membershopinfo_memberid(Info),
				Count = guild_spawn_db:get_membershopinfo_count(Info),
				Time = guild_spawn_db:get_membershopinfo_time(Info),
				update_member_shop_info({Key,GuildId,MemberId,Count,Time})	
			end,AllMemberInfo).

update_member_shop_info(Info)->
	%%io:format("update_member_shop_info ~p ~n",[Info]),
	ets:insert(member_shop_list,Info).

buy_item(RoleId,GuildId,ItemType,Id,Count,RoleMoney)->
	FacilityInfo = guild_facility_op:get_facility_info(GuildId,?GUILD_FACILITY_SHOP),
	Level = guild_facility_op:get_by_facility_item(level,FacilityInfo),
	case guild_proto_db:get_guild_shop_info(Level) of
		[]->
			error;	
		Info->
			case guild_proto_db:get_guild_shopitem_info(Id) of
				[]->
					error;
				ItemInfo->
					case guild_member_op:get_member_info(RoleId) of
						[]->
							slogger:msg("guild buy item member ~p not exist guild ~p \n",[RoleId,GuildId]),
							error;
						MemberInfo->
							Now = timer_center:get_correct_now(),																
							LimitNum = guild_proto_db:get_guild_shopitem_limitnum(ItemInfo),
							Contribution = guild_proto_db:get_guild_shopitem_contribution(ItemInfo),
							LimitLevel = guild_proto_db:get_guild_shopitem_minlevel(ItemInfo),
							RoleLevel = guild_manager_op:get_by_member_item(level,MemberInfo),
							LevelCheck  = (RoleLevel >= LimitLevel),
							DisCount = guild_proto_db:get_guild_shopitem_discount(ItemInfo),
							{MoneyType,MoneyCount} = DisCount,
							TotalMoneyCount = MoneyCount*Count, 
							RealPrice = {MoneyType,TotalMoneyCount},
							MoneyCheck = 
								case lists:keyfind(MoneyType,1,RoleMoney) of
									false->
										false;
									{_,CurMoney}->
										CurMoney >= TotalMoneyCount;
									_->
										false
								end,
							CurContribution = guild_member_op:get_by_member_item(contribution,MemberInfo),
							ContributionCheck = (CurContribution >= Contribution*Count),											
							CurNum = get_item_buy_count_today({GuildId,RoleId,Id},Now),
							NewNum = CurNum + Count,
							LimitNumCheck =  ((NewNum =< LimitNum) or (LimitNum < 0)),	%%负数为不限制
							if
								not LevelCheck->%%等级不足
									ErrMsg = guild_packet:encode_guild_opt_result_s2c(?ERROR_LESS_LEVEL),
									role_pos_util:send_to_role_clinet(RoleId,ErrMsg),
									error_less_level;
								not MoneyCheck-> %%元宝不足
									ErrMsg = guild_packet:encode_guild_opt_result_s2c(?ERROR_LESS_GOLD),
									role_pos_util:send_to_role_clinet(RoleId,ErrMsg),
									error_less_gold;
								not ContributionCheck-> %%帮贡不足
									ErrMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LESS_CONTRIBUTION),
									role_pos_util:send_to_role_clinet(RoleId,ErrMsg),
									error_less_contribution;
								not LimitNumCheck -> %%超过限购
									ErrMsg = guild_packet:encode_guild_opt_result_s2c(?GUILD_ERRNO_LIMITNUM),
									role_pos_util:send_to_role_clinet(RoleId,ErrMsg),
									error_limitnum;
								true->
									%%扣除帮贡
									NewContribution = CurContribution - Contribution*Count,
									NewMemberInfo = guild_member_op:set_by_member_item(contribution,NewContribution,MemberInfo),
									guild_member_op:update_member_info(NewMemberInfo),	
									gm_logger_role:role_guild_contribution_change(RoleId,GuildId,NewContribution - CurContribution,guild_shop),	
									guild_spawn_db:set_member_contribution(RoleId,NewContribution),
									%%发送给进程
									guild_manager_op:send_base_info_update(RoleId,GuildId),
									%%广播贡献度变化给客户端
									Message = guild_packet:encode_guild_member_update_s2c(guild_packet:make_roleinfo([NewMemberInfo])),
									guild_manager_op:broad_cast_to_guild_client(GuildId,Message ),
									%%更新消费记录
									update_member_shop_info({{GuildId,RoleId,Id},GuildId,RoleId,NewNum,Now}),
									%%更新数据库
									guild_spawn_db:add_info_to_membershopinfo(GuildId,RoleId,Id,NewNum,Now),
									
									%%更新帮会日志
									%%
									MemberName = guild_member_op:get_member_name(RoleId),
									MemberPosting = guild_member_op:get_member_posting(RoleId),
									ItemId = guild_proto_db:get_guild_shopitem_itemid(ItemInfo),
									ItemTempInfo = item_template_db:get_item_templateinfo(ItemId),
									ItemName = item_template_db:get_name(ItemTempInfo),
									LogInfo = {shop,MemberName,MemberPosting,MoneyCount,ItemName},				
									guild_manager_op:add_log(GuildId,?GUILD_LOG_MALL,LogInfo),
									%%gm日志
									gm_logger_role:role_buy_guild_mall_item(RoleId,ItemId,MoneyCount,Count),
									%%
									%%发送限购信息
									%%
									ShowIndex = guild_proto_db:get_guild_shopitem_showindex(ItemInfo),
									CurItem = guild_packet:make_guildshopitem(Id,ShowIndex,MoneyCount,NewNum),
									BuyNumMsg = guild_packet:encode_guild_shop_update_item_s2c(ItemType,CurItem),
									role_pos_util:send_to_role_clinet(RoleId,BuyNumMsg), 
									{ok,RealPrice,ItemId}
							end
					end									 	 				
			end
	end.
	

delete_guild(GuildId)->
	ets:match_delete(member_shop_list,{'_',GuildId,'_','_','_'}),
	guild_spawn_db:delete_member_shopinfo_by_guild(GuildId).

delete_member(MemberId)->
	ets:match_delete(member_shop_list,{'_','_',MemberId,'_','_'}),
	guild_spawn_db:delete_member_shopinfo(MemberId).
	
%%
%% Local Functions
%%

get_member_shop_info({GuildId,MemberId,Id})->
	case ets:lookup(member_shop_list, {GuildId,MemberId,Id}) of
		[]-> [];
		[ShopInfoRecord]->
			ShopInfoRecord
	end.

%%
%%获取当天某商品的购买信息
%%

get_item_buy_count_today({GuildId,MemberId,Id},Now)->
	case get_member_shop_info({GuildId,MemberId,Id}) of
		[]->
			%%io:format("get_item_buy_count_today ~p  not find~n",[{GuildId,MemberId,Id}]),
			0;
		{_,_,_,Count,Time}->
			{Today,_} = calendar:now_to_local_time(Now),
			{OtherDay,_} = calendar:now_to_local_time(Time),
			if
				Today =:= OtherDay ->
					Count;
				true->
					0
			end;
		Other->
			%%io:format("get_item_buy_count_today ~p  ~p ~n",[{GuildId,MemberId,Id},Other]),
			0
	end.
