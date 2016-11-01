%% Author: MacX
%% Created: 2011-8-23
%% Description: TODO: Add description to item_skill_book
-module(item_skill_book).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([use_item/2,handle_learn_skill_with_book/3]).
-include("item_struct.hrl").
-include("item_define.hrl").
-include("pet_define.hrl").
-include("error_msg.hrl").
%%
%% API Functions



%%Force => lock_slot_list,[slot1,slot2....]
use_item(ItemInfo,{PetId,Force})->
	SkillBookInfo = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
	if
		Class =:= ?ITEM_TYPE_SKILL_BOOK->
			case lists:keyfind(skill_book, 1, SkillBookInfo) of
				{_,SkillId,SkillLevel}->
					case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_PET_SKILL_SOLT_LOCK,length(Force)) of
						false ->
							Errno = ?LESS_PET_SKILL_LOCK,
							role_op:send_data_to_gate(pet_packet:encode_pet_opt_error_s2c(Errno)),
							false;
						_ ->
							npc_skill_study:do_pet_learn_without_npc(PetId, SkillId, SkillLevel,Force)
					end;
				_->
					false
			end;
		true->
			false
	end.
%%
%% Local Functions
%%
handle_learn_skill_with_book(PetId,Slot,Force)->
	case travel_battle_op:is_in_zone() of
		false ->
			role_op:handle_use_item(Slot,[{PetId,Force}]);
		true ->
			Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_INVALID_OPERATION),
			role_op:send_data_to_gate(Msg)
	end.
