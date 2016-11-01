%% Author: Administrator
%% Created: 2011-4-22
%% Description: TODO: Add description to fatigue_ver2
-module(fatigue_ver2).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").

-define(FATIGUE_CONTEXT,'$fatigue_context_value$').
-define(WARNING_TIMER_NAME,'$fatigue_timer_ref$').
-define(DEFAULT_CLEAR_RELEX_SECONDS,60*60*5).				%%清除疲劳需要的时间
-define(DEFAULT_WARNING_FIRST_TIME_S,60*60). 				%%第一次提醒	
-define(DEFAULT_WARNING_SECOND_TIME_S,2*60*60).  			%%第二次提醒
-define(DEFAULT_ALERT_FIRST_TIME_S,3*60*60).                %%第一次警告
-define(DEFAULT_ALERT_SECOND_TIME_S,(3*60+30)*60).          %%第二次警告
-define(DEFAULT_ALERT_THIRD_TIME_S,4*60*60).                %%第三次警告
-define(DEFAULT_ALERT_FOUTH_TIME_S,(4*60+30)*60).           %%第四次警告


-define(DEFAULT_FATIGUE_SECONDS,60*60*3).					%%最大疲劳时间

%%
%% Exported Functions
%%
-export([hook_online/1,hook_offline/0,apply_get_gainrate/0,fatigue_message/1,apply_set_adult/0,apply_init/0]).


%%
%% API Functions
%%

apply_init()->
	case get(?FATIGUE_CONTEXT) of
		undefined->
			nothing;
		_->
			gen_warning()
	end.

