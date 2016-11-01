%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (travel_battle_op).

-export ([init/0, load_from_db/1, export_for_copy/0, load_by_copy/1, query_role_info/0, register/1, 
	on_offline/0, register_wait/2, join_instance/2, hook_kill_player/2, do_section_end/1, 
	do_stage_end/6, is_in_zone/0, cancel_match/0,show_rank_page/1, lottery/0, broadcast_to_online_client/2, 
	send_month_awards/2,broadcast_to_all_servers/2,leave/0]).

-include ("travel_battle_def.hrl").
-include ("common_define.hrl").
-include ("error_msg.hrl").
-include ("string_define.hrl").
-include ("map_info_struct.hrl").
-include ("creature_define.hrl").
-include ("map_def.hrl").
-include ("role_struct.hrl").

%% travel_battle_info   {state, stage_id, node, section, points, instance_id, lottery_id}

init() ->
	put(travel_battle_info, {false, -1, undefined, 0, 0, undefined, undefined}).
	

load_from_db(_) ->
	init().

export_for_copy() ->
	get(travel_battle_info).

load_by_copy(Info) ->
	put(travel_battle_info, Info).

query_role_info() ->
	Result = case is_battle_start() of
		true ->
			case travel_battle_util:is_travel_battle_server() of
				true ->
					?TRAVEL_BATTLE_IN_PROGRESS;
				false ->
					0
			end;
		false ->
			?TRAVEL_BATTLE_NOT_START
	end,
	if
		Result =/= 0 ->
			Msg = pet_packet:encode_send_error_s2c(Result),
			role_op:send_data_to_gate(Msg);
		true ->
			RoleInfo = creature_op:get_creature_info(),
			RoleId = creature_op:get_id_from_creature_info(RoleInfo),
			{Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, TotalScores} = 
			case role_travel_battle_db:get_role_info(RoleId) of
				[] ->
					{0, 0, 0, 0, 0, 0, 0, 0};
				RoleTravelBattleInfo ->
					Total2 = role_travel_battle_db:get_role_total(RoleTravelBattleInfo),
					TotalWin2 = role_travel_battle_db:get_role_total_win(RoleTravelBattleInfo),
					SerialWin2 = role_travel_battle_db:get_role_serial_win(RoleTravelBattleInfo),
					Gold2 = role_travel_battle_db:get_role_gold(RoleTravelBattleInfo),
					Ticket2 = role_travel_battle_db:get_role_ticket(RoleTravelBattleInfo),
					Silver2 = role_travel_battle_db:get_role_silver(RoleTravelBattleInfo),
					TotalScores2 = role_travel_battle_db:get_role_total_scores(RoleTravelBattleInfo),
					{{_, Month, _}, _} = calendar:now_to_local_time(timer_center:get_correct_now()),
					case role_travel_battle_db:get_role_month(RoleTravelBattleInfo) of
						Month ->
							Scores2 = role_travel_battle_db:get_role_scores(RoleTravelBattleInfo);
						_ ->
							Scores2 = 0,
							role_travel_battle_db:save_role_info(RoleId, 0, Total2, TotalWin2, 
								SerialWin2, Gold2, Ticket2, Silver2, TotalScores2, Month)
					end,
					{Scores2, Total2, TotalWin2, SerialWin2, Gold2, Ticket2, Silver2, TotalScores2}
			end,
			Rank = travel_battle_zone_manager:query_role_rank(RoleId),
			Msg = travel_battle_packet:encode_travel_battle_query_role_info_s2c(Scores, Total, 
				TotalWin, SerialWin, Gold, Ticket, Silver, TotalScores, Rank),
			role_op:send_data_to_gate(Msg)
	end.

register(Stage) ->
	RoleInfo = get(creature_info),
	Flag = lists:any(fun(E) -> RoleInfo#gm_role_info.gs_system_map_info#gs_system_map_info.map_id =:=E end,env:get(travel_battle_map1, [])),
	if
		Flag ->
			Msg = pet_packet:encode_send_error_s2c(?PLEASE_LEAVE_VIPMAP),
			role_op:send_data_to_gate(Msg);
		true ->



	Result = case is_battle_start() of
		true ->
			{State, _, _, _, _, _, _} = get(travel_battle_info),
			if
				State =:= false ->
					case instance_op:is_in_instance() of
						true ->
							?ERRNO_ALREADY_IN_INSTANCE;
						false ->
							0
					end;
				true ->
					?TRAVEL_BATTLE_IN_PROGRESS
			end;
		false ->
			?TRAVEL_BATTLE_NOT_START
	end,
	if
		Result =/= 0 ->
			Msg = pet_packet:encode_send_error_s2c(Result),
			role_op:send_data_to_gate(Msg);
		true ->
			do_register(Stage)
	end
	end.

show_rank_page(Page) when Page < 1; Page > 100 ->
	Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_PAGE_ERROR),
	role_op:send_data_to_gate(Msg);
