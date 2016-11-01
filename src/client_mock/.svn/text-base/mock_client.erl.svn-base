%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%		机器人具体业务处理
%%% Created : 2013-5-6
%%% -------------------------------------------------------------------
-module(mock_client).

-behaviour(gen_fsm).

%% ===================================================================
%% MACRO
%% ===================================================================

-include("login_pb.hrl").
-include("client_def.hrl").
-include("common_define.hrl").
-include("quest_define.hrl").
-include("creature_define.hrl").
-include("attr_keyvalue_define.hrl").

-define(SECRETKEY, "E3it45tiOjLi&fie8Hje56uMu67h").
-define(MOVE_NUM,3).
-define(MOVE_HEARTBEAT, 150).

-define(NPC_ROLE, 1).
-define(NPC_MONSTER, 2).
-define(NPC_MINE, 3).
-define(COMMON_COLLECT, 740000002).

%% External exports
-export([start_link/5]).

-export([init/1, handle_info/3, handle_event/3, handle_sync_event/4, terminate/3, code_change/4]).

-export([loging/2,gaming/2, run/5,commit_quest/2,sendtoserver/2,run_to_npc/1,move_in_same_map/2,get_current_pos/0,run_to/3]).

-record(state, {server_ip, server_port, server_id, speak_interval, client_id, socket}).

%% ====================================================================
%% External functions
%% ====================================================================
run(ServerIp, ServerPort, ServerId, SpeakInterval, ClientId) ->
	login_pb:create(),
	login_pb:init(),
	start_link(ServerIp, ServerPort, ServerId, SpeakInterval, ClientId).

start_link(ServerIp, ServerPort, ServerId, SpeakInterval, ClientId)->
	gen_fsm:start_link(?MODULE, [ServerIp, ServerPort, ServerId, SpeakInterval, ClientId], []).

init([ServerIp, ServerPort, ServerId, SpeakInterval, ClientId]) ->
	gen_fsm:send_event(self(), {login}),
	{ok, loging, #state{server_ip = ServerIp, server_port = ServerPort, server_id = ServerId, 
		speak_interval = SpeakInterval, client_id = ClientId}}.

