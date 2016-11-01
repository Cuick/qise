-module(do_something_of_quests).

-include("login_pb.hrl").
-include("client_def.hrl").
-include("common_define.hrl").
-include("quest_define.hrl").
-include("creature_define.hrl").
-include("attr_keyvalue_define.hrl").

-define(COMMON_COLLECT, 740000002).
-define(COMMON_ATTACK_MAGIC, 510000011).
-define(COMMON_ATTACK_RANGE, 520000011).
-define(COMMON_ATTACK_MELEE, 530000011).
-define(COMMON_TIME, 3*1000).

-define(NPC_ROLE, 1).
-define(NPC_MONSTER, 2).
-define(NPC_MINE, 3).
-record(state, {server_ip, server_port, server_id, speak_interval, client_id, socket}).
	
-export([quest/1,attack_monster/1,next_attack_monster/2,update_quest/1,chang_map/2,do_collect/1,change_bdyymap/2,check_target/1,stop_here/0,kill_self_and_create_other/1,send_change_new_msg/0]).

quest(QuestId) ->
	[QuestNpcId | _] = client_util:get_quest_com_npc_ids(QuestId),
% {pet_quality,eq,1}{pet_grep,eq,1}{pet_skill,eq,1}
	QuestInfo = quest_db:get_info(QuestId),
	lists:map(fun(Object)->
				case Object of
					{{learn_skill,Skillid} = _Message,_Op,_ObjValue} ->
						learn_skill(Skillid);
					{refine = _Message,_Op,_ObjValue} ->
						refine();
					{join_guild = _Message,_Op,_ObjValue} ->
						join_guild();
					{enchantments = _Message,_Op,ObjValue} ->
						enchantments(ObjValue);
					{{level} = _Message,_Op,ObjValue} ->
						level(ObjValue);
					{pet_quality = _Message,_Op,ObjValue} ->
						pet(pet_quality);
					{pet_grep = _Message,_Op,ObjValue} ->
						pet(pet_grep);
					{pet_skill = _Message,_Op,ObjValue} ->
						pet(pet_skill);
					{map_change = _Message,_Op,ObjValue} ->
						% io:format("1~p~n",[QuestNpcId]),
						send_change_new_msg();
						% change_bdyymap(QuestNpcId,ObjValue);
						% bdyy_map_change(QuestNpcId);
					_ ->
						nothing
				end	
		end, quest_db:get_objectivemsg(QuestInfo)),
	lists:map(fun(Mob)->
				case Mob of
					{MobId,MobNum} ->
					% io:format("1~n"),
						do_something(MobId, MobNum, QuestNpcId);
					_ ->
					% io:format("2~n"),
						nothing
				end	
		end, quest_db:get_reqmob(QuestInfo)),
	update_quest(QuestNpcId).

