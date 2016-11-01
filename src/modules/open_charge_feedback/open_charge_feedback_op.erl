-module (open_charge_feedback_op).

-include ("error_msg.hrl").
-include ("item_define.hrl").
-include ("common_define.hrl").

-define (OPEN_CHARGE_FEEDBACK_SYSID, 1192).

-export ([lottery/0, get_award/0]).

lottery() ->
	case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_OPEN_CHARGE_FEEDBACK, 1) of
		true->
			item_util:consume_items_by_classid(?ITEM_TYPE_OPEN_CHARGE_FEEDBACK, 1),
			FeedbackProtoInfo = open_charge_feedback_db:get_feedback_proto_info(),
			AwardList = open_charge_feedback_db:get_feedback_awards(FeedbackProtoInfo),
			Award = util:random_choice(AwardList),
			put(open_charge_feedback_award, Award),
			Msg = open_charge_feedback_packet:encode_open_charge_feedback_lottery_s2c(Award),
		    role_op:send_data_to_gate(Msg);
	    false ->
	    	Msg = open_charge_feedback_packet:encode_open_charge_feedback_lottery_failed_s2c(?ERROR_MISS_ITEM),
			role_op:send_data_to_gate(Msg)
	end.

get_award() ->
	case get(open_charge_feedback_award) of
		undefined ->
			Msg = open_charge_feedback_packet:encode_open_charge_feedback_get_award_s2c(?OPEN_CHARGE_FEEDBACK_LOTTERY_ERROR),
			role_op:send_data_to_gate(Msg);
		MoneyCount ->
			role_op:money_change(?MONEY_GOLD, MoneyCount, open_charge_feedback_lottery),
			system_broadcast_msg(MoneyCount),
			Msg = open_charge_feedback_packet:encode_open_charge_feedback_get_award_s2c(0),
		    role_op:send_data_to_gate(Msg)
	end.

system_broadcast_msg(MoneyCount) ->
	RoleInfo = get(creature_info),
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	ParamInt = system_chat_util:make_int_param(MoneyCount),
    MsgInfo = [ParamRole,ParamInt],
    system_chat_op:system_broadcast(?OPEN_CHARGE_FEEDBACK_SYSID,MsgInfo).