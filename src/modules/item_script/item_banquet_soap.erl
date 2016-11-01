%% Author: MacX
%% Created: 2011-10-12
%% Description: TODO: Add description to item_banquet_soap
-module(item_banquet_soap).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([use_item/2,handle_banquet_soap/2]).
-include("item_struct.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("pet_struct.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("item_define.hrl").

%%
%% API Functions
%%
use_item(ItemInfo,RoleId)->
	States = get_states_from_iteminfo(ItemInfo),
	Class = get_class_from_iteminfo(ItemInfo),
	if
		Class =:= ?ITEM_TYPE_BANQUET_SOAP->
			case lists:keyfind(banquet_exp_add, 1, States) of
				{_,_Value}->
					banquet_op:banquet_dancing_c2s(RoleId);
				_->
					false
			end;
		true->
			false
	end,
	false.

handle_banquet_soap(RoleId,Slot)->
	role_op:handle_use_item(Slot,[RoleId]).
%%
%% Local Functions
%%