show_rank_page(Page) ->
	case travel_battle_zone_manager:show_rank_page(Page) of
		{error, ErrNo} ->
			Msg = pet_packet:encode_send_error_s2c(ErrNo),
			role_op:send_data_to_gate(Msg);
		[RankList,Zong] ->
			RankInfo = [travel_battle_packet:make_role_rank_info(Roleid, RoleName, 
				Gender, Class, Scores) || {Roleid, RoleName, Gender, Class, 
				Scores} <- RankList],
			Msg = travel_battle_packet:encode_travel_battle_show_rank_page_s2c([RankInfo,Zong]),
			role_op:send_data_to_gate(Msg)
	end.

lottery() ->
	{State, StageId, Node, Section, Points, InstanceId, LastLotteryId} = get(travel_battle_info),
	if
		LastLotteryId =/= undefined ->
			LotteryId = LastLotteryId + 1,
			LotteryProto = travel_battle_db:get_lottery_info(LotteryId),
			if
				LotteryProto =/= [] ->
					{MoneyType, MoneyCount} = travel_battle_db:get_lottery_cost(LotteryProto),
					Discount = case vip_op:get_addition_with_vip(travel_battle_lottery_discount) of
						0 ->
							0;
						DiscountList ->
							lists:nth(LotteryId, DiscountList)
					end,
					MoneyCount2 = trunc(MoneyCount * (1 - Discount)),
					case role_op:check_money(MoneyType, -MoneyCount2) of
						true ->
							role_op:money_change(MoneyType, -MoneyCount2, travel_battle_lottery),
							AwardRules = travel_battle_db:get_lottery_awards(LotteryProto),
							Awards = drop:apply_lottery_droplist(AwardRules),
							slogger:msg("travel_battle, lottery, LotteryId: ~p, Money: ~p, Awards: ~p~n", [LotteryId, MoneyCount2, Awards]),
							case package_op:can_added_to_package_template_list(Awards) of
			                    false ->
			                    	send_lottery_awards_mail(LotteryId, Awards),
			                    	Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_AWARDS_MAIL),
									role_op:send_data_to_gate(Msg),

									ItemList = lists:map(fun({ItemId, Count}) ->
		                            % role_op:auto_create_and_put(ItemId, Count, travel_battle_lottery),
		                            pb_util:key_value(ItemId, Count)
			                        end, Awards),
			                        Msg1 = travel_battle_packet:encode_travel_battle_lottery_s2c(ItemList),
			                        role_op:send_data_to_gate(Msg1);
			                    true ->
			                        ItemList = lists:map(fun({ItemId, Count}) ->
			                            role_op:auto_create_and_put(ItemId, Count, travel_battle_lottery),
			                            pb_util:key_value(ItemId, Count)
			                        end, Awards),
			                        Msg = travel_battle_packet:encode_travel_battle_lottery_s2c(ItemList),
			                        role_op:send_data_to_gate(Msg)
			                end,
			                put(travel_battle_info, {State, StageId, Node, Section, Points, InstanceId, LotteryId});
						false ->
							Msg = pet_packet:encode_send_error_s2c(?ERROR_LESS_MONEY),
							role_op:send_data_to_gate(Msg)
					end;
				true ->
					nothing
			end;
		true ->
			nothing
	end.

on_offline()->
	{State, _, Node, _, _, InstanceId, _} = get(travel_battle_info),
	if 
		State ->
			RoleInfo = creature_op:get_creature_info(),
			RoleId = creature_op:get_id_from_creature_info(RoleInfo),
			travel_battle_zone_manager:role_offline(Node, RoleId),
			if
				InstanceId =/= undefined ->
					map_processor:leave_instance(RoleId, InstanceId);
				true ->
					nothing
			end;
		true ->
			nothing
	end.

%%取消报名
cancel_match() ->
	{State, _, Node, _, _, _, _} = get(travel_battle_info),
	if 
		State ->
			RoleInfo = creature_op:get_creature_info(),
			RoleId = creature_op:get_id_from_creature_info(RoleInfo),
			case travel_battle_zone_manager:cancel_match(Node, RoleId) of
				ok ->
					Msg = travel_battle_packet:encode_travel_battle_cancel_match_s2c(),
					role_op:send_data_to_gate(Msg),
					init();
				{error, ErrNo} ->
					init(),
					Msg = pet_packet:encode_send_error_s2c(ErrNo),
					role_op:send_data_to_gate(Msg)
			end;
		true ->
			nothing
	end.

