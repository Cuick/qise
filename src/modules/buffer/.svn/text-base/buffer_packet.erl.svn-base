-module(buffer_packet).

%%
%% Include files
%%
-export([handle/2]).


-include("login_pb.hrl").
-include("data_struct.hrl").

handle(#cancel_buff_c2s{buffid = BuffId},RolePid)->
	RolePid ! {cancel_buff_c2s,BuffId}.
