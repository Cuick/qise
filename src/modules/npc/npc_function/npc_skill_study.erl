%% Author: PC17
%% Created: 2010-9-22
%% Description: TODO: Add description to npc_skill_learn
-module(npc_skill_study).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("npc_define.hrl").
-include("skill_define.hrl").
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-export([do_learn_without_npc/1,do_pet_learn_without_npc/4,do_pet_forget_skill/2]).

-export([auto_do_learn_without_npc/1,learn_pet_skill_without_npc/1]).

-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("pet_struct.hrl").

%%
%% API Functions
%%
init_func()->
	npc_function_frame:add_function(skill_learn,?NPC_FUNCTION_SKILL, ?MODULE).


registe_func(NpcId)->
	Mod= ?MODULE,
	Fun= skill_learn,
	Arg=  [],
	Response=#kl{key=?NPC_FUNCTION_SKILL, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg = [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

%%%%%%%%%%%%%%%
%%
%% db operator
%%
%%%%%%%%%%%%%%%

enum(_RoleInfo,_SkillList,NpcId)->
	Message = role_packet:encode_enum_skill_item_s2c(NpcId),
	role_op:send_data_to_gate(Message),
	{ok}.
	
do_learn_without_npc(Skillid)->
	RoleInfo = get(creature_info),
	SkillLevel = skill_op:get_skill_level(Skillid)+1,
	case skill_db:get_skill_info(Skillid,SkillLevel) of
		[]->
			nothing;
		SkillInfo ->
			{Type,Price} = skill_db:get_money(SkillInfo),
			Soul = skill_db:get_soulpower(SkillInfo),
			NeedItems = skill_db:get_items(SkillInfo),
			case can_learn_skill_skillinfo(RoleInfo,Skillid,SkillInfo) of
				false->
					nothing;
				true->
					role_op:money_change(Type, - Price ,lost_skill),
					role_op:consume_soulpower(Soul),
					lists:foreach(fun(TemplateId)->script_op:destory_item(TemplateId,1) end, NeedItems),
					skill_op:learn_skill(Skillid, SkillLevel),
					skill_op:async_save_to_db(),
					case (skill_db:get_type(SkillInfo) =:= ?SKILL_TYPE_PASSIVE_ATTREXT) of
						true->
							role_op:recompute_skill_attr(),
							role_fighting_force:hook_on_change_role_fight_force();
						_->
							nothing
					end,
					
					Msg = role_packet:encode_update_skill_s2c(get(roleid),Skillid, SkillLevel),
					role_op:send_data_to_gate(Msg)
			end
	end.

learn_pet_skill_without_npc(Skillid)->
	RoleInfo = get(creature_info),
	SkillLevel = 1,
	case skill_db:get_skill_info(Skillid,SkillLevel) of
		[]->
			nothing;
		SkillInfo ->
			Price0 = skill_db:get_money(SkillInfo),
			{_Type,Price} = Price0,
			Soul = skill_db:get_soulpower(SkillInfo),
			NeedItems = skill_db:get_items(SkillInfo),
			case can_learn_skill_skillinfo(RoleInfo,Skillid,SkillInfo) of
				false->
					nothing;
				true->
					put(creature_info, set_pet_skill_to_roleinfo(get(creature_info), [Skillid])),
					role_op:money_change(?MONEY_BOUND_SILVER, -Price ,lost_skill),
					role_op:consume_soulpower(Soul),
					lists:foreach(fun(TemplateId)->script_op:destory_item(TemplateId,1) end, NeedItems),
					quest_op:update({learn_skill,Skillid},SkillLevel),
					{_,_,SkillList} = get(skill_info),
					achieve_op:achieve_update({learn_skill},[0],length(SkillList)),
					gm_logger_role:role_skill_learn(get(roleid),Skillid,SkillLevel,get(level)),
					role_op:async_save_to_roledb(),
					Msg = pet_packet:encode_pet_skill_fuse_s2c(Skillid),
					role_op:send_data_to_gate(Msg)
					
			end
	end.

