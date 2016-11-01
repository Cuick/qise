-module(pet_shop_op).

-export([buy_pet/3, 
		commom_send/0,refresh_shop/2,put_shop_info/0,pet_shop_goods/1,
		do_clear/0,save_test/0]).

-include("pet_def.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").
-include("error_msg.hrl").

-define(PET_SHOP_CONFIG_ETS, pet_shop_config).
-define(ONCE_EFRESH_GOLD, 10).	% 刷新剩余时间所需元宝
-define(SOME_EFRESH_GOLD, 110).

-define(ONCE_ADD_LUCK, 5).
-define(SOME_ADD_LUCK, 120).

-define(ONCE_ADD_ACCOUNT, 1).
-define(SOME_ADD_ACCOUNT, 24).

-define(MONEY_GOLD_AND_TICKET,11).

-define(FREE_TIMES,3).

% 积分不够  18000
% 兑换物品不存在	18001

% encode_pet_shop_account_s2c(Value) ->
% encode_pet_shop_luck_s2c(Value) ->

commom_send() ->
	PetShopGoodsList = pet_shop_db:pet_shop_goods(),
	Luck = get(pet_luck_high),
	Account = get(pet_account),
	Times = ?FREE_TIMES - length(get(pet_refresh_used)),
	PetShopGoods = get(pet_can_buy_goods),
	MsgLuck = pet_packet:encode_pet_shop_luck_s2c(Luck),
	MsgAccount = pet_packet:encode_pet_shop_account_s2c(Account),
	Msg = pet_packet:encode_pet_shop_goods_s2c(?PET_SHOP_REFRESH_TIME, PetShopGoodsList),
	MsgTime = pet_packet:encode_pet_shop_time_s2c(Times),
	MsgCanBuy = pet_packet:encode_pet_shop_rfresh_s2c(PetShopGoods),
	role_op:send_data_to_gate(MsgCanBuy),
	role_op:send_data_to_gate(MsgLuck),
	role_op:send_data_to_gate(MsgAccount),
	role_op:send_data_to_gate(Msg),
	role_op:send_data_to_gate(MsgTime).



refresh_shop(Type,Flag) ->
	{Need_gold, Add_luck, Addaccount} = 
		case Type of
			1 ->%%once
				{?ONCE_EFRESH_GOLD,?ONCE_ADD_LUCK,?ONCE_ADD_ACCOUNT};
			0 ->%%some
				{?SOME_EFRESH_GOLD,?SOME_ADD_LUCK,?SOME_ADD_ACCOUNT}
		end,
	case Flag of 
		0 ->
			do_refresh(Type,gold,Need_gold, Add_luck, Addaccount);
		1 ->
			do_refresh(Type,b_gold,Need_gold, Add_luck, Addaccount)
	end.
do_refresh(Type,Flag,Need_gold, Add_luck, Addaccount) ->
	Used_record = get(pet_refresh_used),
	case Type of
		1  ->
			case check_refresh_times(Used_record) of
				false ->
					refresh(Type,Flag,Need_gold, Add_luck, Addaccount,Used_record,true);
				true ->
					refresh(Type,Flag,Need_gold, Add_luck, Addaccount,Used_record,false)
			end;
		_ ->
			refresh(Type,Flag,Need_gold, Add_luck, Addaccount,Used_record,true)
	end.
	
refresh(Type,Flag,Need_gold, Add_luck, Addaccount,Used_record,Gold_or_Free)->
	if
		Gold_or_Free ->
			% 扣除元宝
			case Flag of 
				gold ->
					case role_op:check_money(?MONEY_GOLD, Need_gold) of
						false ->
							{error, ?ERROR_LESS_GOLD};
						true ->
							case role_op:money_change(?MONEY_GOLD, -Need_gold, pet_shop_refresh) of
								ok ->
									% slogger:msg("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1~p"),
									put_and_send(Used_record,Type,Flag,Add_luck,Addaccount);
								_ ->
									{error, ?ERROR_LESS_GOLD}
							end
					end;
				b_gold ->
					RoleInfo = get(creature_info),
					B_gold = get_ticket_from_roleinfo(RoleInfo),
					if 
						B_gold >= Need_gold ->
							role_op:money_change(?MONEY_TICKET, -Need_gold, pet_shop_refresh),
							put_and_send(Used_record,Type,Flag,Add_luck,Addaccount);
						true ->
							case role_op:check_money(?MONEY_GOLD, Need_gold - B_gold) of
								false ->
									{error, ?ERROR_LESS_GOLD};
								true ->
									role_op:money_change(?MONEY_TICKET, -B_gold, pet_shop_refresh),
									role_op:money_change(?MONEY_GOLD, B_gold-Need_gold, pet_shop_refresh),
									put_and_send(Used_record,Type,Flag,Add_luck,Addaccount)
							end
					end
			end;
		true ->
			put_and_send(Used_record,Type,Flag,Add_luck,Addaccount)
	end.
