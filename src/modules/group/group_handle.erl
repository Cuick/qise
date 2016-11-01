-module(group_handle).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
%%TODO:direct_send

handle_group_create_c2s()->
	IsHasGroup = group_op:has_group(),
	Id = get(roleid),
	Name = get_name_from_roleinfo(get(creature_info)),
	if
		IsHasGroup-> Errno = ?ERR_GROUP_ALREADY_IN_GROUP;
		true-> Errno = []
	end,
	case Errno of
		[]->
			group_op:create(),
			group_op:update_group_list_to_client();
		_ ->
			Message = role_packet:encode_group_cmd_result_s2c(Id,Name,Errno),
			role_op:send_data_to_gate(Message)
	end.

%%自身没有队伍,申请组成队伍(可能是邀请组成或者申请入队)TODO:判断是否是字符串
handle_group_apply_c2s(Name)->
	case travel_battle_util:is_travel_battle_server() of
		false ->
			RoleId = get(roleid),
			RoleName = get_name_from_roleinfo(get(creature_info)),
			case role_pos_util:where_is_role(Name) of
				[]->								%%此人未在线
					Errno = ?ERR_GROUP_CANNOT_FIND_ROLE;
				RolePos->
					Applyid = role_pos_db:get_role_id(RolePos),
					Errno = [],
					HasGroup = group_op:has_group(),
					IsCheckin =  (RoleId =/= Applyid) and (not HasGroup),
					case IsCheckin of
						true->
							RemoteRoleInfo = make_roleinfo_for_othernode(get(creature_info)),
							role_pos_util:send_to_role_by_pos(RolePos,{group_apply_you,RemoteRoleInfo});
						false->
							slogger:msg("handle_group_apply_c2s IsCheckin error~n")	
					end		
			end,
			if 
				Errno =/= []->
					Message = role_packet:encode_group_cmd_result_s2c(RoleId,RoleName,Errno),
					role_op:send_data_to_gate(Message);
				true->
					nothing
			end;
		true ->
			Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_INVALID_OPERATION),
			role_op:send_data_to_gate(Msg)
	end.

%%队长同意他加入
handle_group_agree_c2s(AgreeRoleid)->
	RoleName = get_name_from_roleinfo(get(creature_info)),
	Roleid = get(roleid),	
	case group_op:has_been_inveited_by(AgreeRoleid) of
		true->
			group_op:remove_from_inviteinfo(AgreeRoleid),
			case role_pos_util:where_is_role(AgreeRoleid) of
				[]->			%%此人未在线
					Errno = ?ERR_GROUP_CANNOT_FIND_ROLE;
				RolePos->
						AgreeRoleid = role_pos_db:get_role_id(RolePos),
						OtherNode = role_pos_db:get_role_mapnode(RolePos),
						OtherInfo = role_manager:get_role_remoteinfo_by_node(OtherNode,AgreeRoleid),
						IsLeader = group_op:get_leader() =:= Roleid,
						IsHasGroup = group_op:has_group(),
						IsFull  = group_op:is_full(),
					if 	
						OtherInfo =:= undefined -> Errno = ?ERR_GROUP_CANNOT_FIND_ROLE; 						
						not IsHasGroup -> Errno = ?ERR_GROUP_YOU_ARENT_IN_A_GROUP ;						
						IsFull -> Errno = ?ERR_GROUP_IS_FULL ;
						not IsLeader -> Errno = ?ERR_GROUP_YOU_ARE_NOT_LEADER ;
						true->
							Errno = [],
							handle_insert_new_teamer(OtherInfo)
					end
			end,
			if 
				Errno =/= []->
					Message = role_packet:encode_group_cmd_result_s2c(Roleid,RoleName,Errno),
					role_op:send_data_to_gate(Message);
				true->
					nothing
			end;
		false->
			nothing
	end.
	
%%自身有队伍,邀请别人
handle_group_invite_c2s(Name)->
	RoleId = get(roleid),
	RoleName= get_name_from_roleinfo(get(creature_info)),
	case role_pos_util:where_is_role(Name) of
		[]->								%%此人未在线
			Errno = ?ERR_GROUP_CANNOT_FIND_ROLE;
		RolePos->
			InviterId = role_pos_db:get_role_id(RolePos),
			IsCheckin =  (RoleId =/= InviterId),		
			case IsCheckin of
				true ->
					HasGroup = group_op:has_group(),
					IsFull = group_op:is_full(),
					if
						not HasGroup ->
							Errno = ?ERR_GROUP_YOU_ARENT_IN_A_GROUP ;
						IsFull ->
							Errno = ?ERR_GROUP_IS_FULL;									
						true->
							Errno =[]
					end;
				false ->
					slogger:msg("handle_group_invite_c2s IsCheckin error~n"),
					Errno = ?ERR_GROUP_UNKNOW 
			end,
			if
				Errno =:= []->
					RemoteRoleInfo = make_roleinfo_for_othernode(get(creature_info)),
					role_pos_util:send_to_role_by_pos(RolePos,{group_invite_you,RemoteRoleInfo});
				true -> 
					nothing
			end
	end,
	if 
		Errno =/= []->
			Message = role_packet:encode_group_cmd_result_s2c(RoleId,RoleName,Errno),
			role_op:send_data_to_gate(Message);	
		true -> 
			nothing
	end.		

