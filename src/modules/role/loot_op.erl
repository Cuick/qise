-module(loot_op).

-export([init_loot_list/0,get_loot_info/1,add_loot_to_list/5,set_loot_to_hold/1,delete_loot_from_list/2,is_empty_loot/1,get_item_from_loot/2,remove_item_from_loot/2,
		get_npc_protoid_from_loot/1]).

-export([get_npcid_from_loot/1]).
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("npc_struct.hrl").
-include("login_pb.hrl").
-include("common_define.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%								掉落列表操作
%%掉落列表的构成：[  {包id , [{模板1,数量1},{模板2，数量2}] , 包状态idle/hold ,掉落Npcid,掉落npc模板id,Pos}   ]
%%引入包状态的原因是，当玩家查看包的时候， 再次触发延迟删除
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_loot_list()->
	put(loot_list,[]).
	
get_loot_info(LootId)->
	lists:keyfind(LootId,1,get(loot_list)).	
		
add_loot_to_list(LootId,LootInfo,NpcId,NpcProto,Pos)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of 
		false ->
			put(loot_list,lists:append(LootList,[{LootId,LootInfo,idle,NpcId,NpcProto,Pos}])),
			timer_util:send_after(?LOOT_DELEAY_TIME, self(), {delete_loot, {LootId,0}}); %%10s后删除todo,10s for test
		_ ->
			todo
	end.
	
set_loot_to_hold(LootId)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		false ->
			slogger:msg("set_loot_to_hold ,error Lootid:~p~n",[LootId]);
		{LootId,LootInfo,_,NpcId,ProtoId,Pos}->
			put(loot_list,lists:keyreplace(LootId,1,LootList,{LootId,LootInfo,hold,NpcId,ProtoId,Pos}))
	end.	
	
%%	DleStatu:0:普通删除，只删除idle状态的包裹；1：强制删除
delete_loot_from_list(LootId,DleStatu)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		false ->					%%已经被主动删除
			nothing;
		{LootId,_,Status,_,_,_}->
			case DleStatu of
				1 ->						%%强制删除
					put(loot_list,lists:keydelete(LootId,1,LootList)),
					release;
				0 ->						
					case Status of
						idle ->				
							put(loot_list,lists:keydelete(LootId,1,LootList)),
							release;
						hold ->
							timer_util:send_after(?LOOT_DELEAY_TIME, self(), {delete_loot, {LootId,1}}),  %%玩家打开了包裹，暂时不删，10秒后触发强制删除
							nothing
					end
			end
	end.

%%  0-> 空包 
%% !0-> 不空
is_empty_loot(LootInfo)->
	lists:foldl(fun({ItemId,_Count},Sum)
				-> ItemId + Sum
				end,0,LootInfo).

%%取出lootid里第slotid个位置上的{物品id,Count}
get_item_from_loot(LootId,SlotId)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		{LootId,LootInfo,_Statu,_NpcId,_NpcProtoId,_Pos}->
			case (SlotId > erlang:length(LootInfo)) or (SlotId =< 0) of
				false->
					lists:nth(SlotId,LootInfo);
				true ->  
					{0,0}
			end;
		false ->
			{0,0}
	end.
		
%%remove前已调用get，所以不用再检测槽数,注：并不是真正的remove掉，而是将物品信息设置为{0,0}	
remove_item_from_loot(LootId,SlotId)->			
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		{LootId,LootInfo,_Statu,NpcId,NpcProtoId,Pos}->
			{ItemId,_} = lists:nth(SlotId,LootInfo),
			case ItemId =/= 0 of
				true ->		
					NewLootInfo = lists:keyreplace(ItemId,1,LootInfo,{0,0}),
					put(loot_list,lists:keyreplace(LootId,1,LootList,{LootId,NewLootInfo,idle,NpcId,NpcProtoId,Pos})),
					{remove,NewLootInfo};
				false ->
					nothing
			end;				
		false ->
			nothing
	end.
%%获取包裹是谁掉落的
get_npcid_from_loot(LootId)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		{_,_,_,NpcId,_NpcProtoId,_}->
			NpcId;
		false ->
			0
	end.
get_npc_protoid_from_loot(LootId)->
	LootList = get(loot_list),
	case lists:keyfind(LootId,1,LootList) of
		{_,_,_,_NpcId,NpcProtoId,_}->
			NpcProtoId;
		false ->
			0
	end.	
	