register_wait(State, Num) ->
	Msg = travel_battle_packet:encode_travel_battle_register_wait_s2c(State, Num),
	role_op:send_data_to_gate(Msg).

join_instance(InstanceId, {X, Y}) ->
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	LineId = ?TRAVEL_BATTLE_LINE_ID,
	{State, StageId, Node, Section, Points, _, LotteryId} = get(travel_battle_info),
	StageInfo = travel_battle_db:get_stage_info(StageId),
	{{MoneyType, MoneyBase}, PointBase} = travel_battle_db:get_stage_cost(StageInfo),
	NowSection = Section + 1,
	MoneyCount = MoneyBase * NowSection,
	role_op:unlock_money(),
	slogger:msg("travel_battle, join section cost, Section: ~p, Cost: ~p~n", [NowSection, MoneyCount]),
	role_op:money_change(MoneyType, -MoneyCount, travel_battle_section_lost),
	Points2 = Points - PointBase * NowSection,
	put(travel_battle_info, {State, StageId, Node, NowSection, Points2, InstanceId, LotteryId}),
	MapId = travel_battle_db:get_stage_map_id(StageInfo),
	case map_processor:join_instance(RoleId, InstanceId, Node) of
		ok->
			case travel_battle_util:is_travel_battle_server() of
				true ->
					role_op:enter_map_in_same_node(node(),InstanceId,MapId,LineId,X,Y);
				false ->
					MapInfo = get(map_info),
					role_op:change_map_in_other_node_begin(MapInfo, Node, InstanceId, MapId, LineId, X, Y)
			end;
		error->
			slogger:msg("map_processor:join_instance error~n")
	end.

hook_kill_player(KillerId, KillerName) ->
    case is_in_zone() of
        true ->
            RoleInfo = creature_op:get_creature_info(),
			RoleId = creature_op:get_id_from_creature_info(RoleInfo),
            timer:send_after(?TRAVEL_BATTLE_DEAD_LEAVE_MAP_TIME, {kick_from_travel_battle_section, losser}),
			case role_travel_battle_db:get_role_info(RoleId) of
			[] ->
				nothing;
			RoleTravelBattleInfo ->
				SerialWin = role_travel_battle_db:get_role_serial_win(RoleTravelBattleInfo),
				if
					SerialWin >= ?TRAVEL_BATTLE_SERIAL_WIN_OVER_BASE ->
						serial_win_over_broadcast(KillerId, KillerName, SerialWin);
					true ->
						nothing
				end
			end;
        false ->
            nothing
    end.

do_section_end(Result) ->
	role_op:unlock_money(),
	{State, StageId, Node, Section, Points, InstanceId, LotteryId} = get(travel_battle_info),
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	map_processor:leave_instance(RoleId, InstanceId),
	MapInfo = get(map_info),
	role_op:leave_map(RoleInfo,MapInfo),
	{Score, Points2, NextSectionCheckResult} = get_section_awards_and_check_next_section(RoleId, StageId, Section, Points, Result),
	StageInfo = travel_battle_db:get_stage_info(StageId),
	SectionInterval = travel_battle_db:get_stage_interval(StageInfo),
	if
		SectionInterval =/= 0 ->
			timer:sleep(SectionInterval);
		true ->
			nothing
	end,
	if 
		NextSectionCheckResult =:= ?TRAVEL_BATTLE_NEXT_SECTION_CHECK_TRUE ->
			role_op:lock_money(),
			travel_battle_zone_manager:join_next_section(Node, RoleId, Score);
		true ->
			travel_battle_zone_manager:quit_from_stage(Node, RoleId, Score)	
	end,
	put(travel_battle_info, {State, StageId, Node, Section, Points2, undefined, LotteryId}),
	reset_role_data().

do_stage_end(RoleNode, MapId, MapProc, LineId, {X, Y}, Rank) ->
	{_, StageId, _, _, _, InstanceId, _} = get(travel_battle_info),
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	map_processor:leave_instance(RoleId, InstanceId),
	RoleName = creature_op:get_name_from_creature_info(RoleInfo),
	Class = creature_op:get_class_from_creature_info(RoleInfo),
	Gender = creature_op:get_gender_from_creature_info(RoleInfo),
	Scores = get_stage_awards(RoleId, StageId, Rank),
	travel_battle_zone_manager:update_role_rank_info(RoleId, RoleName, Gender, Class, Scores),
	reset_role_data(),
	put(travel_battle_info, {false, -1, undefined, 0, 0, undefined, 0}),
	role_op:unlock_money(),
	MapInfo = get(map_info),
	role_op:change_map_in_other_node_begin(MapInfo, RoleNode, MapProc, MapId, LineId, X, Y).

