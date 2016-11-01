-module(login_continuously_op).

-export([
		init/0,
		load_from_db/1,
		export_for_copy/0,
		write_to_db/0,
		async_write_to_db/0,
		load_by_copy/1]).

-export([
		get_counter/0,
		get_log/1,
		set_log/1
		]).

-export([show/0, get_gift/2]).

% test
-export([test/0]).


-include("role_struct.hrl").
-include("login_continuously.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").

%%%===================================================================
%%%  CALLBACK
%%%===================================================================
init()->
	load_from_db(get(roleid)).

load_from_db(RoleId)->
	Now = timer_center:get_correct_now(),
	{{N,Y,D},{_,_,_}}	=  calendar:now_to_local_time(Now),
	NewTime = {{N,Y,D},{0,0,0}},
	{TableName, RoleId, Login_Date, Counter, Normal, Pay} =
		login_continuously_db:get_role_logincontinously_info(RoleId),
	RoleTable = #role_logincnt_table{
		tablename=TableName,
		roleid=RoleId,
		login_date=Login_Date,
		counter=Counter,
		normal_log=Normal,
		pay_log=Pay
	},
%% 	slogger:msg("normal pay log:", [Normal, Pay]),
	{{ON,OY,OD},{_,_,_}} = Login_Date,
	case calendar:time_difference({{ON,OY,OD},{0,0,0}}, NewTime) of
		% 同一天
		{0, _Times} ->
			put(?ROLETABLE, RoleTable);

			% test blow -----------------------------------------------
%% 			put(?ROLETABLE,
%% 			RoleTable#role_logincnt_table{
%% 				login_date=NewTime,
%% 				counter=random:uniform(3),
%% 				normal_log=0,
%% 				pay_log=0});
			% test ----------------------------------------------------
		% 昨天
		{1, _Times} ->
			put(?ROLETABLE,
				RoleTable#role_logincnt_table{
					login_date=NewTime,
					counter=Counter+1,
					normal_log=?HASGOTGIFT_N,
					pay_log=?HASGOTGIFT_N});
		{_Days, _Times} ->
			put(?ROLETABLE,
				RoleTable#role_logincnt_table{
					login_date=NewTime,
					counter=1,
					normal_log=?HASGOTGIFT_N,
					pay_log=?HASGOTGIFT_N})
	end.

export_for_copy()->
	get(?ROLETABLE).

write_to_db()->
	login_continuously_db:save_role_logincontinously_info(get(roleid), get_info()).

async_write_to_db()->
	login_continuously_db:async_save_role_logincontinously_info(get(roleid), get_info()).

load_by_copy(Info)->
	put(?ROLETABLE, Info).

%%%===================================================================
%%%  API
%%%===================================================================
show() ->
	#role_logincnt_table{counter=Counter, normal_log=Log1, pay_log=Log2} = get(?ROLETABLE),
	UserType = get_user_type(),
%% 	slogger:msg("~p ~n", [get(?ROLETABLE)]),
 	Message = login_continuously_packet:encode_login_continuously_show_s2c(Counter, Log1, Log2, UserType),
 	role_op:send_data_to_gate(Message).

get_gift(Day, Type) ->
	% Day 领取第几天的
	% Type 0 -> 普通类型
	%      1 -> 付费类型
	case get_counter() =:= Day of
	true ->
		case get_user_type() =/= Type of
		true -> fail(5);
		false ->
			case get_log(Type) of  % 是否领取过
			?HASGOTGIFT_N ->
				case login_continuously_db:get_reward(Day, Type) of
				nothing -> fail(1);  % 查配置失败
				GiftList ->
					case package_op:can_added_to_package_template_list(GiftList) of
					false ->
						send_error(?ERROR_PACKEGE_FULL),
						fail(2);
					true ->
						lists:foreach(
							fun({Gift,Count})->
							role_op:auto_create_and_put(Gift,Count,continuous_logging_gift) end,GiftList),
						set_log(Type),
						success()
					end
				end;
			?HASGOTGIFT_Y -> fail(3)  % 已经领取
			end
		end;
	_ -> fail(4)  % 失败 天数不对 or 类型不对
	end.


%%%===================================================================
%%%  INTERNAL 
%%%===================================================================
fail(Err) -> slogger:msg("fail ~p", [Err]),send_result(?GET_FAIL).
success() -> slogger:msg("succ"),send_result(?GET_SUCC).
send_result(Result) ->
	Msg = login_continuously_packet:encode_login_continuously_reward_s2c(Result),
	role_op:send_data_to_gate(Msg).
send_error(Err) ->
	Msg = pet_packet:encode_send_error_s2c(Err),
	role_op:send_data_to_gate(Msg).

% test
test() -> ok.

get_info() ->
	RoleTable = get(?ROLETABLE),
	{RoleTable#role_logincnt_table.tablename,
	RoleTable#role_logincnt_table.roleid,
	RoleTable#role_logincnt_table.login_date,
	RoleTable#role_logincnt_table.counter,
	RoleTable#role_logincnt_table.normal_log,
	RoleTable#role_logincnt_table.pay_log}.

get_user_type() ->
	case vip_db:get_role_sum_gold(get(roleid)) of
		{ok,[]}->
			?NORMAL;
		{ok,RoleSumInfo}->
			SumGold = vip_db:get_sumgold_from_suminfo(RoleSumInfo),
			if
				SumGold > 0 ->
					?PAY;
				true ->
					?NORMAL
			end;
		_->
			?NORMAL
	end.

get_counter() ->
	case get(?ROLETABLE) of
		#role_logincnt_table{counter=Counter} -> Counter;
		_ -> 0
	end.

get_log(Type) ->
	case get(?ROLETABLE) of
		#role_logincnt_table{normal_log=Log1, pay_log=Log2} ->
			case Type of
				?NORMAL -> Log1;
				?PAY -> Log2
			end;
		_ -> ?HASGOTGIFT_N
	end.

set_log(Type) ->
	case get(?ROLETABLE) of
		RoleTable when erlang:is_record(RoleTable, role_logincnt_table)->
			case Type of
				?NORMAL -> put(?ROLETABLE, RoleTable#role_logincnt_table{normal_log=?HASGOTGIFT_Y});
				?PAY -> put(?ROLETABLE, RoleTable#role_logincnt_table{pay_log=?HASGOTGIFT_Y})
			end;
		_ -> nothing
	end.

