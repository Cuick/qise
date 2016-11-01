%% Author: CuiChengKai
%% Created: 2013-12-31
-module(god_tree_db).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("god_tree_def.hrl").
-include("base_define.hrl").
-include("common_define.hrl").
-define(ETS_GOD_TREE_INFO,'ets_god_tree_info').
%%
%% Exported Functions
%%
-export([get_info/0,change_time/1,save_to_db/0,clear_storage/0]).

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
	ets:new(?ETS_GOD_TREE_INFO, [set,public,named_table]).

init()->
	db_operater_mod:init_ets(god_tree_info, ?ETS_GOD_TREE_INFO,#god_tree_info.type).

create_mnesia_table(disc)->
	db_tools:create_table_disc(god_tree_info,record_info(fields,god_tree_info),[],set).
	
create_mnesia_split_table(role_god_tree_storage,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,role_god_tree_storage),[],set).

delete_role_from_db(RoleId)->
	OwnerTable = db_split:get_owner_table(role_god_tree_storage, RoleId),
	dal:delete_rpc(OwnerTable, RoleId).

tables_info()->
	[{god_tree_info,proto},{role_god_tree_storage,disc_split}].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info()->
	case ets:lookup(?ETS_GOD_TREE_INFO,1) of
		[]->
			[];
		[{_,{_,_,Term}}]->
			Term
	end.
change_time(Time)->
	case ets:lookup(?ETS_GOD_TREE_INFO,1) of
		[]->
			slogger:msg("god_tree_db: change_time  error~p~n");
		[{_,{_,_,Term}}]->
			[Drop,_,Gold]=Term,
			ets:insert(?ETS_GOD_TREE_INFO,{1,{god_tree_info,1,[Drop,Time,Gold]}})
	end.

	
save_to_db()->
	case ets:lookup(?ETS_GOD_TREE_INFO,1) of
			[]->
				slogger:msg("god_tree_db: save_to_db  error~p~n");
			[{_,{_,_,Term}}]->
				Object = util:term_to_record({1,Term},god_tree_info),
				dal:write_rpc(Object)
	end.

clear_storage()->
	ServerId = env:get(serverid, 1),
	Flag = ServerId*?SERVER_MAX_ROLE_NUMBER + ?MIN_ROLE_ID + 1,
	OwnerTable = db_split:get_owner_table(role_god_tree_storage, Flag),
	dal:clear_table(OwnerTable).