is_in_zone() ->
	{State, _, _, _, _, _, _} = get(travel_battle_info),
	State.

broadcast_to_all_servers(Type, Param) ->
	travel_battle_util:cast_for_all_server(?MODULE, broadcast_to_online_client, [Type, Param]).

broadcast_to_online_client(Type, Param) ->
	Msg = travel_battle_packet:encode_travel_battle_notice_s2c(Type, Param),
    role_pos_util:send_to_all_online_clinet(Msg).

send_month_awards(RoleId, Rank) ->
	case role_db:get_role_info(RoleId) of
		[] ->
			nothing;
		RoleInfo ->
			RoleName = role_db:get_name(RoleInfo),
			FromName = language:get_string(?STR_SYSTEM),
			Title = language:get_string(?TRAVEL_BATTLE_MONTH_AWARDS_TITLE),
			Content = util:sprintf(language:get_string(?TRAVEL_BATTLE_MONTH_AWARDS_CONTENT), [Rank]),
			MonthAwardsInfo = travel_battle_db:get_month_awards_info(Rank),
			Awards = travel_battle_db:get_month_awards(MonthAwardsInfo),
			mail_op:gm_send_multi_2(FromName,RoleName,Title,Content,Awards,0),
			month_awards_broadcast(RoleId, RoleName, Rank)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
do_register(Stage) ->
	StageInfo = travel_battle_db:get_stage_info(Stage),
	{{MoneyType, MoneyCount}, _} = travel_battle_db:get_stage_cost(StageInfo),
	StageLevel = travel_battle_db:get_stage_level(StageInfo),
	RoleInfo = creature_op:get_creature_info(),
	Level = creature_op:get_level_from_creature_info(RoleInfo),
	Result = if
		Level >= StageLevel ->
			case role_op:check_money(MoneyType, -MoneyCount) of
				true ->
					0;
				false ->
					?ERROR_MONEY_NOT_ENOUGH
			end;
		true ->
			?ERROR_LESS_LEVEL
	end,
	if
		Result =:= 0 ->
			ZoneList = travel_battle_db:get_stage_zone_list(StageInfo),
			case random_choice_zone_node(ZoneList) of
				[] ->
					Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_SYSTEM_ERROR),
					role_op:send_data_to_gate(Msg);
				Node ->
					
					RoleId = creature_op:get_id_from_creature_info(RoleInfo),
					Pos = creature_op:get_pos_from_creature_info(RoleInfo),
					FightForce = creature_op:get_fighting_force_from_creature_info(RoleInfo),
					MapInfo = get(map_info),
					MapId = get_mapid_from_mapinfo(MapInfo),
					LineId = get_lineid_from_mapinfo(MapInfo),
					MapProc = get_proc_from_mapinfo(MapInfo),
					case travel_battle_zone_manager:register(Node, RoleId, FightForce, node(), 
						role_op:make_role_proc_name(RoleId), MapId, MapProc, LineId, Pos) of
						{ok, Result2} ->
							{State, PersonNum} = Result2,
							Points = travel_battle_db:get_stage_points(StageInfo),
							put(travel_battle_info, {true, Stage, Node, 0, Points, undefined, undefined}),
							Msg = travel_battle_packet:encode_travel_battle_register_s2c(State, PersonNum, Points),
							role_op:send_data_to_gate(Msg);
						{error, ErrNo} ->
							Msg = pet_packet:encode_send_error_s2c(ErrNo),
							role_op:send_data_to_gate(Msg)
					end
			end;
		true ->
			Msg = pet_packet:encode_send_error_s2c(Result),
			role_op:send_data_to_gate(Msg)
	end.

random_choice_zone_node(ZoneList) ->
	ConnectNodes = travel_battle_deamon_op:get_connect_map_nodes(),
	Nodes = lists:foldl(fun(ZoneId, Acc) ->
		case lists:keyfind(ZoneId, 1, ConnectNodes) of
			false ->
				Acc;
			{ZoneId, Node} ->
				[Node | Acc]
		end
	end, [], ZoneList),
	Length = length(Nodes),
	if
		Length > 1 ->
			lists:nth(random:uniform(Length), Nodes);
		Length =:= 1 ->
			[H | _] = Nodes,
			H;
		true ->
			[]
	end.

