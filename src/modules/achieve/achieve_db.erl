%% Author: MacX
%% Created: 2010-12-10
%% Description: TODO: Add description to achieve_db
-module(achieve_db).
%% 
%% define
%% 
-define(ACHIEVE_ETS,achieve_table).
%%
%% Include files
%%
-include("mnesia_table_def.hrl").
%%
%% Exported Functions
%%

-export([get_bonus/1]).
  
-export([
		 async_update_achieve_role_to_mnesia/2,sync_update_achieve_role_to_mnesia/2,
		 get_achieve_role/1,get_achieve_info/1,get_achieve_by_chapter/1
		]).

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
	db_tools:create_table_disc(achieve, record_info(fields,achieve), [], set),
	db_tools:create_table_disc(achieve_role, record_info(fields,achieve_role), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{achieve,proto},{achieve_role,disc}].

delete_role_from_db(RoleId)->
	dal:delete_rpc(achieve_role, RoleId).

create()->
	ets:new(?ACHIEVE_ETS,[set,public,named_table]).

init()->
	db_operater_mod:init_ets(achieve, ?ACHIEVE_ETS,#achieve.achieveid).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

async_update_achieve_role_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,achieve_role),
	dmp_op:async_write(RoleId,Object).

sync_update_achieve_role_to_mnesia(RoleId,Term)->
	Object = util:term_to_record(Term,achieve_role),
	dmp_op:sync_write(RoleId,Object).

get_achieve_info(Id)->
	case ets:lookup(?ACHIEVE_ETS, Id) of
		[]->[];
        [{_,Info}]-> Info 
	end.

get_bonus(Info)->
	erlang:element(#achieve.bonus, Info).

get_chapter(Info)->
	erlang:element(#achieve.chapter, Info).

get_achieve_by_chapter(Chapter)->
	ets:foldl(fun({_,Info},AccInfoTmp)->
					case get_chapter(Info) of
						Chapter->
							{_T,Achieveid,Chapter,Part,Target,Bonus,Bonus2,Type,Script} = Info,
							AccInfoTmp++[{Achieveid,Chapter,Part,Target,Bonus,Bonus2,Type,Script}];
						_->
							AccInfoTmp
					end
				end,[], ?ACHIEVE_ETS).

get_achieve_role(RoleId)->
	case dal:read_rpc(achieve_role,RoleId) of
		{ok,[]}-> {ok,[]};
		{ok,Result}-> {ok,Result};
		{failed,badrpc,Reason}-> slogger:msg("get_achieve_role failed ~p:~p~n",[badrpc,Reason]);
		{failed,Reason}-> slogger:msg("get_achieve_role failed :~p~n",[Reason])
	end.
	
%%
%% Local Functions
%%