do_learn_without_npc(Skillid,SkillLevel)->
    RoleInfo = get(creature_info),
    case skill_db:get_skill_info(Skillid,SkillLevel) of
        []->
            % slogger:msg("learn skill error Roleid ~p Skill: ~p Level ~p~n",[get_id_from_roleinfo(RoleInfo),Skillid,SkillLevel]);
            nothing;
        SkillInfo ->
            {Type,Price} = skill_db:get_money(SkillInfo),
            Soul = skill_db:get_soulpower(SkillInfo),
            NeedItems = skill_db:get_items(SkillInfo),
            case can_learn_skill_skillinfo(RoleInfo,Skillid,SkillInfo) of
                false->
                    nothing;
                true->
                    role_op:money_change(Type, -Price ,lost_skill),
                    role_op:consume_soulpower(Soul),
                    lists:foreach(fun(TemplateId)->script_op:destory_item(TemplateId,1) end, NeedItems),
                    skill_op:learn_skill(Skillid, SkillLevel),
                    skill_op:async_save_to_db(),
                    case (skill_db:get_type(SkillInfo) =:= ?SKILL_TYPE_PASSIVE_ATTREXT) of
                        true->
                            role_op:recompute_skill_attr(),
                            role_fighting_force:hook_on_change_role_fight_force();
                        _->
                            nothing
                    end,
                    Msg = role_packet:encode_update_skill_s2c(get(roleid),Skillid, SkillLevel),
                    role_op:send_data_to_gate(Msg)
            end
    end.

%% 一键升级
auto_do_learn_without_npc(SkillList)->
    RoleInfo = get(creature_info),
    lists:foreach(fun({_,Skillid,Level}) ->
        %% 目前技能最高级别为10级
        lists:foldl(fun(SkillLevel,Acc) ->
            if
                    Acc =:= true -> true;
                    true ->
                        case skill_db:get_skill_info(Skillid,SkillLevel) of
                            []->
                                % slogger:msg("learn skill error Roleid ~p Skill: ~p Level ~p~n",[get_id_from_roleinfo(RoleInfo),Skillid,SkillLevel]);
                                nothing;
                            SkillInfo ->
                                {Type,Price} = skill_db:get_money(SkillInfo),
                                Soul = skill_db:get_soulpower(SkillInfo),
                                NeedItems = skill_db:get_items(SkillInfo),
                                case can_learn_skill_skillinfo(RoleInfo,Skillid,SkillInfo) of
                                    false -> true;
                                    true ->
                                        role_op:money_change(Type, -Price ,lost_skill),
                                        role_op:consume_soulpower(Soul),
                                        lists:foreach(fun(TemplateId)->script_op:destory_item(TemplateId,1) end, NeedItems),
                                        skill_op:learn_skill(Skillid, SkillLevel),
                                        skill_op:async_save_to_db(),
                                        case (skill_db:get_type(SkillInfo) =:= ?SKILL_TYPE_PASSIVE_ATTREXT) of
                                            true->
                                                role_op:recompute_skill_attr(),
                                                role_fighting_force:hook_on_change_role_fight_force();
                                            _->
                                                nothing
                                        end,
                                        Msg = role_packet:encode_update_skill_s2c(get(roleid),Skillid, SkillLevel),
                                        role_op:send_data_to_gate(Msg),
                                        false
                                end
                        end
            end
        end,false,lists:seq(Level+1,Level+11)) % 10级别范围
        %%lists:foreach(fun(SkillLevel) -> do_learn_without_npc(SkillId, SkillLevel) end, lists:seq(Level+1, 10))
    end,SkillList).

do_pet_learn_without_npc(PetId,SkillId,SkillLevel,Lock_slot_list)->
	case pet_op:get_pet_gminfo(PetId) of
		[]->
			false;
		GmPetInfo->
			case skill_db:get_skill_info(SkillId,SkillLevel) of
				[]->
					false;
				SkillInfo->
					{Type,Price} = skill_db:get_money(SkillInfo),
					Soul = skill_db:get_soulpower(SkillInfo),
					case can_pet_learn_skill_skillinfo(GmPetInfo,SkillId,SkillLevel,SkillInfo,Lock_slot_list) of
						false->
							false;
						true->
							% 原技能列表
							OldSkillList = get(pets_skill_info),
							case pet_skill_op:learn_skill(PetId, SkillId, SkillLevel,Lock_slot_list) of
								false->
									false;
								_->
									% 新技能列表
									NewSkillList = get(pets_skill_info),
									skill_log(PetId,GmPetInfo,OldSkillList,NewSkillList,Lock_slot_list),
									role_op:money_change(Type, -Price ,lost_pet_skill),
									role_op:consume_soulpower(Soul),							
									true
							end
					end
			end
	end.