get_section_awards_and_check_next_section(RoleId, StageId, Section, Points, winner) ->
	StageInfo = travel_battle_db:get_stage_info(StageId),
	{{MoneyType, MoneyCount}, PointBase} = travel_battle_db:get_stage_cost(StageInfo),
	AddCount = MoneyCount * Section * 2,
	role_op:money_change(MoneyType, AddCount, travel_battle_section_awards),
	{AddGold, AddTicket, AddSilver} = if
		MoneyType =:= ?MONEY_GOLD ->
			{AddCount, 0, 0};
		MoneyType =:= ?MONEY_TICKET ->
			{0, AddCount, 0};
		MoneyType =:= ?MONEY_BOUND_SILVER ->
			{0, 0, AddCount};
		true ->
			{0, 0, 0}
	end,
	SectionAwardsInfo = travel_battle_db:get_section_awards_info(StageId),
	WinScore = travel_battle_db:get_section_winner_score(SectionAwardsInfo),
	{Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, TotalScores, Month} =
	case role_travel_battle_db:get_role_info(RoleId) of
		[] ->
			{{_, Month2, _}, _} = calendar:now_to_local_time(timer_center:get_correct_now()),
			{WinScore, 1, 1, 1, AddGold, AddTicket, AddSilver, WinScore, Month2};
		RoleTravelBattleInfo ->
			Scores2 = role_travel_battle_db:get_role_scores(RoleTravelBattleInfo),
			Total2 = role_travel_battle_db:get_role_total(RoleTravelBattleInfo),
			TotalWin2 = role_travel_battle_db:get_role_total_win(RoleTravelBattleInfo),
			SerialWin2 = role_travel_battle_db:get_role_serial_win(RoleTravelBattleInfo),
			Gold2 = role_travel_battle_db:get_role_gold(RoleTravelBattleInfo),
			Ticket2 = role_travel_battle_db:get_role_ticket(RoleTravelBattleInfo),
			Silver2 = role_travel_battle_db:get_role_silver(RoleTravelBattleInfo),
			TotalScores2 = role_travel_battle_db:get_role_total_scores(RoleTravelBattleInfo),
			Month3 = role_travel_battle_db:get_role_month(RoleTravelBattleInfo),
			{Scores2 + WinScore, Total2 + 1, TotalWin2 + 1, SerialWin2 + 1, Gold2 + AddGold, 
				Ticket2 + AddTicket, Silver2 + AddSilver, TotalScores2 + WinScore, Month3}
	end,
	slogger:msg("travel_battle, section result: win, RoleId: ~p, Scores: ~p, Total: ~p, TotalWin: ~p, SerialWin: ~p, Gold: ~p, Ticket: ~p, Silver: ~p, TotalScores: ~p, Month: ~p~n", [RoleId, Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, TotalScores, Month]),
	role_travel_battle_db:save_role_info(RoleId, Scores, Total, TotalWin, SerialWin, Gold, 
		Ticket, Silver, TotalScores, Month),
	Points2 = Points + PointBase * Section * 2,
	MoneyCost = MoneyCount * Section,
	PointsCost = PointBase * Section,
	NewSection = (Section + 1),
	NextSectionMoneyCount = MoneyCount * NewSection,
	NextSectionPointsCost = PointBase * NewSection,
	NextSectionCheckResult = case Points2 >= NextSectionPointsCost andalso role_op:check_money(MoneyType, 
		NextSectionMoneyCount) of
		true ->
			?TRAVEL_BATTLE_NEXT_SECTION_CHECK_TRUE;
		false ->
			?TRAVEL_BATTLE_NEXT_SECTION_CHECK_FALSE
	end,
	{CheckResult, Awards} = check_serial_win_awards(SerialWin),
	AwardsList = [pb_util:key_value(ItemId, Count) || {ItemId, Count} <- Awards],
	Msg = travel_battle_packet:encode_travel_battle_section_result_s2c(Section,
		?TRAVEL_BATTLE_RESULT_WINNER, Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, 
		TotalScores, Points2, CheckResult, AwardsList, MoneyCost, PointsCost, NextSectionMoneyCount,
		NextSectionPointsCost, NextSectionCheckResult),
	role_op:send_data_to_gate(Msg),
	{WinScore, Points2, NextSectionCheckResult};
