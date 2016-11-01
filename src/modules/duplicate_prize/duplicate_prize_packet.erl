-module(duplicate_prize_packet).

-include("login_pb.hrl").

-export([encode_duplicate_prize_item_s2c/1, encode_duplicate_prize_notify_s2c/1]).

encode_duplicate_prize_item_s2c(Index) ->
	login_pb:encode_duplicate_prize_item_s2c(#duplicate_prize_item_s2c{prize_index = Index}).

encode_duplicate_prize_notify_s2c(MapId) ->
	login_pb:encode_duplicate_prize_notify_s2c(#duplicate_prize_notify_s2c{duplicate_id = MapId}).
