%%% =======================================================================
%%% 
%%% bang da yuanyang database.
%%%
%%% =======================================================================
-module(bdyy_db).

-include("mnesia_table_def.hrl").
-include ("bdyy_def.hrl").

-export([start/0, create_mnesia_table/1, create_mnesia_split_table/2, tables_info/0, delete_role_from_db/1]).
-export([create/0, init/0]).

-compile(export_all).

-define(BDYY_PROTO_ETS, ets_bdyy_proto).
-define(BDYY_ITEM_ETS, ets_bdyy_item).
-define(BDYY_SECTION_ETS, ets_bdyy_section).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(bdyy_proto, record_info(fields, bdyy_proto), [], set),
	db_tools:create_table_disc(bdyy_item, record_info(fields, bdyy_item), [], set),
	db_tools:create_table_disc(bdyy_section, record_info(fields, bdyy_section), [], set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{bdyy_proto,proto}, {bdyy_item, proto}, {bdyy_section, proto}].

delete_role_from_db(_)->
	nothing.

create()->	
	ets:new(?BDYY_PROTO_ETS, [set,named_table]),
	ets:new(?BDYY_ITEM_ETS, [set, named_table]),
	ets:new(?BDYY_SECTION_ETS, [set, named_table]).

init()->
	db_operater_mod:init_ets(bdyy_proto, ?BDYY_PROTO_ETS, #bdyy_proto.id),
	db_operater_mod:init_ets(bdyy_item, ?BDYY_ITEM_ETS, #bdyy_item.id),
	db_operater_mod:init_ets(bdyy_section, ?BDYY_SECTION_ETS, #bdyy_section.section).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_proto_info() ->
	case ets:lookup(?BDYY_PROTO_ETS, ?BDYY_PROTO_ID) of
		[]->[];
		[{?BDYY_PROTO_ID,Term}]-> Term
	end.

get_proto_duration(ProtoInfo) ->
	ProtoInfo#bdyy_proto.duration.

get_proto_sections(ProtoInfo) ->
	ProtoInfo#bdyy_proto.section_num.

get_item_info(ItemId) ->
	case ets:lookup(?BDYY_ITEM_ETS, ItemId) of
		[]->[];
		[{ItemId,Term}]-> Term
	end.

get_item_all() ->
	AllItems = ets:match(?BDYY_ITEM_ETS, {'_', '$1'}),
	lists:flatten(AllItems).

get_item_show_rate(ItemProto) ->
	ItemProto#bdyy_item.show_rate.

get_item_id(ItemProto) ->
	ItemProto#bdyy_item.id.

get_item_money(ItemProto) ->
	ItemProto#bdyy_item.money.

get_section_info(SectionId) ->
	case ets:lookup(?BDYY_SECTION_ETS, SectionId) of
		[]->[];
		[{ItemId,Term}]-> Term
	end.

get_section_next_show(SectionInfo) ->
	SectionInfo#bdyy_section.next_show.

get_section_show_time(SectionInfo) ->
	SectionInfo#bdyy_section.show_time.