hook_online(Account)->
	Now = timer_center:get_correct_now(),
	{A,B,_C} = Now,
	NowSecond = A * 1000000 + B,
	#fatigue{fatigue=FatigueTime,offline=OfflineTime,relex=Relex} = FatigueInfo = read_fatigue(Account,NowSecond),
	TempRelex = Relex + NowSecond- OfflineTime,
	ClearFatigueTime = env:get2(fatigue, clear_relex_seconds,?DEFAULT_CLEAR_RELEX_SECONDS),
	{NewRelex,NewFatigue} = if TempRelex>=ClearFatigueTime->
									{0,0};
								true->
									{TempRelex,FatigueTime}
							end,
	MaxFatigueTime = env:get2(fatigue, max_fatigue_seconds,?DEFAULT_FATIGUE_SECONDS),
	if
		MaxFatigueTime =< NewFatigue->	%%在线时间已达上限
			send_regurl(),
			LeftTime = ClearFatigueTime - NewRelex,
			SendPack = #fatigue_login_disabled_s2c{lefttime=LeftTime,prompt = get_prompt_msg(ver2_login_msg)},
			BinSend = login_pb:encode_fatigue_login_disabled_s2c(SendPack),
			role_op:send_data_to_gate(BinSend);
		true->
			put(?FATIGUE_CONTEXT,{FatigueInfo#fatigue{fatigue=NewFatigue,relex=NewRelex},NowSecond}),
			send_regurl(),
			gen_warning()
	end.
	

hook_offline()->
	case get(?FATIGUE_CONTEXT) of
		undefined-> ignor;
		{FatigueInfo,LoginTime} ->
			Now = timer_center:get_correct_now(),
			{A,B,_C} = Now,
			NowSecond = A * 1000000 + B,
			MaxFatigueTime =  env:get2(fatigue, max_fatigue_seconds,?DEFAULT_FATIGUE_SECONDS),
			FatigueTime = erlang:min(FatigueInfo#fatigue.fatigue + NowSecond - LoginTime,MaxFatigueTime),
			write_fatigue(FatigueInfo#fatigue{fatigue=FatigueTime,offline=NowSecond})
	end.
		
gen_warning()->
	case get(?FATIGUE_CONTEXT) of
		undefined->
			nothing;
		{FatigueInfo,LoginTime} ->
			Now = timer_center:get_correct_now(),
			{A,B,_C} = Now,
			NowSecond = A * 1000000 + B,
			FatigueTime = FatigueInfo#fatigue.fatigue + NowSecond - LoginTime,
			FirstWarningSeconds = env:get2(fatigue, first_warning_seconds, ?DEFAULT_WARNING_FIRST_TIME_S),
			SecondWarningSeconds = env:get2(fatigue, second_warning_seconds, ?DEFAULT_WARNING_SECOND_TIME_S),
			FirstAlertSeconds = env:get2(fatigue, first_alert_seconds, ?DEFAULT_ALERT_FIRST_TIME_S),
			SecondAlertSeconds = env:get2(fatigue, second_alert_seconds, ?DEFAULT_ALERT_SECOND_TIME_S),
			ThirdAlertSeconds = env:get2(fatigue, third_alert_seconds, ?DEFAULT_ALERT_THIRD_TIME_S),
			FouthAlertSeconds = env:get2(fatigue, fouth_alert_seconds, ?DEFAULT_ALERT_FOUTH_TIME_S),
			MaxFatigueTime =  env:get2(fatigue, max_fatigue_seconds,?DEFAULT_FATIGUE_SECONDS),
			if
				FatigueTime >= MaxFatigueTime->
					send_alert(get_prompt_msg(ver2_offline_msg));
				FatigueTime >= FouthAlertSeconds -> 
		   			InterlVal = (MaxFatigueTime - FatigueTime)*1000,
		   			gen_timer(InterlVal,alert,get_prompt_msg(ver2_offline_msg));
		   		FatigueTime >= ThirdAlertSeconds ->
					InterlVal = (FouthAlertSeconds - FatigueTime)*1000,
		   			gen_timer(InterlVal,prompt,get_prompt_msg(ver2_alert_msg4));
		   		FatigueTime >= SecondAlertSeconds ->
					InterlVal = (ThirdAlertSeconds - FatigueTime)*1000,
		   			gen_timer(InterlVal,prompt,get_prompt_msg(ver2_alert_msg3));
		   		FatigueTime >= FirstAlertSeconds ->
					InterlVal = (SecondAlertSeconds - FatigueTime)*1000,
		   			gen_timer(InterlVal,prompt,get_prompt_msg(ver2_alert_msg2));
				FatigueTime >= SecondWarningSeconds ->
					InterlVal = (FirstAlertSeconds - FatigueTime)*1000,
		   			gen_timer(InterlVal,prompt,get_prompt_msg(ver2_alert_msg1));
				FatigueTime >= FirstWarningSeconds ->
					InterlVal = (SecondWarningSeconds - FatigueTime)*1000,
		   			gen_timer(InterlVal,prompt,get_prompt_msg(ver2_warning_msg2));
	   			true->
		  			InterlVal = (FirstWarningSeconds - FatigueTime)*1000,
		   			gen_timer(InterlVal,prompt,get_prompt_msg(ver2_warning_msg1))
			end
	end.

apply_set_adult()->
	put(?FATIGUE_CONTEXT,undefined).

apply_get_gainrate()->
	case get(?FATIGUE_CONTEXT) of
		undefined ->
			1;
		{FatigueInfo,LoginTime} ->
			Now = timer_center:get_correct_now(),
			{A,B,_C} = Now,
			NowSecond = A * 1000000 + B,
			FatigueTime = FatigueInfo#fatigue.fatigue + NowSecond - LoginTime,
			FirstAlertSeconds = env:get2(fatigue, first_alert_seconds, ?DEFAULT_ALERT_FIRST_TIME_S),
			if
				FatigueTime >= FirstAlertSeconds ->
					0.5;
				true ->
					1
			end
	end.

read_fatigue(Account,NowSecond)->
	fatigue_db:read_fatigue(Account,NowSecond).

write_fatigue(FatigueInfo)->
	fatigue_db:write_fatigue(FatigueInfo).

gen_timer(AfterInterval,Type,Message)->
	free_timer(),
	case AfterInterval of
		0-> self()!{fatigue_ver2,{Type,Message}};
		_->
			case timer_util:send_after(AfterInterval, {fatigue_ver2,{Type,Message}}) of
				{ok,TimerRef}->put(?WARNING_TIMER_NAME,TimerRef);
				{error,_Reason}->error
			end
	end.

free_timer()->
	case get(?WARNING_TIMER_NAME) of
		undefined -> ignor;
		TimerRef -> timer_util:cancel_timer(TimerRef),
					put(?WARNING_TIMER_NAME,undefined)
  	end.

fatigue_message({Type,Message})->
	case Message of
		""-> ignor;
		_-> 
		case Type of
			alert-> 
					send_alert(Message);
			prompt->
					send_prompt(Message),
					gen_warning();
			_-> ignor
		end
	end.

send_regurl()->
	URL = env:get2(fatigue,goto_url ,[]),
	case URL of 
		[]-> ignor;
		_->	SendPack = #finish_register_s2c{gourl=URL},
			BinSend = login_pb:encode_finish_register_s2c(SendPack),
			role_op:send_data_to_gate(BinSend)
	end.

send_prompt(Message)->
	SendPack = #fatigue_prompt_with_type_s2c{prompt=Message,type=2},
	BinSend = login_pb:encode_fatigue_prompt_with_type_s2c(SendPack),
	role_op:send_data_to_gate(BinSend).

send_alert(Message)->
	SendPack = #fatigue_prompt_with_type_s2c{prompt=Message,type=1},
	BinSend = login_pb:encode_fatigue_prompt_with_type_s2c(SendPack),
	role_op:send_data_to_gate(BinSend).
	
%%
%% Local Functions
%%

get_prompt_msg(Key)->
	env:get2(fatigue, Key ,<<"">>).