get_section_awards_and_check_next_section(RoleId, StageId, Section, Points, _) ->
	StageInfo = travel_battle_db:get_stage_info(StageId),
	{{MoneyType, MoneyBase}, PointBase} = travel_battle_db:get_stage_cost(StageInfo),
	SectionAwardsInfo = travel_battle_db:get_section_awards_info(StageId),
	LosserScore = travel_battle_db:get_section_losser_score(SectionAwardsInfo),
	{Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, TotalScores, Month} =
	case role_travel_battle_db:get_role_info(RoleId) of
		[] ->
			{{_, Month2, _}, _} = calendar:now_to_local_time(timer_center:get_correct_now()),
			{LosserScore, 1, 0, 0, 0, 0, 0, LosserScore, Month2};
		RoleTravelBattleInfo ->
			Scores2 = role_travel_battle_db:get_role_scores(RoleTravelBattleInfo),
			Total2 = role_travel_battle_db:get_role_total(RoleTravelBattleInfo),
			TotalWin2 = role_travel_battle_db:get_role_total_win(RoleTravelBattleInfo),
			SerialWin2 = role_travel_battle_db:get_role_serial_win(RoleTravelBattleInfo),
			Gold2 = role_travel_battle_db:get_role_gold(RoleTravelBattleInfo),
			Ticket2 = role_travel_battle_db:get_role_ticket(RoleTravelBattleInfo),
			Silver2 = role_travel_battle_db:get_role_silver(RoleTravelBattleInfo),
			TotalScores2 = role_travel_battle_db:get_role_total_scores(RoleTravelBattleInfo),
			Month3 = role_travel_battle_db:get_role_month(RoleTravelBattleInfo),
			{Scores2 + LosserScore, Total2 + 1, TotalWin2, 0, Gold2, Ticket2, Silver2, 
				TotalScores2 + LosserScore, Month3}
	end,
	slogger:msg("travel_battle, section result: loss, RoleId: ~p, Scores: ~p, Total: ~p, TotalWin: ~p, SerialWin: ~p, Gold: ~p, Ticket: ~p, Silver: ~p, TotalScores: ~p, Month: ~p~n", [RoleId, Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, TotalScores, Month]),
	role_travel_battle_db:save_role_info(RoleId, Scores, Total, TotalWin, SerialWin, Gold, 
		Ticket, Silver, TotalScores, Month),
	{{MoneyType, MoneyBase}, PointBase} = travel_battle_db:get_stage_cost(StageInfo),
	MoneyCost = MoneyBase * Section,
	PointsCost = PointBase * Section,
	NewSection = (Section + 1),
	NextSectionMoneyCount = MoneyBase * NewSection,
	NextSectionPointsCost = PointBase * NewSection,
	NextSectionCheckResult = case Points >= NextSectionPointsCost andalso role_op:check_money(MoneyType, 
		NextSectionMoneyCount) of
		true ->
			?TRAVEL_BATTLE_NEXT_SECTION_CHECK_TRUE;
		false ->
			?TRAVEL_BATTLE_NEXT_SECTION_CHECK_FALSE
	end,
	Msg = travel_battle_packet:encode_travel_battle_section_result_s2c(Section, 
		?TRAVEL_BATTLE_RESULT_LOSSER, Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, 
		TotalScores, Points, ?TRAVEL_BATTLE_SERIAL_WIN_AWARD_NONE, [], MoneyCost, PointsCost, 
		NextSectionMoneyCount, NextSectionPointsCost, NextSectionCheckResult),
	role_op:send_data_to_gate(Msg),
	{LosserScore, Points, NextSectionCheckResult}.

