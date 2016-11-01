%% Author: MacX
%% Created: 2010-12-13
%% Description: TODO: Add description to achieve_package
-module(achieve_packet).

%%
%% Include files
%%
-export([handle/2]).
-export([encode_achieve_init_s2c/1,encode_achieve_update_s2c/1,encode_achieve_error_s2c/1]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%


%%
%% API Functions
%%
handle(#achieve_open_c2s{},RolePid)->
	role_processor:achieve_open_c2s(RolePid);
handle(#achieve_reward_c2s{chapter=Chapter,part=Part},RolePid)->
	role_processor:achieve_reward_c2s(RolePid,Chapter,Part);
handle(_Message,_RolePid)->
	ok.

encode_achieve_init_s2c(InitAchieves)->
	login_pb:encode_achieve_init_s2c(#achieve_init_s2c{parts=InitAchieves}).
encode_achieve_update_s2c(AchievePart)->
	login_pb:encode_achieve_update_s2c(#achieve_update_s2c{part=AchievePart}).
encode_achieve_error_s2c(Reason)->
	login_pb:encode_achieve_error_s2c(#achieve_error_s2c{reason=Reason}).
%%
%% Local Functions
%%

