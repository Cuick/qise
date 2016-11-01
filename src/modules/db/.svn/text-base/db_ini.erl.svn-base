%% Author: adrian
%% Created: 2010-7-8
%% Description: TODO: Add description to db_ini
-module(db_ini).
-compile(export_all).

-export([db_init_master/0,db_init_slave/0,create_split_table/3]). 

db_init_master()->
	db_operater_mod:start(),
	case mnesia:system_info(is_running) of
		yes ->	mnesia:stop();
		no -> o;
		starting -> mnesia:stop()
	end,
	mnesia:create_schema([node()]),
	db_init_ram_tables(),
	db_init_disc_tables().

db_init_slave()->
	DbNode = node_util:get_dbnode(),
	db_tools:config_disc_db_node(DbNode).

%% @doc 初始化所有的硬盘ets表
db_init_disc_tables()->
	mnesia:start(),
	db_operater_mod:create_all_disc_table().

%% @doc 初始化所有的内存ets表
db_init_ram_tables()->
	mnesia:start(),
	db_operater_mod:create_all_ram_table().
%% @doc
create_split_table(CreateMod,BaseTable,Table)->
	CreateMod:create_mnesia_split_table(BaseTable,Table).

