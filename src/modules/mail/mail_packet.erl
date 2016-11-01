%% Author: adrianx
%% Created: 2010-11-16
%% Description: TODO: Add description to mail_packet
-module(mail_packet).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([handle/2]).

%%
%% API Functions
%%

handle(Message, RolePid)->
	RolePid	! Message.


%%
%% Local Functions
%%

