%%% -------------------------------------------------------------------
%%% Author  : kebo
%%% @doc 首充6重礼包相关
%%% @end
%%% Created : 2012-9-11
%%% -------------------------------------------------------------------
-module(charge_package_op).

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
charge_package_init()->
	RoleId = get(roleid),
    AllGolds = vip_op:get_role_sum_gold(RoleId),
    ChargePackageList = get_role_charge_package(RoleId, AllGolds),
	ChargePackage = do_update_charge_packet_status(ChargePackageList, AllGolds),
	charge_package_db:sync_updata(RoleId,ChargePackage),
	ChargePackage2 = case ChargePackage of
		#charge_package_info_db{info = Info} ->
			Info;
		ChargePackage ->
			ChargePackage
	end,
	Message = charge_package_packet:encode_charge_package_init_s2c(AllGolds,ChargePackage2),
	role_op:send_data_to_gate(Message).
	
%% @doc 玩家领取礼包	
get_charge_package(Id)->
    #charge_package_proto{item_id = ItemId, gold = Gold} = charge_package_db:get_charge_package_proto_info(Id),
    #charge_package_syschat_id_proto{syschat_id = SysId} = charge_package_db:get_charge_package_syschat_id_proto_info(Id),
    RoleId = get(roleid),
	#charge_package_info_db{info = Info1} = Packages = get_role_charge_package(RoleId, 0),
	{_,HasGet}=lists:keyfind(Id, 1, Info1),
	case HasGet  of
		% 未领取
	 	0->
			Result = do_update(ItemId, SysId),
			case Result of
				?SUCCESS -> 
					Info2 = lists:keyreplace(Id, 1, Info1 , {Id, 1}),
					Packages2 = Packages#charge_package_info_db{info = Info2},
					charge_package_db:sync_updata(RoleId, Packages2);
		            %broadcast_op:get_charge_package(Id);
				_ -> ok
			end;
		% 礼包已领取
		1->
			Result=?ERROR_HAD_REWARDED_CHARGE_PACKAGE;
		_ ->
		 	Result = ?GET_FIRST_CHARGE_GIFT_ERROR
	end,
   Message = charge_package_packet:encode_get_charge_package_s2c(Result),
   role_op:send_data_to_gate(Message).
							
hook_prompt_player_offline(RoleId)->
  todo.

%% @doc 玩家充值成功后，回调通知玩家元宝改变，是否可领取状态改变
hook_prompt_player_online() ->
	RoleId = get(roleid),
	AllGolds = vip_op:get_role_sum_gold(RoleId),
	ChargePackageList = get_role_charge_package(RoleId, AllGolds),
	ChargePackageList2 = do_update_charge_packet_status(ChargePackageList, AllGolds),
	charge_package_db:sync_updata(RoleId,ChargePackageList2),
	Message = charge_package_packet:encode_charge_package_init_s2c(AllGolds,ChargePackageList2),
	role_op:send_data_to_gate(Message).

%% @doc 获取玩家的领取6重礼包状态
%% 1. 如果玩家没有领取初始化过，则初始化
%% 2. 返回玩家的6重礼包状态						
get_role_charge_package(RoleId, SumGold)->
	ChargePackage =  charge_package_db:get_charge_package_info(RoleId),
	if 
	% 1. 没有领取或者初始化过状态
	ChargePackage =:= [] orelse ChargePackage =:= undefined ->
        	ChargPackageProtoList = charge_package_db:get_all_charge_package_proto_info(),
			ChargePackage2 = init_role_charg_package(ChargPackageProtoList, [], SumGold),
			charge_package_db:sync_updata(RoleId, ChargePackage2), 
			ChargePackage2;
	% 2. 有领取或者初始化过状态
	true -> ChargePackage
    end.

%% @doc 把玩家每重礼包领取状态
init_role_charg_package([], ChangePacketList, _SumGold) ->
	ChangePacketList;
init_role_charg_package([#charge_package_proto{id = Id, gold = Gold, item_id = ItemId} = Data | T], ChangePacketList, SumGold) ->
	ChargPackage = 
	if 
		% 可领取
		SumGold >= Gold ->
			{Id, 0};
		% 不可领取
		true ->
			{Id, -1}
	end,
	ChangePacketList2 = [ChargPackage | ChangePacketList],
	init_role_charg_package(T, ChangePacketList2, SumGold).

%% @doc 领取礼包，更新玩家背包
do_update(ItemId, SysId) ->
	TemplateInfo = item_template_db:get_item_templateinfo(ItemId),
	%GiftList = element(#item_template.states,TemplateInfo),	
	GiftList=drop:apply_rulelist(element(#item_template.states,TemplateInfo), 999),
	case package_op:can_added_to_package_template_list(GiftList) of
		false ->
			Result = ?ERROR_PACKEGE_FULL;
		true ->
		lists:foreach(fun({Gift,Count})->
			role_op:auto_create_and_put(Gift,Count,charge_package_gift) end,GiftList),
            system_brodcast_for_charge_package(SysId, get(creature_info), ItemId),
			Result =?SUCCESS
	end.


%% 更新玩家的礼包不可领取状态为可领取状态
 do_update_charge_packet_status(#charge_package_info_db{info = ChargePackageList}, SumGold) ->
 	Fun = fun({Id, Status}) -> 
 			#charge_package_proto{gold = Gold} = charge_package_db:get_charge_package_proto_info(Id),
 			case Status of
 				1 -> {Id, 1};
 				0 -> {Id, 0};
 				-1 -> ?IF(Gold =< SumGold, {Id, 0}, {Id, -1})
 			end
 	 end,
 	 lists:map(Fun, ChargePackageList);
 do_update_charge_packet_status(ChargePackageList, SumGold) ->
 	Fun = fun({Id, Status}) -> 
 			#charge_package_proto{gold = Gold} = charge_package_db:get_charge_package_proto_info(Id),
 			case Status of
 				1 -> {Id, 1};
 				0 -> {Id, 0};
 				-1 -> ?IF(Gold =< SumGold, {Id, 0}, {Id, -1})
 			end
 	 end,
 	 lists:map(Fun, ChargePackageList).

system_brodcast_for_charge_package(SysId,RoleInfo,ItemTempId)->
    ParamRole = system_chat_util:make_role_param(RoleInfo),
    ParamItem = system_chat_util:make_item_param(ItemTempId),
    MsgInfo = [ParamRole,ParamItem],
    system_chat_op:system_broadcast(SysId,MsgInfo).







