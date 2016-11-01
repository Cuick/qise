-module(duplicate_prize_op).

-export([init/0,duplicate_prize_item/1, notify_duplicate_prize_can_get/0, export_for_copy/0, load_by_copy/1, duplicate_prize_get/2,save_to_db/0]).

-include("webgame.hrl").
-include("error_msg.hrl").
-include("duplicate_prize.hrl").
-include("map_info_struct.hrl").
-include("login_pb.hrl").

init() ->
	RoleId = get(roleid),
	Duplicate_prize_map1 = case duplicate_prize_db:get_duplicate_prize_map(RoleId) of
		{_, RoleId, Duplicate_prize_map} ->
			Duplicate_prize_map;
		_ ->
			0
	end,
	put(duplicate_prize_map,Duplicate_prize_map1).
% 客户端请求可领奖励物品
duplicate_prize_item(RoleState) ->
	case catch do_duplicate_prize_item(RoleState) of
		{error, Code} ->
			Msg = pet_packet:encode_send_error_s2c(Code),
			role_op:send_data_to_gate(Msg),
			RoleState;
		{ok, NewRoleState} ->
			NewRoleState
	end.

do_duplicate_prize_item(RoleState) ->
	{LastMapId,LastMapProc} = get(?LAST_MAP),
	Duplicate_prize_map = get(duplicate_prize_map),
	?IF(get(?DUPLICATE_PRIZE_FLAG) =:= ?DUPLICATE_PRIZE_SEND, ok, ?S2CERR(?ERROR_SYSTEM)),
	
	% 地图id是否合法
	?IF(LastMapId =/= undefined, ok, ?S2CERR(?ERROR_SYSTEM)),
	% 获取地图奖励信息
	LastMapPrizeInfo = duplicate_prize_db:get_duplicate_prize(LastMapId),
	% 计算获得奖励
	{Index, ItemTemplate, Num} = duplicate_prize_db:calculate_prize(LastMapPrizeInfo),
	Msg = duplicate_prize_packet:encode_duplicate_prize_item_s2c(Index),
	put(?DUPLICATE_PRIZE, {ItemTemplate, Num}),
	role_op:send_data_to_gate(Msg),
	{ok, RoleState}.

% 通知客户端副本奖励可领
notify_duplicate_prize_can_get() ->
	{LastMapId,LastMapProc} = get(?LAST_MAP),
	Duplicate_prize_map = get(duplicate_prize_map),
	case Duplicate_prize_map =:= LastMapProc of
		true ->
			ok;
		false ->
			case LastMapId =:= get_mapid_from_mapinfo(get(map_info)) of
				true ->
					ok;
				false ->
					case duplicate_prize_db:get_duplicate_prize2(LastMapId) of
						[] ->
							ok;
						ok ->
							case get(?DUPLICATE_PRIZE_FLAG) =:= ?DUPLICATE_PRIZE_NOT_SEND orelse get(?DUPLICATE_PRIZE_FLAG) =:= undefined of
								true ->
									put(?DUPLICATE_PRIZE_FLAG, ?DUPLICATE_PRIZE_SEND),
									Msg = duplicate_prize_packet:encode_duplicate_prize_notify_s2c(LastMapId),
									role_op:send_data_to_gate(Msg);
								false ->
									0
							end
					end
			end
	end.

% 领取副本奖励
duplicate_prize_get(#duplicate_prize_get_c2s{tag = Tag},RoleState) ->
	if
		Tag =:= 0 ->
			put(?DUPLICATE_PRIZE, undefined),
			put(?DUPLICATE_PRIZE_FLAG, ?DUPLICATE_PRIZE_NOT_SEND),
			RoleState;
		true ->
			case catch do_duplicate_prize_get(RoleState) of
				{error, Code} ->
					Msg = pet_packet:encode_send_error_s2c(Code),
					role_op:send_data_to_gate(Msg),
					RoleState;
				{ok, NewRoleState} ->
					NewRoleState
			end
	end.

do_duplicate_prize_get(RoleState) ->
	case get(?DUPLICATE_PRIZE) of
		{ItemTemplateId, Num} ->
			% 背包是否可装下
			?IF(package_op:can_added_to_package(ItemTemplateId, Num) =/= 0, ok, ?S2CERR(?ERROR_PACKAGE_FULL)),
			role_op:add_items_to_bag([{ItemTemplateId, Num}], duplicae_prize),
			{_,LastMapProc} = get(?LAST_MAP),
			put(duplicate_prize_map,LastMapProc),
			put(?DUPLICATE_PRIZE, undefined),
			put(?DUPLICATE_PRIZE_FLAG, ?DUPLICATE_PRIZE_NOT_SEND);
		_ ->
			nothing
	end,
	{ok, RoleState}.

export_for_copy() ->
	{get(duplicate_prize_map), get(?LAST_MAP), get(?DUPLICATE_PRIZE), get(?DUPLICATE_PRIZE_FLAG)}.

load_by_copy({Duplicate_prize_map, LastMapId, DuplicatePrize, DuplicatePrizeFlag}) ->
	put(duplicate_prize_map,Duplicate_prize_map),
	put(?LAST_MAP, LastMapId),
	put(?DUPLICATE_PRIZE, DuplicatePrize),
	put(?DUPLICATE_PRIZE_FLAG, DuplicatePrizeFlag).

save_to_db()->
	RoleId = get(roleid),
	Duplicate_prize_map = get(duplicate_prize_map),
	duplicate_prize_db:save_duplicate_prize_map(RoleId, Duplicate_prize_map).