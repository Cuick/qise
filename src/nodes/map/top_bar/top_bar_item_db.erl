-module (top_bar_item_db).

%%
%% Include files
%%
-include("mnesia_table_def.hrl").

-compile(export_all).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).

-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).

-define (ETS_HOT_BAR_ITEM,ets_top_bar_item).
-define (ETS_TEMP_ACTIVITY,ets_temp_activity).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(top_bar_item, record_info(fields,top_bar_item), [], set),
	db_tools:create_table_disc(temp_activity, record_info(fields,temp_activity), [], set).	

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{top_bar_item, proto}, {temp_activity, proto}].

create()->
	ets:new(?ETS_HOT_BAR_ITEM, [set, named_table]),
	ets:new(?ETS_TEMP_ACTIVITY, [public, set, named_table]).

init()->
	db_operater_mod:init_ets(top_bar_item, ?ETS_HOT_BAR_ITEM, #top_bar_item.id),
	db_operater_mod:init_ets(temp_activity, ?ETS_TEMP_ACTIVITY, #temp_activity.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_item_info(Id)->
	case ets:lookup(?ETS_HOT_BAR_ITEM,Id) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_all_items_info() ->
	ets:tab2list(?ETS_HOT_BAR_ITEM).

get_type(ItemInfo) ->
	ItemInfo#top_bar_item.type.

get_script(ItemInfo) ->
	ItemInfo#top_bar_item.script.

get_start_time(ItemInfo) ->
	ItemInfo#top_bar_item.start_time.

get_end_time(ItemInfo) ->
	ItemInfo#top_bar_item.end_time.

get_pos(ItemInfo) ->
	ItemInfo#top_bar_item.pos.

get_activity_info(ActivityId) ->
	case ets:lookup(?ETS_TEMP_ACTIVITY,ActivityId) of
		[]->[];
		[{_,Term}]-> Term
	end.

get_activity_id(ActivityInfo) ->
	ActivityInfo#temp_activity.id.

get_activity_awards_time(ActivityInfo) ->
	ActivityInfo#temp_activity.awards_time.

get_activity_type(ActivityInfo) ->
	ActivityInfo#temp_activity.type.

get_activity_start_time(ActivityInfo) ->
	ActivityInfo#temp_activity.start_time.

get_activity_end_time(ActivityInfo) ->
	ActivityInfo#temp_activity.end_time.

get_activity_condition(ActivityInfo) ->
	ActivityInfo#temp_activity.condition.

get_activity_awards(ActivityInfo) ->
	ActivityInfo#temp_activity.awards.

get_activity_awards_type(ActivityInfo) ->
	ActivityInfo#temp_activity.awards_type.

get_activity_awards_send_type(ActivityInfo) ->
	ActivityInfo#temp_activity.awards_send_type.

get_activity_bar_item(ActivityInfo) ->
	ActivityInfo#temp_activity.bar_item.

get_activity_bar_sid(ActivityInfo) ->
	ActivityInfo#temp_activity.sid.
get_activity_bar_condition(ActivityInfo) ->
	ActivityInfo#temp_activity.condition.

get_all_activity_info() ->
	ets:tab2list(?ETS_TEMP_ACTIVITY).

delete_activity(ActivityId) ->
	dal:delete_rpc(temp_activity, ActivityId),
	ets:delete(?ETS_TEMP_ACTIVITY, ActivityId).

update_activity(ActivityInfo) ->
	ActivityId = get_activity_id(ActivityInfo),
	dal:write_rpc(ActivityInfo),
	ets:insert(?ETS_TEMP_ACTIVITY, {ActivityId, ActivityInfo}).

load_open_or_combine_activities(Type, StartTime, EndTime) ->
	FileName = "../config/open_and_combine_server.config",
	case file:open(FileName, [read]) of
        {ok, Fd}->
            read_activity_loop(Fd, Type, StartTime, EndTime),
            file:close(Fd);
        {error,Reason}->
            slogger:msg("open file ~p error:~p~n",[FileName, Reason])
    end.

read_activity_loop(Fd, Type, StartTime, EndTime) ->
	case io:read(Fd, '') of
        {error, Reason} ->
            slogger:msg("read_activity_loop error, Reason: ~p~n", [Reason]);
        eof ->
            nothing;
        {ok, Term} ->
            BarItem = Term#temp_activity.bar_item,
            if
            	BarItem =:= Type ->
            		ActivityId = Term#temp_activity.id,
            		Term2 = Term#temp_activity{start_time = StartTime, end_time = EndTime},
					ets:insert(?ETS_TEMP_ACTIVITY, {ActivityId, Term2});
            	true ->
            		nothing
            end,
            read_activity_loop(Fd, Type, StartTime, EndTime)
    end.