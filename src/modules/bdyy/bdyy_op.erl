%%% =======================================================================
%%% 
%%% bang da yuanyang op.
%%%
%%% =======================================================================
-module(bdyy_op).


-export([init/0, destroy/0, is_start/0, is_in_instance/0, spawn_new_item/0, hit_right/1, time_end/0]).

-include("common_define.hrl").
-include("bdyy_def.hrl").
-include("instance_define.hrl").
-include("role_struct.hrl").


init() ->
	RoleInfo = get(creature_info),
	RoleId = get_id_from_roleinfo(RoleInfo),
	ProtoInfo = bdyy_db:get_proto_info(),
	SectionNum = bdyy_db:get_proto_sections(ProtoInfo),
	put(bdyy_info, {SectionNum, 0, 0}),
	spawn_new_item().

destroy() ->
	put(bdyy_info, {false, 0, []}),
	Msg = bdyy_packet:encode_bdyy_item_end_s2c(),
	role_op:send_data_to_gate(Msg).

is_in_instance() ->
	case instance_op:is_in_instance() of
		true ->
			ProtoId = instance_op:get_cur_protoid(),
			ProtoInfo = instance_proto_db:get_info(ProtoId),
			Type = instance_proto_db:get_type(ProtoInfo),
			case Type of
				?INSTANCE_TYPE_BDYY ->
					true;
				_ ->
					false
			end;
		_ ->
			false
	end.

is_start() ->
	case get(bdyy_info) of
		undefined ->
			false;
		_ ->
			true
	end.

get_random_item() ->
	AllItems = bdyy_db:get_item_all(),
	RateSum = lists:foldl(fun(ItemProto, Sum) ->
								Rate = bdyy_db:get_item_show_rate(ItemProto),
								Sum + Rate
							end, 0, AllItems),
	Rate = random:uniform(RateSum),
	{_, ItemId, _} = lists:foldr(fun(TmpItemProto, {Sum, ItemId, Flag}) ->
		TmpRate = bdyy_db:get_item_show_rate(TmpItemProto),
		NewSum = Sum - TmpRate,
		if 
			Flag andalso NewSum =< Rate ->
				TmpItemId = bdyy_db:get_item_id(TmpItemProto),
				{NewSum, TmpItemId, false};
			true ->
				{NewSum, ItemId, Flag}
		end
	end, {RateSum, [], true}, AllItems),
	ItemId.

spawn_new_item() ->
	{SectionNum, NowSection, NowMoney} = get(bdyy_info),
	if
	 	NowSection >= SectionNum ->
	 		role_op:money_change(?MONEY_SILVER, NowMoney, bdyy_awards),
	 		erase(bdyy_info),
	 		Msg = bdyy_packet:encode_bdyy_item_end_s2c(NowMoney),
	 		role_op:send_data_to_gate(Msg);
	 	true ->
	 		ItemId = get_random_item(),
	 		Section = NowSection + 1,
	 		SectionInfo = bdyy_db:get_section_info(Section),
	 		ShowTime = bdyy_db:get_section_show_time(SectionInfo),
	 		Msg = bdyy_packet:encode_bdyy_item_show_s2c(ItemId, ShowTime),
	 		role_op:send_data_to_gate(Msg),
	 		put(bdyy_info, {SectionNum, Section, NowMoney}),
	 		NextShow = bdyy_db:get_section_next_show(SectionInfo),
			if
				NextShow =:= 0 ->
					spawn_new_item();
				true ->
					erlang:send_after(NextShow, self(), {bdyy_next_show})
			end
	 end.


hit_right(ItemId) ->
	{SectionNum, NowSection, NowMoney} = get(bdyy_info),
	ItemInfo = bdyy_db:get_item_info(ItemId),
	{Min, Max} = bdyy_db:get_item_money(ItemInfo),
	Money = if
		Max =:= Min ->
			Max;
		true ->
			Min + random:uniform(Max - Min)
	end,
	Msg = bdyy_packet:encode_bdyy_item_hit_s2c(Money),
	role_op:send_data_to_gate(Msg),
	put(bdyy_info, {SectionNum, NowSection, NowMoney + Money}).


time_end() ->
	{_, NowSection, NowMoney} = get(bdyy_info),
	role_op:money_change(?MONEY_SILVER, NowMoney, bdyy_awards),
	erase(bdyy_info),
	Msg = bdyy_packet:encode_bdyy_item_end_s2c(NowMoney),
	role_op:send_data_to_gate(Msg).