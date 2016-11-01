-module (npc_wedding_ceremony_action).

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
-export([wedding_ceremony_action/0]).
%%
%% API Functions
%%

init_func()->
	npc_function_frame:add_function(wedding_ceremony,?NPC_FUNCTION_WEDDING_CEREMONY, ?MODULE).

registe_func(NpcId)->
	Mod= ?MODULE,
	Fun= wedding_ceremony_action,
	Arg=  [],
	Response= #kl{key=?NPC_FUNCTION_WEDDING_CEREMONY, value=[]},
	
	EnumMod = ?MODULE,
	EnumFun = enum,
	EnumArg =  [],
	Action = {Mod,Fun,Arg},
	Enum   = {EnumMod,EnumFun,EnumArg},
	
	{Response,Action,Enum}.

enum(_,_,_)->
	#kl{key=?NPC_FUNCTION_WEDDING_CEREMONY, value=[]}.


wedding_ceremony_action() ->
	todo.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%local
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
