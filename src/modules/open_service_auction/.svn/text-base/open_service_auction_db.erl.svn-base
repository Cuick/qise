-module (open_service_auction_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define (ETS_OPEN_SERVICE_AUCTION_PROTO,ets_open_service_auction_proto).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(open_service_auction_proto, record_info(fields,open_service_auction_proto), [], set).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{open_service_auction_proto,proto}].

create()->
	ets:new(?ETS_OPEN_SERVICE_AUCTION_PROTO, [set,named_table]).

init()->
	db_operater_mod:init_ets(open_service_auction_proto, ?ETS_OPEN_SERVICE_AUCTION_PROTO,#open_service_auction_proto.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_auction_proto_info() ->
	case ets:lookup(?ETS_OPEN_SERVICE_AUCTION_PROTO,1) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_auction_duration(AuctionProto) ->
	AuctionProto#open_service_auction_proto.duration.

get_auction_item_id(AuctionProto) ->
	AuctionProto#open_service_auction_proto.item_id.

get_auction_base(AuctionProto) ->
	AuctionProto#open_service_auction_proto.base.

get_auction_increment(AuctionProto) ->
	AuctionProto#open_service_auction_proto.increment.