%% Copyright
-module(levelgold_packet).
-author("zhuo.yan").
-include("login_pb.hrl").
-include("logger.hrl").
-define(ldebug, true).

-export([handle/2, process_msg/1]).
-export([encode_goldlevel_show_s2c/2]).


%% API
handle(Message, RolePid) ->
	RolePid ! {levelgold_msg,Message}.
process_msg(#get_gold_by_level_c2s{level=Level}) ->
	levelgold_op:get_gold_by_level(Level);
process_msg(UnKnow) ->
	?LOG_INFO2(["unknow message", UnKnow]).

%% ENCODE
encode_goldlevel_show_s2c(RoleId, Hist) ->
	login_pb:encode_goldlevel_show_s2c(#goldlevel_show_s2c{roleid=RoleId, hist=Hist}).