put_and_send(Used_record0,Type,Flag,Add_luck,Addaccount) ->
	Used_record = get(pet_refresh_used),
	PetShopGoods = pet_shop_db:random_pet_goods(Type,Flag),
	case Type of
		1  ->
			New_Times = ?FREE_TIMES - length(Used_record)-1,
			case length(Used_record) of
				_ when length(Used_record) > ?FREE_TIMES  ->
					nothing;
				_ ->
					put(pet_refresh_used,Used_record++[date()])
			end;
		_ ->
			New_Times = ?FREE_TIMES - length(Used_record),
			dono
	end,
	PetShopGoods2 = if
		Type =:= 1 ->
			Goods1 = case get(pet_can_buy_goods) of
				[] ->
					[];
				Goods ->
					[_ | T] = Goods,
					T
			end,
			PetShopGoods ++ Goods1;
		true ->
			PetShopGoods
	end,
	put(pet_can_buy_goods,PetShopGoods2),
	NewLuck = get(pet_luck_high) + Add_luck,
	put(pet_luck_high, NewLuck),
	NewAccount = get(pet_account) + Addaccount,
	put(pet_account, NewAccount),
	% 保存数据库
	pet_shop_db:save_data(),
	% dal:write_rpc(#pet_shop{role_id = get(roleid), pet_goods_list = PetShopGoods, obligate3 = Used_record++[date()], obligate4 = NewAccount, obligate5 = NewLuck}),
	Msg = pet_packet:encode_pet_shop_rfresh_s2c(PetShopGoods2),
	MsgLuck = pet_packet:encode_pet_shop_luck_s2c(NewLuck),
	MsgAccount = pet_packet:encode_pet_shop_account_s2c(NewAccount),
	MsgTime = pet_packet:encode_pet_shop_time_s2c(New_Times),
	role_op:send_data_to_gate(Msg),
	role_op:send_data_to_gate(MsgLuck),
	role_op:send_data_to_gate(MsgAccount),
	role_op:send_data_to_gate(MsgTime).

	% do_clear().
    % broadcast_op:pet_refresh(PetShopGoods),
	% {ok, RoleState #role_state{pet_shop_goods_list = PetShopGoods, buy_pet = []}}	
send_can_buy_goods(Goods) ->
	Msg = pet_packet:encode_pet_shop_rfresh_s2c(Goods),
	role_op:send_data_to_gate(Msg).
save_test() ->
	dal:write_rpc(#pet_shop{role_id = 60000002, obligate3 = [], obligate4 = 0, obligate5 = 0}).
do_clear() ->
	put(pet_refresh_used,[]),
	pet_shop_db:save_data(pet_refresh_used, []).
check_refresh_times(Used_record) ->
	case length(Used_record) of
		0 ->
			true;
		_ ->
			Today = date(),
			Common = hd(Used_record),
			if  Today =/= Common->
					put(pet_refresh_used,[]),
					true;
				true ->
					Acc = length(Used_record),
					if  Acc < (?FREE_TIMES) ->
							true;
						true ->
							false
					end
			end

	end.

% 取出倒计时Timer
% cancel_pet_shop_timer(RoleTimerRefList) ->
% 	case lists:keyfind(pet_shop, 1, RoleTimerRefList) of
% 		false ->
% 			RoleTimerRefList;
% 		{pet_shop, PetShopTimerRef} ->
% 			erlang:cancel_timer(PetShopTimerRef),
% 			lists:keydelete(pet_shop, 1, RoleTimerRefList)
% 	end.

% % 添加一个timer
% add_pet_shop_timer(RoleTimerRefList, PetShopTimerRef) ->
% 	RoleTimerRefList ++ [pet_shop, PetShopTimerRef].

% % 从商店列表中删除一个宠物
% delete_pet([], _PetTemplateId, LastList) ->
% 	LastList;
% delete_pet([H|T], PetTemplateId, LastList) ->
% 	{TemplateId, _Price} = H,
% 	case TemplateId =:= PetTemplateId of
% 		true ->
% 			LastList ++ T;
% 		false ->
% 			delete_pet(T, PetTemplateId, LastList ++ [H])
% 	end.

% 请求宠物商店商品
pet_shop_goods(RoleState) ->
			PetShopGoods = get(pet_can_buy_goods),
			Msg = pet_packet:encode_pet_shop_goods_s2c(?PET_SHOP_REFRESH_TIME, PetShopGoods),
			role_op:send_data_to_gate(Msg),
			{ok, RoleState}.
% gold购买宠物
buy_pet(PetTemplateId, 1, RoleState) ->
	PetShopGoods = get(pet_can_buy_goods),
	case PetShopGoods =:= [] of
		true ->
			% 本轮宠物已买光
			{error, ?ERROR_PET_SHOP_EMPTY};
		false ->
			% 是否在本轮商店中
			case lists:keyfind(PetTemplateId, 1, PetShopGoods) of
				false ->
					{error, ?ERROR_PET_SHOP_NOT_EXIST};
				{PetTemplateId, Price} ->
					% 铜钱是否充足
					case role_op:check_money(?MONEY_GOLD, Price) of
						false ->
							{error, ?ERROR_LESS_GOLD};
						true ->
							% 背包是否已满
							case package_op:can_added_to_package(PetTemplateId, 1) of
								0 ->
									{error, ?ERROR_PACKEGE_FULL};
								_Other ->
									% 放入背包
									role_op:auto_create_and_put(PetTemplateId, 1, pet_shop),
									% 把购买的宠物从本轮宠物商店中删除
									put(pet_can_buy_goods,[]),
									put(pet_luck_high, 0),
									% 扣钱
									role_op:money_change(?MONEY_GOLD, -Price, pet_shop),
									% 保存数据库
									% pet_shop_db:save_data(pet_account,LefeAcc),
									% dal:write_rpc(#pet_shop{role_id = get(roleid), pet_goods_list = [], obligate5 = 0}),
									MsgLuck = pet_packet:encode_pet_shop_luck_s2c(0),
									role_op:send_data_to_gate(MsgLuck),
									Msg = pet_packet:encode_pet_shop_rfresh_s2c([]),
									role_op:send_data_to_gate(Msg),
									pet_shop_db:save_data(),
									broadcast(PetTemplateId,Price),
									% broadcast_op:specify_item(PetTemplateId),
									{ok, RoleState}
							end
					end
			end
	end;
% accound购买宠物
buy_pet(PetTemplateId, 0, RoleState) ->
	case check_account(PetTemplateId) of 
		{ok,LefeAcc,Price} ->
			case package_op:can_added_to_package(PetTemplateId, 1) of
				0 ->
					{error, ?ERROR_PACKEGE_FULL};
				_Other ->
					% 放入背包
					role_op:auto_create_and_put(PetTemplateId, 1, pet_shop),
					put(pet_account, LefeAcc),
					% 保存数据库
					pet_shop_db:save_data(pet_account,LefeAcc),
					% dal:write_rpc(#pet_shop{role_id = get(roleid), obligate4 = LefeAcc}),
					MsgAccount = pet_packet:encode_pet_shop_account_s2c(LefeAcc),
					role_op:send_data_to_gate(MsgAccount),
					Msg = pet_packet:encode_pet_shop_goods_s2c(?PET_SHOP_REFRESH_TIME, []),
					role_op:send_data_to_gate(Msg),
					broadcast(PetTemplateId,Price),
					{ok, RoleState}
			end;
		{error, ErrCode} ->
			{error, ErrCode}
	end.



check_account(PetTemplateId)  ->
	case util:tab2list(?PET_SHOP_CONFIG_ETS) of
		[] ->
			[];
		PetShopConfigList ->
			case lists:keyfind(PetTemplateId,#pet_shop_config.pet_template_id, PetShopConfigList) of
				false->
					% slogger:msg("pet_rename error PetId ~p Roleid ~p ~n",[PetId,get(roleid)]),
					{error, 18001};
				PetShopConfig->
					Price = PetShopConfig#pet_shop_config.price,
					LastAcc = get(pet_account),
					if
						Price > LastAcc ->
							{error, 18000};
						true ->
							{ok,LastAcc - Price,Price}
					end
			end
	end.

% buy_pet(PetTemplateId, RoleState) ->
% 	#role_state{pet_shop_end_time = PetShopEndTime, pet_shop_goods_list = PetGoodsList, buy_pet = BuyPetList} = RoleState,
% 	case PetGoodsList =:= [] of
% 		true ->
% 			% 本轮宠物已买光
% 			{error, ?ERROR_PET_SHOP_EMPTY};
% 		false ->
% 			% 宠物是否在本轮商店中
% 			case lists:keyfind(PetTemplateId, 1, PetGoodsList) of
% 				false ->
% 					{error, ?ERROR_PET_SHOP_NOT_EXIST};
% 				{PetTemplateId, Price} ->
% 					% 铜钱是否充足
% 					case role_op:check_money(?MONEY_BOUND_SILVER, Price) of
% 						false ->
% 							{error, ?ERROR_LESS_MONEY};
% 						true ->
% 							% 背包是否已满
% 							case package_op:can_added_to_package(PetTemplateId, 1) of
% 								0 ->
% 									{error, ?ERROR_PACKEGE_FULL};
% 								_Other ->
% 									% 放入背包
% 									role_op:auto_create_and_put(PetTemplateId, 1, pet_shop),
% 									% 把购买的宠物从本轮宠物商店中删除,加入已购买List
% 									NewPetGoodsList = delete_pet(PetGoodsList, PetTemplateId, []),
% 									NewBuyPetList = BuyPetList ++ [{PetTemplateId, Price}],
% 									% 扣钱
% 									role_op:money_change(?MONEY_BOUND_SILVER, -Price, pet_shop),
% 									% 保存数据库
% 									dal:write_rpc(#pet_shop{role_id = get(roleid), end_time = PetShopEndTime, pet_goods_list = NewPetGoodsList, buy_pet = NewBuyPetList}),

% 									Msg = pet_packet:encode_pet_shop_goods_s2c(PetShopEndTime - util:now_sec(), NewPetGoodsList),
% 									role_op:send_data_to_gate(Msg),
% 									{ok, RoleState#role_state{pet_shop_goods_list = NewPetGoodsList, buy_pet = NewBuyPetList}}
% 							end
% 					end
% 			end
% 	end.

% 刷新剩余时间
% refresh_remain_time(RoleState) ->
% 	% 元宝是否充足
% 	case role_op:check_money(?MONEY_GOLD, ?REFRESH_REMAIN_TIME_CONSUME) of
% 		false ->
% 			{error, ?ERROR_LESS_GOLD};
% 		true ->
% 			PetShopGoodsList = pet_shop_db:random_pet_goods(),
% 			% 取消上次计时器Timer
% 			TimerRefList = cancel_pet_shop_timer(RoleState#role_state.timer_ref),
% 			% 本次计时器Timer
% 			PetShopTimerRef = erlang:start_timer(?PET_SHOP_REFRESH_TIME * 1000, self(), pet_shop_refresh),
% 			NewTimerRefList = add_pet_shop_timer(TimerRefList, PetShopTimerRef),
% 			% 扣除元宝
% 			role_op:money_change(?MONEY_GOLD, -?REFRESH_REMAIN_TIME_CONSUME, pet_shop_refresh),
% 			% 保存数据库
% 			PetShopEndTime = util:now_sec() + ?PET_SHOP_REFRESH_TIME,
% 			dal:write_rpc(#pet_shop{role_id = get(roleid), end_time = PetShopEndTime, pet_goods_list = PetShopGoodsList, buy_pet = []}),

% 			Msg = pet_packet:encode_pet_shop_goods_s2c(?PET_SHOP_REFRESH_TIME, PetShopGoodsList),
% 			role_op:send_data_to_gate(Msg),
%             broadcast_op:pet_refresh(PetShopGoodsList),
% 			{ok, RoleState#role_state{pet_shop_end_time = PetShopEndTime, pet_shop_goods_list = PetShopGoodsList, buy_pet = []}}
% 	end.
put_shop_info() ->
	case pet_shop_db:get_pet_shop_db(get(roleid)) of
		{error,ErrCode} ->
			send;
		Shopinfo ->
			Used_record = pet_shop_db:get_used_record(Shopinfo),
			Account = pet_shop_db:get_account(Shopinfo),
			Luck = pet_shop_db:get_luck(Shopinfo),
			Goods = pet_shop_db:get_goods(Shopinfo),
			% slogger:msg("pet_shop: ~p,~p,~p,~p ~n",[Used_record,Account,Luck,Goods]),
			send_can_buy_goods(Goods),
			put(pet_can_buy_goods,Goods),
			put(pet_refresh_used,Used_record),
			put(pet_account,Account),
			put(pet_luck_high,Luck)
		% Other ->
		% 	slogger:msg("pet_shop_Other: ~p ~n",[Other])
		end.
broadcast(IiemId,Price) ->
	broadcast_op:buy_item2(IiemId,Price).

