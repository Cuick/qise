-module (npc_wedding_register_action).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("npc_define.hrl").
-include("wedding_def.hrl").

-behaviour(npc_function_mod).
%%
%% Exported Functions
%%

-export([init_func/0,registe_func/1,enum/3]).
-export([wedding_register_action/0]).
%%
%% API Functions
%%

init_func()->
	npc_function_frame:add_function(wedding_register,?NPC_FUNCTION_WEDDING_REGISTER, ?MODULE).

registe_func(NpcId)->
	Mod= ?MODULE,
	Fun= wedding_register_action,
	Arg=  [],
	Response= #kl{key=?NPC_FUNCTION_WEDDING_REGISTER, value=[1]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg =  [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,_,NpcId)->
	#kl{key=?NPC_FUNCTION_WEDDING_REGISTER, value=[]}.


wedding_register_action() ->
	todo.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%local
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