%%接受了邀请
handle_group_accept_c2s(InviterId)->
	Hasgroup = group_op:has_group(),
	HasbeenInvite = group_op:has_been_inveited_by(InviterId),
	group_op:remove_from_inviteinfo(InviterId),
	if 
		(not Hasgroup) and (HasbeenInvite) ->
			RemoteRoleInfo = make_roleinfo_for_othernode(get(creature_info)),
			role_pos_util:send_to_role(InviterId,{group_accept_you,RemoteRoleInfo});	%%发给邀请人同意加入
		true ->
			slogger:msg("handle_group_accept_c2s error Hasgroup:~p  HasbeenInvite:~p~n",[Hasgroup,HasbeenInvite])
	end.	

handle_group_depart_c2s()->
	Hasgroup = group_op:has_group(),
	Leaderid = group_op:get_leader(),
	RoleName= get_name_from_roleinfo(get(creature_info)),
	SelfId = get(roleid),
	if 
		not Hasgroup ->
			Errno = ?ERR_GROUP_YOU_ARENT_IN_A_GROUP;
		true->
			Errno = []
	end,
	
	if
		Errno =:= []->
			case SelfId =:= Leaderid of
				false->
					case role_pos_util:where_is_role(Leaderid) of
						[]->			%%队长未在线???
							group_op:disband();
						RolePos->
							group_handle:handle_group_destroy(),
							role_pos_util:send_to_role_by_pos(RolePos,{remove_teamer,SelfId})
					end;
				true->
					handle_remove_teamer(SelfId)
			end;
		true->
			Message = role_packet:encode_group_cmd_result_s2c(SelfId,RoleName,Errno),
			role_op:send_data_to_gate(Message)
	end.

handle_group_decline_c2s(InviterId)->
	RoleId = get(roleid),
	RoleName = get_name_from_roleinfo(get(creature_info)),
	HasbeenInvite = group_op:has_been_inveited_by(InviterId),
	group_op:remove_from_inviteinfo(InviterId),
	if
		HasbeenInvite ->
			Message= role_packet:encode_group_decline_s2c(RoleId,RoleName), %%group_decline_s2c{roleid,name}
			role_pos_util:send_to_role_clinet(InviterId,Message);
		true ->
			nothing
	end.						
			
handle_group_kickout_c2s(KickRoleid)->
	RoleId = get(roleid),	
	RoleName = get_name_from_roleinfo(get(creature_info)),
	IsHaveMember = group_op:has_member(KickRoleid),	
	IsLeader = group_op:get_leader() =:= RoleId,
	if 
		not IsHaveMember -> Errno = ?ERR_GROUP_IS_NOT_IN_YOUR_GROUP;
		not IsLeader	-> Errno = ?ERR_GROUP_YOU_ARE_NOT_LEADER;
		true ->	Errno = []
	end,
	if 
		Errno =/= []->
			Message = role_packet:encode_group_cmd_result_s2c(RoleId,RoleName,Errno),
			role_op:send_data_to_gate(Message);
		true ->			%%kickout
			group_op:remove_member(KickRoleid)
	end. 			

handle_group_setleader_c2s(NewLeadId)->		%%
	RoleId = get(roleid),	
	RoleName = get_name_from_roleinfo(get(creature_info)),
	IsHaveMember = group_op:has_member(NewLeadId),	
	IsLeader = group_op:get_leader() =:= RoleId,
	case role_pos_util:where_is_role(NewLeadId) of
				[]->			%%此人未在线
					Isonline = false,
					NewLeaderInfo = [];
				RolePos->
					NewLeaderInfo = {role_pos_db:get_role_id(RolePos),role_pos_db:get_role_mapnode(RolePos),role_pos_db:get_role_pid(RolePos)},
					Isonline = true
	end,					
	case NewLeadId =/= RoleId of 
		true->
			if  not Isonline -> 	Errno = ?ERR_GROUP_CANNOT_FIND_ROLE; 
				not IsHaveMember -> Errno = ?ERR_GROUP_IS_NOT_IN_YOUR_GROUP;
				not IsLeader	-> Errno = ?ERR_GROUP_YOU_ARE_NOT_LEADER;
				true ->	Errno = []
			end,
			if 
				Errno =/= []->
					Message = role_packet:encode_group_cmd_result_s2c(RoleId,RoleName,Errno),
					role_op:send_data_to_gate(Message);
				true ->			%%kickout
					group_op:set_leader(NewLeaderInfo)	
			end;
		false->
			nothing
	end.
	