%%return true/false
do_pet_forget_skill(PetId, SkillId)->
%%	case pet_op:get_pet_gminfo(PetId) of
%%		[]->
%%			false;
%%		_->
%%			SkillLevel = pet_skill_op:get_skill_level(PetId, SkillId),
%%			if
%%				SkillLevel =:= 0->
%%					false;
%%				true->
%%					AllSoul = calculus_skill_consume_soulpower(SkillId,SkillLevel),
%%					pet_skill_op:forget_skill(PetId, SkillId),
%%					role_op:obtain_soulpower(AllSoul),
%%					Msg = role_packet:encode_update_skill_s2c(PetId,SkillId, 0),
%%					role_op:send_data_to_gate(Msg),
%%					true
%%			end
%%	end.
	false.		

calculus_skill_consume_soulpower(SkillId,SkillLevel)->
	lists:foldl(fun(LevelTmp,AccPower)->
					case skill_db:get_skill_info(SkillId, LevelTmp) of
						[]->
							AccPower;
						SkillInfo->
							AccPower + skill_db:get_soulpower(SkillInfo)
					end end,0, lists:seq(1, SkillLevel)).

can_pet_learn_skill_skillinfo(PetInfo,SkillId,SkillLevel,SkillInfo,Lock_slot_list)->
	PetId = get_id_from_petinfo(PetInfo),
	{Type,Price} = skill_db:get_money(SkillInfo),
	EngouhMoney = role_op:check_money(Type,Price),
	EngouhLevel = skill_db:get_learn_level(SkillInfo) =< get_level_from_petinfo(PetInfo),
	% PetProto = get_proto_from_petinfo(PetInfo),
	% PetProtoInfo = pet_proto_db:get_info(PetProto),
	% PetSpecies = pet_proto_db:get_species(PetProtoInfo),
	% NeedCreature = lists:member(PetSpecies, skill_db:get_creature(SkillInfo)),
	NeedSkillList = skill_db:get_required_skills(SkillInfo),
	NeedItems = skill_db:get_items(SkillInfo),
	IsHasItem = lists:filter(fun(TemplateId)->item_util:is_has_enough_item_in_package(TemplateId,1) end, NeedItems)=:=NeedItems,
	IsHasSkill = lists:foldl(fun({NeedId,NeedLevel},Re)->
									 if 
										 not Re->
											 Re;
										 true->
											 pet_skill_op:get_skill_level(PetId, NeedId)>=NeedLevel
									end		 
								end,true,NeedSkillList),
	IsHasSolt = pet_skill_op:check_useful_slot(PetId,Lock_slot_list),
	IsHasSoul = role_soulpower:get_cursoulpower()>= skill_db:get_soulpower(SkillInfo),
	IsSameSkill =  pet_skill_op:check_same_skill(PetId,SkillId,SkillLevel),
	if
		not EngouhMoney->
			Errno = ?ERROR_LESS_MONEY;
		not EngouhLevel->
			Errno = ?ERROR_PET_LESS_LEVEL;
		% not NeedCreature->
		% 	Errno = ?ERROR_PET_LEARN_SKILL_SPECIES_NOT_MATCH;
		not IsHasSkill->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_NEED_SKILL;
		not IsHasSoul->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_SOULPOWER;
		not IsHasItem->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_ITEM;
		not IsHasSolt->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_SLOT;
		IsSameSkill->
			Errno = ?ERROR_PET_LEARN_SKILL_SAME_SKILL;
		true->
			Errno = []
	end,
	if
		Errno =:= []->
			true;
		true->
%%			io:format("can_pet_learn_skill_skillinfo ~p ~n",[Errno]),
			role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno)),
			false
	end.

