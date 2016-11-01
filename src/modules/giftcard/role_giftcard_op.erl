-module(role_giftcard_op).

-include("error_msg.hrl").

-export([hook_on_online/1,gift_card_apply_c2s/2]).

-define(ROLE_CARD_STATE_GIFT,1).
-define(ROLE_CARD_STATE_NOT_GIFT,0).

hook_on_online(RoleId)->
	Url = env:get(gift_card_url, []),
	case giftcard_db:get_role_status(RoleId, 1) of
		false->			%%not gift
			State = ?ROLE_CARD_STATE_NOT_GIFT;
		_->
			State = ?ROLE_CARD_STATE_GIFT
	end,
	Msg = giftcard_packet:encode_gift_card_state_s2c(Url,State),
	role_op:send_data_to_gate(Msg).		
			
gift_card_apply_c2s(KeyStr, Type) ->
	case giftcard_db:get_role_status(get(roleid), Type) of
		false->			%%not gift
			case giftcard_db:get_card_status(KeyStr, Type) of
				nocard->
					Errno = ?ERROR_CARD_NUMBER;		
				havegot->
					Errno = ?ERROR_CARD_HAVE_BEEN_GIFT;
				havenotgot->
					case env:get(gift_card_itemid, []) of
						[]->
							Errno = ?ERROR_CARD_UNKNOWN;
						{FresherCardId, MediaCardId,_,_,_}->
							ItemProtoId = if
								Type =:= 1 ->
									FresherCardId;
								true ->
									MediaCardId
							end,
							case role_op:auto_create_and_put(ItemProtoId,1,got_gift_card) of
								{ok,_}->
									Errno = 0,
									giftcard_db:write_data(KeyStr,get(roleid), Type);
								_->
									Errno = -1
							end
					end;
				_->
					Errno = ?ERROR_CARD_NUMBER	
			end;
		true->			%%has gift
			Errno = ?ERROR_CARD_HAVE_GIFT;
		_->				%%error
			Errno = ?ERROR_CARD_UNKNOWN
	end,
	if
		Errno =/=-1 ->
			Msg = giftcard_packet:encode_gift_card_apply_s2c(Errno),
			role_op:send_data_to_gate(Msg);
		true->
			nothing
	end.


	

