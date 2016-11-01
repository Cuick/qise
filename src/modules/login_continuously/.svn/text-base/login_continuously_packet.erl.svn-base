%% Copyright
-module(login_continuously_packet).
-author("zhuo.yan").
-include("login_pb.hrl").
-include("logger.hrl").

-export([handle/2, process_msg/1]).
-export([
	encode_login_continuously_show_s2c/4,
	encode_login_continuously_reward_s2c/1]).


%% API
handle(Message, RolePid) ->
	RolePid ! {login_continuously_msg,Message}.

%% PROCESS
process_msg(#login_continuously_reward_c2s{day=Day, type=Type}) ->
	login_continuously_op:get_gift(Day, Type);
process_msg(UnKnow) ->
	?LOG_INFO2(["unknow message", UnKnow]).

%% ENCODE
encode_login_continuously_show_s2c(Counter, Log1, Log2, UserType) ->
	login_pb:encode_login_continuously_show_s2c(#login_continuously_show_s2c{counter=Counter, normal=Log1, pay=Log2, usertype=UserType}).

encode_login_continuously_reward_s2c(Result) ->
	login_pb:encode_login_continuously_reward_s2c(#login_continuously_reward_s2c{result=Result}).
