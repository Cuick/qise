%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-13
%%% -------------------------------------------------------------------

-module (travel_battle_packet).

-include ("login_pb.hrl").
-include ("travel_battle_def.hrl").

-export ([handle/2, encode_travel_battle_query_role_info_s2c/9, encode_travel_battle_register_s2c/3,
	encode_travel_battle_register_wait_s2c/2, encode_travel_battle_show_rank_page_s2c/1,
	make_role_rank_info/5, encode_travel_battle_open_shop_s2c/1, encode_travel_battle_shop_buy_s2c/1,
	encode_travel_battle_lottery_s2c/1, encode_travel_battle_forecast_begin_notice_s2c/0,
	encode_travel_battle_forecast_end_notice_s2c/0, encode_travel_battle_open_notice_s2c/0,
	encode_travel_battle_close_notice_s2c/0, encode_travel_battle_prepare_s2c/1,
	encode_travel_battle_role_skills_s2c/1, encode_travel_battle_change_skill_success_s2c/1,
	encode_travel_battle_change_skill_failed_s2c/1, encode_travel_battle_upgrade_skill_success_s2c/0,
	encode_travel_battle_upgrade_skill_failed_s2c/1, encode_travel_battle_section_result_s2c/18,
	encode_travel_battle_stage_result_s2c/6, encode_travel_battle_cancel_match_s2c/0,
	encode_travel_battle_notice_s2c/2]).

handle(Message = #travel_battle_query_role_info_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_register_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_open_shop_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_shop_buy_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_show_rank_page_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_lottery_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_change_skill_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_upgrade_skill_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_cast_skill_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(Message = #travel_battle_cancel_match_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};
	
handle(Message = #travel_battle_leave_c2s{}, RolePid) ->
	RolePid ! {travel_battle, Message};

handle(_,_)->
	nothing.

encode_travel_battle_query_role_info_s2c(Scores, Total, TotalWin, 
	SerialWin, Gold, Ticket, Silver, TotalScores, Rank) ->
	login_pb:encode_travel_battle_query_role_info_s2c(#travel_battle_query_role_info_s2c{
		score = Scores, total = Total, total_win = TotalWin, serial_win = SerialWin,
		gold = Gold, ticket = Ticket, silver = Silver, total_scores = TotalScores, 
		rank = Rank}).

encode_travel_battle_register_s2c(State, PersonNum, Points) ->
	login_pb:encode_travel_battle_register_s2c(#travel_battle_register_s2c{
		state = State, person_num = PersonNum, points = Points}).

encode_travel_battle_register_wait_s2c(State, PersonNum) ->
	login_pb:encode_travel_battle_register_s2c(#travel_battle_register_wait_s2c{
		state = State, person_num = PersonNum}).

encode_travel_battle_cancel_match_s2c() ->
	login_pb:encode_travel_battle_cancel_match_s2c(#travel_battle_cancel_match_s2c{}).

encode_travel_battle_section_result_s2c(Section, Result, Scores, Total, TotalWin, 
	SerialWin, Gold, Ticket, Silver, TotalScores, Points, SerialWinResult, 
	SerialWinAwards, MoneyCost, PointsCost, NextSectionMoneyCount, NextSectionPointsCost, 
	NexSectionCheckResult) ->
	login_pb:encode_travel_battle_section_result_s2c(#travel_battle_section_result_s2c{
		section = Section, result = Result, scores = Scores, total = Total, total_win = TotalWin,
		serial_win = SerialWin, gold = Gold, ticket = Ticket, silver = Silver,
		total_scores = TotalScores, points = Points, serial_win_result = SerialWinResult,
		serial_win_awards = SerialWinAwards, points_cost = PointsCost, money_cost = MoneyCost,
		next_section_money_cost = NextSectionMoneyCount, next_section_points_cost = NextSectionPointsCost,
		check_result = NexSectionCheckResult}).

encode_travel_battle_stage_result_s2c(Rank, Scores, Gold, Ticket, 
	Silver, TotalScores) ->
	login_pb:encode_travel_battle_stage_result_s2c(#travel_battle_stage_result_s2c{
		rank = Rank, scores = Scores, gold = Gold, ticket = Ticket, silver = Silver,
		total_scores = TotalScores}).

encode_travel_battle_open_shop_s2c(ItemList) ->
	login_pb:encode_travel_battle_open_shop_s2c(#travel_battle_open_shop_s2c{item_list = ItemList}).

encode_travel_battle_shop_buy_s2c(Scores) ->
	login_pb:encode_travel_battle_shop_buy_s2c(#travel_battle_shop_buy_s2c{
		total_scores = Scores}).

encode_travel_battle_show_rank_page_s2c(RankInfo) ->
	login_pb:encode_travel_battle_show_rank_page_s2c(
		#travel_battle_show_rank_page_s2c{rank_list = RankInfo}).

encode_travel_battle_lottery_s2c(ItemList) ->
	login_pb:encode_travel_battle_lottery_s2c(
		#travel_battle_lottery_s2c{item_list = ItemList}).

encode_travel_battle_forecast_begin_notice_s2c() ->
	login_pb:encode_travel_battle_forecast_begin_notice_s2c(
		#travel_battle_forecast_begin_notice_s2c{}).

encode_travel_battle_forecast_end_notice_s2c() ->
	login_pb:encode_travel_battle_forecast_end_notice_s2c(
		#travel_battle_forecast_end_notice_s2c{}).

encode_travel_battle_open_notice_s2c() ->
	login_pb:encode_travel_battle_open_notice_s2c(
		#travel_battle_open_notice_s2c{}).

encode_travel_battle_close_notice_s2c() ->
	login_pb:encode_travel_battle_close_notice_s2c(
		#travel_battle_close_notice_s2c{}).

encode_travel_battle_prepare_s2c(Seconds) ->
	login_pb:encode_travel_battle_prepare_s2c(
		#travel_battle_prepare_s2c{seconds = Seconds}).

encode_travel_battle_role_skills_s2c(SkillList) ->
	login_pb:encode_travel_battle_role_skills_s2c(
		#travel_battle_role_skills_s2c{skills = SkillList}).

encode_travel_battle_change_skill_success_s2c(SkillId) ->
	login_pb:encode_travel_battle_change_skill_success_s2c(
		#travel_battle_change_skill_success_s2c{skill_id = SkillId}).

encode_travel_battle_change_skill_failed_s2c(Reason) ->
	login_pb:encode_travel_battle_change_skill_failed_s2c(
		#travel_battle_change_skill_failed_s2c{reason = Reason}).

encode_travel_battle_upgrade_skill_success_s2c() ->
	login_pb:encode_travel_battle_upgrade_skill_success_s2c(
		#travel_battle_upgrade_skill_success_s2c{}).

encode_travel_battle_notice_s2c(Type, Param) ->
	login_pb:encode_travel_battle_notice_s2c(#travel_battle_notice_s2c{
		type = Type, param = Param
		}).

encode_travel_battle_upgrade_skill_failed_s2c(Reason) ->
	login_pb:encode_travel_battle_upgrade_skill_failed_s2c(
		#travel_battle_upgrade_skill_failed_s2c{reason = Reason}).

make_role_rank_info(Roleid,RoleName, Gender, Class, Scores) ->
	Sid = travel_battle_util:get_serverid_by_roleid(Roleid),
	#travel_battle_role_rank_info{name = RoleName, gender = Gender,
	class = Class, scores = Scores,sid = Sid}.

