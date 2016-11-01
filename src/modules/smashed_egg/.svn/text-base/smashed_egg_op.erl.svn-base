%% Author: CuiChengKai
%% Created: 2013-11-23
-module(smashed_egg_op).


%%
%% Include files
%%
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("login_pb.hrl").
-include("error_msg.hrl").
-define(REFRESH_SUCCESS,0).
-define (REFRESH_GOLD_NOT_ENOUGH, 1).
-define (REFRESH_ERROR_UNKNOWN, 2).
-define(ALREADY_SMASHED,1).
-define(ALREADY_SHOW,2).


%%
%% Exported Functions
%%
-export([init/0,process_message/1,export_for_copy/0,load_by_copy/1]).

%%
%% API Functions
%%



init()->
	Roleid=get(roleid),
	ItemList = load_form_db(Roleid),
	put(smashed_egg_itemlist,ItemList).

process_message({smashed_egg_init_c2s,_})->
	ItemList = get(smashed_egg_itemlist),
	if
		is_list(ItemList) ->
			Msg = smashed_egg_packet:encode_smashed_egg_init_s2c(ItemList),
			role_op:send_data_to_gate(Msg);
		true ->
			Msg = pet_packet:encode_send_error_s2c(?ERROR_UNKNOWN),
			role_op:send_data_to_gate(Msg)
	end;

process_message({smashed_egg_tamp_c2s,_,Place})->
	Result = case package_op:get_empty_slot_in_package() of
				0->
					?ERROR_PACKAGE_FULL;
				_->
					[BindProtoId,NonBindProtoId,_] = smashed_egg_db:get_protoid(1),
					BindNum = item_util:get_items_count_in_package(BindProtoId),
					if
					   	BindNum >= 1 ->
					   		role_op:consume_items(BindProtoId, 1),
					   		do_tamp_egg(Place);
					   	true ->
					   		NonBindNum = item_util:get_items_count_in_package(NonBindProtoId), 
					   		if
					   			NonBindNum >= 1 ->
					   				role_op:consume_items(NonBindProtoId, 1),
					   				do_tamp_egg(Place);
					   			true ->
					   				?SINKER_NOT_ENOUGH
					   		end
					end		
			end,
	if
		Result =:= 0 ->
			nothing;
		true ->
			Msg = pet_packet:encode_send_error_s2c(Result),
			role_op:send_data_to_gate(Msg)
	end;

process_message({smashed_egg_refresh_c2s,_})->
	Gold =lists:nth(3,smashed_egg_db:get_protoid(1)),
	case role_op:check_money(?MONEY_GOLD, Gold) of
	    true->											%% gold is enough
		    role_op:money_change(?MONEY_GOLD, -Gold, smashed_egg_refresh_cost),
		    put(smashed_egg_itemlist,[]),
		    Msg = smashed_egg_packet:encode_smashed_egg_refresh_s2c(?REFRESH_SUCCESS),
			role_op:send_data_to_gate(Msg);				    
	    false->											%% gold is not enough
   			%%maybe  hacker
		    slogger:msg("process_smashed_egg:money not enough maybe hacker~p~n",[get(roleid)]),
   		    Msg = smashed_egg_packet:encode_smashed_egg_refresh_s2c(?REFRESH_GOLD_NOT_ENOUGH),
		    role_op:send_data_to_gate(Msg)
    end.


