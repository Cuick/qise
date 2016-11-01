%% Author: adrianx
%% Created: 2010-10-9
%% Description: TODO: Add description to t_senswords
-module(t_senswords).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([test/0]).

%%
%% API Functions
%%

test()->
	env:init(),
	senswords:init(),
	BinString = <<"游客001">>,
	senswords:word_is_sensitive(BinString).