handle_group_disband_c2s()->
	RoleId = get(roleid),	
	RoleName = get_name_from_roleinfo(get(creature_info)),	
	IsLeader = group_op:get_leader() =:= RoleId,
	if 
		not IsLeader	-> Errno = ?ERR_GROUP_YOU_ARE_NOT_LEADER;
		true ->	Errno = []
	end,
	if 
		Errno =/= []->
			Message = role_packet:encode_group_cmd_result_s2c(RoleId,RoleName,Errno),
			role_op:send_data_to_gate(Message);
		true ->			%%kickout
			group_op:disband()
	end.

		
%%有人向你发送申请组队	
handle_group_apply_you(RemoteRoleInfo)->
	RoleId = get(roleid),	
	RoleName = get_name_from_roleinfo(get(creature_info)),	
	HasGroup = group_op:has_group(),
	IsFull = group_op:is_full(),
	OtherId = get_id_from_othernode_roleinfo(RemoteRoleInfo),
	if 
		not HasGroup->		%%自己没有队伍,按邀请处理
			Errno = [],
			handle_group_invite_you(RemoteRoleInfo);
		IsFull ->
			Errno = ?ERR_GROUP_IS_FULL;
		true->				%%自己有队伍,且未满,发送给队长请求
			Errno = [],
			Leaderid = group_op:get_leader(),
			%%发送给队长添加 			
			role_pos_util:send_to_role(Leaderid,{group_apply_to_leader,RemoteRoleInfo})
	end,
	if 
		Errno =/= []->
			Message = role_packet:encode_group_cmd_result_s2c(RoleId,RoleName,Errno),
			role_op:send_data_to_gate(Message),
			%%io:format("handle_group_apply_you ApplyNode ~p ApplyPid ~p~n",[ApplyNode,ApplyPid]),
			role_pos_util:send_to_role_clinet(OtherId,Message);
		true->
			nothing
	end.

%%有人请求进队		
handle_group_apply_to_leader(RemoteRoleInfo)->
	ApplyPid = get_proc_from_othernode_roleinfo(RemoteRoleInfo),
	ApplyName = get_name_from_othernode_roleinfo(RemoteRoleInfo),
	%%io:format("handle_group_apply_to_leader ApplyName ~p ApplyPid ~p~n",[ApplyName,ApplyPid]),
	ApplyId = get_id_from_othernode_roleinfo(RemoteRoleInfo),
	group_op:insert_to_inviteinfo(ApplyId),
	RoleId = get(roleid),
	case RoleId =:= group_op:get_leader() of
		true->
			Message = role_packet:encode_group_apply_s2c(ApplyId,ApplyName),
			role_op:send_data_to_gate(Message);
		false->
			slogger:msg("handle_group_apply_leader is not leader error~n")
	end. 	

%%有人邀请我
handle_group_invite_you(RemoteInviterInfo)->
	RoleId = get(roleid),	
	RoleName = get_name_from_roleinfo(get(creature_info)),	
	InviterId = get_id_from_othernode_roleinfo(RemoteInviterInfo),
	InviterName = get_name_from_othernode_roleinfo(RemoteInviterInfo),
	Hasgroup = group_op:has_group(),
	HasbeenInvite = group_op:has_been_inveited_by(InviterId),
	if   
		HasbeenInvite ->
			Errno = ?ERR_GROUP_ALREADY_INVITE;
		Hasgroup ->
			Errno = ?ERR_GROUP_ALREADY_IN_GROUP;
		true ->
			Errno = []
	end,
		
	if
		Errno =/= [] ->
			%%io:format("handle_group_invite_you InviterNode ~p InviterPid ~p~n",[InviterNode,InviterPid]),
			Message = role_packet:encode_group_cmd_result_s2c(RoleId,RoleName,Errno),
			role_pos_util:send_to_role_clinet(InviterId,Message);
		true ->
			group_op:insert_to_inviteinfo(InviterId),
			Message = role_packet:encode_group_invite_s2c(InviterId,InviterName),			
			role_op:send_data_to_gate(Message)
	end.

				

