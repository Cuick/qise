%%% =======================================================
%%% 
%%% =======================================================

-module (client_util).
-include("mnesia_table_def.hrl").
-export ([get_quest_com_npc_ids/1, get_quest_acc_npc_ids/1,
			 get_npc_pos/2,get_npc_pos/1,get_monster_pos/2,get_npc_ids/1,
			 get_mod_by_npcid/1,get_npc_maxHP/1,get_random_nps/1,
			 get_npc_mod_pos/1,get_transpots_info/2,get_npc_type/1,
			 get_npc_type_by_spawn/1,get_random_pos/1]).

get_quest_com_npc_ids(QuestId) ->
	ets:foldl(fun({NpcId, {quest_npc, NpcId, {_, ComList}}}, NpcIds) ->
				case lists:member(QuestId, ComList) of
					true ->
						[NpcId | NpcIds];
					false ->
						NpcIds
				end
			end, [], ets_quest_npc_info).

get_quest_acc_npc_ids(QuestId) ->
	ets:foldl(fun({NpcId, {quest_npc, NpcId, {AccList, _}}}, NpcIds) ->
				case lists:member(QuestId, AccList) of
					true ->
						[NpcId | NpcIds];
					false ->
						NpcIds
				end
			end, [], ets_quest_npc_info).

get_npc_pos(QuestNpcId, MapId) ->
	ets:foldl(fun({_, _, {creature_spawns, _, ProtoId, TmpMapId, BornPos, _, _, _, _, _, _}}, PosList) ->
				if 
					QuestNpcId =:= ProtoId andalso TmpMapId =:= MapId ->
						[BornPos | PosList];
					true ->
						PosList
				end
			end, [], npc_spawns_ets).
get_npc_type_by_spawn(NpcId) ->
	ModId = get_mod_by_npcid(NpcId),
	get_npc_type(ModId).

get_npc_type(ModId) ->
	case ets:lookup(npc_proto_ets,ModId) of
		[] -> none;
		[{_Id,Value}] -> element(#creature_proto.npcflags,Value)
		end.

get_monster_pos(MonsterId, MapId) ->
	ets:foldl(fun({_, _, {creature_spawns, SpawnId, _ProtoId, TmpMapId, BornPos, _, _, _, _, _, _}}, PosList) ->
				if 
					MonsterId =:= SpawnId andalso TmpMapId =:= MapId ->
						[BornPos | PosList];
					true ->
						PosList
				end
			end, [], npc_spawns_ets).

get_npc_ids(3020002) ->
	[3020002,3020022,3020032,3020042];

get_npc_ids(Mod_id) ->
	ets:foldl(fun({NpcId, _, {creature_spawns, _, ProtoId, _TmpMapId, _BornPos, _, _, _, _, _, _}}, IdList) ->
				if 
					Mod_id =:= ProtoId ->
						[NpcId | IdList];
					true ->
						IdList
				end
			end, [], npc_spawns_ets).

get_mod_by_npcid(NpcId) ->
	case ets:lookup(npc_spawns_ets,NpcId) of
		[] ->
			none;
		[{_,_,{_,_,ModId,_,_,_,_,_,_,_,_}}] ->
			ModId
		end.

get_npc_maxHP(ModId) ->
	case ets:lookup(npc_proto_ets,ModId) of
		[] -> none;
		[{_Id,Value}] -> element(#creature_proto.hpmax,Value)
		end.

get_random_nps(ModId) ->
	% io:format("aaaaaaaaaaaaaaaaModId~p~n",[ModId]),
	NpcIdList = get_npc_ids(ModId),
	{N,_Time} = random:uniform_s(length(NpcIdList),now()),
	element(N,list_to_tuple(NpcIdList)).

get_npc_mod_pos(ModId) ->
	ets:foldl(fun({NpcId, _, {creature_spawns, _, ProtoId, TmpMapId, BornPos, _, _, _, _, _, _}}, PosList) ->
				if 
					ModId =:= ProtoId ->

						[{TmpMapId, BornPos} | PosList];
					true ->
						PosList
				end
			end, [], npc_spawns_ets).
get_npc_pos(TargetId) ->
	ets:foldl(fun({NpcId, _, {creature_spawns, _, ProtoId, TmpMapId, BornPos, _, _, _, _, _, _}}, PosList) ->
				if 
					NpcId =:= TargetId ->
						[{TmpMapId, BornPos} | PosList];
					true ->
						PosList
				end
			end, [], npc_spawns_ets).
get_transpots_info(CurMapId, TargetMapId) ->
	ets:foldl(fun({_, {transports, FromMapId, ToMapId, TargetPos, TransportId, _Description}}, TransportList) ->
				if 
					CurMapId =:= FromMapId andalso TargetMapId =:= ToMapId ->
						[{TransportId, TargetPos} | TransportList];
					true ->
						TransportList
				end
			end, [], ets_transports_info).


get_random_pos(MapId) ->
	
	X = get_random_account(20,500),
	Y = get_random_account(20,500),
	MapDb = mapdb_processor:make_db_name(MapId),
	case mapop:check_pos_is_valid({X,Y},MapDb) of
		true ->
			{X,Y};
		false ->
			get_random_pos(MapId)
			% {X,Y}	
	end.
get_random_account(High) ->
	<<A:32,B:32,C:32>> = crypto:strong_rand_bytes(12),
	{Pos,_Time} = random:uniform_s(High,{A,B,C}),
	% {Pos,_Time} = random:uniform_s(High,now()),
	Pos.
get_random_account(Base,Max) ->
	High = Max-Base,
	Base + get_random_account(High).
% <<A:32,B:32,C:32>> = crypto:strong_rand_bytes(12),
%  random:uniform_s(500,{A,B,C}).