-module (wedding_packet).

-include ("login_pb.hrl").

-export ([handle/2, encode_wedding_apply_s2c/1, encode_wedding_apply_result_s2c/2, encode_wedding_ceremony_time_available_s2c/1,
	encode_wedding_ceremony_select_s2c/1, encode_wedding_ceremony_notify_s2c/2, encode_wedding_ceremony_start_s2c/2,
	encode_wedding_ceremony_end_s2c/2]).

handle(Msg, RolePid) ->
	RolePid ! {wedding_from_client, Msg}.

encode_wedding_apply_s2c(RoleName) ->
	login_pb:encode_wedding_apply_s2c(#wedding_apply_s2c{role_name = RoleName}).

encode_wedding_apply_result_s2c(RoleName, Result) ->
	login_pb:encode_wedding_apply_result_s2c(#wedding_apply_result_s2c{role_name = RoleName, result = Result}).

encode_wedding_ceremony_time_available_s2c(TimeList) ->
	login_pb:encode_wedding_ceremony_time_available_s2c(#wedding_ceremony_time_available_s2c{time_list = TimeList}).

encode_wedding_ceremony_select_s2c(Result) ->
	login_pb:encode_wedding_ceremony_select_s2c(#wedding_ceremony_select_s2c{result = Result}).

encode_wedding_ceremony_notify_s2c(Applicant, Spouse) ->
	login_pb:encode_wedding_ceremony_notify_s2c(#wedding_ceremony_notify_s2c{spouse_1 = Applicant, spouse_2 = Spouse}).

encode_wedding_ceremony_start_s2c(Applicant, Spouse) ->
	login_pb:encode_wedding_ceremony_start_s2c(#wedding_ceremony_start_s2c{spouse_1 = Applicant, spouse_2 = Spouse}).

encode_wedding_ceremony_end_s2c(Applicant, Spouse) ->
	login_pb:encode_wedding_ceremony_end_s2c(#wedding_ceremony_end_s2c{spouse_1 = Applicant, spouse_2 = Spouse}).

