-module(loot_with_limits).
-export([use_item/1]).

-include("data_struct.hrl").
-include("item_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").

use_item(ItemInfo)->
	Rules = get_states_from_iteminfo(ItemInfo),
	case is_tuple(Rules) andalso erlang:tuple_size(Rules) =:= 2 of
		true ->
			{DropList, ExtraCondition} = Rules,
			case package_op:get_empty_slot_in_package(erlang:length(DropList)) of
				0->
					Message = role_packet:encode_add_item_failed_s2c(?ERROR_PACKEGE_FULL),
					role_op:send_data_to_gate(Message);
				_->
					case lists:keyfind(money, 1, ExtraCondition) of
						false ->
							ObtItemsApply = drop:apply_quest_droplist(DropList),
							lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_giftplayer) end,ObtItemsApply),
							true;
						{money, MoneyType, Num} ->
							case role_op:check_money(MoneyType, erlang:abs(Num)) of
								false ->
                                    Message = case MoneyType of
                                                  ?MONEY_BOUND_SILVER ->
                                                      role_packet:encode_add_item_failed_s2c(?ERRNO_MAIL_NOTENOUGH_SILVER);
                                                  ?MONEY_SILVER ->
                                                      role_packet:encode_add_item_failed_s2c(?ERRNO_MAIL_NOTENOUGH_SILVER);
                                                  ?MONEY_GOLD ->
                                                      role_packet:encode_add_item_failed_s2c(?ERROR_LESS_GOLD);
                                                  ?MONEY_TICKET ->
                                                      role_packet:encode_add_item_failed_s2c(?ERROR_LESS_TICKET);
                                                  ?MONEY_CHARGE_INTEGRAL ->
                                                      role_packet:encode_add_item_failed_s2c(?ERROR_LESS_INTEGRAL);
                                                  ?MONEY_CONSUMPTION_INTEGRAL ->
                                                      role_packet:encode_add_item_failed_s2c(?ERROR_LESS_INTEGRAL);
                                                  ?MONEY_HONOR ->
                                                      role_packet:encode_add_item_failed_s2c(?ERROR_LESS_HONOR)
                                              end,
									role_op:send_data_to_gate(Message);
								true ->
									role_op:money_change(MoneyType, Num, use_item),
									ItemId = get_template_id_from_iteminfo(ItemInfo),
									broadcast_op:use_item(ItemId),
									ObtItemsApply = drop:apply_quest_droplist(DropList),
									lists:foreach(fun({Itemid,ItemCount})->role_op:auto_create_and_put(Itemid,ItemCount,got_giftplayer) end,ObtItemsApply),
									true
							end
					end
			end;
		false ->
			Message = role_packet:encode_add_item_failed_s2c(?ERROR_SYSTEM),
			role_op:send_data_to_gate(Message)
	end.
