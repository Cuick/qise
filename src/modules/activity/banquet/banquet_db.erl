%% Author: MacX
%% Created: 2011-9-29
%% Description: TODO: Add description to banquet_db
-module(banquet_db).

%%
%% Include files
%%
-include("banquet_define.hrl").
-define(BANQUET_OPTION,ets_banquet_option).
-define(BANQUET_EXP,ets_banquet_exp).
%%
%% Exported Functions
%%
-export([get_option_info/1,get_banquet_exp_info/1]).
-export([
		 get_banquet_id/1,
		 get_banquet_duration/1,
		 get_banquet_instance_proto/1,
		 get_banquet_looptime/1,
		 get_banquet_dancing/1,
		 get_banquet_cheering/1,
		 get_banquet_vip_exp_addition/1,
		 get_banquet_vip_op_addition/1,
		 get_banquet_pet_swanking/1,
		 get_banquet_exp_level/1,
		 get_banquet_exp_exp/1,
		 get_banquet_exp_soulpower/1,
		 get_banquet_exp_dancing_self/1,
		 get_banquet_exp_dancing_be/1,
		 get_banquet_exp_cheering_self/1,
		 get_banquet_exp_cheering_be/1,
		 get_banquet_exp_pet_swanking/1
		 ]).
%%
%% API Functions
%%
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(banquet_option,record_info(fields,banquet_option),[],set),
	db_tools:create_table_disc(banquet_exp,record_info(fields,banquet_exp),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{banquet_option,proto},{banquet_exp,proto}].

delete_role_from_db(_)->
	nothing.

create()->
	ets:new(?BANQUET_OPTION, [set,named_table]),
	ets:new(?BANQUET_EXP, [set,named_table]).

init()->
	db_operater_mod:init_ets(banquet_option, ?BANQUET_OPTION,#banquet_option.banquet_id),
	db_operater_mod:init_ets(banquet_exp, ?BANQUET_EXP,#banquet_exp.level).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_option_info(SpaId)->
	case ets:lookup(?BANQUET_OPTION,SpaId) of
		[]->[];
		[{SpaId,Term}]-> Term
	end.

get_banquet_exp_info(Level)->
	case ets:lookup(?BANQUET_EXP,Level) of
		[]->[];
		[{Level,Term}]-> Term
	end.

get_banquet_id(Info)->
	erlang:element(#banquet_option.banquet_id, Info).

get_banquet_duration(Info)->
	erlang:element(#banquet_option.duration, Info).

get_banquet_instance_proto(Info)->
	erlang:element(#banquet_option.instance_proto, Info).

get_banquet_looptime(Info)->
	erlang:element(#banquet_option.looptime, Info).

get_banquet_dancing(Info)->
	erlang:element(#banquet_option.dancing, Info).

get_banquet_cheering(Info)->
	erlang:element(#banquet_option.cheering, Info).

get_banquet_vip_exp_addition(Info)->
	erlang:element(#banquet_option.vip_exp_addition, Info).

get_banquet_vip_op_addition(Info)->
	erlang:element(#banquet_option.vip_op_addition, Info).

get_banquet_pet_swanking(Info)->
	erlang:element(#banquet_option.pet_swanking, Info).


get_banquet_exp_level(Info)->
	erlang:element(#banquet_exp.level, Info).

get_banquet_exp_exp(Info)->
	erlang:element(#banquet_exp.exp, Info).

get_banquet_exp_soulpower(Info)->
	erlang:element(#banquet_exp.soulpower, Info).

get_banquet_exp_dancing_self(Info)->
	erlang:element(#banquet_exp.dancing_self, Info).

get_banquet_exp_dancing_be(Info)->
	erlang:element(#banquet_exp.dancing_be, Info).

get_banquet_exp_cheering_self(Info)->
	erlang:element(#banquet_exp.cheering_self, Info).

get_banquet_exp_cheering_be(Info)->
	erlang:element(#banquet_exp.cheering_be, Info).

get_banquet_exp_pet_swanking(Info)->
	erlang:element(#banquet_exp.pet_swanking, Info).

%%	
%% Local Functions
%%

