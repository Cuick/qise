-module (dead_valley_effect).


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
	case dead_valley_db:get_exp_info(CurLevel) of
		[]->
			nothing;
		Info->
			Exp = dead_valley_db:get_exp(Info),
			SelfEffUp = [{expr,Exp}],
			SelfEffUpSend = lists:map(fun(OriAttrTmp)-> role_attr:to_role_attribute(OriAttrTmp) end, SelfEffUp),
			Message = role_packet:encode_buff_affect_attr_s2c(RoleID,SelfEffUpSend),
			role_op:send_data_to_gate(Message),
            role_op:obtain_exp([{expr, Exp}])
	end,
	[].

%%
%% Local Functions
%%
