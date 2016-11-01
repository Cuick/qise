
-module(yybattle_proto_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-define(YYBATTLE_PROTO_NAME,ets_yybattle_proto).

-compile(export_all).
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
	db_tools:create_table_disc(yybattle_proto, record_info(fields,yybattle_proto), [], set).
	
create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{yybattle_proto,proto}].

create()->
	ets:new(?YYBATTLE_PROTO_NAME, [set,named_table]).
      
init()->
	db_operater_mod:init_ets(yybattle_proto, ?YYBATTLE_PROTO_NAME, #yybattle_proto.type).
      


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_info(Type)->
	case ets:lookup(?YYBATTLE_PROTO_NAME,Type) of
	    []->[];
	    [{Type,Term}]-> Term
        end.


get_type(ProtoInfo) ->
        erlang:element(#yybattle_proto.type, ProtoInfo).

get_campplayernum(ProtoInfo) ->
        erlang:element(#yybattle_proto.campplayernum, ProtoInfo).

get_campabornarea(ProtoInfo) ->
        erlang:element(#yybattle_proto.campabornarea, ProtoInfo).

get_campbbornarea(ProtoInfo) ->
        erlang:element(#yybattle_proto.campbbornarea, ProtoInfo).

get_winnerbaseexp(ProtoInfo) ->
        erlang:element(#yybattle_proto.winnerbaseexp, ProtoInfo).

get_winnerexpfactor(ProtoInfo) ->
        erlang:element(#yybattle_proto.winerexpfactor, ProtoInfo).

get_loserbaseexp(ProtoInfo) ->
        erlang:element(#yybattle_proto.loserbaseexp, ProtoInfo).

get_loserexpfactor(ProtoInfo) ->
        erlang:element(#yybattle_proto.loserexpfactor, ProtoInfo).

get_winnerward(ProtoInfo) ->
        erlang:element(#yybattle_proto.winnerward, ProtoInfo).

get_loserward(ProtoInfo) ->
        erlang:element(#yybattle_proto.loserward, ProtoInfo).

get_winnerbasehonor(ProtoInfo) ->
        erlang:element(#yybattle_proto.winnerbasehonor, ProtoInfo).

get_winnerhonorfactor(ProtoInfo) ->
        erlang:element(#yybattle_proto.winnerhonorfactor, ProtoInfo).

get_loserbasehonor(ProtoInfo) ->
        erlang:element(#yybattle_proto.loserbasehonor, ProtoInfo).

get_loserhonorfactor(ProtoInfo) ->
        erlang:element(#yybattle_proto.loserhonorfactor, ProtoInfo).

get_instanceid(ProtoInfo) ->
        erlang:element(#yybattle_proto.instanceid, ProtoInfo).
