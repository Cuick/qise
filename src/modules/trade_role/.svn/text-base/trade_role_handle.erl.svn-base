-module(trade_role_handle).
-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").

%%申请交易
handle_trade_role_apply_c2s(RoleId)->
	case role_manager:get_role_info(RoleId) of
		undefined ->
			slogger:msg("role: ~p  trade_role_apply_c2s  RoleId ~p undefined ~n",[get(roleid),RoleId]);
		RoleInfo ->
			ServerCkeck = get_serverid_from_roleinfo(RoleInfo) =:= get_serverid_from_roleinfo(get(creature_info)),
			NotTradingNow = not trade_role:is_trading(),
			case NotTradingNow and ServerCkeck of
				true->
					SelfState = get_state_from_roleinfo(get(creature_info)),
					OtherState = get_state_from_roleinfo(RoleInfo ),
					IsInAoi = creature_op:is_in_aoi_list(RoleId),
					if
						SelfState =:= deading->
							Errno = ?TRADE_ERROR_YOU_ARE_DEAD;
						OtherState =:= deading->
							Errno = ?TRADE_ERROR_TARGET_ARE_DEAD;
						not IsInAoi->
							Errno = ?TRADE_ERROR_IS_NOT_AOI;	
						true->
							Errno = []
					end,
					if
						Errno =/= []->
							ErrMsg = trade_role_packet:encode_trade_role_errno_s2c(Errno),
							role_op:send_data_to_gate(ErrMsg);
						true->			
							Msg = {trade_role_apply,get(roleid)},
							role_op:send_to_other_role(RoleId,Msg )
					end;
				_->
					slogger:msg("maybe hack handle_trade_role_apply_c2s is trading now! ~p ",[get(roleid)])
			end
	end.

%%接受交易
handle_trade_role_accept_c2s(RoleId)->
	case trade_role:is_in_inviter(RoleId) of
		true->
			case trade_role:is_trading() of
				false->
					case role_manager:get_role_info(RoleId) of
						undefined ->
							slogger:msg("role: ~p  trade_role_accept_c2s  RoleId ~p undefined ~n",[get(roleid),RoleId]);
						_ ->
							trade_role:remove_from_inviter(RoleId),
							%%通知对方开启
							Msg = {trade_role_accept,get(roleid)},
							role_op:send_to_other_role(RoleId,Msg)
					end;
				true->
					ErrMsg = trade_role_packet:encode_trade_role_errno_s2c(?TRADE_ERROR_TRADING_NOW),
					role_op:send_data_to_gate(ErrMsg)
			end;	
		false->
			slogger:msg("RoleId maybe hack  ~p, accpet trad with who not inviter him ~n",[get(roleid)])
	end.
	
%%拒绝交易
handle_trade_role_decline_c2s(RoleId)->
	case trade_role:is_in_inviter(RoleId) of
		true->
			trade_role:remove_from_inviter(RoleId),
			case role_manager:get_role_info(RoleId) of
				undefined ->
					nothing;
				RoleInfo->
					MsgDecline  = trade_role_packet:encode_trade_role_decline_s2c(get(roleid)),
					role_op:send_to_other_client_roleinfo(RoleInfo,MsgDecline)
			end;
		false->
			nothing
	end.

%%设置金钱
handle_set_trade_money_c2s(Money_type,Moneycount)->
	trade_role:trade_role({set_money,Money_type,Moneycount}).

%%设置物品
handle_set_trade_item_c2s(Trade_slot,Package_slot)->
	trade_role:trade_role({set_trade_item,Trade_slot,Package_slot}).

%%锁定
handle_trade_role_lock_c2s()->
	trade_role:trade_role(lock).

%%取消
handle_cancel_trade_c2s()->
	case trade_role:is_trading() of
		true->
			role_op:send_to_other_role(get(trade_target),cancel_trade),
			trade_role:trade_role(cancel);
		_->
			nothing
	end.	

%%完成交易
handle_trade_role_dealit_c2s()->
	trade_role:trade_role(deal).


%%%%%%%%%%%%%%%%%%
%% 进程间
%%%%%%%%%%%%%%%%%%

%%有人申请和你交易
handle_trade_role_apply(RoleId)->
	case role_manager:get_role_info(RoleId) of
		undefined ->
			nothing;
		RoleInfo ->	
			case trade_role:is_trading() of
				true->
					ErrMsg = trade_role_packet:encode_trade_role_errno_s2c(?TRADE_ERROR_TRADING_NOW),
					role_op:send_to_other_client_roleinfo(RoleInfo,ErrMsg);
				false->
						trade_role:insert_inviter(RoleId),
						%%通知客户端有人和你交易
						Msg =  trade_role_packet:encode_trade_role_apply_s2c(RoleId),
						role_op:send_data_to_gate(Msg )
			end
	end.


%%别人接受了和你交易
handle_trade_role_accept(RoleId)->
	case trade_role:is_trading() of
		false ->	
			case role_manager:get_role_info(RoleId) of
				undefined ->
					nothing;
				_ ->
					%%通知客户端交易开启
					MsgBegin = trade_role_packet:encode_trade_begin_s2c(RoleId),
					role_op:send_data_to_gate(MsgBegin),
					%%开启交易
					trade_role:trade_role({trade_begin,RoleId}),
					Msg = {trade_role_accept1,get(roleid)},
					role_op:send_to_other_role(RoleId,Msg)
			end;
		true ->
			case role_manager:get_role_info(RoleId) of
				undefined ->
					nothing;
				RoleInfo ->	
					ErrMsg = trade_role_packet:encode_trade_role_errno_s2c(?TRADE_ERROR_TRADING_NOW),
					role_op:send_to_other_client_roleinfo(RoleInfo,ErrMsg)	
			end
	end.
%我同意了对方的交易以后，告诉了对方。对方判断自己没有在交易的话，通知我开始交易。
handle_trade_role_accept1(RoleId)->
	%%通知客户端开启交易
	MsgBegin = trade_role_packet:encode_trade_begin_s2c(RoleId),
	role_op:send_data_to_gate(MsgBegin),
	%%开启交易
	trade_role:trade_role({trade_begin,RoleId}).

%%别人锁定了
handle_other_lock()->
	%%发送别人锁定
	trade_role:trade_role(other_lock).

handle_other_deal()->
	trade_role:trade_role(other_deal).

handle_cancel_trade()->
	trade_role:trade_role(cancel).
	
handle_trade_error()->
	trade_role:trade_role(trade_error).