get_stage_awards(RoleId, StageId, Rank) when Rank > 0 ->
	StageAwardsInfo = travel_battle_db:get_stage_awards_info(StageId, Rank),
	{MoneyType, MoneyCount} = travel_battle_db:get_stage_money(StageAwardsInfo),
	role_op:money_change(MoneyType, MoneyCount, travel_battle_stage_awards),
	{AddGold, AddTicket, AddSilver} = if
		MoneyType =:= ?MONEY_GOLD ->
			{MoneyCount, 0, 0};
		MoneyType =:= ?MONEY_TICKET ->
			{0, MoneyCount, 0};
		MoneyType =:= ?MONEY_BOUND_SILVER ->
			{0, 0, MoneyCount};
		true ->
			{0, 0, 0}
	end,
	AddScore = travel_battle_db:get_stage_scores(StageAwardsInfo),

	case role_travel_battle_db:get_role_info(RoleId) of
		[] ->
			{{_, Month, _}, _} = calendar:now_to_local_time(timer_center:get_correct_now()),
			Scores = AddScore,
			Total = 1,
			TotalWin = 0,
			SerialWin = 0,
			Gold = AddGold,
			Ticket = AddTicket,
			Silver = AddSilver,
			TotalScores = AddScore;
		RoleTravelBattleInfo ->
			% RoleTravelBattleInfo = role_travel_battle_db:get_role_info(RoleId),
			Scores = role_travel_battle_db:get_role_scores(RoleTravelBattleInfo) + AddScore,
			Total = role_travel_battle_db:get_role_total(RoleTravelBattleInfo),
			TotalWin = role_travel_battle_db:get_role_total_win(RoleTravelBattleInfo),
			SerialWin = role_travel_battle_db:get_role_serial_win(RoleTravelBattleInfo),
			Gold = role_travel_battle_db:get_role_gold(RoleTravelBattleInfo) + AddGold,
			Ticket = role_travel_battle_db:get_role_ticket(RoleTravelBattleInfo) + AddTicket,
			Silver = role_travel_battle_db:get_role_silver(RoleTravelBattleInfo) + AddSilver,
			TotalScores = role_travel_battle_db:get_role_total_scores(RoleTravelBattleInfo) + AddScore,
			Month = role_travel_battle_db:get_role_month(RoleTravelBattleInfo)
	end,


	slogger:msg("travel_battle, stage result: Rank: ~p, RoleId: ~p, Scores: ~p, Total: ~p, TotalWin: ~p, SerialWin: ~p, Gold: ~p, Ticket: ~p, Silver: ~p, TotalScores: ~p, Month: ~p~n", [Rank, RoleId, Scores, Total, TotalWin, SerialWin, Gold, Ticket, Silver, TotalScores, Month]),
	role_travel_battle_db:save_role_info(RoleId, Scores, Total, TotalWin, 
		SerialWin, Gold, Ticket, Silver, TotalScores, Month),
	Msg = travel_battle_packet:encode_travel_battle_stage_result_s2c(Rank, Scores, 
		Gold, Ticket, Silver, TotalScores),
	role_op:send_data_to_gate(Msg),
	stage_awards_broadcast(RoleId, Rank),
	Scores;
get_stage_awards(RoleId, _, Rank) ->
	RoleTravelBattleInfo = role_travel_battle_db:get_role_info(RoleId),
	Scores = role_travel_battle_db:get_role_scores(RoleTravelBattleInfo),
	Gold = role_travel_battle_db:get_role_gold(RoleTravelBattleInfo),
	Ticket = role_travel_battle_db:get_role_ticket(RoleTravelBattleInfo),
	Silver = role_travel_battle_db:get_role_silver(RoleTravelBattleInfo),
	TotalScores = role_travel_battle_db:get_role_total_scores(RoleTravelBattleInfo),
	Msg = travel_battle_packet:encode_travel_battle_stage_result_s2c(Rank, Scores, 
		Gold, Ticket, Silver, TotalScores),
	role_op:send_data_to_gate(Msg),
	Scores.

reset_role_data() ->
	CreatureInfo = creature_op:get_creature_info(),
	NewHp = creature_op:get_hpmax_from_creature_info(CreatureInfo),
	NewMp = creature_op:get_mpmax_from_creature_info(CreatureInfo),
	CreatureInfo1 = creature_op:set_life_to_creature_info(CreatureInfo, NewHp),
	CreatureInfo2 = creature_op:set_mana_to_creature_info(CreatureInfo1, NewMp),
	CreatureInfo3 = creature_op:set_state_to_creature_info(CreatureInfo2, gaming),
	put(creature_info, CreatureInfo3),
	role_op:update_role_info(get(roleid), CreatureInfo3),
	role_op:only_self_update([{mp,NewMp},{hp,NewHp},{state,?CREATURE_STATE_GAME}]),
	Class = get_class_from_roleinfo(CreatureInfo3),
	Level = get_level_from_roleinfo(CreatureInfo3),
	%%不会触发map_complate,需要自己启动恢复buff
	buffer_op:generate_hprecover(Class,Level),	
	buffer_op:generate_mprecover(Class,Level),
	skill_op:clear_all_casttime(),
	Msg = role_packet:encode_skill_cooldown_reset_s2c(),
	role_op:send_data_to_gate(Msg),
	gaming.

check_serial_win_awards(SerialWin) ->
	case travel_battle_db:get_serial_win_info(SerialWin) of
		[] ->
			{?TRAVEL_BATTLE_SERIAL_WIN_AWARD_NONE, []};
		SerialWinInfo ->
			Awards = travel_battle_db:get_serial_win_awards(SerialWinInfo),
			Result = case package_op:can_added_to_package_template_list(Awards) of
                false ->
                	send_serial_win_awards_mail(SerialWin, Awards),
                	?TRAVEL_BATTLE_SERIAL_WIN_AWARD_MAIL;
                true ->
                    ItemList = lists:map(fun({ItemId, Count}) ->
                        role_op:auto_create_and_put(ItemId, Count, travel_battle_serial_win_award)
                    end, Awards),
                    ?TRAVEL_BATTLE_SERIAL_WIN_AWARD_PACKAGE
            end,
        	serial_win_broadcast(SerialWin),
        	{Result, Awards}
	end.

