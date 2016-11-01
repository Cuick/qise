-module (wedding_op).

-include ("error_msg.hrl").
-include ("string_define.hrl").

-export ([apply/1, agree/1, refuse/1, get_ceremony_time_time_available/0, ceremony_select/2, wedding_with_role/1, do_wedding_check/0]).

-include ("role_struct.hrl").

apply(RoleName) ->
	ErrNo = case autoname_db:get_autoname_used(RoleName) of
		{ok, []} ->
			?ERR_CODE_ROLENAME_INVALID;
		{ok, {_, _, RoleId, _}} ->
			case role_pos_util:where_is_role(RoleId) of
				[] ->
					?ERROR_ROLE_OFFLINE;
				_ ->
					case can_wedding_with_me(RoleId) of
						ok ->
							RoleInfo = get(creature_info),
							SelfName = get_name_from_roleinfo(RoleInfo),
							Msg = wedding_packet:encode_wedding_apply_s2c(SelfName),
							role_pos_util:send_to_role_clinet(RoleId,Msg),
							[];
						{error, ErrNo2} ->
							ErrNo2
					end
			end
	end,
	if
		ErrNo =/= [] ->
			Msg2 = wedding_packet:encode_wedding_apply_result_s2c(RoleName, ErrNo),
			role_op:send_data_to_gate(Msg2);
		true ->
			nothing
	end.

agree(RoleName) ->
	ErrNo = case autoname_db:get_autoname_used(RoleName) of
		{ok, []} ->
			?ERR_CODE_ROLENAME_INVALID;
		{ok, {_, _, RoleId, _}} ->
			case role_pos_util:where_is_role(RoleId) of
				[] ->
					?ERROR_ROLE_OFFLINE;
				_ ->
					case call_wedding_with_me(RoleId) of
						ok ->
							set_spouse(RoleId),
							[];
						{error, ErrNo2} ->
							ErrNo2
					end
			end
	end,
	if
		ErrNo =/= [] ->
			Msg2 = wedding_packet:encode_wedding_apply_result_s2c(RoleName, ErrNo),
			role_op:send_data_to_gate(Msg2);
		true ->
			nothing
	end.


refuse(RoleName) ->
	ErrNo = case autoname_db:get_autoname_used(RoleName) of
		{ok, []} ->
			?ERR_CODE_ROLENAME_INVALID;
		{ok, {_, _, RoleId, _}} ->
			case role_pos_util:where_is_role(RoleId) of
				[] ->
					?ERROR_ROLE_OFFLINE;
				_ ->
					RoleInfo = get(creature_info),
					SelfName = get_name_from_roleinfo(RoleInfo),
					Msg = wedding_packet:encode_wedding_apply_result_s2c(SelfName, ?ERROR_WEDDING_ROLE_REFUSED),
					role_op:send_to_other_client(RoleId,Msg),
					[]
			end
	end,
	if
		ErrNo =/= [] ->
			Msg2 = wedding_packet:encode_wedding_apply_result_s2c(RoleName, ErrNo),
			role_op:send_data_to_gate(Msg2);
		true ->
			nothing
	end.

get_ceremony_time_time_available() ->
	Result = wedding_ceremony_manager:query_free_times(),
	Msg = wedding_packet:encode_wedding_ceremony_time_available_s2c(Result),
	role_op:send_data_to_gate(Msg).

ceremony_select(Type, Time) ->
	RoleInfo = get(creature_info),
	Result = case get_spouse_from_roleinfo(RoleInfo) of
		0 ->
			?ERROR_WEDDING_ROLE_NOT_MARRIED;
		SpouseId ->
			%% TODO  check make group
			CeremonyTypeInfo = wedding_db:get_ceremony_type_info(Type),
			{MoneyType, MoneyCount} = wedding_db:get_ceremony_type_cost(CeremonyTypeInfo),
			case role_op:check_money(MoneyType, MoneyCount) of
				{ok, _} ->
					role_op:money_change(MoneyType, MoneyCount, ceremony_select),
					RoleName = get_name_from_roleinfo(RoleInfo),
					SpouseRolePos = role_pos_util:where_is_role(SpouseId),
					SpouseName = role_pos_db:get_role_rolename(SpouseRolePos),
					case wedding_ceremony_manager:book_ceremony(RoleName, SpouseName, Type, Time) of
						ok ->
							RewardList = wedding_db:get_ceremony_type_items(CeremonyTypeInfo),
							FromName = language:get_string(?STR_SYSTEM),
	                        Title = language:get_string(?WEDDING_CEREMONY_AWARDS_TITILE),
	                        Content = language:get_string(?WEDDING_CEREMONY_AWARDS_CONTENT),
	                        mail_op:gm_send_multi_2(FromName,RoleName,Title,Content,RewardList,0),
	                        mail_op:gm_send_multi_2(FromName,SpouseName,Title,Content,RewardList,0),
	                        Ring = wedding_db:get_ceremony_type_ring(CeremonyTypeInfo),
	                        Title2 = language:get_string(?WEDDING_CEREMONY_RING_TITLE),
	                        Content2 = language:get_string(?WEDDING_CEREMONY_RING_CONTENT),
	                        mail_op:gm_send_multi(FromName,RoleName,Title2,Content2,[Ring],0),
	                        mail_op:gm_send_multi(FromName,SpouseName,Title2,Content2,[Ring],0),
							0;
						{error, ErrNo} ->
							ErrNo
					end;
				_ ->
					?ERROR_LESS_MONEY
			end
	end,
	Msg = wedding_packet:encode_wedding_ceremony_select_s2c(0),
	role_op:send_data_to_gate(Msg).

wedding_with_role(RoleId) ->
	case do_wedding_check() of
		ok -> 
			set_spouse(RoleId),
			ok;
		Ret ->
			Ret
	end.

do_wedding_check() ->
	RoleInfo = get(creature_info),
	case get_spouse_from_roleinfo(RoleInfo) of
		0 ->
			ok;
		_ ->
			{error, ?ERROR_WEDDING_ROLE_HAS_MARRIED}
	end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% local
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

can_wedding_with_me(RoleId) ->
	case creature_op:get_creature_info(RoleId) of
		undefined ->
			RoleRef = role_pos_util:get_role_pos(RoleId),
			try
				role_processor:wedding_check(RoleRef)
			catch
				E : R ->
					slogger:msg("call_wedding_with_me error ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
					{error, ?ERROR_UNKNOWN}
			end;
		RoleInfo ->
			case get_spouse_from_roleinfo(RoleInfo) of
				0 ->
					ok;
				_ ->
					{error, ?ERROR_WEDDING_ROLE_HAS_MARRIED}
			end
	end.

call_wedding_with_me(RoleId) ->
	RoleRef = case creature_op:get_creature_info(RoleId) of
		undefined ->
			role_pos_util:get_role_pos(RoleId);
		RoleInfo ->
			get_pid_from_roleinfo(RoleInfo)
	end,
	try
		role_processor:wedding_with_me(RoleRef,get(roleid))
	catch
		E : R ->
			slogger:msg("call_wedding_with_me error ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
			{error, ?ERROR_UNKNOWN}
	end.

set_spouse(RoleId) ->
	put(creature_info, set_spouse_to_roleinfo(get(creature_info), RoleId)),
	role_op:only_self_update([{spouse,RoleId}]).