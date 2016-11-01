-module (open_charge_feedback_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define (ETS_OPEN_CHARGE_FEEDBACK_PROTO,ets_open_charge_feedback_proto).
-define (ETS_OPEN_CHARGE_FEEDBACK, ets_open_charge_feedback).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(open_charge_feedback_proto, record_info(fields,open_charge_feedback_proto), [], set),
	db_tools:create_table_disc(open_charge_feedback, record_info(fields,open_charge_feedback), [], set).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{open_charge_feedback_proto,proto}, {open_charge_feedback,proto}].

create()->
	ets:new(?ETS_OPEN_CHARGE_FEEDBACK_PROTO, [set,named_table]),
	ets:new(?ETS_OPEN_CHARGE_FEEDBACK, [set, named_table]).

init()->
	db_operater_mod:init_ets(open_charge_feedback_proto, ?ETS_OPEN_CHARGE_FEEDBACK_PROTO,#open_charge_feedback_proto.id),
	db_operater_mod:init_ets(open_charge_feedback, ?ETS_OPEN_CHARGE_FEEDBACK,#open_charge_feedback.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_feedback_proto_info() ->
	case ets:lookup(?ETS_OPEN_CHARGE_FEEDBACK_PROTO,1) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_feedback_duration(FeedbackProtoInfo) ->
	FeedbackProtoInfo#open_charge_feedback_proto.duration.

get_feedback_awards(FeedbackProtoInfo) ->
	FeedbackProtoInfo#open_charge_feedback_proto.awards.

get_all_feedback_info() ->
	lists:flatten(ets:match(?ETS_OPEN_CHARGE_FEEDBACK, {'_', '$1'})).

get_feedback_id(FeedbackInfo) ->
	FeedbackInfo#open_charge_feedback.id.

get_feedback_limit(FeedbackInfo) ->
	FeedbackInfo#open_charge_feedback.limit.

get_feedback_count(FeedbackInfo) ->
	FeedbackInfo#open_charge_feedback.feedback.

get_feedback_item(FeedbackInfo) ->
	FeedbackInfo#open_charge_feedback.items.