loging({login}, State) ->
	#state{server_ip = ServerIp, server_port = ServerPort, server_id = ServerId, 
		speak_interval = SpeakInterval, client_id = ClientId} = State,
	UserName ="10000" ++ integer_to_list(ClientId),
	Gender = (ClientId rem 2),
	put(gender,Gender),
	Class = (ClientId rem 3) + 1,
	put(class,Class),
	{ok,Socket} = gen_tcp:connect(ServerIp, ServerPort, [binary,{packet,2}]),    
	%% 认证开始
	begin_auth(UserName,UserName,ServerId),
	{next_state, loging, State#state{socket=Socket}};

loging(#user_auth_fail_s2c{reasonid = ReasonId}, State)->
	io:format("user_auth_fail_s2c reasonid:~p~n",[ReasonId]),
	{next_state, loging, State};

loging(#init_random_rolename_s2c{bn=Bname,gn=Gname},State)->
	Gender = get(gender),
	if
		Gender =:= 0 ->
			if
				is_binary(Gname)->
					put(role_name,binary_to_list(Gname));
				true->
					put(role_name,Gname)
			end;
		true->
			if
				is_binary(Bname)->
					put(role_name,binary_to_list(Bname));
				true->
					put(role_name,Bname)
			end
	end,
	send_create_role_request(),
	{next_state, loging, State};


loging(#player_role_list_s2c{roles=RoleList}, State)->	
	case RoleList of
		[]->
			nothing;
		_-> 
			[#r{roleid=RoleId, 
						name=RoleName,
						lastmapid=LastMapId,
						classtype = Classtype,
						gender = Gender
					}|_T] = RoleList,
			put(role_id,RoleId),
			put(gender,Gender),
			put(class,Classtype),
			put(role_name,RoleName),
			if
				is_binary(RoleName)->
					put(role_name,binary_to_list(RoleName));
				true->
					put(role_name,RoleName)
			end,
			send_line_query(LastMapId)	
	end,
	{next_state, loging, State};
 
loging(#create_role_sucess_s2c{role_id=RoleId}, State)->
	put(role_id,RoleId),
	send_role_select(RoleId,0),
	{next_state, loging, State};

loging(#role_line_query_ok_s2c{lines = Lines}, State)->
	send_role_select(get(role_id),0),	
	{next_state, loging, State};
	
loging(#learned_skill_s2c{skills = SkillsList}, State)->
	Skills =
		if
			SkillsList =:= []->
				[];
			true->
				lists:map(fun({_,SkillId,_,_})->
								  SkillId
						  end,SkillsList)
		end,
	put(roleskill,Skills),
	{next_state, loging, State};
	
loging(#role_map_change_s2c{x = X, y = Y,lineid = LineId,mapid =MapId}, State)->
	send_map_complete(),
	put(line_id, LineId),
	put(map_id, MapId),
	put_current_pos(X, Y),
	put(path,[]),
	timer:send_after(random:uniform(60)*1000,{speek_loop}),
	query_time_c2s(),
	erlang:send_after(3 * 1000, self(), {quest_check}),
	{next_state, gaming, State};

loging(#object_update_s2c{create_attrs = CreateAttrs, change_attrs = ChangeAttrs, deleteids = DeleteIds}, State) ->
	update_aoi(CreateAttrs, ChangeAttrs, DeleteIds),
	{next_state, loging, State};

loging(#quest_list_update_s2c{quests = Quests}, State) ->
	put_quests(Quests),
	{next_state, loging, State};

loging(Value, State)->
	% io:format("login now Value :~p~n",[Value]),
	{next_state, loging, State}.

gaming(#object_update_s2c{create_attrs = CreateAttrs, change_attrs = ChangeAttrs, deleteids = DeleteIds}, State) ->
	update_aoi(CreateAttrs, ChangeAttrs, DeleteIds),
	{next_state, gaming, State};

gaming(#quest_list_update_s2c{quests = Quests}, State) ->
	put_quests(Quests),
	{next_state, gaming, State};

gaming(#query_time_s2c{time_async = ServerTime},State)->
	put(server_time,{now(),ServerTime - 50}),
	{next_state, gaming, State};

gaming(#quest_list_add_s2c{quest = Quest}, State) ->
	put_quests([Quest]),
	do_quest(),
	{next_state, gaming, State};

gaming({move_heartbeat,ReqList},State)->
	case ReqList =/= [] of 		%%寻路未跑完
		true->
			[#c{x = X,y=Y}|T] = ReqList,			
			put(pos,{X,Y}),
			gen_fsm:send_event_after(?MOVE_HEARTBEAT, {move_heartbeat, T}),
			NextState = gaming;
		_->			%%格跑完
			case get(path) of			
				[]->			%%路径跑完,做行动
					{PosX,PosY} = get_current_pos(),
					Msg = login_pb:encode_stop_move_c2s(#stop_move_c2s{posx = PosX,posy = PosY,time = get_now_time()}),
					sendtoserver(self(),Msg),
					case get(move) of
						undefined ->
							io:format("no move target"),
							nothing;
						{target, npc, NpcId} ->
							io:format("move npc ~p~n",[NpcId]),
							timer:sleep(2000),
							check_npc_function(NpcId);
						{target, monster, MonsterId} ->
							io:format("move monster ~p~n",[MonsterId]),
							do_something_of_quests:attack_monster(MonsterId);
						{target, transport, {TargetMapId,TransportId}} ->
							io:format("move transport ~p~n",[TransportId]),
							do_something_of_quests:chang_map(TargetMapId,TransportId);
						{target, mine, MineId} ->
							io:format("move mine ~p~n",[MineId]),
							do_something_of_quests:do_collect(MineId);
						{target, stop, _} ->
							io:format("stop here ~p~n",[get_current_pos()]),
							do_something_of_quests:stop_here();
						_ ->
							io:format("no move target ~n"),
							nothing
					end,
					NextState = gaming;
				Path->				%%路径没跑完,继续跑
					move_request(Path),
					NextState = gaming
			end		
	end,			
	{next_state, NextState, State};

gaming(#npc_function_s2c{npcid = NpcId, quests = Quests, queststate = QuestState}, State) ->
	QS = lists:zip(Quests, QuestState),
	lists:foreach(fun({QuestId, Status}) ->
					case Status of
						?QUEST_STATUS_COMPLETE ->
						    io:format("commit quest: ~p, RoleId: ~p~n", [QuestId, get(role_id)]),
							commit_quest(NpcId, QuestId);
						_ ->
							case QuestId of
								100200010 ->
									do_something_of_quests:change_bdyymap(QuestId);
								 _ ->
								 	do_something_of_quests:quest(QuestId)
							end
							
					end
				end, QS),
	{next_state, gaming, State};

gaming(#quest_details_s2c{npcid = NpcId, questid = QuestId, queststate = QuestState}, State) ->
	case QuestState of
		?QUEST_STATUS_AVAILABLE ->
			io:format("accept quest: ~p, RoleId: ~p~n", [QuestId, get(role_id)]),
			accept_quest(NpcId, QuestId);
		_ ->
			nothing
	end,
	{next_state, gaming, State};

gaming(#quest_complete_s2c{questid = QuestId}, State) ->
	io:format("finished quest: ~p, RoleId: ~p~n", [QuestId, get(role_id)]),
	{next_state, gaming, State};

gaming(#questgiver_states_update_s2c{npcid = NpcIds, queststate = Queststates}, State) ->
	NewQuestState = lists:zip(NpcIds,Queststates),
	lists:foreach(fun({NpcId,Queststate}) ->
				io:format("update questNPC: ~p, Queststate: ~p~n", [NpcId, Queststate]),
				case Queststate of
					?QUEST_STATUS_COMPLETE ->
						run_to_npc(NpcId),
						put(move, {target, npc, NpcId});
					_  ->
					nothing
				end
			end,NewQuestState),
	{next_state, gaming, State};

gaming(#role_map_change_s2c{x = X, y = Y, lineid = LineId, mapid = MapId}, State) ->
	send_map_complete(),
	put(line_id, LineId),
	put(map_id, MapId),
	put_current_pos(X, Y),
	put(path,[]),
	case MapId of 
		1202 ->
			Bin = login_pb:encode_bdyy_start_c2s(#bdyy_start_c2s{}),
			send_after_toserver(1000*10,self(),Bin);
		_ ->
			case get(last_map) of
				undefined ->
					do_quest();
				{TargetMapId,TransporPos} ->
					run_to(get_current_pos(), TransporPos, TargetMapId),
					put(move,{target, stop, {}});
				_ ->
					do_quest()
			end
	end,
	
	io:format("now in  map:~p~n",[MapId]),
	% io:format("finished quest: ~p, RoleId: ~p~n", [QuestId, get(role_id)]),
	{next_state, gaming, State};

% gaming(#be_attacked_s2c{enemyid = [Accackid], skill = _Skill, units = IdList, flytime = _Flytime}, State) ->
gaming({be_attacked_s2c, _, Accackid, Skill, IdList, _Flytime}, State) ->
	Roleid = get(role_id),
	{_,NpcId,_,DelHP} = case IdList of
		[] ->
			{0,0,0,0};
		_ ->
			hd(IdList)
		end,
	case Accackid of
		Roleid ->
			case get({attack,NpcId}) of
				undefined -> 
		 			% io:format("not attack the Id:~p npc	~n",[NpcId]),
		 			0;
				Value -> 
					% io:format("MonsterId ~p befor Hp:~p~n",[NpcId, Value]),
					% io:format("~p be attack by self,DelHP:~p~n",[NpcId,DelHP]),
					do_something_of_quests:next_attack_monster(NpcId,Value + DelHP)
			end;
		_ ->
			case get(collecting) of
				undefined ->
					% io:format("not collecting the dead npc :~p~n",[NpcId]),
						dono;
					% NpcId ->
					% 	ModId = client_util:get_mod_by_npcid(NpcId),
					% 	NewNpcId = client_util:get_random_nps(ModId),
					% 	put(collecting,NewNpcId),
					% 	move_in_same_map(NewNpcId,mine);
					_ ->
						no
			end
		end,
	{next_state, gaming, State};
% gaming(#role_attack_s2c{result = Result, skillid = Skillid, enemyid = Enemyid, creatureid = Creatureid}, State) ->
% 	Roleid = get(role_id),
% 	case Accackid of
% 		Roleid ->
% 			{_,NpcId,_,DelHP} = hd(IdList),
% 			case get({attack,NpcId}) of
% 				undefined -> 
% 		 			io:format("not attack the Id:~p npc	~n",[NpcId]),
% 		 			0;
% 				Value -> 
% 					io:format("MonsterId ~p befor Hp:~p~n",[NpcId, Value]),
% 					io:format("~p be attack by self,DelHP:~p~n",[NpcId,DelHP]),
% 					do_something_of_quests:next_attack_monster(NpcId,Value + DelHP)
% 			end;
% 		_ ->
% 			% io:format("	~p receive attack_msg,AccackRoleid is ~p ~n",[Roleid,Accackid]),
% 			dono
% 		end,
% 	{next_state, gaming, State};

% gaming(#be_killed_s2c{creatureid = [Creatureid], murderer = _Murderer, deadtype = Deadtype, posx = _X, posy = _Y, series_kills = _Series_kills}, State) ->
gaming({be_killed_s2c, _, Creatureid, Murderer, Deadtype, _X, _Y, _Series_kills}, State) ->
	RoleName = get(role_name),
	DoKillName = binary_to_list(Murderer),
	case DoKillName of
		RoleName ->
			% io:format("~p be killed by self~n",[Creatureid]),
			Npctype = client_util:get_npc_type_by_spawn(Creatureid),
			case Npctype of
				?NPC_MONSTER ->
					kill_quest(Creatureid);
				?NPC_MINE ->
					collect_quest(Creatureid)
			end;
			
		_ ->
			% io:format("~p be killed by othe~n",[Creatureid]),
			check_self_target(Creatureid)		
	end,
	% erase({attack,Creatureid}),
	{next_state, gaming, State};	

gaming(#update_item_s2c{items = Items}, State) -> 
	put_items(Items),{next_state, gaming, State};

gaming(#add_item_s2c{item_attr = ItemAttr}, State) ->
 	put_add_item(ItemAttr),{next_state, gaming, State};
 	
gaming(#bdyy_item_show_s2c{item_id = _ItemId,show_time = _Show_time}, State) ->
 	{next_state, gaming, State};

% gaming(#role_map_change_s2c{x = X,y = Y,lineid = Lineid,mapid = Mapid}, State) ->
%  	send_map_complete(),
% 	put(line_id, LineId),
% 	put(map_id, MapId),
% 	put_current_pos(X, Y),
% 	put(path,[]),
% 	timer:send_after(random:uniform(60)*1000,{speek_loop}),
% 	query_time_c2s(),
% 	erlang:send_after(3 * 1000, self(), {quest_check}),
%  	{next_state, gaming, State};
gaming(#bdyy_item_end_s2c{}, State) ->
 	% io:format("3~n"),
	Message = login_pb:encode_instance_exit_c2s(
						#instance_exit_c2s{}),
	sendtoserver(self(), Message),
	% do_something_of_quests:update_quest(QuestNpcId),
 	{next_state, gaming, State};

gaming(#create_pet_s2c{pet = PetInfo}, State) ->
 	put(pet,PetInfo),
 	io:format("get the pet is~p ~n",[PetInfo]),
 % 	Message = login_pb:encode_pet_grade_riseup_c2s(
	% 					#pet_grade_riseup_c2s{petid = PetInfo#p.petid, extitems = 0,consum_type = 0,up_type = 1}),
	% sendtoserver(self(),Message), 

	Message = login_pb:encode_pet_quality_riseup_c2s(
						#pet_quality_riseup_c2s{petid = PetInfo#p.petid, flag = 1,up_type = 1}),
	sendtoserver(self(), Message),
 	{next_state, gaming, State};

 gaming(#quest_statu_update_s2c{quests = Quests}, State) ->
 	{_, QuestId, Status, _, _} = Quests, 
 	% case lists:any(fun(ID)-> ID =:= QuestId end,[100400006,100400007,101000013]) of
 	% 	true ->
 	% 		io:format("quest_statu_update_s2c the Quest is:~p ~n",[Quests]),
		% 	[QuestNpcId | _] = client_util:get_quest_com_npc_ids(QuestId),
		% 	run_to_npc(QuestNpcId);

 	% 	_ ->
 	% 		dono
 	% end,
 	case Status of
		?QUEST_STATUS_COMPLETE ->
			case QuestId of
				100200011 ->
					dono;
				_ ->
					stop_accack(QuestId),
					% io:format("quest_statu_update_s2c the Quest is:~p ~n",[Quests]),
					[QuestNpcId | _] = client_util:get_quest_com_npc_ids(QuestId),
					run_to_npc(QuestNpcId)
			end;
		_  ->
			% io:format("quest_statu_update_s2c here do none ~n"),
			do_no
	end,

 	% put_quests([Quests]),
	% do_quest(),
 % 	lists:foreach(fun(Quest)->
 % 			put_quests()
 % 		end,Quests),
 % 	Message = login_pb:encode_pet_grade_riseup_c2s(
	% 					#quest_statu_update_s2c{q = PetInfo#p.petid, extitems = 0,consum_type = 0,up_type = 1}),
	% sendtoserver(self(),Message), 
 	{next_state, gaming, State};

 % gaming({up_quest,QuestNpcId}, State) -> 
	% do_something_of_quests:update_quest(QuestNpcId),{next_state, gaming, State};



gaming(Value, State) ->
	% io:format("gameing now Value :~p~n",[Value]),
	{next_state, gaming, State}.

%% --------------------------------------------------------------------
%% Func: handle_info/3
%% Purpose: Handling all non call/cast messages
%% Returns: 
%% --------------------------------------------------------------------

handle_info({sendtoserver,Binary},StateName,#state{socket=Socket}=State)->
	gen_tcp:send(Socket, Binary),
	{next_state, StateName, State};
	
handle_info({tcp_closed, _Socket}, StateName, StateData) ->
	io:format("tcp_closed Roleid ~p~n",[get(role_id)]),
	exit(normal),
	{stop,normal, StateData};

handle_info({tcp,Socket,Binary},StateName,State)->
	try
		put(check_alive,now()),	
		Term = erlang:binary_to_term(Binary),
		ID = element(2,Term),
		BinMsg = erlang:setelement(1,Term, login_pb:get_record_name(ID)),
		% io:format("yanzengyan, receive msg: ~p~n", [BinMsg]),
		util:send_state_event(self(), BinMsg)
	catch
		E:R->
			slogger:msg("tcp error record_name Binary E:~p,R~p,~p ~n",[E,R,Binary])
	end,			
	{next_state, StateName, State};

handle_info({quest_check}, StateName, State) ->
	case get(quests) of
		undefined ->
			erlang:send_after(3 * 1000, self(), {quest_check});
		_ ->
			do_quest()
	end,
	{next_state, StateName, State};

handle_info({check_target,NpcId}, StateName, State) ->
	do_something_of_quests:check_target(NpcId),
	{next_state, StateName, State};

handle_info(#be_attacked_s2c{enemyid = [Accackid], skill = _Skill, units = IdList, flytime = _Flytime}, StateName, State) ->
	Roleid = get(role_id),
	io:format("	~p receive attack_msg,AccackRoleid is ~p ~n",[Roleid,Accackid]),
	{next_state, StateName, State};

handle_info({up_quest,QuestNpcId}, StateName, State) -> 
	% io:format("3~n"),
	Message = login_pb:encode_instance_exit_c2s(
						#instance_exit_c2s{}),
	sendtoserver(self(), Message),
	do_something_of_quests:update_quest(QuestNpcId),
	{next_state,StateName, State};

handle_info(check_heart, StateName, State) -> 
	do_something_of_quests:stop_here(),
	{next_state,StateName, State};

handle_info(create_new_client, StateName, State) -> 
	do_something_of_quests:kill_self_and_create_other(State),
	{next_state,StateName, State};

handle_info(Value, StateName, StateData) ->
	% io:format("handle_info now Value :~p~n",[Value]),
	{next_state,StateName, StateData}.

handle_event(stop, StatName, StateData)->
	{stop, normal, StateData};

handle_event(Value, StateName, StateData) ->
	% io:format("handle_event now Value :~p~n",[Value]),
	{next_state, StateName, StateData}.

handle_sync_event(Event, From, StateName, StateData) ->
	% io:format("sync handle evevt now Value :~p~n",[Event]),
	{reply, ok, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% --------------------------------------------------------------------
terminate(Reason, StateName, StatData) ->
	ok.

%% --------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% --------------------------------------------------------------------
code_change(OldVsn, StateName, StateData, Extra) ->
	{ok, StateName, StateData}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

sendtoserver(Pid,Binary)->
	Pid ! {sendtoserver,Binary}.
send_after_toserver(Time,Pid,Binary)->
	erlang:send_after(Time,Pid,{sendtoserver,Binary}).

begin_auth(AccountName,_UserId,ServerId)->
	{MegaSecs, Secs, _MicroSecs} = now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	Time = integer_to_list(TimeSeconds),
	% PlatformKey = env:get(platform_key, []),
	% slogger:msg("aaaaaaaaaaaaaaaaa~p~n",[env:get(platform_key, [])]),
	PlatformKey = "1bA3blMO9xCu7rvN8hp7Jo",
	% PlatformKey = "1bA3blMO9xCu7rvN8hp7Jo",
	AuthStr = "account="++AccountName++"&timestamp="++Time,
    AuthStr2 = AuthStr++"&key="++PlatformKey,
    MD5Bin = erlang:md5(http_uri:encode(AuthStr2)),
    MD5Str = auth_util:binary_to_hexstring(MD5Bin),

	AuthTerm = #user_auth_c2s{username=AccountName,serverId = ServerId,time = Time,sign = MD5Str, flag = 0},
	Binary = login_pb:encode_user_auth_c2s(AuthTerm),
	sendtoserver(self(), Binary).

send_create_role_request()->	
	Name = get(role_name),
	Gender = get(gender),
	Class = get(class),
	Message = login_pb:encode_create_role_request_c2s(#create_role_request_c2s{role_name = Name,gender = Gender,classtype = Class}),
	sendtoserver(self(), Message).

send_line_query(LastMapId)->
	Message = login_pb:encode_role_line_query_c2s(#role_line_query_c2s{mapid = LastMapId}),
	sendtoserver(self(), Message).

send_role_select(RoleId,LineId)->	
	Message = login_pb:encode_player_select_role_c2s(
						#player_select_role_c2s{roleid = RoleId,lineid = LineId}),
	sendtoserver(self(), Message).

send_map_complete()->
	Message = login_pb:encode_map_complete_c2s(#map_complete_c2s{}),	
	sendtoserver(self(), Message).

query_time_c2s()->
	Message2 = login_pb:encode_query_time_c2s(#query_time_c2s{}),
	sendtoserver(self(), Message2).

update_aoi(CreateAttrs, ChangeAttrs, DeleteIds) ->
	AoiList = case get(aoi_list) of
		undefined ->
			CreateAttrs;
		OldAoiList ->
			lists:append(CreateAttrs, OldAoiList)
	end,
	AoiList2 = if
		DeleteIds =:= [] ->
			AoiList;
		true ->
			lists:foldl(fun(Creature, TmpAoiList) ->
				Id = element(2, Creature),
				lists:keydelete(Id, 2, TmpAoiList)
			end, AoiList, DeleteIds)
	end,
	AoiList3 = if
		ChangeAttrs =:= [] ->
			AoiList2;
		true ->
			lists:foldl(fun(Creature, TmpAoiList) ->
				Id = element(2, Creature),
				TmpAttrList = element(4, Creature),
				case lists:keyfind(Id, 2, TmpAoiList) of
					false ->
						[Creature | TmpAoiList];
					CreatureThis ->
						OldAttrList = element(4, CreatureThis),
						NewAttrList = lists:foldl(fun(Attr, TmpAttrList1) ->
													Key = element(2, Attr),
													lists:keyreplace(Key, 2, TmpAttrList1, Attr)
												end, OldAttrList, TmpAttrList),
						CreatureThis2 = setelement(4, CreatureThis, NewAttrList),
						lists:keyreplace(Id, 2, TmpAoiList, CreatureThis2)
				end
			end, AoiList2, ChangeAttrs)
	end,
	put(aoi_list, AoiList3),
	update_myself(AoiList3, ?ROLE_ATTR_MOVESPEED),
	update_myself(AoiList3, ?ROLE_ATTR_POSX),
	update_myself(AoiList3, ?ROLE_ATTR_POSY).

update_myself(AoiList, Key) ->
	MyRoleId = get(role_id),
	case lists:keyfind(MyRoleId, 2, AoiList) of
		{_, MyRoleId, _, AttrList} ->
			case lists:keyfind(Key, 2, AttrList) of
				{_, _, Value} ->
					put(Key, Value);
				_ ->
					nothing
			end;
		_ ->
			nothing
	end.

put_quests(Quests) ->
	case get(quests) of
		undefined ->
			put(quests, Quests);
		OldQuests ->
			put(quests, Quests ++ OldQuests)
	end.

do_quest() ->
	case get(quests) of 
		[] ->
			do_something_of_quests:send_change_new_msg();
		[{_, QuestId, Status, _, _} | T] ->
			case Status of
				?QUEST_STATUS_COMPLETE ->
					[QuestNpcId | _] = client_util:get_quest_com_npc_ids(QuestId),
					run_to_npc(QuestNpcId);
				?QUEST_STATUS_INCOMPLETE ->
					do_something_of_quests:quest(QuestId);
				_ ->
					put(quests, T)
			end;
		_ ->
			do_something_of_quests:send_change_new_msg()
	end.
	% io:format("now quests are :~p~n",[get(quests)]),
	% io:format("the Quest Id is:~p,Status is :~p~n",[QuestId,Status]),

move_request(Path)->		
	{ReqList, RemList} = lists:split(erlang:min(?MOVE_NUM,erlang:length(Path)),Path),
	put(path, RemList),
	if
		Path =/= []->				
			[NextPos | _] =  ReqList,		
			{_,X,Y} = NextPos,
			{NowX, NowY} = get_current_pos(),
			put_current_pos(X, Y),	
			Message = login_pb:encode_role_move_c2s(#role_move_c2s{time = get_now_time(),posx = NowX,posy = NowY,path=ReqList}),
			sendtoserver(self(), Message);
		true->
			nothing
	end,
	util:send_state_event(self(), {move_heartbeat,ReqList}).

get_current_pos() ->
	{get(?ROLE_ATTR_POSX), get(?ROLE_ATTR_POSY)}.

put_current_pos(X, Y) ->
	put(?ROLE_ATTR_POSX, X),
	put(?ROLE_ATTR_POSY, Y).

get_now_time() ->
	{Now,ServerTime} = case get(server_time) of 
		undefined ->
			{now(),1375410881};
		ServerTime0 ->
			ServerTime0
	end,
	trunc(timer:now_diff(now(),Now)/1000) + ServerTime.

check_npc_function(NpcId) ->
	Message = login_pb:encode_npc_function_c2s(
						#npc_function_c2s{npcid = NpcId}),
	sendtoserver(self(), Message).

commit_quest(NpcId, QuestId) ->
	Message = login_pb:encode_questgiver_complete_quest_c2s(
						#questgiver_complete_quest_c2s{questid = QuestId, npcid = NpcId, choiceslot = 0}),
	sendtoserver(self(), Message).

accept_quest(NpcId, QuestId) ->
	Message = login_pb:encode_questgiver_accept_quest_c2s(
						#questgiver_accept_quest_c2s{npcid = NpcId, questid = QuestId}),
	sendtoserver(self(), Message).

run_to_creature(NpcId,Type) ->
	case Type of
		npc  ->
			run_to_npc(NpcId);
		mine ->
			move_in_same_map(NpcId,Type);
		monster ->
			move_in_same_map(NpcId,Type)
	end.
move_in_same_map(NpcId,Type) ->
	CurPos = get_current_pos(),
	[{TargetMapId, TargetPos}| _] = client_util:get_npc_pos(NpcId),
	run_to(CurPos, TargetPos, TargetMapId),
	put(move, {target, Type, NpcId}).

run_to_npc(NpcId) ->
	CurMapId = get(map_id),
	CurPos = get_current_pos(),
	[{TargetMapId, TargetPos}| _] = client_util:get_npc_pos(NpcId),
	if CurMapId =:=  TargetMapId ->
			run_to(CurPos, TargetPos, CurMapId),
			put(move, {target, npc, NpcId});
		true ->
			% io:format("change map ~p to ~p~n",[CurMapId,TargetMapId] ),
			[{TransportId, TransporPos}| _] = client_util:get_transpots_info(CurMapId,TargetMapId),
			run_to(CurPos, TransporPos, CurMapId),
			put(move,{target, transport, {TargetMapId,TransportId}})
	end.

run_to(CurPos, TargetPos, TargetMapId) ->
	TmpPath = path:path_find(CurPos, TargetPos, TargetMapId),
	if 
		TmpPath =:= [] ->
			nothing;
		true ->
			Length = erlang:length(TmpPath),
			if 
				Length > 1 ->
					{TmpPath2, _} = lists:split(Length - 1, TmpPath),
					Path = lists:map(fun({TmpX,TmpY})-> #c{x=TmpX, y=TmpY} end,TmpPath2),
				 	put(path,Path),
					move_request(Path);
				true ->
					gen_fsm:send_event(self(),{move_heartbeat,[]})
			end
	end.

kill_quest(Creatureid) ->
	ModId = client_util:get_mod_by_npcid(Creatureid),
	case get({kill,ModId}) of
		undefined ->
			% io:format("no killed quest:~p~n",[ModId]),
			dono;
		{KilledNum,TotalNum,QuestNpcId} ->
			if
				TotalNum - (KilledNum+1)  > 0->
					% io:format("the Mod: ~p, monster ~p ,be killed: ~p times.~n", [ModId, Creatureid, (KilledNum+1)]),
					put({kill,ModId},{KilledNum+1,TotalNum,QuestNpcId}),
					% timer:sleep(1000),
					NewNpcId = client_util:get_random_nps(ModId),
					% NpcMaxHp = client_util:get_npc_maxHP(ModId),
					% put({attack,NewNpcId},NpcMaxHp),
					move_in_same_map(NewNpcId,monster);
					% put(move, {target, monster, NewNpcId});
				true ->
					% io:format("the Mod: ~p, monster ~p ,be killed: ~p times,ok.~n", [ModId, Creatureid, (KilledNum+1)]),
					do_something_of_quests:update_quest(QuestNpcId)
					% erase({kill,ModId})
			end
	end.
check_self_target(Creatureid) ->
	Self = get(role_id),
	case Creatureid of
		Self ->
			do_something_of_quests:send_change_new_msg();
		_ ->
			ModId = client_util:get_mod_by_npcid(Creatureid),
			case get({kill,ModId}) of
				undefined ->
					% io:format("no killed quest:~p~n",[ModId]),
					dono;
				{KilledNum,TotalNum,_QuestNpcId} ->
					case get({attack,Creatureid}) of
							undefined ->
								% io:format("not attack the dead npc :~p~n",[Creatureid]),
								dono;
							_NpcMaxHp ->
								NewNpcId = client_util:get_random_nps(ModId),
								% NpcMaxHp = client_util:get_npc_maxHP(ModId),
								% io:format("put the npc :~p,the dead npc:~p~n",[NewNpcId,Creatureid]),
								% put({attack,NewNpcId},NpcMaxHp),
								move_in_same_map(NewNpcId,monster)
								% put(move, {target, monster, NewNpcId})
					end
			end,
			case get({collect,ModId}) of
				undefined ->
					% io:format("no collected quest:~p~n",[ModId]),
					dono;
				_ ->
					case get(collecting) of
							undefined ->
								% io:format("not collecting the dead npc :~p~n",[Creatureid]),
								dono;
							Creatureid ->
								NewNpcId2 = client_util:get_random_nps(ModId),
								put(collecting,NewNpcId2),
								move_in_same_map(NewNpcId2,mine);
							_ ->
								no
					end
			end

	end.

collect_quest(Creatureid) ->
	ModId = client_util:get_mod_by_npcid(Creatureid),
	case get({collect,ModId}) of
		undefined ->
			dono;
		{KilledNum,TotalNum,QuestNpcId} ->
			% if
				% TotalNum - (KilledNum+1)  > 0->
					% io:format("the Mod: ~p, MineId ~p ,be collected: ~p times.~n", [ModId, Creatureid, (KilledNum+1)]),
					put({collect,ModId},{KilledNum+1,TotalNum,QuestNpcId}),
					% timer:sleep(1000),
					NewNpcId = client_util:get_random_nps(ModId),
					move_in_same_map(NewNpcId,mine)
					% put(move, {target, mine, NewNpcId});
				% true ->
					% io:format("the Mod: ~p, mine  ~p ,be collected: ~p times,ok.~n", [ModId, Creatureid, (KilledNum+1)]),
					% do_something_of_quests:update_quest(QuestNpcId)
					% erase({collect,ModId})
			% end
	end.

put_add_item(ItemAttr)->
	case get(item_attr) of 
		undefined ->
			put(item_attr,ItemAttr);
		OldItemAttr ->
 			Slot=element(7,ItemAttr),
 			auto_equip_item(Slot)
	end.

put_items(Items) ->
	case get(items) of
		undefined ->put(items,Items);
		OldItems ->put(items, OldItems ++ Items)
	end.

auto_equip_item(Slot)->
	Message = login_pb:encode_auto_equip_item_c2s(#auto_equip_item_c2s{slot = Slot}),
	sendtoserver(self(), Message).
questgiver_states_update(NpcId) -> 
	Message = login_pb:encode_questgiver_states_update_c2s(#questgiver_states_update_c2s{npcid = NpcId}),
 	% io:format("Npcid:~p ~n",[NpcId]), 
 	sendtoserver(self(), Message).
 stop_accack(QuestId) ->
 	QuestInfo = quest_db:get_info(QuestId),
 	lists:map(fun(Mob)->
				case Mob of
					{MobId,_} ->
						erase({collect,MobId}),
						erase({kill,MobId});
					_ ->
						nothing
				end	
		end, quest_db:get_reqmob(QuestInfo)).
 	