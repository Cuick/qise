-module (travel_battle_shop).

-include ("error_msg.hrl").
-include ("travel_battle_def.hrl").

-export ([get_shop_items/0, buy/2]).

-include ("role_struct.hrl").

get_shop_items() ->
	ShopInfo = travel_battle_db:get_shop_info(),
	Items = travel_battle_db:get_shop_item_list(ShopInfo),
	Result = [pb_util:key_value(ItemId, Price) ||
		{ItemId, Price} <- Items],
	Msg = travel_battle_packet:encode_travel_battle_open_shop_s2c(Result),
	role_op:send_data_to_gate(Msg).

buy(ItemId, Count) when Count > 0 ->
	ShopInfo = travel_battle_db:get_shop_info(),
	Items = travel_battle_db:get_shop_item_list(ShopInfo),
	Result = case lists:keyfind(ItemId, 1, Items) of
		false ->
			?TRAVEL_BATTLE_SHOP_ITEM_NOT_EXIST;
		{ItemId, Price} ->
			CreatureInfo = get(creature_info),
			RoleId = get_id_from_roleinfo(CreatureInfo),
			ScoreNeed = Price * Count,
			case role_travel_battle_db:get_role_info(RoleId) of
				[] ->
					?TRAVEL_BATTLE_SCORES_NOT_ENOUGH;
				RoleTravelBattleInfo ->
					Total = role_travel_battle_db:get_role_total(RoleTravelBattleInfo),
					TotalWin = role_travel_battle_db:get_role_total_win(RoleTravelBattleInfo),
					SerialWin = role_travel_battle_db:get_role_serial_win(RoleTravelBattleInfo),
					Gold = role_travel_battle_db:get_role_gold(RoleTravelBattleInfo),
					Ticket = role_travel_battle_db:get_role_ticket(RoleTravelBattleInfo),
					Silver = role_travel_battle_db:get_role_silver(RoleTravelBattleInfo),
					TotalScores = role_travel_battle_db:get_role_total_scores(RoleTravelBattleInfo),
					Scores = role_travel_battle_db:get_role_scores(RoleTravelBattleInfo),
					Month = role_travel_battle_db:get_role_month(RoleTravelBattleInfo),
					if
						TotalScores >= ScoreNeed ->
							case package_op:can_added_to_package_template_list([{ItemId, Count}]) of
								true ->
									role_op:auto_create_and_put(ItemId, Count, travel_battle_shop_buy),
									LeftTotalScores = TotalScores - ScoreNeed,
									Msg = travel_battle_packet:encode_travel_battle_shop_buy_s2c(
										LeftTotalScores),
									role_op:send_data_to_gate(Msg),
									role_travel_battle_db:save_role_info(RoleId, Scores, Total, 
										TotalWin, SerialWin, Gold, Ticket, Silver, LeftTotalScores, Month),
									if
										Price >= ?TRAVEL_BATTLE_SHOP_BUY_BROADCAST_BASE ->
											shop_buy_broadcast(CreatureInfo, ScoreNeed, ItemId);
										true ->
											nothing
									end,
									0;
								false ->
									?ERROR_PACKEGE_FULL
							end;
						true ->
							?TRAVEL_BATTLE_SCORES_NOT_ENOUGH
					end
			end
	end,
	if
		Result =/= 0 ->
			Msg2 = pet_packet:encode_send_error_s2c(Result),
			role_op:send_data_to_gate(Msg2);
		true ->
			nothing
	end;
buy(_, _) ->
	nothing.

shop_buy_broadcast(RoleInfo, Scores, ItemId) ->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamScores = system_chat_util:make_int_param(Scores),
	ParamItem = system_chat_util:make_int_param(ItemId),
    MsgInfo = [ParamRole,ParamScores,ParamItem],
    travel_battle_op:broadcast_to_all_servers(?TRAVEL_BATTLE_NOTICE_SHOP_BUY, MsgInfo).