do_tamp_egg(Place)->
	ItemList = get(smashed_egg_itemlist),
	case lists:keyfind(Place,1,ItemList) of
	 	false ->
	 		ItemId=get_item(),
	 		role_op:auto_create_and_put(ItemId, 1, smashed_egg),
	 		broad_obtain(ItemId),
	 		ItemList_Around=get_around_item(Place,ItemList),
	 		ItemList_Send=[{Place,ItemId,1}|ItemList_Around],
			ItemListLast=ItemList_Send ++ ItemList,
			put(smashed_egg_itemlist,ItemListLast),
			Msg = smashed_egg_packet:encode_smashed_egg_tamp_s2c(ItemList_Send),
		    role_op:send_data_to_gate(Msg),
		    0;
		{Place1,ItemId,State} ->
			case State of
				?ALREADY_SMASHED ->
					?ERROR_ALREADY_SMASHED;
				?ALREADY_SHOW ->
					role_op:auto_create_and_put(ItemId, 1, smashed_egg),
	 				broad_obtain(ItemId),
					ItemList_Around=get_around_item(Place,ItemList),
					ItemList_Send=[{Place,ItemId,1}|ItemList_Around],
					ItemListLast=lists:keyreplace(Place,1,ItemList++ItemList_Around,{Place,ItemId,1}),
					put(smashed_egg_itemlist,ItemListLast),
					Msg = smashed_egg_packet:encode_smashed_egg_tamp_s2c(ItemList_Send),
				    role_op:send_data_to_gate(Msg),
				    0;
				_->
					?ERROR_UNKNOWN
			end;
		_->
			?ERROR_UNKNOWN		
	 end.

get_around_item(Place,ItemList)->
	PlaceUp=Place - 8,
	PlaceDown=Place + 8,
	PlaceLeft=Place-1,
	PlaceRight=Place+1,
	ItemList1 = if
					PlaceUp < 1  ->
						[];
					true ->
						
						case lists:keyfind(PlaceUp,1,ItemList) of
							false ->
								[{PlaceUp,get_item(),2}];
						 	_->
						 		[]
						end
				end,
	ItemList2 = if
					PlaceDown > 64  ->
						ItemList1;
					true ->
						
						case lists:keyfind(PlaceDown,1,ItemList) of
							false ->
								[{PlaceDown,get_item(),2} | ItemList1];
						 	_->
						 		ItemList1
						end
				end,
	ItemList3 = if
					PlaceLeft rem 8 =:= 0  ->
						ItemList2;
					true ->
						
						case lists:keyfind(PlaceLeft,1,ItemList) of
							false ->
								[{PlaceLeft,get_item(),2} | ItemList2];
						 	_->
						 		ItemList2
						end
				end,
	if
		PlaceRight rem 8 =:= 1  ->
			ItemList3;
		true ->
			case lists:keyfind(PlaceRight,1,ItemList) of
				false ->
					[{PlaceRight,get_item(),2} | ItemList3];
			 	_->
			 		ItemList3
			end
	end.
get_item()->
	ItemList = get(smashed_egg_itemlist),
	Id = case lists:keyfind(0,1,ItemList) of
		 	false ->
		 		random:uniform(64);
		 	{Place1,Ids,State}->
		 		get_id(Ids)
		 end,
	put(smashed_egg_itemlist,[{0,[Id],3}]),
	[Drop] = smashed_egg_db:get_drops(Id),
	case Drop of
		[]->
			slogger:msg("smashed_egg_db:get_drops:error:drops is null noitem~p~n"),
			[];
		_->
			lottery_items(Drop)
	end.
get_id(Ids)->
	Id = random:uniform(64),
	Result = lists:member(Id,Ids),
	if
		Result ->
			get_id(Ids);
		true ->
			Id
	end.

lottery_items(Drop)->
	[{TemplateId,ItemCount}] = drop:apply_rule(Drop,1),
	TemplateId.

broad_obtain(ItemId)->
	creature_sysbrd_util:sysbrd({smashed_egg,ItemId},1).

export_for_copy()->
	{get(smashed_egg_itemlist)}.

load_by_copy({ItemList})->
	put(smashed_egg_itemlist,ItemList).

load_form_db(RoleId)->
	OwnerTable = db_split:get_owner_table(smashed_egg_item_list, RoleId),
	case dal:read_rpc(OwnerTable,RoleId) of
		{ok,[{_,_,ItemList}]}->
			ItemList;
		_->[]
	end.