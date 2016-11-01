-module(item_exp_gift).
-export([use_item/1,use_item/2,handle_pet_exp_item/2]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("item_define.hrl").
-include("pet_struct.hrl").
-include("error_msg.hrl").

use_item(ItemInfo)->
	Moneys = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
	case lists:keyfind(exp_add, 1, Moneys) of
		{_,Value}->
			if
				Class =:= ?ITEM_TYPE_PET_EXP->
					obtain_exp(Value);	
				true ->
					role_op:obtain_exp(Value),
					true
			end;
		_->
			false
	end.
handle_pet_exp_item(PetId,Slot)->
	role_op:handle_use_item(Slot,[PetId]).

use_item(ItemInfo,PetId)->
	EffectList = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
	if
		Class =:= ?ITEM_TYPE_PET_EXP->
			case lists:keyfind(exp_add, 1, EffectList) of
				{_,Value}->
					obtain_exp(Value,PetId),
					true;
				_->
					ErrorMsg = pet_packet:encode_pet_opt_error_s2c(5),
					role_op:send_data_to_gate(ErrorMsg),
					false
			end;
		true ->
			false
	end.
obtain_exp(Value) ->
	case pet_op:get_out_pet() of
		[]->
			ErrorMsg = pet_packet:encode_pet_opt_error_s2c(?NO_PET_OUT),
			role_op:send_data_to_gate(ErrorMsg),
			false;
		PetInfo->
			pet_level_op:obt_exp(PetInfo, Value),
			true
	end.

obtain_exp(Value,PetId) ->
	case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			ErrorMsg = pet_packet:encode_pet_opt_error_s2c(17010),
			role_op:send_data_to_gate(ErrorMsg);
		GmPetInfo->
			pet_level_op:obt_exp(GmPetInfo,Value)
	end.