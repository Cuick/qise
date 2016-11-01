%% Author: CuiChengKai
%% Created: 2013-11-23
-module(smashed_egg_db).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("smashed_egg_def.hrl").
-include("base_define.hrl").
-define(ETS_SMASHED_EGG_TYPE,'ets_smashed_egg_type').
-define(ETS_SMASHED_EGG_DROP,'ets_smashed_egg_drop').
%%
%% Exported Functions
%%
-export([get_drops/1,get_protoid/1,save_to_db/0]).

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
	ets:new(?ETS_SMASHED_EGG_TYPE,[set,named_table]),
	ets:new(?ETS_SMASHED_EGG_DROP, [set,named_table]).
init()->
	db_operater_mod:init_ets(smashed_egg_type, ?ETS_SMASHED_EGG_TYPE,#smashed_egg_type.type),
	db_operater_mod:init_ets(smashed_egg_drop, ?ETS_SMASHED_EGG_DROP,#smashed_egg_drop.place).
create_mnesia_table(disc)->
	db_tools:create_table_disc(smashed_egg_type,record_info(fields,smashed_egg_type),[],set),
	db_tools:create_table_disc(smashed_egg_drop,record_info(fields,smashed_egg_drop),[],set).
create_mnesia_split_table(smashed_egg_item_list,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,smashed_egg_item_list),[],set).

delete_role_from_db(RoleId)->
	OwnerTable = db_split:get_owner_table(smashed_egg_item_list, RoleId),
	dal:delete_rpc(OwnerTable, RoleId).

tables_info()->
	[{smashed_egg_type,proto},{smashed_egg_drop,proto},{smashed_egg_item_list,disc_split}].

get_protoid(Type)->
	case ets:lookup(?ETS_SMASHED_EGG_TYPE,Type) of
		[]->
			slogger:msg("smashed_egg_db: get_protoid error~n"),
			[];
		[{_,Term}]->
			erlang:element(#smashed_egg_type.protoid_list,Term)
	end.


get_drops(Place)->
	case ets:lookup(?ETS_SMASHED_EGG_DROP,Place) of
		[]->
			slogger:msg("smashed_egg_db: get_drops error~n"),
			[];
		[{_,Term}]->
			erlang:element(#smashed_egg_drop.drop,Term)
	end.


save_to_db()->
	RoleId=get(roleid),
	ItemList = get(smashed_egg_itemlist),
	OwnerTable = db_split:get_owner_table(smashed_egg_item_list, RoleId),
	Object = util:term_to_record({RoleId,ItemList},OwnerTable),
	dal:write_rpc(Object).



