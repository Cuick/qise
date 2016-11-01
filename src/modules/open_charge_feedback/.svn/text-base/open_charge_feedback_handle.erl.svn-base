-module (open_charge_feedback_handle).

-include ("login_pb.hrl").

-export ([process_msg/1]).


process_msg(#open_charge_feedback_lottery_c2s{}) ->
	open_charge_feedback_op:lottery();

process_msg(#open_charge_feedback_get_award_c2s{}) ->
	open_charge_feedback_op:get_award();

process_msg(_) ->
	nothing.