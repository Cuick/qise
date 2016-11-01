-module(pet_packet).

-compile(export_all).

-export([		
		handle/2,
		make_pet/43,
		make_pet/3,
		encode_create_pet_s2c/1,
		encode_init_pets_s2c/3,
		encode_pet_opt_error_s2c/1,
		encode_pet_present_s2c/1,
		encode_pet_present_apply_s2c/1,
		encode_pet_delete_s2c/1,
		encode_pet_training_info_s2c/3,
		encode_pet_training_init_info_s2c/3,
		encode_pet_explore_info_s2c/5,
		encode_pet_explore_error_s2c/1,
		encode_pet_explore_gain_info_s2c/2,
		encode_pet_random_talent_s2c/4,
		encode_update_item_for_pet_s2c/2,	
		encode_pet_upgrade_quality_s2c/2,	
		encode_pet_upgrade_quality_up_s2c/3,
		encode_pet_shop_time_s2c/1
		]).


-include("login_pb.hrl").
-include("data_struct.hrl").
-include("pet_struct.hrl").
-include("pet_def.hrl").
handle(Message,RolePid)->
	RolePid ! {pet_base_msg,Message}.

% encode_pet_room_s2c(Petrooms)->
% 	login_pb:encode_pet_room_s2c(#pet_room_s2c{petrooms = Petrooms}).

%%宠物进阶


encode_pet_grade_riseup_s2c(PetId, Is_success,Luckly) ->
		slogger:msg(" ~p ~p ~p ~n", [PetId, Is_success, Luckly]),
        login_pb:encode_pet_grade_riseup_s2c(#pet_grade_riseup_s2c{petid = PetId, is_success=Is_success,luckly = Luckly}).

encode_create_pet_s2c(Pet)->
	login_pb:encode_create_pet_s2c(#create_pet_s2c{pet = Pet}).

encode_init_pets_s2c(Pets,MaxNum,Present)->
	login_pb:encode_init_pets_s2c(#init_pets_s2c{pets = Pets,max_pet_num = MaxNum,present_slot = Present}).

encode_pet_opt_error_s2c(Reason)->
	login_pb:encode_pet_opt_error_s2c(#pet_opt_error_s2c{reason=Reason}).

encode_pet_training_info_s2c(PetId,TotalTime,RemainTime)->
	login_pb:encode_pet_training_info_s2c(#pet_training_info_s2c{petid = PetId,totaltime = TotalTime,remaintime = RemainTime}).

encode_pet_training_init_info_s2c(PetId,TotalTime,RemainTime)->
	login_pb:encode_pet_training_init_info_s2c(#pet_training_init_info_s2c{petid = PetId,totaltime = TotalTime,remaintime = RemainTime}).

encode_pet_present_s2c(Pps)->
	login_pb:encode_pet_present_s2c(#pet_present_s2c{present_pets=Pps}).

encode_pet_present_apply_s2c(Slot)->
	login_pb:encode_pet_present_apply_s2c(#pet_present_apply_s2c{delete_slot = Slot}). 

encode_pet_delete_s2c(PetId)->
	login_pb:encode_pet_delete_s2c(#pet_delete_s2c{petid = PetId}).

encode_pet_random_talent_s2c(Power,HitRate,Criticalrate,Stamina)->
	login_pb:encode_pet_random_talent_s2c(#pet_random_talent_s2c{power=Power,hitrate=HitRate,criticalrate=Criticalrate,stamina=Stamina}).

%%quality riseup return message
encode_pet_quality_riseup_s2c(Is_success, PetId, Lucky) ->
	login_pb:encode_pet_quality_riseup_s2c(#pet_quality_riseup_s2c{is_success = Is_success, petid=PetId, lucky=Lucky}).

%%quality return message
encode_pet_upgrade_quality_s2c(Result,QualityValue)->
	login_pb:encode_pet_upgrade_quality_s2c(#pet_upgrade_quality_s2c{result = Result,value = QualityValue}).

encode_pet_upgrade_quality_up_s2c(Type,Result,QualityUpValue)->
	login_pb:encode_pet_upgrade_quality_up_s2c(#pet_upgrade_quality_up_s2c{type = Type,result = Result,value = QualityUpValue}).


encode_update_item_for_pet_s2c(PetId,ItemUpdates)->
	login_pb:encode_update_item_for_pet_s2c(#update_item_for_pet_s2c{petid = PetId,items = ItemUpdates}).

encode_pet_item_opt_result_s2c(Errno)->
	login_pb:encode_pet_item_opt_result_s2c(#pet_item_opt_result_s2c{errno = Errno}).
	
encode_update_pet_slot_num_s2c(SlotsNum)->
	login_pb:encode_update_pet_slot_num_s2c(#update_pet_slot_num_s2c{num = SlotsNum}).



encode_init_pet_skill_slots_s2c(SlotsInfo)->
	login_pb:encode_init_pet_skill_slots_s2c(#init_pet_skill_slots_s2c{pslots = SlotsInfo}).

encode_learned_pet_skill_s2c(SkillInfo)->
	login_pb:encode_learned_pet_skill_s2c(#learned_pet_skill_s2c{pskills = SkillInfo}).

encode_update_pet_skill_slot_s2c(PetId,SlotInfo)->
	login_pb:encode_update_pet_skill_slot_s2c(#update_pet_skill_slot_s2c{petid = PetId,slot = SlotInfo}).

encode_update_pet_skill_s2c(PetId,SkillInfo)->
	login_pb:encode_update_pet_skill_s2c(#update_pet_skill_s2c{petid = PetId,skills = SkillInfo}).


%%pet explore
encode_pet_explore_info_s2c(PetId,RemainTimes,SiteId,ExploreStyle,LeftTime)->
	login_pb:encode_pet_explore_info_s2c(#pet_explore_info_s2c{petid = PetId,remaintimes = RemainTimes,siteid = SiteId,explorestyle = ExploreStyle,lefttime = LeftTime}).

encode_pet_explore_error_s2c(Error)->
	login_pb:encode_pet_explore_error_s2c(#pet_explore_error_s2c{error = Error}).

encode_pet_explore_gain_info_s2c(PetId,ItemList)->
	login_pb:encode_pet_explore_gain_info_s2c(#pet_explore_gain_info_s2c{petid = PetId,gainitem = ItemList}).



encode_pet_learn_skill_cover_best_s2c(PetId,Slot,SkillId,OldLevel,NewLevel)->
	login_pb:encode_pet_learn_skill_cover_best_s2c(#pet_learn_skill_cover_best_s2c{petid = PetId,
																				   slot = Slot,
																				   skillid = SkillId,
																				   oldlevel = OldLevel,
																				   newlevel = NewLevel}).

%%pet explore storage
encode_pet_cur_heart_s2c(PetId,Heart) ->
	login_pb:encode_pet_cur_heart_s2c(#pet_cur_heart_s2c{petid = PetId,heart = Heart}).
encode_explore_storage_info_s2c(Items)->
	login_pb:encode_explore_storage_info_s2c(#explore_storage_info_s2c{items = Items}).

encode_explore_storage_init_end_s2c()->
	login_pb:encode_explore_storage_init_end_s2c(#explore_storage_init_end_s2c{}).

encode_explore_storage_updateitem_s2c(UpdateItems)->
	login_pb:encode_explore_storage_updateitem_s2c(#explore_storage_updateitem_s2c{itemlist = UpdateItems}).

encode_explore_storage_additem_s2c(AddItems)->
	login_pb:encode_explore_storage_additem_s2c(#explore_storage_additem_s2c{items = AddItems}).

encode_explore_storage_delitem_s2c(Start,Length)->
	login_pb:encode_explore_storage_delitem_s2c(#explore_storage_delitem_s2c{start = Start,length = Length}).

encode_explore_storage_opt_s2c(Error)->
	login_pb:encode_explore_storage_opt_s2c(#explore_storage_opt_s2c{code = Error}).
encode_pet_savvy_up_s2c(IsSucess, Savvy, MaxSavvy) ->
	login_pb:encode_pet_savvy_up_s2c(#pet_savvy_up_s2c{is_sucess = IsSucess, savvy = Savvy, max_savvy = MaxSavvy} ).

%% 宠物资质编码
encode_pet_qualification_upgrade_s2c(Is_success)->
	login_pb:encode_pet_qualification_upgrade_s2c(#pet_qualification_upgrade_s2c{is_success = Is_success}).

%% 宠物精炼 % yz
encode_pet_reset_type_attr_s2c(Type, AttrList) ->
    login_pb:encode_pet_reset_type_attr_s2c(#pet_reset_type_attr_s2c{type=Type, attrlist=AttrList}).

% 宠物商店
encode_pet_shop_goods_s2c(RemainTime, PetGoodsList) ->
	PetShopInfoList = to_pet_shop_info(PetGoodsList),
	login_pb:encode_pet_shop_goods_s2c(#pet_shop_goods_s2c{remain_time = RemainTime, pet_goods = PetShopInfoList}).

% 宠物类型转换
encode_pet_type_change_s2c(PetId, NewType) ->
	login_pb:encode_pet_type_change_s2c(#pet_type_change_s2c{pet_id = PetId, new_type = NewType}).

% 发送错误码(通用)
encode_send_error_s2c(Code) ->
	login_pb:encode_send_error_s2c(#send_error_s2c{error_code = Code}).

encode_pet_inherit_s2c(MainPetId) ->
	login_pb:encode_pet_inherit_s2c(#pet_inherit_s2c{main_pet_id = MainPetId}).

encode_pet_inherit_preview_s2c(New_pet_info) ->
	login_pb:encode_pet_inherit_preview_s2c(#pet_inherit_preview_s2c{new_pet_info = New_pet_info}).

encode_pet_room_s2c(Petrooms) ->
	login_pb:encode_pet_room_s2c(#pet_room_s2c{petrooms = Petrooms}).

encode_pet_opend_room_s2c(Openrooms) ->
	login_pb:encode_pet_opend_room_s2c(#pet_opend_room_s2c{opend_rooms = Openrooms}).

encode_pet_open_room_s2c(Room) ->
	login_pb:encode_pet_open_room_s2c(#pet_open_room_s2c{room =Room}).

encode_pet_into_room_s2c(Room_id,Petid,StartTime) ->
	login_pb:encode_pet_into_room_s2c(#pet_into_room_s2c{room_id = Room_id,petid = Petid,star_time = StartTime}).

encode_pet_shop_rfresh_s2c(Goods) ->
	login_pb:encode_pet_shop_rfresh_s2c(#pet_shop_rfresh_s2c{goods = Goods}).

encode_gold_get_exp_s2c(Room_id,Petid,Gold,Exp) ->
	login_pb:encode_gold_get_exp_s2c(#gold_get_exp_s2c{room_id = Room_id,petid = Petid,gold = Gold,exp = Exp}).

encode_room_balance_s2c(Room_id,Petid) ->
	login_pb:encode_pet_room_balance_s2c(#pet_room_balance_s2c{room_id = Room_id,petid = Petid}).

encode_pet_shop_account_s2c(Value) ->
	login_pb:encode_pet_shop_account_s2c(#pet_shop_account_s2c{value = Value}).

encode_pet_shop_luck_s2c(Value) ->
	login_pb:encode_pet_shop_luck_s2c(#pet_shop_luck_s2c{value = Value}).

encode_pet_skill_fuse_s2c(Skillid) ->
	login_pb:encode_pet_shop_luck_s2c(#pet_skill_fuse_s2c{skillid = Skillid}).

encode_pet_skill_buy_slot_s2c(Slot) ->
	login_pb:encode_pet_shop_luck_s2c(#pet_skill_buy_slot_s2c{slot = Slot}).

encode_pet_sex_change_s2c(PetId,Sex) ->
	login_pb:encode_pet_sex_change_s2c(#pet_sex_change_s2c{petid = PetId,sex = Sex}).

encode_pet_shop_time_s2c(Times) ->
	login_pb:encode_pet_shop_time_s2c(#pet_shop_times_s2c{times = Times}).




to_pet_shop_info(PetGoodsList) ->
	lists:foldl(fun({PetTempLateId, Price}, Acc) ->
				Acc ++ [#pet_shop_info{pet_template_id = PetTempLateId, pet_price = Price}]
		end, [], PetGoodsList).



make_pet(PetInfo,GmPetInfo,ItemsInfo)->
	#my_pet_info{
			petid = PetId,			
			attr = {PowerAttr,HitrateAttr,DodgeAttr,CriticalrateAttr,CriticaldamageAttr,LifeAttr,Toughness,MagicDefenseAttr,FarDefenseAttr,NearDefenseAttr},
			%quality_value_info = {Quality_Value_Power,Quality_Value_Hitrate,Quality_Value_Dodge,Quality_Value_Criticalrate,Quality_Value_Criticaldamage,Quality_Value_Life,Quality_Value_Defense},		
			quality_value_info = Quality_Value_Info,		
            quality_value_up_info = Quality_Value_Up_Info,
			trade_lock = Trad_Lock,
		    quality_riseup_retries = PetStage,
			grade_riseup_lucky = Grade_Riseup_Lucky,
            quality_riseup_lucky = Quality_riseup_lucky
			} = PetInfo,
	#gm_pet_info{
			proto = Proto,
			level = Level,
			name = Name,
			gender = Gender,
			mana = Mana,
			quality = Quality,
			exp = Exp,
			class = Class,
			state = State,
			mpmax = Mpmax,
			power = Power,				
			hitrate = Hitrate,
			criticalrate = Criticalrate,	
			criticaldamage = CriticalDestoryrate,	
			fighting_force = Fighting_Force,
            grade = Grade,
            savvy = Savvy,
            life = Life,
            dodge = Dodge,
            defense = Defense,
			magic_defense = MagicDefense,
			far_defense = FarDefense,
			near_defense = NearDefense,
			magic_immunity = MagicImmunity,
			far_immunity = FarImmunity,
			near_immunity = NearImmunity,
			current_heart = Happy,
			refresh_defense = Refresh_defense
			} = GmPetInfo,
    New_Quality_riseup_lucky = case Quality_riseup_lucky of
        {_, Real_Quality_riseup_lucky} -> Real_Quality_riseup_lucky;
        _ -> 0
    end,
    slogger:msg("quality_riseup_lucky ~p ~p ~n", [Quality_riseup_lucky, New_Quality_riseup_lucky]),
	Pet_Items = lists:map(fun(ItemInfo)->pb_util:to_item_info(ItemInfo) end,ItemsInfo),
	make_pet(PetId, Proto, Level, Name, Gender, Mana, Quality, Exp, Mpmax, Power, Hitrate, Dodge, Criticalrate, CriticalDestoryrate, Life, Defense, Fighting_Force, PowerAttr, HitrateAttr, DodgeAttr, CriticalrateAttr, CriticaldamageAttr, LifeAttr, 0, Class, State, Quality_Value_Info, Quality_Value_Up_Info, Pet_Items, Trad_Lock, Grade, Savvy, Grade_Riseup_Lucky, New_Quality_riseup_lucky, PetStage, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity,Happy,Refresh_defense).

make_pet(Petid, Proto, Level, Name, Gender, Mana, Quality, Exp, Mpmax, Power, Hitrate, Dodge, Criticalrate, Criticaldamage, Life, Defense, Fighting_Force, PowerAttr, HitrateAttr, DodgeAttr, CriticalrateAttr, CriticaldamageAttr, LifeAttr, DefenseAttr, Class_type, State, _Quality_Value_Info, _Quality_Value_Up_Info, Pet_Items, Trad_Lock, Grade, Savvy, Grade_Riseup_Lucky, Quality_riseup_lucky, PetStage, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity,Happy,Refresh_defense)->
% slogger:msg("111111111111111111111111111111:~p~n",[Happy]),
	#p{
		petid = Petid,
		protoid = Proto,
		level = Level,
		name = Name,
		gender = Gender,
		mana = Mana,
		quality = Quality,
		exp = Exp,
		power = Power,
		hitrate = Hitrate,
		dodge = Dodge,
		criticalrate = Criticalrate,
		criticaldamage = Criticaldamage,
		life = Life,
		defense = Defense,
		fighting_force = Fighting_Force,
		power_attr = PowerAttr,
		hitrate_attr = HitrateAttr,
        dodge_attr = DodgeAttr,		
		criticalrate_attr = CriticalrateAttr,	
		criticaldamage_attr = CriticaldamageAttr,
		mpmax = Mpmax,
		class_type = Class_type,
		state = State,
		pet_equips = Pet_Items,
	  	trade_lock = Trad_Lock,
		grade = Grade,
		savvy = Savvy,
		grade_riseup_lucky = Grade_Riseup_Lucky,
        quality_riseup_lucky = Quality_riseup_lucky,
		pet_stage = PetStage,
		magic_defense = MagicDefense,
		far_defense = FarDefense,
		near_defense = NearDefense,
		magic_immunity = MagicImmunity,
		far_immunity = FarImmunity,
		near_immunity = NearImmunity,
		happy = Happy,
		refresh_defense = Refresh_defense
	}.

make_psll(Slot,Status)->
	#psll{slot = Slot,status = Status}.

make_psl(PetId,PsllInfo)->
	#psl{petid = PetId,slots = PsllInfo}.

make_psk(Slot,SkillID,Level)->
	#psk{slot = Slot,skillid = SkillID,level = Level}.

make_ps(PetId,SkillsInfo)->
	#ps{petid = PetId,skills = SkillsInfo}.

make_lti(ProtoId,Count)->
	#lti{protoid = ProtoId,item_count = Count}.

	
make_rooom(Pet_room) ->
	#pet_room{
		pet_id = PetId,
		room_id = Roomid,   	
		start_time = Start_time0,			%开始时间
		duration = Duration
	} = Pet_room,
	Start_time1 = now_to_seconds(Start_time0),
	Now = now_to_seconds(now()),
	Start_time2 = Duration*60*20 -(Now - Start_time1),
	Start_time = case Start_time2 > 0 of
		 		true	->
		 			Start_time2;
		 		_  ->
		 			0
				end,
	make_rooom(PetId,Roomid,Start_time,Duration).
make_rooom(PetId,Roomid,Start_time,Duration) ->
	#pr{
		pet_id = PetId,
		room_id = Roomid,   	
		start_time = Start_time,
		duration = Duration
	}.
now_to_seconds({MegaSecs, Secs, _}) ->MegaSecs * 1000000 + Secs.