-module (open_charge_feedback_packet).

-include ("login_pb.hrl").

-export ([handle/2, encode_open_charge_feedback_lottery_failed_s2c/1,
	encode_open_charge_feedback_lottery_s2c/1,
	encode_open_charge_feedback_get_award_s2c/1]).


handle(Message = #open_charge_feedback_lottery_c2s{}, RolePid) ->
	RolePid ! {open_charge_feedback, Message};

handle(Message = #open_charge_feedback_get_award_c2s{}, RolePid) ->
	RolePid ! {open_charge_feedback, Message};

handle(_,_)->
	nothing.

encode_open_charge_feedback_lottery_failed_s2c(Reason) ->
	login_pb:encode_open_charge_feedback_lottery_failed_s2c(
		#open_charge_feedback_lottery_failed_s2c{reason = Reason}).

encode_open_charge_feedback_lottery_s2c(Result) ->
	login_pb:encode_open_charge_feedback_lottery_s2c(
		#open_charge_feedback_lottery_s2c{result = Result}).

encode_open_charge_feedback_get_award_s2c(Result) ->
	login_pb:encode_open_charge_feedback_get_award_s2c(
		#open_charge_feedback_get_award_s2c{result = Result}).