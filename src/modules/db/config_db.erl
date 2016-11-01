%% Author: yanzengyan
%% Created: 2012-7-18
%% Description: 生成配置文件数据库
-module(config_db).

%%
%% Include files
%%

%%
%% Exported Functions
%%

-export([run/1]).

%%
%% API Functions
%%


run([Arg1, Arg2]) ->
    env:init(),
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:wait_for_tables(mnesia:system_info(tables), infinity),
    ConfigPath = atom_to_list(Arg1),
    EbinPath = atom_to_list(Arg2),
    delete_all_tables(ConfigPath),
    create_all_tables(EbinPath),
    gen_config_data(ConfigPath),
    mnesia:stop(),
    mnesia:start(),
    mnesia:wait_for_tables(mnesia:system_info(tables), infinity),
    mnesia:stop(),
    io:format("yanzengyan, process finished!!!~n").

delete_all_tables(ConfigPath) ->
    mnesia:delete_table(creature_spawns),
    delete_config_tables(ConfigPath, activities),
    delete_config_tables(ConfigPath, game).

create_all_tables(EbinPath) ->
    ets:new(dp_operater_mods, [public, set, named_table, {keypos, 1}]),
    ets:new(dp_split_tables, [public, set, named_table, {keypos, 1}]),
    lists:foreach(fun(Mod)->
                    safe_aplly(Mod, start, [])
        end, get_all_behaviour_mod(db_operater_mod, EbinPath)),
    ets:foldl(fun({Module,_,_},_)->
                Module:create_mnesia_table(disc)     
            end,[], dp_operater_mods).

gen_config_data(ConfigPath) ->
    gen_creature_spawns_table(ConfigPath),
    gen_config_tables(ConfigPath, activities),
    gen_config_tables(ConfigPath, game).

delete_config_tables(ConfigPath, Type) ->
    FileName = gen_file_name(ConfigPath, Type),
    case file:open(FileName, [read]) of
        {ok, Fd}->
            delete_table_loop([], Fd),
            file:close(Fd);
        {error,Reason}->
            slogger:msg("open file ~p error:~p~n",[FileName, Reason])
    end.

gen_file_name(ConfigPath, Type) ->
    ConfigPath ++ "/" ++ atom_to_list(Type) ++ ".config".

delete_table_loop(UsedTables, Fd) ->
    case io:read(Fd, []) of
        {ok, Term}->
            TableName = erlang:element(1, Term),
            case lists:member(TableName, UsedTables) of
                true->
                    NewUsedTables = UsedTables;
                _->
                    case mnesia:delete_table(TableName) of
                        {atomic, ok}->
                            NewUsedTables = [TableName | UsedTables];
                        {aborted, R}->
                            slogger:msg("delete table ~p error ~p ~n",[TableName, R]),
                            NewUsedTables = UsedTables
                    end
            end,
            delete_table_loop(NewUsedTables,Fd);
        eof->
            nothing;
        Error->
            slogger:msg("clear table loop error ~p ~n",[Error])
    end.

gen_creature_spawns_table(ConfigPath) ->
    FileName = gen_file_name(ConfigPath, creature_spawns),
    case file:consult(FileName) of
        {ok, [Terms]}->
            mnesia:change_table_copy_type(creature_spawns, node(), ram_copies),
            lists:foreach(fun(Term) ->
                                  Record = list_to_tuple([creature_spawns | tuple_to_list(Term)]),
                                  mnesia:dirty_write(Record)
                          end, Terms),
            mnesia:change_table_copy_type(creature_spawns, node(), disc_copies);
        {error,Reason}->
            slogger:msg("open file ~p error:~p~n",[FileName, Reason])
    end.                
  
gen_config_tables(ConfigPath, Type) ->
    FileName = gen_file_name(ConfigPath, Type),
    case file:open(FileName, [read]) of
        {ok, Fd}->
            gen_config_tables_loop([], [], Fd),
            file:close(Fd);
        {error,Reason}->
            slogger:msg("open file ~p error:~p~n",[FileName, Reason])
    end.

write_list_ets_hack(NewRecordList) ->
    mnesia:ets(fun()-> [write_data_one_ets_hack(Term) || Term <- NewRecordList] end).            
              
write_data_one_ets_hack(Record) ->
    case catch mnesia:dirty_write(Record) of
        ok ->
            ok;
        {'EXIT', {aborted, Reason}}->
            slogger:msg("write record error! Record: ~p, Reason: ~p~n", [Record, Reason]),
            error;
        Errno ->
            slogger:msg("write record error! Record: ~p, Errno: ~p~n", [Record, Errno]),
            error
    end.

gen_config_tables_loop(RecordList, LastTable, Fd) ->
    case io:read(Fd, '') of
        {error, Reason} ->
            slogger:msg("read file creature_spawns error, Reason: ~p~n", [Reason]);
        eof ->
            write_list_ets_hack(RecordList),
            if LastTable =/= [] ->
                   mnesia:change_table_copy_type(LastTable, node(), disc_copies);
               true ->
                   nothing
            end;
        {ok, Term} ->
            NewLastTable = erlang:element(1, Term),
            NewRecordList = if LastTable =:= [] ->
                                   mnesia:change_table_copy_type(NewLastTable, node(), ram_copies),
                                   [Term | RecordList];
                               NewLastTable =/= LastTable ->
                                   write_list_ets_hack(RecordList),
                                   mnesia:change_table_copy_type(LastTable, node(), disc_copies),
                                   mnesia:change_table_copy_type(NewLastTable, node(), ram_copies),
                                   [Term];
                               length(RecordList) >= 10 ->
                                   write_list_ets_hack(RecordList),
                                   [Term];
                               true ->
                                   [Term | RecordList]
            end,
            gen_config_tables_loop(NewRecordList, NewLastTable, Fd)
    end.

%% 获取所有实现了Behaviour行为的模块
get_all_behaviour_mod(Behaviour, Path)->
    lists:filter(fun(Mod)->is_mod_is_behaviour(Mod,Behaviour) end,get_all_module(Path)).

%% @doc判断某些模块是否为Behav类型
is_mod_is_behaviour(Mod,Behav)->
    is_behaviour_attributes(Mod:module_info(attributes),Behav).

is_behaviour_attributes([],_)->
    false;
is_behaviour_attributes([{behaviour,Behaviours}|Tail],Behav)->
    case lists:member(Behav,Behaviours) of
        true->
            true;
        _->
            is_behaviour_attributes(Tail,Behav)
    end;
is_behaviour_attributes([_|Tail],Behav)->
    is_behaviour_attributes(Tail,Behav).   

safe_aplly(Mod, Func, Args)->
    try
        erlang:apply(Mod, Func, Args)
    catch
        E:R->
            slogger:msg("~p:~p ~p ~p ~p ~n",[Mod, Func, Args,E,R])
    end.

get_all_module(Path) ->
    {ok,ALLFiles} = file:list_dir(Path),
    lists:foldl(
                fun(FileName,AccModules)->
                    case get_module_by_beam(FileName) of
                        []->
                            AccModules;
                        NewModule->
                            [NewModule|AccModules] 
                    end
                end, [] ,ALLFiles).

%% @doc 根据文件名称获取模块名称atom定义
get_module_by_beam(FileName)->
    case string:right(FileName,5) of
        ".beam"->
            erlang:list_to_atom(string:substr(FileName,1,string:len(FileName) - 5));
        _->
            []
    end.