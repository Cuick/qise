-module(quest_give_buff).
-export([on_acc_script/2]).

on_acc_script(_QuestId,BuffInfo)->
	role_op:add_buffers_by_self([BuffInfo]),
	true.