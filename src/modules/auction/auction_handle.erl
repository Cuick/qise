-module(auction_handle).

-compile(export_all).

-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").

handle(#stall_sell_item_c2s{slot = Slot,silver = Silver,gold = Gold,ticket=Ticket})->
	if
		((Silver >= 0)  and (Gold >= 0) and ((Gold + Silver) > 0))->
			io:format("Slot ~p ,Moneys ~p ~n",[Slot,Silver]),
			auction_op:proc_item_up_stall(Slot,{Silver,Gold,Ticket});
		true->
			slogger:msg("stall_sell_item_c2s error money ~p ~n",[{Silver,Gold,Ticket}])
	end;

handle(#stalls_search_c2s{index = Index})->
	auction_op:proc_stalls_search(Index);

handle(#stalls_search_item_c2s{index = Index,searchstr = Str})->
	auction_op:proc_stalls_item_search(Index,Str);

handle(#stall_detail_c2s{stallid = StallId})->
	auction_op:proc_stall_detail(StallId);

handle(#stall_recede_item_c2s{itemlid = ItemLid,itemhid = ItemHid})->
	ItemId = get_itemid_by_low_high_id(ItemHid,ItemLid),
	auction_op:proc_recede_item(ItemId);

handle(#stall_buy_item_c2s{stallid = StallId,itemlid =ItemLid,itemhid = ItemHid})->
	ItemId = get_itemid_by_low_high_id(ItemHid,ItemLid),
	auction_op:proc_buy_item_c2s(StallId,ItemId);

handle(#stall_role_detail_c2s{rolename = RoleName})->
	auction_op:proc_stall_detail_by_rolename(RoleName);

handle(#stall_rename_c2s{stall_name = StallName})->
	auction_op:proc_rename(StallName);

handle(Other)->
	slogger:msg("auction_handle error msg ~p ~n",[Other]).