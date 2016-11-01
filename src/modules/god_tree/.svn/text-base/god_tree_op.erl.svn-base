%% Author: CuiChengKai
%% Created: 2013-12-31
-module(god_tree_op).




-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("login_pb.hrl").
-include("error_msg.hrl").


-export([process_message/1,init/0]).

init()->
	case god_tree_db:get_info() of
		[] ->
			Msg = pet_packet:encode_send_error_s2c(?ERROR_UNKNOWN),
			role_op:send_data_to_gate(Msg);
		[_,Time,_]->
			Msg = god_tree_packet:encode_god_tree_init_s2c(Time),
			role_pos_util:send_to_all_online_clinet(Msg)
	end.

process_message({god_tree_init_c2s,_})->
	case god_tree_db:get_info() of
		[] ->
			Msg = pet_packet:encode_send_error_s2c(?ERROR_UNKNOWN),
			role_op:send_data_to_gate(Msg);
		[_,Time,_]->
			Msg = god_tree_packet:encode_god_tree_init_s2c(Time),
			role_op:send_data_to_gate(Msg)
	end;

process_message({god_tree_rock_c2s,_,Times})->
	Result = case god_tree_db:get_info() of
				[] ->
					?ERROR_UNKNOWN;
				[Drop,Time,{Gold1,Gold10,Gold50}]->
					 if
					 	Time =:= 0 ->
					 		?GOD_TREE_NOT_START;
					 	true ->
					 		ReMainSize = god_tree_storage_op:get_remain_size(),
							if 		
								Times=<ReMainSize->
									case Times of
										1 ->
											do_rock_tree(Drop,Times,Gold1);
										10 ->
											do_rock_tree(Drop,Times,Gold10);
										50 ->
											do_rock_tree(Drop,Times,Gold50);
										_ ->
											?ERROR_UNKNOWN
									end;
								true ->
									?GOD_TREE_PACKET_NOT_ENOUGH
							end
					 end
			end,
	if
		Result =:= 0 ->
			nothing;
		true ->
			Msg = pet_packet:encode_send_error_s2c(Result),
			role_op:send_data_to_gate(Msg)
	end.

do_rock_tree(Drop,Times,GoldNum) ->
	case role_op:check_money(?MONEY_GOLD, GoldNum) of
	    true->											%% gold is enough
		    role_op:money_change(?MONEY_GOLD, -GoldNum, rock_god_tree),
            lottery_operate(Drop,Times);						    
	    false->											%% gold is not enough
   			%%maybe  hacker
		    slogger:msg("god_tree_op:do_rock_tree money not enough maybe hacker~p~n",[get(roleid)]),
   		    ?GOD_TREE_GOLD_NOT_ENOUGH
    end.

lottery_operate(Drop,Times) ->
	broadcast_op:god_tree_count(Times),
	ItemList = lottery_items(Drop,Times,[]),
	MergeItemList = god_tree_storage_op:array_item(ItemList),
	Msg = god_tree_packet:encode_god_tree_rock_s2c(MergeItemList),
	role_op:send_data_to_gate(Msg),
	god_tree_storage_op:add_item(MergeItemList),
	0.

lottery_items(_RuleId,0,GetItemList)->
	GetItemList;

lottery_items(RuleId,Times,GetItemList)->
	[{TemplateId,ItemCount}] = drop:apply_rule(RuleId,1),
	broad_obtain(TemplateId,ItemCount),
	lottery_items(RuleId,Times-1,[{TemplateId,ItemCount}|GetItemList]).


broad_obtain(ProtoId,Count)->
	creature_sysbrd_util:sysbrd({god_tree,ProtoId},Count).


