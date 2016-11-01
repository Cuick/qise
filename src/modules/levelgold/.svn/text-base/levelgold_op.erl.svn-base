-module(levelgold_op).
-author("zhuo.yan").

-include("common_define.hrl").
-include("error_msg.hrl").
-include("logger.hrl").
%% -define(ldebug, true).

-export([
		init/0,
		load_from_db/1,
		export_for_copy/0,
		write_to_db/0,
		async_write_to_db/0,
		load_by_copy/1]).
-export([show/0, get_gold_by_level/1]).

% test
-export([test1/0]).

-define(ROLEDATA, role_levelgold).

%%%===================================================================
%%%  CALLBACK
%%%===================================================================
init()->
	load_from_db(get(roleid)).

load_from_db(RoleId)->
	put(?ROLEDATA, levelgold_db:get_role_levelgold_info(RoleId)).

export_for_copy()->
	get(?ROLEDATA).

write_to_db()->
	case get(?ROLEDATA) of
		undefined ->
			nothing;
		[] ->
			nothing;
		Info ->
			levelgold_db:save_role_levelgold_info(get(roleid), Info)
	end.

async_write_to_db()->
	case get(?ROLEDATA) of
		undefined ->
			nothing;
		[] ->
			nothing;
		Info ->
			levelgold_db:async_save_role_levelgold_info(get(roleid), Info)
	end.

load_by_copy(Info)->
	put(?ROLEDATA, Info).

%%%===================================================================
%%%  API
%%%===================================================================
show() ->
	Hist = g_hist(get(?ROLEDATA)),
	?LOG_INFO("~p ~n", [Hist]),
 	Message = levelgold_packet:encode_goldlevel_show_s2c(get(roleid), Hist),
 	role_op:send_data_to_gate(Message).

get_gold_by_level(GLevel) ->
	Check = check(GLevel),
	if
		Check ->
		case levelgold_db:gold(GLevel)	of
		0 -> send_error(?ERROR_GETGOLDBYLEVEL_FAIL);
		Gold ->
			role_op:money_change(?MONEY_TICKET, Gold, levelgold),
			Info = levelgold_db:update_hist(GLevel, get(?ROLEDATA)),
			put(?ROLEDATA, Info),
			show()
		end;
		true ->	send_error(?ERROR_GETGOLDBYLEVEL_FAIL)
	end.

%%%===================================================================
%%%  INTERNAL 
%%%===================================================================
check(Level) ->
	case c_level(Level) of
	true -> c_hist(Level);
	_ -> false
	end.

c_level(Level) ->	Level =< get(level).

c_hist(Level) -> not lists:member(Level, g_hist(get(?ROLEDATA))).

g_hist({_, _, Hist}) -> Hist;
g_hist(_) -> [].


send_error(Err) ->
	Msg = pet_packet:encode_send_error_s2c(Err),
	role_op:send_data_to_gate(Msg).

% test
test1() ->
	show(),
	L = random:uniform(10),
	get_gold_by_level(L).
