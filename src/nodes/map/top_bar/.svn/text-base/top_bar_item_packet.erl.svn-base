-module (top_bar_item_packet).

-include ("login_pb.hrl").
-include ("top_bar_item_def.hrl").

-export ([handle/2, encode_top_bar_show_items_s2c/1, encode_top_bar_hide_items_s2c/1,
	encode_temp_activity_contents_s2c/2, encode_temp_activity_get_award_s2c/1, mk_activity_content/9]).

handle(Message = #temp_activity_contents_c2s{}, RolePid) ->
	RolePid ! {top_bar_item_from_client, Message};

handle(Message = #temp_activity_get_award_c2s{}, RolePid) ->
	RolePid ! {top_bar_item_from_client, Message};

handle(_, _) ->
	nothing.

encode_top_bar_show_items_s2c(ItemIds) ->
	login_pb:encode_top_bar_show_items_s2c(#top_bar_show_items_s2c{item_ids = ItemIds}).

encode_top_bar_hide_items_s2c(ItemIds) ->
	login_pb:encode_top_bar_hide_items_s2c(#top_bar_hide_items_s2c{item_ids = ItemIds}).

encode_temp_activity_contents_s2c(ItemId, Contents) ->
	login_pb:encode_top_bar_hide_items_s2c(#temp_activity_contents_s2c{
		item_id = ItemId, contents = Contents
		}).

encode_temp_activity_get_award_s2c(Result) ->
	login_pb:encode_temp_activity_get_award_s2c(#temp_activity_get_award_s2c{
		result = Result
		}).

mk_activity_content(ActivityId, Type, StartTime, EndTime, AwardsShowType, Awards, SendType, Sid, Condition) ->
	#temp_activity_content{activity_id = ActivityId, type = Type,
	start_time = festival_packet:make_timer(StartTime),
	end_time = festival_packet:make_timer(EndTime), award_show_type = AwardsShowType,
	awards = mk_awards(Awards), send_type=SendType, sid=Sid, condition=Condition}.

mk_awards(Awards) when is_list(Awards) ->
	[mk_awards(Award) || Award <- Awards];
mk_awards({ItemId, Count}) ->
	pb_util:key_value(ItemId, Count);
mk_awards({Min, Max, ItemList}) ->
	#awards_struct{min = Min, max = Max, item_list = mk_awards(ItemList)}.