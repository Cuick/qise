-module(pet_handle).

-compile(export_all).

-include("data_struct.hrl").
-include("pet_struct.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("item_define.hrl").
-include("login_pb.hrl").
-include("little_garden.hrl").
-include("mnesia_table_def.hrl").


-define(VIP_ROOM, [5,6,7]).

% 2,20000000000001,0
% {pet,2,[2,20000000000001,40]}
% {pet,0,[2,20000000000001,40]}

%{pet,1,1}
% {pet,2,[1,20000000000002,2]}
% {pet,0,[1,20000000000002,0]}
% {pet,0,[1,20000000000002,120]}

%{pet,1,2}
% {pet,2,[1,20000000000002,2]}
% {pet,0,[1,20000000000002,0]}
% {pet,0,[1,20000000000002,240]}
% do(N,Msg)->
% 	case N of
% 		0  ->
% 			[A,B,C] =  Msg,
% 			pet_hostel:handle_balance(A,B,C);
% 		1 ->
% 			pet_hostel:open_room(Msg);
% 		2 ->
% 			[A,B,C] =  Msg,
% 			pet_hostel:pet_in_room(A,B,C);
% 		3 ->
% 			[A,B,C] =  Msg
% 			pet_inherit_op:pet_inherit(A,B,C)
% 	end.
special_handle_room_id(Room_id) ->
	Bool = lists:member(Room_id,?VIP_ROOM),
	case Bool of
		true ->
			case get(role_vip) of
				#vip_role{level = Level} = VipRole ->
					pet_hostel:get_vip_room_id(Level);
				_ ->
					Room_id
			end;
		_ ->
			Room_id
	end.	

process_base_message(#pet_grade_riseup_c2s{petid = PetId,extitems = ExtItems,consum_type = ConsumType, up_type = Up_type}, RoleState)->
       pet_grade_op:process_message(PetId,ExtItems, ConsumType, Up_type),
	   RoleState;

process_base_message(#pet_room_c2s{}, RoleState) ->
	pet_hostel:send_pet_room_data(),
	RoleState;
process_base_message(#pet_open_room_c2s{room_id = Room_id}, RoleState) ->
	pet_hostel:open_room(special_handle_room_id(Room_id)),
	RoleState;
process_base_message(#pet_room_balance_c2s{room_id = Room_id,petid = Petid,gold = Gold}, RoleState) ->
	pet_hostel:handle_balance(special_handle_room_id(Room_id),Petid,Gold),
	RoleState;

process_base_message(#pet_into_room_c2s{room_id = Room_id,petid = Petid,duration = Duration}, RoleState) ->
	pet_hostel:pet_in_room(special_handle_room_id(Room_id),Petid,Duration),
	RoleState;

process_base_message(#pet_shop_c2s{}, RoleState) ->
	pet_shop_op:commom_send(),
	RoleState;

process_base_message(#pet_skill_fuse_del_c2s{}, RoleState) ->
	pet_skill_op:del_fuse_skill(),
	RoleState;

process_base_message(#pet_savvy_up_c2s{pet_id = PetId}, RoleState) ->
	pet_savvy_up_op:pet_savvy_up(PetId),
	RoleState;

process_base_message(#pet_move_c2s{petid = PetId,posx = PosX,posy = PosY,path=Path,time = Time}, RoleState)->
	pet_op:pet_move(PetId,{PosX,PosY},Path,Time),
	RoleState;

process_base_message(#car_move_c2s{carid = CarId,posx = PosX,posy = PosY,path=Path,time = Time}, RoleState)->
	pet_op:car_move(CarId,{PosX,PosY},Path,Time),
	RoleState;

process_base_message(#pet_stop_move_c2s{petid = PetId,posx = PosX,posy = PosY,time = Time}, RoleState)->
	pet_op:pet_stop_move(PetId,{PosX,PosY},Time),
	RoleState;

process_base_message(#pet_attack_c2s{petid = PetId,skillid = Skill,creatureid = Target}, RoleState)->
	pet_op:pet_attack(PetId,Skill,Target),
	RoleState;

process_base_message(#summon_pet_c2s{type = Type,petid = PetId}, RoleState)->
	handle_summon_pet_c2s(Type,PetId),
	RoleState;

process_base_message(#pet_feed_c2s{petid = PetId,slot = ItemSlot}, RoleState)->
	item_feed_pet:handle_use_item(PetId,ItemSlot),
    RoleState;

process_base_message(#pet_swap_slot_c2s{petid = PetId,slot=Slot}, RoleState)->
	pet_op:swap_slot(PetId,Slot),
	RoleState;

process_base_message(#pet_start_training_c2s{petid = PetId,totaltime = TotalTime,type = Type}, RoleState)->
	%pet_training:pet_training_start(PetId,TotalTime,Type);
    RoleState;

process_base_message(#pet_stop_training_c2s{petid = PetId}, RoleState)->
	%pet_training:pet_training_stop(PetId);
    RoleState;

process_base_message(#pet_speedup_training_c2s{petid = PetId,speeduptime = Time}, RoleState)->
	%pet_training:pet_training_speedup(PetId,Time);
    RoleState;

process_base_message(#pet_rename_c2s{petid = PetId,newname = NewName}, RoleState)->
	handle_pet_rename_c2s(PetId,NewName),
	RoleState;

process_base_message(#pet_present_apply_c2s{slot = Slot}, RoleState)->
	RoleState;

process_base_message(#pet_learn_skill_c2s{petid = PetId,slot = Slot,force = Force}, RoleState)->
	item_skill_book:handle_learn_skill_with_book(PetId, Slot,Force),
	RoleState;

process_base_message(#pet_forget_skill_c2s{petid = PetId,skillid = SkillId,slot=Slot}, RoleState)->
	RoleState;

process_base_message(#pet_skill_fuse_c2s{types = Types}, RoleState)->
	pet_skill_op:skill_fuse(Types),
	RoleState;
process_base_message(#pet_skill_buy_slot_c2s{petid = PetId,slot = Slot}, RoleState)->
	pet_skill_op:open_slot(PetId,Slot),
	RoleState;

process_base_message(#pet_swank_c2s{}, RoleState)->
	case banquet_op:pet_swank() of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg);
		_ ->
			do_no
	end,
	RoleState;
process_base_message(#pet_egg_use_c2s{slot = Slot,sex = Sex}, RoleState)->
	item_obt_pet:handle_use_pet_egg(Sex,Slot),
	RoleState;


process_base_message(#pet_sex_change_c2s{petid = Petid,sex = Sex}, RoleState)->
	item_obt_pet:change_pet_sex(Sex,Petid),
	% item_exp_gift:handle_pet_exp_item(Petid,Sex),
	RoleState;

process_base_message(#pet_exp_use_c2s{petid = Petid,slot = Slot}, RoleState)->
	% item_obt_pet:change_pet_sex(Sex,Petid),
	item_exp_gift:handle_pet_exp_item(Petid,Slot),
	RoleState;

% -record(pet_egg_use_c2s, {msgid=24000,slot,sex}).
% -record(pet_sex_change_c2s, {msgid=24001,petid,sex}).
% -record(pet_sex_change_s2c, {msgid=24002,petid,sex}).

% -record(pet_exp_use_c2s, {msgid=24003,petid,slot}).
% pet_skill_fuse_c2s

% ������
process_base_message(#pet_reset_type_attr_c2s{pet_id = PetId, type = Type, attr_list = AttrList}, RoleState)->
	case pet_reset_type_attr:do_pet_reset_type_attr(PetId, Type, AttrList, RoleState) of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg),
            Message = pet_packet:encode_pet_reset_type_attr_s2c(Type, []),
            role_op:send_data_to_gate(Message),
			RoleState;
		{ok, RoleState, NewAttr} ->
            Message = pet_packet:encode_pet_reset_type_attr_s2c(Type, NewAttr),
            role_op:send_data_to_gate(Message),
            pet_op:save_pet_to_db(PetId),
            RoleState
	end;

process_base_message(#pet_inherit_preview_c2s{main_pet_id = MainPetId, assistant_pet_id = AssistantPetId}, RoleState) ->
	case pet_inherit_op:pet_inherit_preview(MainPetId, AssistantPetId, RoleState) of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg),
			RoleState;
		{ok, RoleState} ->
			RoleState
	end;

process_base_message(#pet_inherit_c2s{main_pet_id = MainPetId, assistant_pet_id = AssistantPetId}, RoleState) ->
	case pet_inherit_op:pet_inherit(MainPetId, AssistantPetId, RoleState) of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg),
			RoleState;
		{ok, RoleState} ->
			RoleState
	end;

%%%pet_quality_riseup 
process_base_message(#pet_quality_riseup_c2s{petid = PetId, flag = Flag, up_type = Up_type}, RoleState) ->
	pet_quality_riseup_op:quality_riseup(PetId, Flag, Up_type),
	RoleState;

process_base_message(#pet_upgrade_quality_up_c2s{petid = PetId,type = Type,needs = Needs}, RoleState)->
	%pet_quality_op:pet_upgrade_quality_up(PetId,Type,Needs);
    RoleState;

%%pet add attr point
process_base_message(#pet_add_attr_c2s{petid = PetId,power_add = PowerPoint,hitrate_add = HitratePoint,criticalrate_add = CriticalratePoint,stamina_add = StaminaPoint}, RoleState)->
	%pet_add_attr_op:pet_add_attr(PetId,PowerPoint,HitratePoint,CriticalratePoint,StaminaPoint);
    RoleState;

process_base_message(#pet_wash_attr_c2s{petid = PetId,type = Type}, RoleState)->
	%pet_add_attr_op:wash_pet_attr_point(Type,PetId);
    RoleState;

process_base_message(#equip_item_for_pet_c2s{petid = PetId,slot = Slot}, RoleState)->
	handle_pet_item_equip(PetId,Slot),
	RoleState;
  
process_base_message(#unequip_item_for_pet_c2s{petid = PetId,slot = Slot}, RoleState)->
	RoleState;

process_base_message(Message = #pet_change_talent_c2s{}, RoleState)->
	%pet_talent_op:process_message(Message);
    RoleState;

process_base_message(Message = #pet_random_talent_c2s{}, RoleState)->
	%pet_talent_op:process_message(Message);
    RoleState;

process_base_message(Message = #pet_evolution_c2s{}, RoleState)->
	%pet_evolution:process_message(Message);
    RoleState;

process_base_message(#pet_skill_slot_lock_c2s{petid =PetId,slot = Slot,status = Status}, RoleState)->
	pet_skill_op:change_skill_slot_status(PetId,Slot,Status),
	RoleState;

%%pet explore 						
process_base_message(#pet_explore_info_c2s{petid = PetId}, RoleState)->
	%pet_explore_op:request_pet_explore_info(PetId);
    RoleState;

process_base_message(#pet_explore_start_c2s{petid = PetId,explorestyle = ExploreStyle,siteid = SiteId,lucky =Lucky}, RoleState)->
	%pet_explore_op:pet_explore_start(PetId,ExploreStyle,SiteId,Lucky);
   	RoleState;

process_base_message(#pet_explore_speedup_c2s{petid = PetId}, RoleState)->
	%pet_explore_op:speedup_explore(PetId);
    RoleState;

process_base_message(#pet_explore_stop_c2s{petid = PetId}, RoleState)->
	%pet_explore_op:pet_explore_stop(PetId);
    RoleState;

process_base_message(#buy_pet_slot_c2s{}, RoleState)->
	pet_op:buy_pet_slot(),
	RoleState;

%%pet explore storage 
process_base_message(#explore_storage_init_c2s{}, RoleState)->
	%explore_storage_op:explore_storage_init();
    RoleState;

process_base_message(#explore_storage_getitem_c2s{slot = Slot,itemsign = Sign}, RoleState)->
	%explore_storage_op:explore_storage_getitem(Slot,Sign);
    RoleState;

process_base_message(#explore_storage_getallitems_c2s{}, RoleState)->
	%explore_storage_op:explore_storage_getallitems();
    RoleState;

%% ��������
process_base_message(#pet_qualification_upgrade_c2s{petid = PetId, index = Index}, RoleState)->
	pet_quality_value_op:qualification_upgrade_logic(PetId, Index),
	RoleState;

% ����
process_base_message(#pet_shop_goods_c2s{}, RoleState) ->
	case pet_shop_op:pet_shop_goods(RoleState) of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg),
			RoleState;
		{ok, NewRoleState} ->
			NewRoleState
	end;

process_base_message(#buy_pet_c2s{pet_template_id = PetTempLateId, buy_type = Buy_type}, RoleState) ->
	case pet_shop_op:buy_pet(PetTempLateId, Buy_type ,RoleState) of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg),
			RoleState;
		{ok, NewRoleState} ->
			NewRoleState
	end;

process_base_message(#refresh_remain_time_c2s{gold = Gold,num = Num}, RoleState) ->
	case pet_shop_op:refresh_shop(Num,Gold) of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg);
		_ ->
				ok
	end,
	RoleState;

process_base_message(#pet_type_change_c2s{pet_id = PetId, change_type = ChangeType, flag = Flag}, RoleState) ->
	case pet_op:pet_type_change(PetId, ChangeType, Flag, RoleState) of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg),
			RoleState;
		{ok, NewRoleState} ->
			NewRoleState
	end;

process_base_message(UnknownMsg, _RoleState)->
	slogger:msg("~p unknown pet base msg ~p ~n",[?MODULE,UnknownMsg]).


handle_summon_pet_c2s(Type,PetId)->
	io:format("handle_summon_pet_c2s ~p ~p ~n",[Type,PetId]),
	case Type of
		?PET_OPT_CALLBACK->
			pet_op:call_back(PetId);
		?PET_OPT_CALLOUT->
			pet_op:call_out(PetId);
		?PET_OPT_DELETE->
			pet_op:delete_pet(PetId,true);
		?PET_OPT_RIDING->
			%%pet_op:ride_pet(PetId);
			nothing;
		?PET_OPT_DISMOUNT->
			pet_op:dismount_pet(PetId);
		_->
			todo
	end.


handle_pet_rename_c2s(PetId,NewName)->
	case senswords:word_is_sensitive(NewName) or (length(NewName) > ?MAX_PETNAME_LEN) of
		true->
			Msg = pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_NAME);
		false->
			case pet_op:pet_rename(PetId,NewName) of
				true ->
					Msg = pet_packet:encode_pet_opt_error_s2c(?PET_NAME_OK);
				_ ->
					Msg = pet_packet:encode_pet_opt_error_s2c(?ERROR_PET_NAME)
			end

	end,
	role_op:send_data_to_gate(Msg).
						
						
handle_pet_item_equip(PetId,Slot)->
	case package_op:where_slot(Slot) of
		package->
			pet_op:proc_pet_item_equip(equip,PetId,Slot);
		pet_body->
			pet_op:proc_pet_item_equip(unequip,PetId,Slot);
		_->
			nothing
	end.


												
