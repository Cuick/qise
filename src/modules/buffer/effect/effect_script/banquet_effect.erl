%% Author: MacX
%% Created: 2011-10-10
%% Description: TODO: Add description to banquet_effect
-module(banquet_effect).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([effect/2]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("sitdown_define.hrl").
-include("map_define.hrl").
-include("effect_define.hrl").
%%
%% API Functions
%%
effect(_Value,_SkillInput)->
	CurInfo = get(creature_info),
	RoleID = get_id_from_roleinfo(CurInfo),
	CurLevel = get_level_from_roleinfo(CurInfo),
	case banquet_db:get_banquet_exp_info(CurLevel) of
		[]->
			nothing;
		Info->
			Exp = banquet_db:get_banquet_exp_exp(Info),
			SoulPower = banquet_db:get_banquet_exp_soulpower(Info),
			SelfEffUp = [{soulpower,SoulPower},{expr,Exp}],
			SelfEffUpSend = lists:map(fun(OriAttrTmp)-> role_attr:to_role_attribute(OriAttrTmp) end, SelfEffUp),
			Message = role_packet:encode_buff_affect_attr_s2c(RoleID,SelfEffUpSend),
			role_op:send_data_to_gate(Message),
	%%		ExpRate = get_expratio_from_roleinfo(get(creature_info)),
			ExpRateList = get_expratio_from_roleinfo(get(creature_info)),
			case lists:keyfind(?EFFECT_EXP_BANQUET,1,ExpRateList) of
				false->
					ExpRate = 1;
				{_,AddValue}->
					ExpRate = 1 + AddValue/100
			end,
			case vip_op:get_addition_with_vip(banquet_addition) of
				0->
					VipAdd = 0;
				Value->
					VipAdd = Value
			end,
            NormalExp = Exp * ExpRate,
            VipExp = Exp * VipAdd,
            role_op:obtain_exp([{expr, NormalExp}, {vip_expr, VipExp}]),
            NormalSoulPower = SoulPower * ExpRate,
            VipSoulPower = SoulPower * VipAdd,
            role_op:obtain_soulpower([{soulpower, NormalSoulPower}, {vip_soulpower, VipSoulPower}])
	end,
	[].

%%
%% Local Functions
%%

