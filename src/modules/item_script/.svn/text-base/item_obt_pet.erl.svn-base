-module(item_obt_pet).
-export([use_item/1,use_item/2,handle_use_pet_egg/2,change_pet_sex/2]).
-include("data_struct.hrl").
-include("item_struct.hrl").
-include("pet_struct.hrl").

use_item(ItemInfo)->
	[{ProtoId, Quality}] = get_states_from_iteminfo(ItemInfo),
	QualityProto = pet_quality_proto_db:get_info(Quality),
	QualityProperties = pet_quality_proto_db:get_quality_properties_from_info(QualityProto),
	MinGrowth = pet_quality_proto_db:get_min_growth_in_quality_from_info(QualityProperties),
	slogger:msg("%%use_item ~p and ~p and 	~p ~n",[ProtoId, MinGrowth, Quality]),
	Flag = pet_op:apply_create_pet(ProtoId, MinGrowth, Quality),
	case Flag of
		false ->
			false;
		_ ->
			true
	end.

handle_use_pet_egg(Sex,Slot)->
	role_op:handle_use_item(Slot,[Sex]).

use_item(ItemInfo,Sex)->
	[{ProtoId, Quality}] = get_states_from_iteminfo(ItemInfo),
	QualityProto = pet_quality_proto_db:get_info(Quality),
	QualityProperties = pet_quality_proto_db:get_quality_properties_from_info(QualityProto),
	MinGrowth = pet_quality_proto_db:get_min_growth_in_quality_from_info(QualityProperties),
	slogger:msg("%%use_item,~p and ~p and 	~p ~n",[ProtoId, MinGrowth, Quality]),
	case pet_op:apply_create_pet(ProtoId, MinGrowth, Quality) of
		false ->
			false;
		{true,Pet_id} ->
			% self() ! {change_pet_sex,Sex,Pet_id},
			change_pet_sex(Sex,Pet_id),
			true
	end.
change_pet_sex(Sex,PetId) ->
	case pet_op:get_pet_gminfo(PetId) of
		[]->
			slogger:msg("change_pet_sex error PetId [] ~p ~n",[PetId]);
		GmPetInfo->
			OldSex = get_gender_from_petinfo(GmPetInfo),
			case Sex of
				OldSex ->
					dono;
				1 ->
					NewPetInfo = set_gender_to_petinfo(GmPetInfo, Sex),
					pet_op:update_gm_pet_info_all(NewPetInfo),
					MessageData = pet_packet:encode_pet_sex_change_s2c(PetId, Sex),
					role_op:send_data_to_gate(MessageData),
					ProtoId = get_proto_from_petinfo(NewPetInfo),
					case get_state_from_petinfo(NewPetInfo) of
						?PET_STATE_BATTLE->
							pet_attr:self_update_and_broad(PetId, [{pet_gender,Sex},{pet_proto,abs(ProtoId)}]);
						_ ->
							pet_attr:only_self_update(PetId, [{pet_gender,Sex},{pet_proto,abs(ProtoId)}])
					end;
				_ ->
					NewPetInfo = set_gender_to_petinfo(GmPetInfo, Sex),
					pet_op:update_gm_pet_info_all(NewPetInfo),
					MessageData = pet_packet:encode_pet_sex_change_s2c(PetId, Sex),
					role_op:send_data_to_gate(MessageData),
					ProtoId = get_proto_from_petinfo(NewPetInfo),
					case get_state_from_petinfo(NewPetInfo) of
						?PET_STATE_BATTLE->
							pet_attr:self_update_and_broad(PetId, [{pet_gender,Sex},{pet_proto,ProtoId + 100}]);
						_ ->
							pet_attr:only_self_update(PetId, [{pet_gender,Sex},{pet_proto,ProtoId + 100}])
					end
			end
			% NewPetInfo = set_gender_to_petinfo(GmPetInfo, Sex),
			% pet_op:update_gm_pet_info_all(NewPetInfo),
			% MessageData = pet_packet:encode_pet_sex_change_s2c(PetId, Sex),
			% role_op:send_data_to_gate(MessageData)
	end.