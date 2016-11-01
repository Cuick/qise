%% Author: adrianx
%% Created: 2010-10-4
%% Description: TODO: Add description to api_op
-module(api_op).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("mnesia_table_def.hrl").
-include("string_define.hrl").
-include("top_bar_item_def.hrl").
%%
%% API Functions
%%

user_charge(JsonObject) ->
	process_rpc(JsonObject, get_mapnode(), api_user_charge_rpc, 
		["account", "count", "order", "pf", "timestamp", "type", "sid", "sign"]).

role_check(JsonObject) -> 
	process_rpc(JsonObject, get_dbnode(), api_role_check_rpc, 
		["account", "timestamp", "sign"]).

order_query(JsonObject) ->
	process_rpc(JsonObject, get_dbnode(), api_order_query_rpc,
		["order"]).

user_info(JsonObject) ->
	process_rpc(JsonObject, get_dbnode(), api_user_info_rpc,
		["account", "pf", "timestamp", "sign", "sid"]).

query_gate_state()->
	GateNodes = node_util:get_gatenodes(),
	CountFun = fun(GateNode)->
					   Count = case rpc:call(GateNode, gs_prof, pids, []) of
								   {badrpc,Reason}-> slogger:msg("bad call ~p!!~n",[Reason]),0;
								   Plist-> length(Plist)
							   end,
					   {GateNode,Count}
			   end,
	lists:map(CountFun, GateNodes).

query_line_state()->
	Lines = env:get(lines_info, []),
	MapIds = lists:foldl(fun({_LineId,LineInfo},OldList)->
								 lists:foldl(fun({MapId,_Node},OldMapIds)->
													 case lists:member(MapId, OldMapIds) of
														 true-> OldList;
														 false-> [MapId|OldMapIds]
													 end
											 end,OldList,LineInfo)
						end, [], Lines),

	CountFun = fun(MapId)-> {MapId,lines_manager:get_line_status(MapId)} end,
	lists:map(CountFun, MapIds).
%%
%% Local Functions
%%
get_mapnode()->
	MapNodes = node_util:get_mapnodes(),
	[MapNode |_]= MapNodes,
	MapNode.

get_linenode()->
	LineNodes = node_util:get_linenodes(),
	[LineNode|_] = LineNodes,
	LineNode.

get_dbnode()->
	DbNodes = node_util:get_dbnodes(),
	[DbNode|_] = DbNodes,
	DbNode.

prepaire_argument(JsonObject,AgumentNameList)->
	F = fun(X,Acc)->
			case util:get_json_member(JsonObject, X) of
				{ok,Res}-> Acc ++ [Res];
				{error,_Reason}-> Acc
			end
		end,
	lists:foldl(F, [], AgumentNameList).

process_rpc(JsonObject,Node,RemoteCall,ArgumentNameList)->
	ArgumentList = prepaire_argument(JsonObject,ArgumentNameList),
	SendStruct = case rpc:call(Node, ?MODULE , RemoteCall , ArgumentList) of
					 {badrpc,Reason}-> slogger:msg("~p error:~p",[RemoteCall,Reason]),
									   {struct,[{<<"status">>, 100}]};
					 Ret->
						 case Ret of
							 {ok,ResultString}->
								 {struct, ResultString};
							 _->
								 {struct,[{<<"status">>, 100}]}
								 
						end
				 end,
	{ok,SendBin} = util:json_encode(SendStruct),
	api_client:send_data(self(),SendBin).


api_user_charge_rpc(Account, Count, Order, Pf, Timestamp, Type, Sid, Sign) ->
	case auth_util:check_time(Timestamp) of
		true ->
			{ok, [{<<"status">>, 3}]};
		false ->
			PlatformKey = env:get2(platform_key, Pf, []),
			AuthStr = "account="++Account++"&count="++Count++"&key="++PlatformKey++"&order="++Order++"&pf="++Pf++"&timestamp="++Timestamp++"&type="++Type,
			case auth_util:platform_check(AuthStr,Sign) of
				true ->
					AddCount = list_to_integer(Count),
					Transaction = 
					fun()->
						case mnesia:read(account, Account) of
							[]->
								[];
							[Account0]->
								#account{roleids = RoleIds, gold = OldGold} = Account0,
								NewGold = OldGold + AddCount,
								NewAccount = Account0#account{gold = NewGold},
								mnesia:write(NewAccount),
								NewAccount
						end
					end,
					case dal:run_transaction_rpc(Transaction) of
						{ok,[]}->
							slogger:msg("user charge error, can't find uesr: ~p, gold: ~p~n",[Account,AddCount]),
				            {ok, [{<<"status">>, 1}]};
						{ok,Result}->
							#account{username=Account,roleids=RoleIds,gold=TotalGold} = Result,
							ServerId = list_to_integer(Sid),
							[RoleId3 | _] = lists:filter(fun(RoleId) ->
								travel_battle_util:get_serverid_by_roleid(RoleId) =:= ServerId
							end, RoleIds),
							slogger:msg("~p,Platfoemat charge success,charged ~p,now ~p!~n",[RoleId3,Count,TotalGold]),
							RoleInfo = role_db:get_role_info(RoleId3),
							RoleName = role_db:get_name(RoleInfo),
							RoleLevel = role_db:get_level(RoleInfo),
							send_account_charge_mail(RoleName, AddCount, TotalGold),
							FirstChargeFlag = case check_first_charge(RoleId3) of
								true ->
									1;
								_ ->
									0
							end,
							vip_op:add_sum_gold(RoleId3,AddCount),

							FRole = fun(RoleId2) ->
								case role_pos_util:where_is_role(RoleId2) of
									[]->
										top_bar_manager:hook_activity_count(RoleId2, ?ACTIVITY_CHARGE, AddCount);
									RolePos->
										Node = role_pos_db:get_role_mapnode(RolePos),
										Proc = role_pos_db:get_role_pid(RolePos),
										role_processor:account_charge(Node, Proc, {account_charge, AddCount, TotalGold})
								end
							end,
							lists:foreach(FRole, RoleIds),
							gm_logger_role:role_gold_change(Account, RoleId3, AddCount, TotalGold, got_charge),
							gm_logger_role:game_charge_level(Account, RoleId3, ServerId, RoleLevel, Order, Type, (AddCount div 10), AddCount, FirstChargeFlag),
				            {ok, [{<<"status">>, 0}]};
						_->
							slogger:msg("money_change gold unknow error!!!! (account,~p) error! Count ~p ",[Account,Count]),
				            {ok, [{<<"status">>, 100}]}
					end;
				false ->
					{ok, [{<<"status">>, 2}]}
			end
		end.