%%别人接受了你的邀请,可能是apply里的invite,则要自己创建队伍,处理添加
%%如果是已有队伍邀请别人,组队的信息操作全部交由队长来做
handle_group_accept_you(NewTeamerInfo)->
	RoleId = get(roleid),	
	RoleName = get_name_from_roleinfo(get(creature_info)),	
	NewTeamerId = get_id_from_othernode_roleinfo(NewTeamerInfo),
	case group_op:has_group() of
		false ->			%%创建create
			group_op:create(),
			handle_insert_new_teamer(NewTeamerInfo);
		true->				%%已有组队,add
			Leaderid = group_op:get_leader(),
				case group_op:is_full() of
					false->
						if 
							RoleId =/= Leaderid ->    %%发送给队长添加
								role_pos_util:send_to_role(Leaderid,{insert_new_teamer,NewTeamerInfo});
							true ->
								handle_insert_new_teamer(NewTeamerInfo)
						end;
					true->
						Errno = ?ERR_GROUP_IS_FULL,
						Message = role_packet:encode_group_cmd_result_s2c(RoleId,RoleName,Errno),%%
						role_pos_util:send_to_role_clinet(NewTeamerId,Message)
				end
	end.
	
handle_insert_new_teamer(OtherRemoteInfo)->	
	RoleId = get(roleid),
	case group_op:get_leader() =:= RoleId of
		true->
			case group_op:is_full() of
				false ->
					group_op:add_member(OtherRemoteInfo);					
				true ->
					slogger:msg("insert_new_teamer group_op:is_full error!!!!!~n")
			end;
		false ->
			slogger:msg("insert_new_teamer Leader error!!!!!~n")		
	end.		


handle_update_group_list(NewGroupInfo)->
	group_op:set_group_info(NewGroupInfo).			
%%	group_op:update_invisible_info().			%%如果更新间隔较短,这一步或许不需要	
						
handle_remove_teamer(Roleid)->
	RoleId = get(roleid),
	case group_op:get_leader() =:= RoleId of
		true->
			group_op:remove_member(Roleid);					
		false ->
			slogger:msg("handle_remove_teamer Leader error!!!!!~n")		
	end.
	
handle_group_destroy(GroupId)->
	case group_op:has_group() and (group_op:get_id() =:=  GroupId) of
		true->
			group_op:group_destroy();
		false->
			slogger:msg("handle_group_group_destroy hasnot group ~p role ~p !!!!!~n",[GroupId,get(roleid)])
	end.
	
handle_group_destroy()->
	case group_op:has_group() of
		true->
			group_op:group_destroy();
		false ->
			slogger:msg("handle_group_group_destroy hasnot group ~p !!!!!~n",[get(roleid)])	
	end.
	
handle_regist_member_info(Otherid,Info)->	
	RoleId = get(roleid),
	case group_op:get_leader() =:= RoleId of
		true->
			group_op:regist_member_info(Otherid,Info);					
		false ->
			slogger:msg("handle_remove_teamer Leader error!!!!!~n")		
	end.
	
handle_group_update_timer()->
	group_op:update_by_timer().	
	
handle_delete_invite(Roleid)->
	group_op:remove_from_inviteinfo_timeout(Roleid).			 	
	
%%招募
handle_recruite_c2s(Ins,Des)->
	RoleId = get(roleid),
	case group_op:get_leader() =:= RoleId of
		true->
			group_op:set_to_recruitment(Ins,Des);					
		false ->
			slogger:msg("handle_recruite_c2s Leader error!!!!!~n")		
	end.
	
handle_recruite_cancel_c2s()->
	RoleId = get(roleid),
	case group_op:get_leader() =:= RoleId of
		true->
			group_op:set_to_unrecruitment();					
		false ->
			slogger:msg("handle_recruite_c2s Leader error!!!!!~n")		
	end.
	
handle_group_instance_start({InstanceProtoId,MapPos,LeaderId})->
	case transport_op:can_directly_telesport() of
		false->
			nothing;
		_->
			case group_op:get_leader() =:= LeaderId of 
				true->
					group_op:proc_leader_instance_invite(InstanceProtoId,MapPos);
				_->	
					nothing
			end
	end.	
	
handle_group_instance_join()->
	group_op:proc_group_instance_join().				

role_recruite_c2s(InstanceId)->
	group_op:set_role_to_recruitment(InstanceId).
role_recruite_cancel_c2s()->
	group_op:set_role_to_unrecruitment().
	
handle_aoi_role_group_c2s()->
	group_op:proc_get_aoi_role_group().		
					