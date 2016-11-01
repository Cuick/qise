%% Author: Administrator
%% Created: 2011-11-29
%% Description: TODO: Add description to role_handle
-module(role_handle).


-export([process_client_msg/1]).
%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("login_pb.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%


%%
%% API Functions
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 包处理函数结合
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 消息: 更换场景
process_client_msg(#role_map_change_c2s{seqid=SeqId, transid=TransId}) ->
	role_op:touch_teleporter(get(creature_info), get(map_info), SeqId, TransId);


%%消息：用npc切换场景
process_client_msg(#npc_map_change_c2s{npcid =NpcId, id=Id}) ->
	role_op:transport_by_npc(get(creature_info), get(map_info), NpcId, Id);

process_client_msg(#npc_function_c2s{npcid =NpcId}) ->
	role_op:npc_function_list(NpcId);

process_client_msg(#role_change_line_c2s{lineid =Lineid}) ->
	role_op:change_line(Lineid);

%% 消息: 更新快捷栏
process_client_msg(#update_hotbar_c2s{clsid = CLSID, entryid = EntryID, pos = Pos}) ->
	role_op:update_hotbar( Pos, CLSID, EntryID);
	
%%消息：查看掉落	
process_client_msg(#loot_query_c2s{packetid = PacketId}) ->
	role_op:query_loot(PacketId);

%%消息：捡起掉落
process_client_msg(#loot_pick_c2s{packetid = PacketId,slot_num = SlotNum}) ->
	role_op:pick_loot(PacketId,SlotNum);
	
%%摧毁物品
process_client_msg(#destroy_item_c2s{slot = SlotNum})->
	role_op:handle_destroy_item(SlotNum);		

%%拆分物品
process_client_msg(#split_item_c2s{slot = SlotNum,split_num=SplitNum})->
	role_op:split_item(SlotNum,SplitNum);

%%堆叠，交换	
process_client_msg(#swap_item_c2s{srcslot = Srcslot,desslot=Desslot})->
	role_op:swap_item(Srcslot,Desslot);
	
process_client_msg(#enum_shoping_item_c2s{npcid=NpcID}) ->
	shop_op:enum_shoping_item(get(creature_info), NpcID);

process_client_msg(#buy_item_c2s{npcid=NpcID, item_clsid=ItemClsid, count=Count}) ->
	case get(is_in_world) of
		true->
			shop_op:buy_item(get(creature_info), ItemClsid, Count, NpcID);
		_ ->
			nothing		
	end;

process_client_msg(#trade_item_c2s{npc_id=NpcID, item_id=ItemId, count=Count}) ->
	case get(is_in_world) of
		true->
			shop_op:trade_item(get(creature_info), ItemId, Count, NpcID);
		_ ->
			nothing		
	end;

process_client_msg(#sell_item_c2s{npcid=NpcID, slot=Slot}) ->
	shop_op:sell_item(get(creature_info), NpcID, Slot);

process_client_msg(#repair_item_c2s{npcid=NpcID, slot=Slot}) ->
	shop_op:repair_item(get(creature_info), NpcID, Slot);	
	
process_client_msg(#arrange_items_c2s{type=Type}) ->
	item_arrange:items_arrange(Type);

%%装备武器	
process_client_msg(#auto_equip_item_c2s{slot = SrcSlotNum}) ->
	role_op:auto_equip_item(SrcSlotNum);			
	
%%观察
process_client_msg(#inspect_c2s{rolename = RoleName,serverid = ServerId}) ->
	role_op:handle_inspect({ServerId,RoleName});

process_client_msg(#inspect_pet_c2s{rolename = RoleName,serverid = ServerId,petid = PetId}) ->
	role_op:handle_inspect_pet_c2s({ServerId,RoleName,PetId});	

process_client_msg(#role_rename_c2s{slot = Slot,newname = NewRoleName}) ->
	item_role_rename:handle_role_rename(Slot,NewRoleName);

process_client_msg(#guild_rename_c2s{slot = Slot,newname = NewGuildName}) ->
	item_guild_rename:handle_guild_rename(Slot,NewGuildName);
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%							组队操作	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
process_client_msg(#group_apply_c2s{username = UserName}) ->
	group_handle:handle_group_apply_c2s(UserName);
	
process_client_msg(#group_agree_c2s{roleid = Roleid}) ->
	group_handle:handle_group_agree_c2s(Roleid);
	
process_client_msg(#group_invite_c2s{username = UserName}) ->
	group_handle:handle_group_invite_c2s(UserName);
	
process_client_msg(#group_create_c2s{}) ->
	group_handle:handle_group_create_c2s();
	
process_client_msg(#aoi_role_group_c2s{}) ->
	group_handle:handle_aoi_role_group_c2s();
	
process_client_msg(#group_accept_c2s{roleid = Roleid}) ->
	group_handle:handle_group_accept_c2s(Roleid);
	
process_client_msg(#group_decline_c2s{roleid = Roleid}) ->
	group_handle:handle_group_decline_c2s(Roleid);
	
process_client_msg(#group_kickout_c2s{roleid = Roleid}) ->
	group_handle:handle_group_kickout_c2s(Roleid);
	
process_client_msg(#group_setleader_c2s{roleid = Roleid}) ->
	group_handle:handle_group_setleader_c2s(Roleid);
	
process_client_msg(#group_disband_c2s{}) ->
	group_handle:handle_group_disband_c2s();
	
process_client_msg(#group_depart_c2s{}) ->
	group_handle:handle_group_depart_c2s();	
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  技能学习列表
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
process_client_msg(#enum_skill_item_c2s{npcid=NpcID}) ->
	skill_op:enum_skill_item(get(creature_info), NpcID);
	 
%%% 开始学习技能
process_client_msg(#skill_learn_item_c2s{ skillid = Skillid}) ->
	skill_op:skill_learn_item_c2s(Skillid);

%% 一键学习技能
process_client_msg(#skill_auto_learn_item_c2s{skilllist=SkillList}) ->
    skill_op:skill_auto_learn_item_c2s(SkillList);

%% 反馈信息
process_client_msg(#feedback_info_c2s{type=Type, title=Title,content=Message,contactway=ContactWay}) ->
	CurInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(CurInfo),
  	RoleName = get_name_from_roleinfo(CurInfo),
  	feedback_op:submit_feedback(RoleName,RoleID,Type, Title,Message,ContactWay);

%%招募
process_client_msg(#recruite_c2s{instance = Ins, description = Des}) ->
	group_handle:handle_recruite_c2s(Ins,Des);	
	
process_client_msg(#recruite_cancel_c2s{}) ->
	group_handle:handle_recruite_cancel_c2s();
	
process_client_msg(#role_recruite_c2s{instanceid = InstanceId}) ->
	group_handle:role_recruite_c2s(InstanceId);

process_client_msg(#role_recruite_cancel_c2s{}) ->
	group_handle:role_recruite_cancel_c2s();
	
process_client_msg(#recruite_query_c2s{instance = InstanceId}) ->
	instance_op:get_instance_and_group_recruit_info(InstanceId);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    游客模式
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	
process_client_msg(#visitor_rename_c2s{n=NewRoleName}) ->
	RoleInfo = get(creature_info),
	RoleId = get_id_from_roleinfo(RoleInfo),
	OldName = get_name_from_roleinfo(RoleInfo),
	BinaryRoleName = case is_list(NewRoleName) of
						true->list_to_binary(NewRoleName) ;
						false-> NewRoleName
					 end,
	
	case role_db:get_roleid_by_name_rpc(NewRoleName) of
		[]->
			RoleInfoDB = role_db:get_role_info(RoleId),
			case role_db:name_can_change(RoleInfoDB) of
				true->
					RoleInfoInDB1 = role_db:put_name(RoleInfoDB,BinaryRoleName),
					role_db:flush_role(RoleInfoInDB1),
					gm_logger_role:role_rename(RoleId,OldName,NewRoleName,get(client_ip)),
					put(creature_info, set_name_to_roleinfo(RoleInfo, BinaryRoleName )),
					role_op:update_role_info(RoleId ,RoleInfo),
					role_op:self_update_and_broad([{name,BinaryRoleName}]),
					role_pos_util:update_role_pos_rolename(RoleId,BinaryRoleName);
				_->
					slogger:msg("kick_out yanzengyan, in role_handle, visitor_rename_c2s~n"),
					role_op:kick_out(RoleId) %%非法用户 企图改名
			end;
		_N->
			VstMsg = login_pb:encode_visitor_rename_failed_s2c(
						#visitor_rename_failed_s2c{reason=?ERR_CODE_ROLENAME_EXISTED}),
			role_op:send_data_to_gate(VstMsg)
	end;
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%         用户设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
process_client_msg(#query_player_option_c2s{key=KeyList}) ->
	KV = role_private_option:get(KeyList),
	Msg = login_pb:encode_query_player_option_s2c(#query_player_option_s2c{kv=KV}),
	role_op:send_data_to_gate(Msg);
	
	
process_client_msg(#replace_player_option_c2s{kv=KeyValueList}) ->
	role_private_option:replace(KeyValueList);
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 日志回传 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
process_client_msg(#info_back_c2s{type = Type,info = Info,version=Version}) ->
	feedback_op:info_back(Type,Info,Version);
		

		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 抽奖请求
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
process_client_msg(#lottery_clickslot_c2s{clickslot=ClickSlot}) ->
	lottery_op:on_playerlottery(ClickSlot);
		
process_client_msg(#lottery_querystatus_c2s{}) ->
	lottery_op:on_querylottery();
	
%%挂机start_block_training_c2s end_block_training_c2s
process_client_msg(#end_block_training_c2s{}) ->
	block_training_op:end_training();

process_client_msg(#query_time_c2s{}) ->
	role_op:async_time_with_clinet();
	
process_client_msg(#identify_verify_c2s{truename=TrueName,card=Card})->
	RoleId = get(roleid),
	RoleProc = role_op:make_role_proc_name(RoleId),	
	case env:get(id_secret_mod,undefined) of
		undefined-> nothing;
		Mod-> Mod:verify_rpc(TrueName,get(account_id),Card,RoleProc)
	end;
	
process_client_msg(#npc_storage_items_c2s{npcid = NpcId}) ->
	storage_op:do_enum(NpcId);
	
process_client_msg(#npc_swap_item_c2s{npcid = NpcId,srcslot = SrcSlot,desslot = DesSlot}) ->	
	storage_op:do_swap_item(NpcId,SrcSlot,DesSlot);

process_client_msg(#fly_shoes_c2s{mapid = MapId,posx = Posx,posy = Posy,slot = Slot}) ->	
	item_fly_shoes:handle_fly_shoes(MapId,Posx,Posy,Slot);
	
process_client_msg(#use_target_item_c2s{targetid = Target,slot = Slot}) ->
	role_op:handle_use_target_item_c2s(Target,Slot);

process_client_msg(#spiritspower_reset_c2s{})->
	spiritspower_op:reset();

process_client_msg(#icon_show_list_c2s{show_list = ShowList}) ->
	role_op:change_icon_show(ShowList);

process_client_msg(#query_travel_server_status_c2s{}) ->
	role_op:query_travel_server_status();
	
process_client_msg(Message)->
	slogger:msg("~p unknown message ~p ~n",[?MODULE,Message]).

%%
%% Local Functions
%%

