%% Copyright
-module(levelitem_packet).

-include("login_pb.hrl").
-include("logger.hrl").
-include("levelitem.hrl").

-export([handle/2, process_msg/1]).
-export([encode_level_award_item_s2c/1]).

%% API
handle(Message, RolePid) ->
	RolePid ! {levelitem_msg,Message}.

process_msg(#get_level_award_c2s{id=Id}) ->
	levelitem_op:get_items_by_id(Id);
process_msg(UnKnow) ->
	?LOG_INFO2(["unknow message", UnKnow]).

%% ENCODE
encode_level_award_item_s2c(Hist)->
	login_pb:encode_level_award_item_s2c(#level_award_show_s2c{hist=Hist}).

