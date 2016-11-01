%% Author: CuiChengKai
%% Created: 2013-12-31
-module(god_tree_packet).

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

handle(Message = #god_tree_init_c2s{},RolePid)->
	RolePid ! {god_tree,Message};

handle(Message = #god_tree_rock_c2s{},RolePid)->
	RolePid ! {god_tree,Message};

handle(_,_)->
	nothing.

encode_god_tree_init_s2c(Info)->
	login_pb:encode_god_tree_init_s2c(#god_tree_init_s2c{result = Info}).	
encode_god_tree_rock_s2c(ItemList)->
	login_pb:encode_god_tree_rock_s2c(#god_tree_rock_s2c{itemlist = ItemList}).
encode_god_tree_broad_s2c(RoleName,ProtoId,Count)->
	login_pb:encode_god_tree_broad_s2c(#god_tree_broad_s2c{rolename=RoleName,item={lti,ProtoId,Count}}).

%%
%% Local Functions
%%

