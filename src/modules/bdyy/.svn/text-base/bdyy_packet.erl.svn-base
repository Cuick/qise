%%% =======================================================================
%%% 
%%% bang da yuanyang packet.
%%%
%%% =======================================================================
-module(bdyy_packet).

-include("login_pb.hrl").

-export([handle/2, encode_bdyy_item_show_s2c/2, encode_bdyy_item_hit_s2c/1, encode_bdyy_item_end_s2c/1]).

handle(Message, RolePid) ->
	RolePid ! {bdyy_from_client, Message}.

encode_bdyy_item_show_s2c(ItemId, ShowTime) ->
	login_pb:encode_bdyy_item_show_s2c(#bdyy_item_show_s2c{item_id = ItemId, show_time = ShowTime}).

encode_bdyy_item_hit_s2c(Result) ->
	login_pb:encode_bdyy_item_hit_s2c(#bdyy_item_hit_s2c{result = Result}).

encode_bdyy_item_end_s2c(RealMoney) ->
	login_pb:encode_bdyy_item_end_s2c(#bdyy_item_end_s2c{awards = RealMoney}).

