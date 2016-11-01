%% Author: Administrator
%% Created: 2011-7-13
%% Description: TODO: Add description to active_borad_packet
-module(active_borad_packet).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).
-include("login_pb.hrl").

%%
%% API Functions
%%
handle(Message=#activity_state_init_c2s{},RolePid)->
	RolePid ! {active_board,activity_state_op,Message};

handle(Message=#activity_boss_born_init_c2s{},RolePid)->
	RolePid ! {active_board,activity_boss_state_op,Message};

handle(_,_)->
	nothing.

make_acs(Id,State)->
	#acs{id = Id,state = State}.

make_bs(BossId,State)->
	#bs{bossid = BossId,state = State}.


encode_activity_state_init_s2c(StateInfo)->
	login_pb:encode_activity_state_init_s2c(#activity_state_init_s2c{aslist = StateInfo}).

encode_activity_boss_born_init_s2c(BsInfo)->
	login_pb:encode_activity_boss_born_init_s2c(#activity_boss_born_init_s2c{bslist = BsInfo}).

%%
%% Local Functions
%%

