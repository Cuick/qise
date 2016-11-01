%% Author: adrian
%% Created: 2010-4-16
%% Description: TODO: Add description to env
-module(env).

%%
%% Include files
%%
-define(SERVER_START_TIME,"../option/server_start_time.option").
-define(SERVER_NAME_FILE,"../option/server_name.option").
-define(SERVER_FILE, "../option/server.option").
-define(GAME_FILE, "../option/game.option").
-define(SERVER_COMBINE_TIME, "../option/server_combine_time.option").
-define(OPTION_ETS,option_value_ets).
-define(SERVER_NAME_ETS,option_servers_name).

%%
%% Exported Functions
%%

-export([get_env/2,get/2,get2/3,put/2,put2/3,get_tuple2/3,get_server_name/1]).
-export([init/0,fresh/0]).
%%
%% API Functions
%%

%%
%% Local Functions
%%

get_env(Opt, Default) ->
	case application:get_env(Opt) of
		{ok, Val} ->  Val;
		_ -> Default
	end.

init()->
	try
		ets:new(?OPTION_ETS, [named_table,public ,set])
	catch
		_:_-> ignor
	end,
	try
		ets:new(?SERVER_NAME_ETS, [named_table,public ,set])
	catch
		_:_-> ignor
	end,
	fresh().

read_from_file(File,Ets)->
	case file:consult(File) of
		{ok, [Terms]} ->
			lists:foreach(fun(Term)->
								  ets:insert(Ets, Term)
						  end, Terms);
		{error, Reason} -> 
			slogger:msg("load option file [~p] Error ~p",[File,Reason]) ,	
			{error, Reason}
	end.

get_server_name(ServerId)->
	try
		case ets:lookup(?SERVER_NAME_ETS, ServerId) of
			[]-> [];
			[{ServerId,ServerName}]-> ServerName
		end
	catch
		E:R->
			slogger:msg("get_server_name error !!!!!!!!! ServerId ~p R ~p  ~p ~n",[ServerId,R,erlang:get_stacktrace()]),
			[]
	end.

	

get(Key,Default)->
	try
		case ets:lookup(?OPTION_ETS, Key) of
			[]-> Default;
			[{_,Value}]->Value
		end
	catch
		E:R->
			slogger:msg("env get error !!!!!!!!! Key ~p R ~p  ~p ~n",[Key,R,erlang:get_stacktrace()]),
			Default
	end.

get2(Key,Key2,Default)->
	case get(Key,[]) of
		[]->Default;
		Value-> case lists:keyfind(Key2, 1, Value) of
					false-> Default;
					{_Key2,Value2}-> Value2
				end
	end.

get_tuple2(Key,Key2,Default)->
	case get(Key,[]) of
		[]->Default;
		Value-> case lists:keyfind(Key2, 1, Value) of
					false-> Default;
					Tuple-> Tuple
				end
	end.

put(Key,Value)->
	ets:insert(?OPTION_ETS, {Key,Value}).

put2(Key,Key2,Value)->
	OldValue = get(Key,[{Key2,Value}]),
	NewValue = lists:keyreplace(Key2, 1, OldValue, {Key2,Value}),
	ets:insert(?OPTION_ETS, {Key,NewValue}).

fresh()->
	ets:delete_all_objects(?OPTION_ETS),
	ets:delete_all_objects(?SERVER_NAME_ETS),
	read_from_file(?SERVER_FILE,?OPTION_ETS),
	read_from_file(?SERVER_NAME_FILE,?SERVER_NAME_ETS),
	read_from_file(?SERVER_START_TIME,?OPTION_ETS),
	GameConfigFileTmp = ?GAME_FILE ++ "." ++ get(platform, "zydl"),
	GameConfigFile = case filelib:is_regular(GameConfigFileTmp) of
		true ->
			GameConfigFileTmp;
		false ->
			?GAME_FILE ++ ".zydl"
	end,
	read_from_file(GameConfigFile,?OPTION_ETS),
	read_from_file(?SERVER_COMBINE_TIME,?OPTION_ETS).
	