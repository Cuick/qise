-module (npc_god_tree_action).

-include("mnesia_table_def.hrl").
-include("login_pb.hrl").
-include("npc_define.hrl").
-include("system_chat_define.hrl").
-include("error_msg.hrl").

-behaviour(npc_function_mod).

-export([init_func/0,registe_func/1,enum/3]).

init_func()->
	npc_function_frame:add_function(god_tree, ?NPC_FUNCTION_GOD_TREE,?MODULE).

registe_func(NpcId)->
	Mod= ?MODULE,
	Fun= god_tree_action,
	Godtreetime = read_god_tree_into_for_npc(NpcId),
	Response= #kl{key=?NPC_FUNCTION_GOD_TREE, value=Godtreetime},
	EnumMod = ?MODULE,
	EnumFun = enum,
	Action = {Mod,Fun,Godtreetime},
	Enum   = {EnumMod,EnumFun,Godtreetime},
	{Response,Action,Enum}.

enum(_,Godtreetime,_)->
	#kl{key=?NPC_FUNCTION_GOD_TREE, value=Godtreetime}.

god_tree_action()->
	{ok}.

read_god_tree_into_for_npc(NpcId)->
	% case dal:read_rpc(npc_tradeitem_list, NpcId) of
	% 	{ok,[R]}->  element(#npc_tradeitem_list.tradeitems,R);
	% 	_->[]
	% end.
	[].