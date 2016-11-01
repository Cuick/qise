%%% -------------------------------------------------------------------
%%% Author  : kebo
%%% @doc 首充6重礼包相关
%%% @end
%%% Created : 2012-9-11
%%% -------------------------------------------------------------------
-module(charge_reward_op).

-compile(export_all).

-include("base_define.hrl").
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("string_define.hrl").
-include("charge_package_def.hrl").
-include("wg.hrl").
-include("mnesia_table_def.hrl").

%% @doc 玩家礼包状态
charge_reward_init()->
	Now = timer_center:get_correct_now(),
	{{N,Y,D},{_,_,_}}	=  calendar:now_to_local_time(Now),
	NewTime = {{N,Y,D},{0,0,0}},
	{ChargeNum1,State1} = 
	case dal:read_rpc(role_charge_reward, get(roleid)) of
		{ok,[]}->
			{0,[]};
		{ok,[Info]}->
			{_,_,ChargeNum,State,Time} = Info,
			{{ON,OY,OD},{_,_,_}} = Time,
			case calendar:time_difference({{ON,OY,OD},{0,0,0}}, NewTime) of
				% 同一天
				{0, _} ->
					{ChargeNum,State};
				_ ->
					charge_reward_db:save_charge_reward_info(get(roleid), 0,[],NewTime),
					{0,[]}
			end;
		_ ->
			{0,[]}
	end,
	Message = charge_reward_packet:encode_charge_reward_init_s2c(ChargeNum1,State1),
	role_op:send_data_to_gate(Message).

	
%% @doc 玩家领取礼包	
get_charge_reward(Id)->
	Now = timer_center:get_correct_now(),
	{{N,Y,D},{_,_,_}}	=  calendar:now_to_local_time(Now),
	NewTime = {{N,Y,D},{0,0,0}},
	{ChargeNum1,State1} = 
	case dal:read_rpc(role_charge_reward, get(roleid)) of
		{ok,[]}->
			{0,[]};
		{ok,[Info]}->
			{_,_,ChargeNum,State,Time} = Info,
			{{ON,OY,OD},{_,_,_}} = Time,
			case calendar:time_difference({{ON,OY,OD},{0,0,0}}, NewTime) of
				% 同一天
				{0, _} ->
					{ChargeNum,State};
				_ ->
					{0,[]}
			end;
		_ ->
			{0,[]}
	end,

	Flag = lists:member(Id,State1),
	State3 =
	if
		Flag ->
			Result=?ERROR_HAD_REWARDED_CHARGE_PACKAGE,
			State1;
		true ->
			{_,_,Gold,ItemId} = charge_reward_db:get_info(Id),
			if
				Gold > ChargeNum1 ->
					Result = ?GET_FIRST_CHARGE_GIFT_ERROR,
					State1;
				true ->
					case package_op:can_added_to_package_template_list([{ItemId,1}]) of
						false ->
							Result = ?ERROR_PACKEGE_FULL,
							State1;
						true ->
							% lists:foreach(fun({Gift,Count})->
							% 	role_op:auto_create_and_put(Gift,Count,charge_reward_gift) end,ItemId),
							role_op:auto_create_and_put(ItemId,1,charge_reward_gift),
							#charge_package_syschat_id_proto{syschat_id = SysId} = charge_package_db:get_charge_package_syschat_id_proto_info(Id+100),
							system_brodcast_for_charge_package(SysId, get(creature_info), ItemId),
							State2 = State1 ++ [Id],
							charge_reward_db:save_charge_reward_info(get(roleid), ChargeNum1,State2,NewTime),
							Result = 1,
							State2
				end
			end
	end,
	Message = charge_reward_packet:encode_get_charge_reward_s2c(Result,ChargeNum1,State3),
   	role_op:send_data_to_gate(Message).

system_brodcast_for_charge_package(SysId,RoleInfo,ItemTempId)->
    ParamRole = system_chat_util:make_role_param(RoleInfo),
    ParamItem = system_chat_util:make_item_param(ItemTempId),
    MsgInfo = [ParamRole,ParamItem],
    system_chat_op:system_broadcast(SysId,MsgInfo).

% %% @doc 领取礼包，更新玩家背包
% do_update(ItemId) ->
% 	TemplateInfo = item_template_db:get_item_templateinfo(ItemId),
% 	%GiftList = element(#item_template.states,TemplateInfo),	
% 	GiftList=drop:apply_rulelist(element(#item_template.states,TemplateInfo), 999),
% 	case package_op:can_added_to_package_template_list(GiftList) of
% 		false ->
% 			?ERROR_PACKEGE_FULL;
% 		true ->
% 		lists:foreach(fun({Gift,Count})->
% 			role_op:auto_create_and_put(Gift,Count,charge_reward_gift) end,GiftList),
% 			?SUCCESS
% 	end.

%% @doc 玩家充值成功后，回调通知玩家元宝改变，是否可领取状态改变
hook_prompt_player_online(IncGold) ->
	Now = timer_center:get_correct_now(),
	{{N,Y,D},{_,_,_}}	=  calendar:now_to_local_time(Now),
	NewTime = {{N,Y,D},{0,0,0}},
	{ChargeNum1,State1} = 
	case dal:read_rpc(role_charge_reward, get(roleid)) of
		{ok,[]}->
			{0,[]};
		{ok,[Info]}->
			{_,_,ChargeNum,State,Time} = Info,
			{{ON,OY,OD},{_,_,_}} = Time,
			case calendar:time_difference({{ON,OY,OD},{0,0,0}}, NewTime) of
				% 同一天
				{0, _} ->
					{ChargeNum,State};
				_ ->
					{0,[]}
			end;
		_ ->
			{0,[]}
	end,

	charge_reward_db:save_charge_reward_info(get(roleid), ChargeNum1 + IncGold,State1,NewTime),
	Message = charge_reward_packet:encode_charge_reward_init_s2c(ChargeNum1 + IncGold,State1),
	role_op:send_data_to_gate(Message).


