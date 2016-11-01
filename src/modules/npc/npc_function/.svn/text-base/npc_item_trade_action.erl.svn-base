-module (npc_item_trade_action).

-behaviour(npc_function_mod).

-include ("npc_define.hrl").
-include ("mnesia_table_def.hrl").
-include ("login_pb.hrl").
-include ("error_msg.hrl").

-export([init_func/0,registe_func/1,enum/3]).

-export ([item_trade_action/5]).

init_func()->
	npc_function_frame:add_function(item_trade, ?NPC_FUNCTION_ITEM_TRADE,?MODULE).

registe_func(NpcId)->
	Mod= ?MODULE,
	Fun= item_trade_action,
	TradeItemList = read_trade_list(NpcId),
	Response= #kl{key=?NPC_FUNCTION_ITEM_TRADE, value=TradeItemList},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	Action = {Mod,Fun,TradeItemList},
	Enum   = {EnumMod,EnumFun,TradeItemList},
	{Response,Action,Enum}.

enum(_,TradeItemList,_)->
	#kl{key=?NPC_FUNCTION_ITEM_TRADE, value=TradeItemList}.

read_trade_list(NpcId) ->
	case dal:read_rpc(npc_sell_list, NpcId) of
		{ok,[ItemList]}->  element(#npc_sell_list.sellitems,ItemList);
		_->[]
	end.

item_trade_action(RoleInfo, TradeList, buy, ItemId, ItemCount) ->
	Result = case lists:keyfind(ItemId, 1, TradeList) of
		false ->
			?ERROR_UNKNOWN;
		{ItemId, LimitCount, Conditions} ->
			case check_item_count(ItemId, ItemCount, LimitCount) of
				true ->
					case check_condition_items(Conditions) of
						true ->
							case package_op:can_added_to_package_template_list([{ItemId, ItemCount}]) of
								true ->
									consume_items(Conditions),
									add_item_to_history(ItemId, ItemCount),
									0;
								false ->
									?ERROR_PACKAGE_FULL
							end;
						false ->
							?ERROR_MISS_ITEM
					end;
				false ->
					?ERROR_COUNT_RESTRICT
			end
	end,
	if
		Result =:= 0 ->
			role_op:auto_create_and_put(ItemId, ItemCount, npc_item_trade);
		true ->
			Msg = pet_packet:encode_send_error_s2c(Result),
			role_op:send_data_to_gate(Msg)
	end.

check_item_count(ItemId, ItemCount, LimitCount) ->
	case role_top_bar_item_db:get_role_awards(get(roleid)) of
		[] ->
			true;
		Awards ->
			case lists:keyfind(ItemId, 1, Awards) of
				false ->
					ItemCount =< LimitCount;
				{ItemId, NowCount} ->
					NowCount + ItemCount =< LimitCount
			end
	end.

check_condition_items(Conditions) ->
	lists:all(fun({ItemId, Count}) ->
		package_op:get_counts_by_template_in_package(ItemId) >= Count
	end, Conditions).

consume_items(Conditions) ->
	lists:foreach(fun({ItemId, Count}) ->
		role_op:consume_items(ItemId, Count)
	end, Conditions).

add_item_to_history(ItemId, Count) ->
	RoleId = get(roleid),
	NewAwards = case role_top_bar_item_db:get_role_awards(RoleId) of
		[] ->
			[{ItemId, Count}];
		Awards ->
			case lists:keyfind(ItemId, 1, Awards) of
				false ->
					[{ItemId, Count} | Awards];
				{ItemId, OldCount} ->
					lists:keyreplace(ItemId, 1, Awards, {ItemId, Count + OldCount})
			end
	end,
	role_top_bar_item_db:save_role_awards(RoleId, NewAwards).
