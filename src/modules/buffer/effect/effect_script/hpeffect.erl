%% Author: adrian
%% Created: 2010-7-21
%% Description: TODO: Add description to hpeffect
-module(hpeffect).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([effect/2]).

%%
%% API Functions
%%

effect(Value,SkillInput)->
	[{hp,Value}].

%%
%% Local Functions
%%

