%% Author: adrian
%% Created: 2010-8-26
%% Description: TODO: Add description to fatigue
-module(fatigue).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-define(FATIGUE_CONTEXT,'$fatigue_context_value$').
-define(WARNING_TIMER_NAME,'$fatigue_timer_ref$').
-define(DEFAULT_CLEAR_RELEX_SECONDS,60*60*5).
-define(DEFAULT_GAIN_0PERCENT_SECONDS,60*60*5).
-define(DEFAULT_GAIN_50PERCENT_SECONDS,60*60*3).

-define(DEFAULT_ALERT_100PERCENT_INTERVAL_SECONDS,60*60). %%every hours
-define(DEFAULT_ALERT_50PERCENT_INTERVAL_SECONDS,30*60).  %%every 30min
-define(DEFAULT_ALERT_0PERCENT_INTERVAL_SECONDS,15*60).   %%every 15min

%%
%% Exported Functions
%%
-export([on_playeronline/1,on_playeroffline/0,
		get_gainrate/0,set_adult/0,
		init/0,load_by_copy/1,export_for_copy/0]).


%%
%% API Functions
%%
init()->
	case env:get2(fatigue, disable, false) of
		true-> ignor;
		false->
			Module = env:get2(fatigue,version,fatigue),
			fatigue_apply(Module,apply_init,[])	
	end.
	
on_playeronline(Account)->
	case env:get2(fatigue, disable, false) of
		true-> ignor;
		false->
			Module = env:get2(fatigue,version,fatigue),
			fatigue_apply(Module,hook_online,[Account])	
	end.

on_playeroffline()->
	case env:get2(fatigue, disable, false) of
		true-> ignor;
		false->
			Module = env:get2(fatigue,version,fatigue),
			fatigue_apply(Module,hook_offline,[])	
	end.

set_adult()->
	Module = env:get2(fatigue,version,fatigue),
	fatigue_apply(Module,apply_set_adult,[]).

get_gainrate()->
	Module = env:get2(fatigue,version,fatigue),
	fatigue_apply(Module,apply_get_gainrate,[]).

load_by_copy(Info)->
	put(?FATIGUE_CONTEXT,Info).

export_for_copy()->
	get(?FATIGUE_CONTEXT).
%%
%% Local Functions
%%

fatigue_apply(M,F,A)->
	try
		erlang:apply(M,F,A)
	catch
		E:R->
			slogger:msg("fatigue_apply M:~p F:~p A: ~p ~n E:~p R:~p S:~p ~n",[M,F,A,E,R,erlang:get_stacktrace()])
	end.