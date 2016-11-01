%% Author: SQ.Wang
%% Created: 2012-1-4
%% Description: TODO: Add description to guild_member_op
-module(guild_op).

%%
%% Include files
%%
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("guild_define.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("system_chat_define.hrl").
-include("instance_define.hrl").
-include("activity_define.hrl").
-include("map_info_struct.hrl").
-define(STRING_LBRACKET,118).
-define(STRING_RBRACKET,119).

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
init(GuildId,LineId,Level,MapId)->
	init(),
	Info = {Level,LineId,MapId},			
	GuildInfo = guild_manager:member_online(get(roleid),GuildId,Info),
	case GuildInfo of
		[]->
			put(guild_info,{0,[],0,0,0,0,[],[]});
		_->	 
			put(guild_info,GuildInfo),
			if
				GuildId=:=0->
					A = guild_util:get_guild_posting(),
					achieve_op:achieve_update({guildposting},[0],guild_util:get_guild_posting());
				true->	
					nothing
			end	
	end,
	guild_handle:handle_guild_impeach_info_c2s(),
	NewGuildLevel = guild_util:get_guild_facility_level(?GUILD_FACILITY),
	achieve_op:achieve_update({guild_level},[0],NewGuildLevel).	

init()->	
	put(guild_apply,false),
	put(guild_invite,[]),
	put(guild_mastercall,[]),
	put(guild_info,{0,[],0,0,0,0,[],[]}).	

export_for_copy()->
	{get(guild_invite),get(guild_info),get(guild_mastercall), get(guild_apply)}.

load_by_copy({InviteInfo,GuildInfo,MasterCall,ApplyInfo})->
	put(guild_invite,InviteInfo),
	put(guild_info,GuildInfo),
	put(guild_mastercall,MasterCall),
	put(guild_apply,ApplyInfo).

create(Name, Type, Silver)->
  Myid = get(roleid),
  case Type of
    1 ->
      case guild_manager:create(Myid,Name, 2) of
        ok->
          guild_facility:falility_required_destroy(?GUILD_FACILITY,1);
        error->
          nothing
      end;
    0 ->
      case guild_manager:create(Myid,Name, 1) of
        ok->
          role_op:money_change(?MONEY_BOUND_SILVER, -Silver, create_guild);
        error->
          nothing
      end
  end,
  NewGuildLevel = guild_util:get_guild_facility_level(?GUILD_FACILITY),
  achieve_op:achieve_update({guild_level},[0],NewGuildLevel).	

destroy()->
	init(),
	put(creature_info, set_guildname_to_roleinfo(get(creature_info),[])),
	put(creature_info, set_guildposting_to_roleinfo(get(creature_info),0)),
	put(creature_info, set_guildtype_to_roleinfo(get(creature_info),?NORMAL_GUILD_TYPE)),
	ChangeAttr = [{guildposting,guild_util:get_guild_posting()},{guildname,guild_util:get_guild_name()},{guildtype,?NORMAL_GUILD_TYPE}],
	role_op:self_update_and_broad(ChangeAttr).

guild_disband()->
	case guild_util:get_guild_id() of
		0->
			nothing;
		GuildId->
			case guild_manager:guild_disband(get(roleid),GuildId) of
				true->
					guild_instance:stop_instance(GuildId);
				_->
					ignor
			end
	end.

set_leader(Roleid)->
	guild_manager:set_leader(guild_util:get_guild_id(),get(roleid),Roleid).
		
join_guild(GuildId)->
	guild_manager:join_guild(get(roleid),GuildId).

depart()->
	guild_manager:depart(guild_util:get_guild_id(),get(roleid)).
				
kick_out(KickRoleId)->
	guild_manager:kick_out(guild_util:get_guild_id(),get(roleid),KickRoleId).
	
promotion(RoleId)->
	guild_manager:promotion(guild_util:get_guild_id(),get(roleid),RoleId).		
	
demotion(RoleId)->
	guild_manager:demotion(guild_util:get_guild_id(),get(roleid),RoleId).

set_notice(Notice)->
	guild_manager:set_notice(guild_util:get_guild_id(),get(roleid),Notice).

get_guild_notice(GuildId)->
	guild_manager:get_guild_notice(get(roleid),GuildId).

on_leave()->
	GuildId = guild_util:get_guild_id(),
	ApplyFlag = get(guild_apply),
	if 
		GuildId =/= 0->
			guild_manager:member_offline(get(roleid),GuildId);
		ApplyFlag->
			guild_manager:member_offline(get(roleid),GuildId);
		true->
			nothing    
	end.	
	
hook_on_levelup(NewLevel)->
	GuildId = guild_util:get_guild_id(),
	if 
		GuildId =/= 0->
			guild_manager:member_levelup(get(roleid),GuildId,NewLevel);
		true->
			nothing
	end.

hook_on_change_fightforce(FightForce)->
	GuildId = guild_util:get_guild_id(),
	if 
		GuildId =/= 0->
			guild_manager:member_change_fightforce(get(roleid),GuildId,FightForce);
		true->
			nothing
	end.
	
change_map(NewLine,NewMap)->
	GuildId = guild_util:get_guild_id(),
	if 
		GuildId =/= 0->
			guild_manager:change_map(get(roleid),GuildId,NewLine,NewMap);
		true->
			nothing
	end.

hook_on_role_name_change(NewNameStr)->
	GuildId = guild_util:get_guild_id(),
	if 
		GuildId =/= 0->
			guild_manager:change_rolename(GuildId,get(roleid),NewNameStr),
			[];
		true->
			[]
	end.

change_nickname(RoleId,NickName)->
	case guild_util:get_guild_id() of
		0->
			nothing;
		GuildId->
			guild_manager:change_nickname(get(roleid),GuildId,RoleId,NickName)
	end.

rename(NewNameStr)->							
	case guild_util:is_have_guild() of
		true->
			case guild_util:get_guild_posting() of
				?GUILD_POSE_LEADER->
					case guild_manager:rename(guild_util:get_guild_id(),NewNameStr) of
						true->
							true;
						_->
							false
					end;
				_->					
					false
			end;
		_->		
			false
	end.

contribute(MoneyType,MoneyCount)->
	case role_op:check_money(?MONEY_SILVER,MoneyCount) of
		true->
			case guild_manager:contribute(guild_util:get_guild_id(),get(roleid),?MONEY_SILVER,MoneyCount) of
				ok->
					role_op:money_change(?MONEY_SILVER,-MoneyCount,lost_function),
					achieve_op:achieve_update({contribute_guild},[?MONEY_SILVER],MoneyCount),
					achieve_op:achieve_update({contribute_guild},[?TYPE_GUILD_CONTRIBUTION],trunc(MoneyCount/10000));
				_->
					nothing
			end;
		_->
			ignor
	end.

contribute(Contribute)->
	HasRight = guild_util:is_have_right(?GUILD_AUTH_CONTRIBUTION),
	if
		HasRight->
			case guild_manager:add_contribute(guild_util:get_guild_id(),get(roleid),Contribute) of
				ok->			
					true;
				_->
					nothing
			end;
		true->
			Msg = guild_packet:encode_guild_opt_result_s2c(?GUILD_GET_CONTRIBUTION_ERROR),
			role_op:send_data_to_gate(Msg),
			false
	end.

hook_on_bekilled(EnemyId,EnemyName)->
	GuildCheck = guild_util:get_guild_id() =/= 0,
	EnemyCheck = not guild_util:is_same_guild(EnemyId),
	case (GuildCheck and EnemyCheck) of
		false->
			nothing;
		_->
			Posting = guild_util:get_guild_posting(),
			MapId = get_mapid_from_mapinfo(get(map_info)),
			LineId = get_lineid_from_mapinfo(get(map_info)),
			LString = language:get_string(?STRING_LBRACKET),
			RString = language:get_string(?STRING_RBRACKET),
			case  map_info_db:get_map_info(MapId) of
				[]->
					false;
				MapInfo->
					case map_info_db:get_is_instance(MapInfo) of
						0->		
							MyNameTmp = get_name_from_roleinfo(get(creature_info)),
							MapNameTmp = map_info_db:get_map_name(MapInfo),
							if 
								is_binary(MyNameTmp)->
									MyName = binary_to_list(MyNameTmp) ++ LString ++guild_log:get_posting_string(Posting)++ RString;
								true->
									MyName = MyNameTmp ++ LString ++guild_log:get_posting_string(Posting)++ RString
							end,
							if 
								is_binary(MapNameTmp)->
									MapName = binary_to_list(MapNameTmp);
								true->
									MapName = MapNameTmp
							end,
							if 
								is_binary(EnemyName)->
									RealEnemyName=binary_to_list(EnemyName);
								true->
									RealEnemyName = EnemyName
							end,
							system_chat_op:send_message_guild(?SYSTEM_CHAT_GUILD_ROLE_KILLED,[RealEnemyName,MyName,MapName,integer_to_list(LineId)],[]);
						_->
							nothing
					end
			end
	end.

update_guild_base_info({_GuildId,_GuildName,GuildLevel,Posting,Contribution,TContribution})->
	case guild_util:get_guild_posting() =/= Posting of
		true->
			put(creature_info, set_guildposting_to_roleinfo(get(creature_info),Posting)),
			ChangeAttr = [{guildposting,Posting}],
			role_op:self_update_and_broad(ChangeAttr);
		false->
			nothing
	end,
	case guild_util:get_guild_name() of
		_GuildName->
			nothing;
		_->
			put(creature_info, set_guildname_to_roleinfo(get(creature_info),_GuildName)),
			ChangeAttr1 = [{guildname,_GuildName}],	
			role_op:self_update_and_broad(ChangeAttr1),
			guild_util:set_guild_name(_GuildName)	
	end,
	guild_util:set_guild_level(GuildLevel),
	guild_util:set_guild_posting(Posting),		
	guild_util:set_guild_contribution(Contribution),
	guild_util:set_guild_tcontribution(TContribution),
	achieve_op:achieve_update({guild_level},[0],GuildLevel).
	
update_guild_info(FullInfo)->
	put(guild_info,FullInfo),
	put(creature_info, guild_util:set_guildname_to_roleinfo(get(creature_info),guild_util:get_guild_name())),
	put(creature_info, guild_util:set_guildposting_to_roleinfo(get(creature_info),guild_util:get_guild_posting())),		
	ChangeAttrtTemp = [{guildposting,guild_util:get_guild_posting()},{guildname,guild_util:get_guild_name()}],
	BestGuildCheck = guild_util:get_guild_id() =:= country_op:get_bestguild(),
	if
		BestGuildCheck->
			GuildType = ?BEST_GUILD_TYPE,
			put(creature_info, set_guildtype_to_roleinfo(get(creature_info),GuildType)),
			ChangeAttr = [{guildtype,GuildType}|ChangeAttrtTemp];
		true->
			ChangeAttr = ChangeAttrtTemp
	end,		
	role_op:self_update_and_broad(ChangeAttr),
	role_op:async_write_to_roledb(),
	achieve_op:achieve_update({guildposting},[0],guild_util:get_guild_posting()),
	NewGuildLevel = guild_util:get_guild_facility_level(?GUILD_FACILITY),
	achieve_op:achieve_update({guild_level},[0],NewGuildLevel).

delele_member(Roleid)->
	guild_util:set_by_item(members,lists:delete(Roleid,guild_util:get_guild_members())).	

add_member(Roleid)->
	MemberList = guild_util:get_guild_members(),
	case lists:keyfind(Roleid,1,MemberList) of
		false->
			guild_util:set_by_item(members,[Roleid]++MemberList);
		_->
			nothing
	end.		
	
change_chatandvoicegroup(ChatGroup,VoiceGroup)->
	case guild_util:get_guild_id() of
		0->
			nothing;
		GuildId->
			guild_manager:change_chatandvoicegroup(get(roleid),GuildId,ChatGroup,VoiceGroup)
	end.	
	
clear_nickname(RoleId)->
	case guild_util:get_guild_id() of
		0->
			nothing;
		GuildId->
			guild_manager:clear_nickname(get(roleid),GuildId,RoleId)
	end.
				
guild_mastercall({GuildId,GuildPosting,RoleName,Line,MapId,Pos,Reason}=CallInfo)->
	case (GuildId=:=guild_util:get_guild_id()) of
		true->
			Msg = guild_packet:encode_guild_mastercall_s2c(GuildPosting,RoleName,Line,MapId,Pos,Reason),
			role_op:send_data_to_gate(Msg),
			put(guild_mastercall,{timer_center:get_correct_now(),{Line,MapId,Pos}});
		_->
			nothing
	end.	
	
mastercall_accept()->
	case guild_util:is_have_guild() of
		true->
			case get(guild_mastercall) of
				[]->
					slogger:msg("mastercall_accept but not call you RoleId ~p ~n",[get(roleid)]);
				{Time,{LineId,MapId,Pos}}->
					case transport_op:can_directly_telesport() of
						true->
							case timer:now_diff(timer_center:get_correct_now(),Time) >= ?GUILD_MASTER_CALL_TIME*1000 of
								true->
									put(guild_mastercall,[]),
									slogger:msg("mastercall_accept but not timeout RoleId ~p ~n",[get(roleid)]);		
								_->
									put(guild_mastercall,[]),
									role_op:transport(get(creature_info), get(map_info),LineId,MapId,Pos)	
							end;
						_->
							nothing
					end		
			end;
		_->
			nothing
	end.

change_guild_battle_limit(FightForce)->
	guild_manager:change_guild_battle_limit({guild_util:get_guild_id(),FightForce}).

clear_cd_by_gm()->
	case guild_util:is_have_guild() of
		true->
			guild_manager:clear_cd_by_gm(guild_util:get_guild_id());
		_->
			ignor
	end.

guild_dice() ->
    {A, B, C} = timer_center:get_correct_now(),
    random:seed(A, B, C),
    Rand = random:uniform(100),
    Message = guild_packet:encode_guild_dice_s2c(get(roleid), Rand),
    Members = guild_util:get_guild_members(),
    role_pos_util:send_to_clinet_list(Message, Members).

