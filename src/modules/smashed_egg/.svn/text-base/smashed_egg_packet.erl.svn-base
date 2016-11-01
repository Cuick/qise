%% Author: CuiChengKai
%% Created: 2013-11-23
-module(smashed_egg_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
%%
%% Exported Functions
%%

-compile(export_all).
%%
%% API Functions
%%

handle(Message = #smashed_egg_init_c2s{},RolePid)->
	RolePid ! {smashed_egg,Message};

handle(Message = #smashed_egg_tamp_c2s{},RolePid)->
	RolePid ! {smashed_egg,Message};

handle(Message = #smashed_egg_refresh_c2s{},RolePid)->
	RolePid ! {smashed_egg,Message};

handle(_,_)->
	nothing.

encode_smashed_egg_init_s2c(ItemList)->
	login_pb:encode_smashed_egg_init_s2c(#smashed_egg_init_s2c{item_list = ItemList}).

encode_smashed_egg_tamp_s2c(ItemList)->
	login_pb:encode_smashed_egg_tamp_s2c(#smashed_egg_tamp_s2c{item_list = ItemList}).

encode_smashed_egg_refresh_s2c(Result)->
	login_pb:encode_smashed_egg_refresh_s2c(#smashed_egg_refresh_s2c{result = Result}).

