-module (title_db).


%%
%% Include files
%%
-include("mnesia_table_def.hrl").
-include("common_define.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define (ETS_TITLE_PROTO, ets_title_proto).
-define (ETS_TITLE_ROLE, ets_title_role).
-define (ETS_TITLE_PROTO_TYPE, ets_title_proto_type).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(title_proto, record_info(fields,title_proto), [], set).	

create_mnesia_split_table(title_role,TrueTabName)->
	db_tools:create_table_disc(TrueTabName,record_info(fields,title_role),[],set).

delete_role_from_db(Title)->
	ServerId = env:get(serverid, 1),
	TitleId = ServerId*?SERVER_MAX_ROLE_NUMBER + ?MIN_ROLE_ID + Title,
	OwnerTable = db_split:get_owner_table(title_role, TitleId),
	dal:delete_rpc(OwnerTable, Title).

tables_info()->
	[{title_proto,proto}],
	[{title_role,disc_split}].

create()->
	ets:new(?ETS_TITLE_PROTO, [set,named_table]),
	ets:new(?ETS_TITLE_ROLE, [set,public,named_table]),
	ets:new(?ETS_TITLE_PROTO_TYPE, [bag, named_table]).

init()->
	db_operater_mod:init_ets(title_proto, ?ETS_TITLE_PROTO,#title_proto.id),
	db_operater_mod:init_ets(title_role, ?ETS_TITLE_ROLE,#title_role.title),
	init_title_proto_type().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_title_proto(TitleId) ->
	case ets:lookup(?ETS_TITLE_PROTO,TitleId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_title_hpmax(TitleProto) ->
	TitleProto#title_proto.hpmax.

get_title_magic_power(TitleProto) ->
	TitleProto#title_proto.magicpower.

get_title_range_power(TitleProto) ->
	TitleProto#title_proto.rangepower.

get_title_melee_power(TitleProto) ->
	TitleProto#title_proto.meleepower.

get_title_magic_defense(TitleProto) ->
	TitleProto#title_proto.magicdefense.

get_title_range_defense(TitleProto) ->
	TitleProto#title_proto.rangedefense.

get_title_melee_defense(TitleProto) ->
	TitleProto#title_proto.meleedefense.

get_title_hitrate(TitleProto) ->
	TitleProto#title_proto.hitrate.

get_title_dodge(TitleProto) ->
	TitleProto#title_proto.dodge.

get_title_criticalrate(TitleProto) ->
	TitleProto#title_proto.criticalrate.

get_title_criticaldestroyrate(TitleProto) ->
	TitleProto#title_proto.criticaldestroyrate.

get_title_toughness(TitleProto) ->
	TitleProto#title_proto.toughness.

get_title_magic_immune(TitleProto) ->
	TitleProto#title_proto.magicimmunity.

get_title_range_immune(TitleProto) ->
	TitleProto#title_proto.rangeimmunity.

get_title_melee_immune(TitleProto) ->
	TitleProto#title_proto.meleeimmunity.

get_title_flag(TitleProto) ->
	TitleProto#title_proto.flag.

get_title_type(TitleProto) ->
	TitleProto#title_proto.type.

get_title_proto_type(Type) ->
	case ets:lookup(?ETS_TITLE_PROTO_TYPE, Type) of
		[] -> [];
		Result ->
			[TitleProto || {_, TitleProto} <- Result]
	end.

get_title_condition(TitleProto) ->
	TitleProto#title_proto.condition.

get_title_id(TitleProto) ->
	TitleProto#title_proto.id.

get_title_exclude(TitleProto) ->
	TitleProto#title_proto.exclude.

init_title_proto_type() ->
	lists:foreach(fun({_, TitleProto}) ->
		{Type, _} = get_title_condition(TitleProto),
		ets:insert(?ETS_TITLE_PROTO_TYPE, {Type, TitleProto})
	end, ets:tab2list(?ETS_TITLE_PROTO)).

% get_title_role(Title) ->
% 	case ets:lookup(?ETS_TITLE_ROLE,Title) of
% 		[]->[];
% 		[{_,Term}]-> Term
% 	end.

% get_title_roleid(TitleRole) ->
% 	TitleRole#title_role.role_id.

% set_title_role(TitleRole)->
% ets:insert(?ETS_TITLE_ROLE, TitleRole).

get_title_role(Title) ->
	ServerId = env:get(serverid, 1),
	TitleId = ServerId*?SERVER_MAX_ROLE_NUMBER + ?MIN_ROLE_ID + Title,
	OwnerTable = db_split:get_owner_table(title_role, TitleId),
	case dal:read_rpc(OwnerTable, Title) of
		{ok,[R]}-> R;
		_->[]
	end.

	
save_title_role(Title, RoleId) ->
	ServerId = env:get(serverid, 1),
	TitleId = ServerId*?SERVER_MAX_ROLE_NUMBER + ?MIN_ROLE_ID + Title,
	OwnerTable = db_split:get_owner_table(title_role, TitleId),
	dal:write_rpc({OwnerTable, Title, RoleId}).

