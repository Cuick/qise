%% Author: CuiChengKai
%% Created: 2013-12-31
-module(god_tree_storage_packet).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("item_struct.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
%%
%% API Functions
%%

handle(Message = #god_tree_init_storage_c2s{},RolePid)->
	RolePid ! {god_tree_storage,Message};

handle(Message = #god_tree_storage_getitem_c2s{},RolePid)->
	RolePid ! {god_tree_storage,Message};

handle(Message = #god_tree_storage_getallitems_c2s{},RolePid)->
	RolePid ! {god_tree_storage,Message};
handle(_,_)->
	nothing.

encode_god_tree_storage_info_s2c(ItemsInfo)->
	login_pb:encode_god_tree_storage_info_s2c(#god_tree_storage_info_s2c{items = ItemsInfo}).

encode_god_tree_storage_init_end_s2c()->
	login_pb:encode_god_tree_storage_init_end_s2c(#god_tree_storage_init_end_s2c{}).

make_tsi(ItemProtoId,Solt,Count,Sign)->
	#tsi{itemprotoid = ItemProtoId,solt = Solt,count = Count,itemsign = Sign}.

encode_god_tree_storage_updateitem_s2c(ItemsList)->
	login_pb:encode_god_tree_storage_updateitem_s2c(#god_tree_storage_updateitem_s2c{itemlist = ItemsList}).

encode_god_tree_storage_additem_s2c(Items)->
	login_pb:encode_god_tree_storage_additem_s2c(#god_tree_storage_additem_s2c{items = Items}).

encode_god_tree_storage_delitem_s2c(Start,Length)->
	login_pb:encode_god_tree_storage_delitem_s2c(#god_tree_storage_delitem_s2c{start = Start,length = Length}).

encode_god_tree_storage_opt_s2c(Code)->
	login_pb:encode_god_tree_storage_opt_s2c(#god_tree_storage_opt_s2c{code = Code}).

%%
%% Local Functions
%%