send_lottery_awards_mail(LotteryId, Awards) ->
	RoleInfo = creature_op:get_creature_info(),
	RoleName = creature_op:get_name_from_creature_info(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?TRAVEL_BATTLE_LOTTERY_TITLE),
	Content = language:get_string(?TRAVEL_BATTLE_LOTTERY_CONTENT),
	mail_op:gm_send_multi_2(FromName,RoleName,Title,Content,Awards,0).

send_serial_win_awards_mail(SerialWin, Awards) ->
	RoleInfo = creature_op:get_creature_info(),
	RoleName = creature_op:get_name_from_creature_info(RoleInfo),
	FromName = language:get_string(?STR_SYSTEM),
	Title = language:get_string(?TRAVEL_BATTLE_SERIAL_WIN_TITLE),
	Content = util:sprintf(language:get_string(?TRAVEL_BATTLE_SERIAL_WIN_CONTENT), [SerialWin]),
	mail_op:gm_send_multi_2(FromName,RoleName,Title,Content,Awards,0).

serial_win_broadcast(SerialWin) ->
	RoleInfo = creature_op:get_creature_info(),
	ParamRole = system_chat_util:make_role_param(RoleInfo),
    ParamWin = system_chat_util:make_int_param(SerialWin),
    MsgInfo = [ParamRole,ParamWin],
    broadcast_to_all_servers(?TRAVEL_BATTLE_NOTICE_SERIAL_WIN, MsgInfo).

month_awards_broadcast(RoleId, RoleName, Rank) ->
	ServerId = travel_battle_util:get_serverid_by_roleid(RoleId),
	ParamRole = system_chat_util:make_role_param(RoleId, RoleName, ServerId),
    ParamRank = system_chat_util:make_int_param(Rank),
    MsgInfo = [ParamRole,ParamRank],
    broadcast_to_all_servers(?TRAVEL_BATTLE_NOTICE_MONTH_RANK, MsgInfo).

stage_awards_broadcast(RoleId, Rank) ->
	RoleInfo = creature_op:get_creature_info(),
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamRank = system_chat_util:make_int_param(Rank),
    MsgInfo = [ParamRole,ParamRank],
    broadcast_to_all_servers(?TRAVEL_BATTLE_NOTICE_STAGE_RANK, MsgInfo).

serial_win_over_broadcast(KillerId, KillerName, SerialWin) ->
	RoleInfo = creature_op:get_creature_info(),
	ParamRole = system_chat_util:make_role_param(RoleInfo),
    ParamWin = system_chat_util:make_int_param(SerialWin),
    KillerServerId = travel_battle_util:get_serverid_by_roleid(KillerId),
    ParamKiller = system_chat_util:make_role_param(KillerId, KillerName, KillerServerId),
    MsgInfo = [ParamKiller, ParamRole, ParamWin],
    broadcast_to_all_servers(?TRAVEL_BATTLE_NOTICE_SERIAL_OVER, MsgInfo).

is_battle_start() ->
	BattleProto = travel_battle_db:get_battle_info(),
	{StartTime, EndTime} = travel_battle_db:get_battle_time_line(BattleProto),
	Now = timer_center:get_correct_now(),
	{Date, Time} = calendar:now_to_local_time(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds({Date, StartTime}),
	EndSecs = calendar:datetime_to_gregorian_seconds({Date, EndTime}),
	NowSecs = calendar:datetime_to_gregorian_seconds({Date, Time}),
	StartSecs - ?TRAVEL_BATTLE_BUFF_TIME =< NowSecs andalso NowSecs =< EndSecs + ?TRAVEL_BATTLE_BUFF_TIME.

leave()->
	role_op:unlock_money(),
	{State, StageId, Node, Section, Points, InstanceId, LotteryId} = get(travel_battle_info),
	RoleInfo = creature_op:get_creature_info(),
	RoleId = creature_op:get_id_from_creature_info(RoleInfo),
	map_processor:leave_instance(RoleId, InstanceId),
	MapInfo = get(map_info),
	role_op:leave_map(RoleInfo,MapInfo),
	{Score, Points2, NextSectionCheckResult} = get_section_awards_and_check_next_section(RoleId, StageId, Section, Points, losser),
	travel_battle_zone_manager:quit_from_stage(Node, RoleId, Score).