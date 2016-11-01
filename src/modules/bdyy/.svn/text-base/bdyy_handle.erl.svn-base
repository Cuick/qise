%%% =======================================================================
%%% 
%%% bang da yuanyang handle.
%%%
%%% =======================================================================

-module(bdyy_handle).

-include("login_pb.hrl").

-export([process_msg/1]).

process_msg(#bdyy_start_c2s{}) ->
	case bdyy_op:is_in_instance() of
		true ->
			case bdyy_op:is_start() of
				true ->
					slogger:msg("yanzengyan, bdyy is started!~n");
				false ->
					bdyy_op:init()
			end;
		false ->
			slogger:msg("yanzengyan, not in bdyy instance!~n")
	end;

process_msg(#bdyy_item_hit_c2s{item_id = ItemId}) ->
	case bdyy_op:is_in_instance() of
		true ->
			case bdyy_op:is_start() of
				true ->
					bdyy_op:hit_right(ItemId);
				false ->
					slogger:msg("yanzengyan, bdyy is not started!~n")
			end;
		false ->
			slogger:msg("yanzengyan, not in bdyy instance!~n")
	end;

process_msg(#bdyy_end_c2s{}) ->
	case bdyy_op:is_in_instance() of
		true ->
			case bdyy_op:is_start() of
				true ->
					bdyy_op:time_end();
				false ->
					slogger:msg("yanzengyan, bdyy is not started!~n")
			end;
		false ->
			slogger:msg("yanzengyan, not in bdyy instance!~n")
	end;

process_msg({bdyy_next_show}) ->
	case bdyy_op:is_in_instance() of
		true ->
			case bdyy_op:is_start() of
				true ->
					bdyy_op:spawn_new_item();
				false ->
					slogger:msg("yanzengyan, bdyy is not started!~n")
			end;
		false ->
			slogger:msg("yanzengyan, not in bdyy instance!~n")
	end;

process_msg({bdyy_time_end}) ->
	case bdyy_op:is_in_instance() of
		true ->
			case bdyy_op:is_start() of
				true ->
					bdyy_op:time_end();
				false ->
					slogger:msg("yanzengyan, bdyy is not started!~n")
			end;
		false ->
			slogger:msg("yanzengyan, not in bdyy instance!~n")
	end;

process_msg(_) ->
	nothing.