learn_skill(Skillid) ->
	Message = login_pb:encode_skill_learn_item_c2s(
						#skill_learn_item_c2s{skillid = Skillid}),
	mock_client:sendtoserver(self(), Message).

do_something(MobId, MobNum, QuestNpcId) ->
	NpcType = client_util:get_npc_type(MobId),
	case NpcType of
		?NPC_MONSTER ->
			kill_monster(MobId, MobNum, QuestNpcId);
		?NPC_MINE ->
			% io:format("the collect quest :~p~n",[NpcType]),
			% send_change_new_msg();
			collect(MobId, MobNum, QuestNpcId);
		_ ->
			% io:format("the no such quest type :~p~n",[NpcType]),
			other
	end.
collect(MobId, MobNum, QuestNpcId) ->
	put({collect,MobId},{0,MobNum, QuestNpcId}),
	NpcId = client_util:get_random_nps(MobId),
	% io:format("collect start Mobid:~p,Num:~p,Npc:~p,MIMN_ID:~p~n",[MobId, MobNum, QuestNpcId,NpcId]),
	put(collecting,NpcId),
	mock_client:move_in_same_map(NpcId,mine).
	% put(move, {target, mine, NpcId}).

kill_monster(MobId, MobNum, QuestNpcId) ->
	put({kill,MobId},{0,MobNum,QuestNpcId}),
	NpcId = client_util:get_random_nps(MobId),
	mock_client:move_in_same_map(NpcId,monster).
	% put(move, {target, monster, NpcId}).

attack_monster(NpcId)->
	% do_attack(NpcId - 1),
	MobId = client_util:get_mod_by_npcid(NpcId),
	NpcMaxHp = client_util:get_npc_maxHP(MobId),
	put({attack,NpcId},NpcMaxHp),
	do_attack(NpcId).
	% do_attack(NpcId + 1).
do_attack(NpcId) ->
	% Npc_is_dead = creature_op:is_creature_dead(creature_op:get_creature_info(NpcId)),
	% case Npc_is_dead of
	% 	 false ->
	% 		no;
	% 	 true ->
	% 	 	MobId = client_util:get_mod_by_npcid(NpcId),
	% 		NewNpcId = client_util:get_random_nps(MobId),
	% 	 	do_attack(NewNpcId)
	% end,
	Class = get(class),
	timer:sleep(2000),
	% io:format("attack_monste ~p~n",[NpcId]),
	Skillid = case Class of
		?CLASS_MAGIC ->
			?COMMON_ATTACK_MAGIC;
		?CLASS_RANGE ->
			?COMMON_ATTACK_RANGE;
		?CLASS_MELEE ->
			?COMMON_ATTACK_MELEE
	end,
	% io:format("attack_monste2~p~n",[NpcId]),
	Message = login_pb:encode_role_attack_c2s(
						#role_attack_c2s{skillid = Skillid, creatureid = NpcId}),
	mock_client:sendtoserver(self(), Message).
	% erlang:send_after(10000,self(),{check_target,NpcId}).

next_attack_monster(MonsterId,NewHp) ->
	if NewHp > 0 -> 
			% io:format("monste is active ~n"),
			put({attack,MonsterId},NewHp),
			do_attack(MonsterId);
		true ->
			% io:format("monste is dead~n")		
			% erase({attack,MonsterId})
			no

	end.

update_quest(NpcId) ->
	Message = login_pb:encode_questgiver_states_update_c2s(
						#questgiver_states_update_c2s{npcid = [NpcId]}),
	mock_client:sendtoserver(self(), Message).

chang_map(TargetMapId,TransportId) ->
	Message = login_pb:encode_role_map_change_c2s(
						#role_map_change_c2s{seqid = TargetMapId, transid = TransportId}),
	mock_client:sendtoserver(self(), Message).

do_collect(MineId) ->
	Message = login_pb:encode_role_attack_c2s(
						#role_attack_c2s{skillid = ?COMMON_COLLECT, creatureid = MineId}),
	mock_client:sendtoserver(self(), Message).

refine() ->
 	refine.
join_guild() ->
	join_guild.
enchantments(N) ->
	enchantments.
level(N) ->
	level.
% 	,slot,sex
% Message = login_pb:encode_pet_egg_use_c2s(
% 						#pet_egg_use_c2s{slot = 1008, sex = 1}),
% mock_client:sendtoserver(self(), Message).
pet(QuestMsg) ->
	case QuestMsg of
		pet_grep  ->
			% get_pet();
			pet_grep();
		pet_quality ->
			get_pet();
			% pet_quality();
		pet_skill ->
			pet_skill();
		_ ->
			body
	end.
get_pet() ->
	Message = login_pb:encode_pet_egg_use_c2s(
						#pet_egg_use_c2s{slot = 1008, sex = 1}),
	mock_client:sendtoserver(self(), Message).


pet_grep() ->
	PetInfo = get(pet),
	Message = login_pb:encode_pet_grade_riseup_c2s(
						#pet_grade_riseup_c2s{petid = PetInfo#p.petid, extitems = 0,consum_type = 0,up_type = 1}),
	mock_client:sendtoserver(self(),Message).

pet_quality() ->
	PetInfo = get(pet),
	Message = login_pb:encode_pet_quality_riseup_c2s(
						#pet_quality_riseup_c2s{petid = PetInfo#p.petid, flag = 1,up_type = 1}),
	mock_client:sendtoserver(self(), Message).


pet_skill() ->
	go_to_random_pos().
	% PetInfo = get(pet),
	% % #pet_learn_skill_c2s{petid = PetId,slot = Slot,force = Force}
	% Message = login_pb:encode_pet_learn_skill_c2s(
	% 					#pet_learn_skill_c2s{petid = PetInfo#p.petid, slot = 1008,force = []}),
	% mock_client:sendtoserver(self(), Message).

% {npc_map_change_c2s,62,2030030,3001202}
bdyy_map_change(QuestNpcId) ->
	mock_client:run_to_npc(QuestNpcId).
	
change_bdyymap(QuestNpcId,MapId) ->
	case get(MapId) of
		true ->
			update_quest(QuestNpcId);
		_ ->
			Message = login_pb:encode_npc_map_change_c2s(
						#npc_map_change_c2s{npcid = 2030030, id = 3001202}),
			mock_client:sendtoserver(self(), Message),
			put(MapId,true)
	end.
	% io:format("2~n").
	% erlang:send_after(1000*90,self(),{up_quest,2030030}).
check_target(NpcId) ->
	CollectMod = get(collect),
	MonstMod = get(kill),
	case CollectMod of
		undefined ->
			case MonstMod of
				undefined ->
					no;
				_ ->
					do_attack(NpcId)
			end;
		_ ->
			do_attack(NpcId)
	end.
	% CollectList = client_util:get_npc_ids(CollectMod),
	% MonstList = client_util:get_npc_ids(MonstMod),

go_to_random_pos() ->
	send_change_new_msg().
	% CurMapId = get(map_id),
	% TargetMapId = 300,
	% CurPos = mock_client:get_current_pos(),
	% TargetPos = client_util:get_random_pos(TargetMapId),
	% io:format("i will go to map:~p,Pos:~p~n",[TargetMapId,TargetPos]),
	% [{TransportId, TransporPos}| _] = client_util:get_transpots_info(CurMapId,TargetMapId),
	% mock_client:run_to(CurPos, TransporPos, CurMapId),
	% put(move,{target, transport, {TargetMapId,TransportId}}),
	% put(last_map,{TargetMapId,TargetPos}).
stop_here() ->
	send_change_new_msg().
	% Message = login_pb:encode_heartbeat_c2s(
	% 					#heartbeat_c2s{beat_time = 0}),
	% mock_client:sendtoserver(self(), Message),
	% erlang:send_after(1000*60*1,self(),check_heart).

send_change_new_msg() ->
	self() ! create_new_client.
kill_self_and_create_other(State) ->
	#state{server_ip = ServerIp, server_port = ServerPort, server_id = ServerId, 
		speak_interval = SpeakInterval, client_id = ClientId} = State,

	NewClientId = ClientId + 10000,
	mock_client_sup:create_new_client(ServerIp, ServerPort, ServerId, SpeakInterval, NewClientId),
	% timer:sleep(5000),
	exit(normal).