api_role_check_rpc(User) ->
	case dal:read(account, User) of
		{ok, [_]} ->
			{ok, [{<<"status">>, 0}]};
		_ ->
			{ok, [{<<"status">>, 8}]}
	end.

% api_order_query_rpc(Order) ->
% 	case dal:read(recharge1, Order) of
% 		{ok, [OrderInfo]} ->
% 			#recharge1{user = User, gold = Gold, money = Money, time = Time} = OrderInfo,
% 			{ok, [{<<"status">>, 0},
% 				{<<"order_id">>, list_to_binary(Order)},
% 				{<<"gold">>, Gold},
% 				{<<"money">>, Money},
% 				{<<"time">>, Time}]};
% 		_ ->
% 			{ok, [{<<"status">>, 7}]}
% 	end.

api_user_info_rpc(User,Pf,Timestamp,Sign,Sid) ->
	case auth_util:check_time(Timestamp) of
		true ->
			{ok, [{<<"status">>, 3}]};
		false ->
			PlatformKey = env:get2(platform_key, Pf, []),
			AuthStr = "account="++User++"&key="++PlatformKey++"&pf="++Pf++"&timestamp="++Timestamp,
			case auth_util:platform_check(AuthStr,Sign) of
				true ->
					case dal:read(account, User) of
						{ok, [Account]} ->
							#account{roleids = RoleIds} = Account,
							ServerId = list_to_integer(Sid),
							[RoleId | _] = lists:filter(fun(RoleIdTmp) ->
								travel_battle_util:get_serverid_by_roleid(RoleIdTmp) =:= ServerId
							end, RoleIds),
							RoleTable = db_split:get_owner_table(roleattr, RoleId), 
							case dal:read(RoleTable, RoleId) of
								{ok, [RoleAttr]} ->
									Level = erlang:element(7, RoleAttr),
									Name = erlang:element(4, RoleAttr),
									Class = erlang:element(6, RoleAttr),
									Gender = erlang:element(5, RoleAttr),
									Class_Name = case Class of
													1 ->
														 <<"天师">>;
													2 ->
														 <<"神羿">>;
													3 ->
														 <<"武尊">>
									end,
									Gender_cn = case Gender of
													0 ->
														 <<"女">>;
													1 ->
														 <<"男">>
									end,
									{ok, [{<<"status">>, 0},
									{<<"name">>, Name},
									{<<"level">>, Level},
									{<<"class">>, Class_Name},
									{<<"gender">>, Gender_cn}]};
								_ ->
									{ok, [{<<"status">>, 100}]}
							end;
						_ ->
							{ok, [{<<"status">>, 1}]}
					end;
				false ->
					{ok, [{<<"status">>, 2}]}
			end
	end.

send_account_charge_mail(Account, Count, Total) ->
	Now = timer_center:get_correct_now(),
	{{Year, Month, Day}, {Hour, Min, _}} = calendar:now_to_local_time(Now),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?STR_ACCOUNT_CHARGE_TITLE),
	Content = util:sprintf(language:get_string(?STR_ACCOUNT_CHARGE_CONTENT), [Year, Month, Day, Hour, Min, Count, Total]),
	mail_op:gm_send_multi(FromName,Account,Title,Content,[],0).

check_first_charge(RoleId) ->
	case vip_db:get_role_sum_gold(RoleId) of
			{ok,[]}->
				true;
			{ok,RoleSumInfo}->
				vip_db:get_sumgold_from_suminfo(RoleSumInfo)=:=0;
			_->
				true
	end.