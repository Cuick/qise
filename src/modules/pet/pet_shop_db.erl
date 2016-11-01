-module(pet_shop_db).
%%
%%
%% Exported Functions
%%
-export([start/0, create_mnesia_table/1, create_mnesia_split_table/2, delete_role_from_db/1, tables_info/0, pet_shop_goods/0]).
-export([init/0, create/0, save_data/0,save_data/2]).
-export([random_pet_goods/0,random_pet_goods/2]).
-export([get_pet_shop_db/1,get_used_record/1, get_account/1, get_luck/1, get_goods/1]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%% Include files
%%
-include("pet_def.hrl").
-include("pet_struct.hrl").
-include("role_struct.hrl").

-define(PET_SHOP_CONFIG_ETS, pet_shop_config).
-define(RANDOM_PET_GOODS_NUM, 12).			% 宠物商店随机个数
-define(RANDOM_PET_GOODS_PRICE, 10).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start() ->
	db_operater_mod:start_module(?MODULE, []).

create_mnesia_table(disc) ->
	db_tools:create_table_disc(pet_shop, record_info(fields, pet_shop), [], set),
	db_tools:create_table_disc(pet_shop_config, record_info(fields, pet_shop_config), [], bag).

create_mnesia_split_table(_, _) ->
	nothing.

tables_info() ->
	[{pet_shop, disc}, {pet_shop_config, proto}].

delete_role_from_db(RoleId) ->
	case dal:read_rpc(pet_shop, RoleId) of
		{ok, PetShopList} ->
			case PetShopList =/= [] of
				true ->
					dal:delete_rpc(pet_shop, RoleId);
				false ->
					ok
			end;
		_Other ->
			ok
	end.

create() ->
	ets:new(?PET_SHOP_CONFIG_ETS, [set, public, named_table, {read_concurrency, true}]).

init()->
	db_operater_mod:init_ets(pet_shop_config, ?PET_SHOP_CONFIG_ETS, #pet_shop_config.pet_template_id).

% -record(pet_shop, {
% 		role_id,
% 		end_time = 0,			% 本轮刷新结束时间
% 		pet_goods_list = [],	% 本轮刷新出的宠物商品([{PetTemplateId, Price}, .....])
% 		buy_pet = [],			% 本轮购买宠物
% 		% 一下为预留字段
% 		obligate,
% 		obligate2,
% 		obligate3,				%Used_record
% 		obligate4,				%account
% 		obligate5  				%luck

get_pet_shop_db(RoleId) ->
	case dal:read_rpc(pet_shop, RoleId) of
		{ok, RolePetShop} ->
			case RolePetShop of
			 [] ->
			 	#pet_shop{role_id = RoleId, end_time = 0, pet_goods_list = [], buy_pet = [],obligate3 = [], obligate4 = 0, obligate5 = 0};
			 [PetShop] ->
			 	PetShop
			 end;
		_ ->
			{error,66}
	end.
get_used_record(PetShop) ->
	case element(#pet_shop.obligate3,PetShop) of
			undefined ->
				[];
			Record ->
				Record
	end.
get_account(PetShop) ->
	case element(#pet_shop.obligate4,PetShop) of
			undefined ->
				0;
			Account ->
				Account
	end.
get_luck(PetShop) ->
	case element(#pet_shop.obligate5,PetShop) of
			undefined ->
				0;
			Luck ->
				Luck
	end.
get_goods(PetShop) ->
	case element(#pet_shop.pet_goods_list,PetShop) of
			undefined ->
				[];
			Goods ->
				Goods
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pet_shop_goods() ->
	case util:tab2list(?PET_SHOP_CONFIG_ETS) of
		[] ->
			[];
		PetShopConfigList ->
			lists:foldl(fun(Ele, Acc) ->
				case Ele#pet_shop_config.type of
					1 ->
						Acc ++ [{Ele#pet_shop_config.pet_template_id, Ele#pet_shop_config.price}];
					0 ->
						Acc
				end
			end, [], PetShopConfigList)
	end.
% 随机宠物商品
random_pet_goods() ->
	case util:tab2list(?PET_SHOP_CONFIG_ETS) of
		[] ->
			[];
		PetShopConfigList ->
%			List = util:do_random(?RANDOM_PET_GOODS_NUM, PetShopConfigList),
			List = do_random(PetShopConfigList),
			lists:foldl(fun(Ele, Acc) ->
						Acc ++ [{Ele#pet_shop_config.pet_template_id, Ele#pet_shop_config.price}]
				end, [], List)
	end.
random_pet_goods(Type,Flag) ->
	case util:tab2list(?PET_SHOP_CONFIG_ETS) of
		[] ->
			[];
		PetShopConfigList ->
			{GoodList,GoodList_bond} =
			lists:foldl(fun(Ele, {Acc,Acc_bond}) ->
						case Ele#pet_shop_config.type of
							0 ->
								{Acc++[Ele],Acc_bond};
							1 ->
								{Acc,Acc_bond++[Ele]}
						end
			end, {[],[]}, PetShopConfigList),
			case Flag of
				gold ->
					random_goods(GoodList,Type,[]);
				b_gold ->	
					random_goods(GoodList_bond,Type,[])
			end
	end.
% lists:foldl(fun(N,Acc) -><<A:32,B:32,C:32>> = crypto:strong_rand_bytes(12), {Pos,_Time} = random:uniform_s(1000000,{A,B,C}),[Acc++Pos] end,[],[1,2,3,4,5,6,7,8,9,0]).



random_goods(PetShopConfigList,Type,GoodsList) ->
	Luck = get(pet_luck_high),
	PetShopConfigLength = 10000,
	<<A:32,B:32,C:32>> = crypto:strong_rand_bytes(12),
	{Pos,_Time} = random:uniform_s(max(1,PetShopConfigLength - Luck),{A,B,C}),
	OriPos = Pos + Luck,
	NewPos = case OriPos of
				_ when OriPos < 500 ->
					OriPos;
				_ when OriPos < PetShopConfigLength ->
					{SUB,_Time2} = random:uniform_s(500,now()),
					OriPos - SUB + 1;
				_ ->
					{SUB,_Time2} = random:uniform_s(500,{A,B,C}),
					PetShopConfigLength - SUB + 1
			end,
	% NewPos = min(PetShopConfigLength, Pos + Luck) - SUB - 1, 
		% PetShopConfigLength >= Pos + Luck ->
		% 	Pos + Luck;
		% true ->
		% 	PetShopConfigLength
		% end,
	slogger:msg("pet_shop NewPos: ~p ~n",[NewPos]),
	Goods = take_out(NewPos, PetShopConfigList),
	slogger:msg("pet_shop Goods: ~p ~n",[Goods]),
	case Type of
		1 ->
			[Good] = Goods,
			% {pet_shop_config,21000961,10000,{2001,3000},1}
			[{Good#pet_shop_config.pet_template_id, ?RANDOM_PET_GOODS_PRICE}];
		0 ->
			case length(GoodsList) of
				?RANDOM_PET_GOODS_NUM ->
					slogger:msg("pet_shop GoodsList: ~p ~n",[GoodsList]),
					lists:foldl(fun([Ele], Acc) ->
						Acc ++ [{Ele#pet_shop_config.pet_template_id, ?RANDOM_PET_GOODS_PRICE}]
					end, [], GoodsList);
				Length ->
					random_goods(PetShopConfigList,Type,GoodsList++[Goods])
			end
	end.
take_out(Pos,PetShopConfigList) ->
	lists:filter(fun(GoodsConfig) ->
		{Min,Max} = GoodsConfig#pet_shop_config.rate,
		Pos >= Min andalso Pos =< Max		
	end,PetShopConfigList).

% 随机商品
do_random(PetShopConfigList) ->
	do_random2(PetShopConfigList, []).

do_random2(PetShopConfigList, RandomList) ->
	case length(RandomList) of
		?RANDOM_PET_GOODS_NUM ->
			RandomList;
		Length ->
			PetShopConfigLength = length(PetShopConfigList),
			Pos = random:uniform(PetShopConfigLength),
			PetShopConfig = lists:nth(Pos, PetShopConfigList),
			do_random2(PetShopConfigList, RandomList ++ [PetShopConfig])

	end.
save_data() ->
	PetShopGoods = get(pet_can_buy_goods),
	Used_record = get(pet_refresh_used),
	Account = get(pet_account),
	Luck = get(pet_luck_high),
	do_save(PetShopGoods,Used_record,Account,Luck).
save_data(Key,Value) ->
	case Key of 
		pet_can_buy_goods ->
			PetShopGoods = Value,
			Used_record = get(pet_refresh_used),
			Account = get(pet_account),
			Luck = get(pet_luck_high);
		pet_refresh_used ->
			PetShopGoods = get(pet_can_buy_goods),
			Used_record = Value,
			Account = get(pet_account),
			Luck = get(pet_luck_high);
		pet_account ->
			PetShopGoods = get(pet_can_buy_goods),
			Used_record = get(pet_refresh_used),
			Account = Value,
			Luck = get(pet_luck_high);
		pet_luck_high ->
			PetShopGoods = get(pet_can_buy_goods),
			Used_record = get(pet_refresh_used),
			Account = get(pet_account),
			Luck = Value
	end,
	do_save(PetShopGoods,Used_record,Account,Luck).


	
do_save(PetShopGoods,Used_record,Account,Luck) ->
	dal:write_rpc(#pet_shop{role_id = get(roleid), pet_goods_list = PetShopGoods, obligate3 = Used_record, obligate4 = Account, obligate5 = Luck}).