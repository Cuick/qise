
-module(pet_heart_op).

-export([add_pet_happiness/2]).

-include("pet_def.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").
add_pet_happiness(PetId,Happiness) ->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			slogger:msg("pet_feed error PetId ~p Roleid ~p ~n",[PetId,get(roleid)]),
			false;
		GmPetInfo->
			case get_heart_from_petinfo(GmPetInfo) >= 100 of
				true ->
					full;
				_ ->
					NewHeart = min(Happiness + get_heart_from_petinfo(GmPetInfo),100),
					NewGmPetInfo = set_heart_to_petinfo(GmPetInfo,NewHeart),
					pet_op:update_gm_pet_info_all(NewGmPetInfo),
					PetInfo = pet_op:get_pet_info(PetId),
					MessageBin = pet_packet:encode_pet_cur_heart_s2c(PetId,NewHeart),
					role_op:send_data_to_gate(MessageBin),
					% NewPetInfo = set_changenameflag_to_mypetinfo(PetInfo,?PET_CHANGE_NAME),
					% update_pet_info_all(NewPetInfo),
					% game_rank_manager:updata_pet_rank_info(PetId,NewName),
					% case get_state_from_petinfo(NewGmPetInfo) of
					% 	?PET_STATE_BATTLE->
					% 		pet_attr:self_update_and_broad(PetId, [{name,NewName}]);
					% 	_->
					% 		pet_attr:only_self_update(PetId, [{name,NewName}])
					% end,
					true
			end
	end.