can_learn_skill_skillinfo(RoleInfo,Skillid,SkillInfo)->
	{Type,Price} = skill_db:get_money(SkillInfo),
	EngouhMoney = role_op:check_money(Type,Price),
	EngouhLevel = skill_db:get_learn_level(SkillInfo) =< get_level_from_roleinfo(RoleInfo),
	LearnClass = skill_db:get_class(SkillInfo),
	NeedClass = (LearnClass=:= get_class_from_roleinfo(RoleInfo)) or (LearnClass=:=0),	
	NeedCreature = lists:member(?SKILL_ROLE_STUDY, skill_db:get_creature(SkillInfo)),
	NeedItems = skill_db:get_items(SkillInfo),
	IsHasItem = lists:filter(fun(TemplateId)->not item_util:is_has_enough_item_in_package(TemplateId,1) end, NeedItems)=:=[],
	NeedSkillList = skill_db:get_required_skills(SkillInfo),
	IsHasSkill = lists:foldl(fun({NeedId,NeedLevel},Re)->
									 if 
										 not Re->
											 Re;
										 true->
											 skill_op:get_skill_level(NeedId)>=NeedLevel
									end		 
								end,true,NeedSkillList),
	IsHasSoul = role_soulpower:get_cursoulpower()>= skill_db:get_soulpower(SkillInfo),
	if
		not EngouhMoney->
			Errno = ?ERROR_LESS_MONEY;
		not EngouhLevel->
			Errno = ?ERROR_PET_LESS_LEVEL;
		not NeedCreature->
			Errno = ?ERROR_PET_LEARN_SKILL_SPECIES_NOT_MATCH;
		not IsHasSkill->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_NEED_SKILL;
		not IsHasSoul->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_SOULPOWER;
		not IsHasItem->
			Errno = ?ERROR_PET_LEARN_SKILL_LESS_ITEM;
		true->
			Errno = []
	end,
	if
		Errno =:= []->
			true;
		true->
%%			io:format("can_pet_learn_skill_skillinfo ~p ~n",[Errno]),
			% role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno)),
			false
	end.
% true.
	% EngouhMoney and EngouhLevel and NeedClass and NeedCreature and IsHasSkill and IsHasSoul and IsHasItem.		

% 处理技能列表
skill_log(PetId,GmPetInfo,OldPetsSkillInfo,NewPetsSkillInfo,Lock_slot_list)->
	% 时间
	{MegaSecs, Secs, _MicroSecs} = timer_center:get_correct_now(),
	RiseupTime = Secs+MegaSecs*1000000,
	%%玩家ID
	RoleId = get(roleid),
	%%玩家名称
	RoleInfo = get(creature_info),
	RoleName = get_name_from_roleinfo(RoleInfo),
	% % 仙仆名称
	PetName = get_name_from_petinfo(GmPetInfo),
	% [{OldPetid,OldSkillList},{} = OldPetsSkillInfo,
	% [{NewPetid,NewSkillList}] = NewPetsSkillInfo,
	[{OldPetid,OldSkillList}] = lists:subtract(OldPetsSkillInfo,NewPetsSkillInfo),
	{_,NewSkillList} = lists:keyfind(OldPetid,1,NewPetsSkillInfo),
	OldDiff = lists:subtract(NewSkillList,OldSkillList),
	[{DPosition,{DSkillid,DSkillLevel,_},_}] = OldDiff,
	lists:foreach(fun(Skill) ->
		{Position,{Skillid,SkillLevel,_},_} = Skill,

		case Skillid =/= 0 of
			true ->
			Flag = lists:member(Position, Lock_slot_list),
			if
				Flag ->
					Lock = 1;
				true ->
					Lock = 0
			end,
			NewSkillInfo = skill_db:get_skill_info(Skillid,SkillLevel),
			NewSkillName = skill_db:get_name(NewSkillInfo),
			if
				Skillid=/=0 ->
					if
						DPosition =:= Position ->
							OldSkillid = DSkillid,
							OldSkillLevel = DSkillLevel,
							SkillInfo = skill_db:get_skill_info(OldSkillid,OldSkillLevel),
							SkillName = skill_db:get_name(SkillInfo),
							gm_logger_role:insert_log_pet_skill_riseup(RoleId,RoleName,PetId,PetName,Lock,SkillName,OldSkillLevel,NewSkillName,SkillLevel,RiseupTime);
						true ->
							OldSkillid = Skillid,
							OldSkillLevel = SkillLevel,
							SkillInfo = skill_db:get_skill_info(OldSkillid,OldSkillLevel),
							SkillName = skill_db:get_name(SkillInfo),
							gm_logger_role:insert_log_pet_skill_riseup(RoleId,RoleName,PetId,PetName,Lock,SkillName,OldSkillLevel,NewSkillName,SkillLevel,RiseupTime)
					end;
				true ->
					nothing
			end;
			_->
				nothing
		end
		

	
	end, NewSkillList),
	true.
			
