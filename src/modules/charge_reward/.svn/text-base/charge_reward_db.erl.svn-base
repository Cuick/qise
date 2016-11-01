%% Author: CuiChengKai
%% Created: 2013-12-31
-module(charge_reward_db).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("mnesia_table_def.hrl").
-include("base_define.hrl").
-include("common_define.hrl").
-define(CHARGE_REWARD_INFO,charge_reward_info).
%%
%% Exported Functions
%%
-export([get_info/1,save_charge_reward_info/4]).

%%
%% API Functions
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour export
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-export([start/0,init/0,create/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create()->
	ets:new(?CHARGE_REWARD_INFO, [set,public,named_table]).

init()->
	db_operater_mod:init_ets(charge_reward_info, ?CHARGE_REWARD_INFO,#charge_reward_info.id).

create_mnesia_table(disc)->
	db_tools:create_table_disc(charge_reward_info,record_info(fields,charge_reward_info),[],set).
	
create_mnesia_split_table(role_charge_reward,TrueTabName)->
	db_tools:create_table_disc(role_charge_reward,record_info(fields,role_charge_reward),[],set).

delete_role_from_db(RoleId)->
	% OwnerTable = db_split:get_owner_table(role_charge_reward, RoleId),
	dal:delete_rpc(role_charge_reward, RoleId).

tables_info()->
	[{charge_reward_info,proto},{role_charge_reward,disc_split}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Id)->
	case ets:lookup(?CHARGE_REWARD_INFO,Id) of
		[]->
			[];
		[{_,Info}]->
			Info
	end.
save_charge_reward_info(RoleId,ChargeNum,State,Time) ->
	% TableName = db_split:get_owner_table(role_charge_reward, RoleId),
	dmp_op:sync_write(RoleId, {role_charge_reward, RoleId,ChargeNum,State,Time}).

% -record(role_charge_reward,{roleid,chargeNum,state,time}).