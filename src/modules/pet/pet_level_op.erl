-module(pet_level_op).

-compile(export_all).

-include("data_struct.hrl").
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("role_struct.hrl").
-include("pet_struct.hrl").

obt_exp(GmPetInfo,AddExp)->
	RoleLeve = get_level_from_roleinfo(get(creature_info)),
	ToatlExp = get_totalexp_from_petinfo(GmPetInfo),
	{NewLevel,NewExp} =  pet_level_db:get_level_and_exp(ToatlExp+AddExp),
	PetId = get_id_from_petinfo(GmPetInfo),
	if
		NewLevel > RoleLeve->
			false;
		true->
			OldLevel = get_level_from_petinfo(GmPetInfo),
			if
				OldLevel=/= NewLevel->
					NewGmPetInfo = GmPetInfo#gm_pet_info{totalexp=ToatlExp+AddExp,exp = NewExp,level = NewLevel},
					pet_op:update_gm_pet_info_all(NewGmPetInfo),
					pet_util:recompute_attr(levelup,PetId),
					gm_logger_role:pet_level_up(get(roleid),PetId,get_proto_from_petinfo(GmPetInfo),RoleLeve,NewLevel);
				true->
					pet_attr:only_self_update(PetId,[{expr,NewExp}]),
					NewGmPetInfo = GmPetInfo#gm_pet_info{totalexp=ToatlExp+AddExp,exp = NewExp},
					pet_op:update_gm_pet_info_all(NewGmPetInfo)
			end,
			achieve_op:achieve_update({pet_level},[0],NewLevel),
			true
	end.
obt_exp_hostel(GmPetInfo,AddExp)->
	RoleLeve = get_level_from_roleinfo(get(creature_info)),
	ToatlExp = get_totalexp_from_petinfo(GmPetInfo),
	{NewLevel,NewExp} =  pet_level_db:get_level_and_exp(ToatlExp+AddExp),
	PetId = get_id_from_petinfo(GmPetInfo),
	if
		NewLevel > RoleLeve->
			OldLevel=get_level_from_petinfo(GmPetInfo),
			PetLevelInfo=pet_level_db:get_info(RoleLeve+1),
			PetLevelInfo1=pet_level_db:get_info(RoleLeve),
			TheExp=pet_level_db:get_exp(PetLevelInfo)-1,
			TheLevelExe = TheExp-pet_level_db:get_exp(PetLevelInfo1),
			if
			OldLevel=/= RoleLeve->
					NewGmPetInfo = GmPetInfo#gm_pet_info{totalexp=TheExp,exp = TheLevelExe,level = RoleLeve},
					pet_op:update_gm_pet_info_all(NewGmPetInfo),
					pet_util:recompute_attr(levelup,PetId),
					gm_logger_role:pet_level_up(get(roleid),PetId,get_proto_from_petinfo(GmPetInfo),RoleLeve,RoleLeve);
				true->
					pet_attr:only_self_update(PetId,[{expr,TheLevelExe}]),
					NewGmPetInfo = GmPetInfo#gm_pet_info{totalexp=TheExp,exp = TheLevelExe},
					pet_op:update_gm_pet_info_all(NewGmPetInfo)
			end,
			achieve_op:achieve_update({pet_level},[0],NewLevel),
			false;
		true->
			OldLevel = get_level_from_petinfo(GmPetInfo),
			if
				OldLevel=/= NewLevel->
					NewGmPetInfo = GmPetInfo#gm_pet_info{totalexp=ToatlExp+AddExp,exp = NewExp,level = NewLevel},
					pet_op:update_gm_pet_info_all(NewGmPetInfo),
					pet_util:recompute_attr(levelup,PetId),
					gm_logger_role:pet_level_up(get(roleid),PetId,get_proto_from_petinfo(GmPetInfo),RoleLeve,NewLevel);
				true->
					pet_attr:only_self_update(PetId,[{expr,NewExp}]),
					NewGmPetInfo = GmPetInfo#gm_pet_info{totalexp=ToatlExp+AddExp,exp = NewExp},
					pet_op:update_gm_pet_info_all(NewGmPetInfo)
			end,
			achieve_op:achieve_update({pet_level},[0],NewLevel),
			true
	end.
	
get_pet_max_level()->
	case get(gm_pets_info) of
		[]->
			0;
		GmPetInfoList->
			lists:foldl(fun(GmPetInfo,Acc)->
								PetLevel = get_level_from_petinfo(GmPetInfo),
								if 
									PetLevel >= Acc ->
										PetLevel;
									true->
										Acc
								end
						end,0,GmPetInfoList)
	end.

