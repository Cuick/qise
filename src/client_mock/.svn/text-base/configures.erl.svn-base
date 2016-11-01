%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%		game config management.
%%% Created : 2013-5-6
%%% -------------------------------------------------------------------
-module(configures).

-export([create_all_ets/0]).

create_all_ets() ->
	mod_util:behaviour_apply(ets_operater_mod,create,[]),
    mod_util:behaviour_apply(ets_operater_mod,init,[]).


get_all_behaviour_mod(Behaviour, Path)->
    lists:filter(fun(Mod)->is_mod_is_behaviour(Mod,Behaviour) end,get_all_module(Path)).

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