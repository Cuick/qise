%%% File    : client.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created :  5 Aug 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>
-module(client).

-behaviour(gen_fsm).
-define(PACKAGE_INDEX,1000).
-define(ITEMNUM,10).
-include("login_pb.hrl").
-include("client_def.hrl").
-include("common_define.hrl").
-include("quest_define.hrl").
-include("creature_define.hrl").
-include("attr_keyvalue_define.hrl").
-define(MAP_X,200).
-define(MAP_Y,200).
-define(MAX_ATTACK_TIME,5).
%%-define(MOVE_SPEED,143).
%%-define(MOVE_SPEED,1000).
-define(MOVE_SPEED,2*?ROLE_ATTR_MOVESPEED).
-define(MOVE_NUM,6).
-define(MONEY,100000).
-define(GOLD,10000).
%% fashi,lieshou,zhanshi :1,2,3
%% fashi [713000001,713000002,713000003,713000004,713000005]
%% lieshou [712000001,712000002,712000003,712000004,712000005,712000006]
%% zhanshi[711000001,711000002,711000003,711000004,711000005,711000006]
-define(SKILLLIST,[[713000001,713000002,713000003,713000004,713000005],[712000001,712000002,712000003,712000004,712000005,712000006],[711000001,711000002,711000003,711000004,711000005,711000006]]).
-define(EQUIPMENT,[[17000050,11001101,11009101,11002102,11002105,11004103,11004105,11005104,11005105,11006104,11006105,11006101],[17000050,11001101,11009101,11002102,11002105,11004103,11004105,11005104,11005105,11006104,11006105,11006101],[17000050,11001101,11009101,11002102,11002105,11004103,11004105,11005104,11005105,11006104,11006105,11006101]]).
-export([start/2,sendtoserver/2]).

-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-record(state, {socket, role_info, map_info, client_config}).

-export([loging/2,gaming/2,attacking/2]).

-include("data_struct.hrl").

start(Id, Client_config)->
	gen_fsm:start_link({local,Id},?MODULE, [Client_config], []).

sendtoserver(Pid,Binary)->
	Pid ! {sendtoserver,Binary}.

init([Client_config]) ->
	process_flag(trap_exit,true),
	{A,B,C} = now(),
	random:seed(A,B,C),
	util:send_state_event(self(), {login}),
	{ok,  loging,#state{client_config=Client_config}}.

loging({login}, State) ->
	#state{client_config=Client_config} = State,
	{A,B,C} = erlang:now(),
	#client_config{user_name=Index, 
		       server_addr=Server_addr,
		       server_port=Server_port,
				lineid = LineId,
				mapid = MapId,
				level = Level,
				speekrate = SpeekRate,
				serverid = ServerId} = Client_config,
	random:seed(A,B+Index,C),
	User_name ="1000" ++ integer_to_list(Index),
	put(user_name,User_name),
	put(lineid ,LineId),
	put(mapid,MapId),
	put(speek_rate,SpeekRate),
	put(level,Level),
	put(in_battle,false),
	put(attack_time,0),
	Gender = (Index rem 2),
	put(gender,Gender),
	Class = (Index rem 3) + 1,
	put(class,Class),
	{ok,Socket} = gen_tcp:connect(Server_addr, Server_port, [binary,{packet,2}]),    
	%% 认证开始
	UserId = integer_to_list(Index),
	put(userid,UserId),
	begin_auth(User_name,UserId,ServerId),
	put(player_list, []),
	{next_state, loging, State#state{socket=Socket}};

loging(#user_auth_fail_s2c{reasonid = ReasonId}, State)->
	io:format("user_auth_fail_s2c reasonid:~p~n",[ReasonId]),
	{next_state, loging, State};

loging(#init_random_rolename_s2c{bn=Bname,gn=Gname},State)->
	%%io:format("a new player ~n"),
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
		%%	io:format("player_role_list_s2c rolelist:~p~n",[RoleList]),
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
			{A,B,C} = erlang:now(),
			random:seed(A,B+RoleId,C),
			send_line_query(LastMapId)	
	end,
	{next_state, loging, State};
 
loging(#create_role_sucess_s2c{role_id=RoleId}, State)->
%% io:format("create_role_sucess_s2c RoleId:~p ~n",[RoleId]),
	put(role_id,RoleId),
	send_role_select(get(role_id),get(lineid)),
	{next_state, loging, State};

loging(#role_line_query_ok_s2c{lines = Lines}, State)->
%%	io:format("role_line_query_ok_s2c ok~n"),
	send_role_select(get(role_id),get(lineid)),	
	{next_state, loging, State};
	
loging(#learned_skill_s2c{skills = SkillsList}, State)->
%%	io:format("learned_skill_s2c loging,skilllist:~p~n",[SkillsList]),
	Skills =
		if
			SkillsList =:= []->
%% 				io:format("learned_skill_s2c"),
				[];
			true->
				lists:map(fun({_,SkillId,_,_})->
								  SkillId
						  end,SkillsList)
		end,
	put(roleskill,Skills),
	{next_state, loging, State};
	
loging(#role_map_change_s2c{x=LX, y=LY,lineid = LastLineId,mapid =LastMapid}, State)->
	send_map_complete(),
	TargetMap = get(mapid),
	TargetLine = get(lineid),
	io:format("loging role_map_change_s2c,Lineid:~p,mapid:~p,TargetLine:~p,TargetMap:~p~n",[LastLineId,LastMapid,TargetLine,TargetMap]),
	IsMapLine = (TargetMap =:= LastMapid) and (TargetLine =:= LastLineId),
	if
		IsMapLine ->
		%%	io:format("roleid:~p,loging  send_map_complete~n",[get(role_id)]),
			put(pos,{LX,LY}),
			put(path,[]),
			gm_levelup(get(level)),
			gm_moneychange(?MONEY),
			gm_goldchange(?GOLD),
			timer:send_after(random:uniform(60)*1000,{speek_loop}),
			self() ! {check_alive},
			query_time_c2s(),
			{next_state, gaming, State};
		TargetMap =/= LastMapid->		
		%%	io:format("roleid:~p, loging TargetMap:~p,LastMapid:~p~n",[get(role_id),TargetMap,LastMapid]),
			{Random_X,Random_Y} = path:random_pos(TargetMap),
			put(pos,{Random_X,Random_Y}),
			gm_move(TargetMap,Random_X,Random_Y),
			{next_state, loging, State};
		true->
		%%	io:format("roleid:~p, loging TargetLine:~p,LastLineId:~p~n",[get(role_id),TargetLine,LastLineId]),
			change_line(TargetLine),
			{next_state, loging, State}
	end;	

loging(_Other, State)->
	ignor,	
	{next_state, loging, State}.

gaming(#update_skill_s2c{skillid = SkillId},State)->
	%%io:format("update_skill_s2c gaming,skillid:~p~n",[SkillId]),
	case lists:member(SkillId,get(roleskill)) of
		false->
			put(roleskill,[SkillId|get(roleskill)]);
		true->
			nothing
	end,
	{next_state, gaming, State};


gaming(#role_map_change_s2c{x=X, y=Y,lineid = LineId,mapid =Mapid}, State)->
	io:format("gaming,roleid:~p,Line:~p,,Mapid:~p~n,X:~p,Y:~p~n",[get(role_id),LineId,Mapid,X,Y]),
	send_map_complete(),
	start_random_move(),
	{next_state, gaming, State};


gaming(#query_time_s2c{time_async = ServerTime},State)->
	%%io:format("query_time_s2c~n"),
	put(server_time,{now(),ServerTime - 50}),
	SkillNum = erlang:length(get(roleskill)),
	if 
		SkillNum=<1->
			ClassSkill = lists:nth(get(class),?SKILLLIST),
			learn_skill(ClassSkill);
		true->
			nothing
	end,
	clear_package(),
	EquipmentList = lists:nth(get(class),?EQUIPMENT),
	RandomNum = random:uniform(erlang:length(EquipmentList)),
	Equipment = lists:nth(RandomNum,EquipmentList),
	gm_getitem(Equipment),
	start_random_move(),
	{next_state, gaming, State};


gaming(#add_item_s2c{item_attr = #i{slot = Slot}}, State)->	
	Msg = login_pb:encode_auto_equip_item_c2s(#auto_equip_item_c2s{slot = Slot}),
	sendtoserver(self(), Msg),
	{next_state, gaming, State};


gaming(#questgiver_states_update_s2c{npcid = Npcs,queststate = States}, State)->
	case lists:member(1,Npcs) of
		true->
			QuestState = lists:foldl(fun(Index,Tmpre)->
						if
							Tmpre =/= 0->
								Tmpre;
							true->	
								case lists:nth(Index,Npcs) of
									2010001->
										lists:nth(Index,States);
									_->
										Tmpre 
								end
						end					 
					end,0,lists:seq(1, erlang:length(Npcs)) ),
			if
				QuestState =:= ?QUEST_STATUS_COMPLETE->
					%%io:format("questgiver_states_update_s2c0000000~n"),
					put(next_action,{com_quest,2010001}),
					put(path,[]);
%%					;
				true->
					nothing
			end;			 
		_->
			nothing
	end,
	{next_state, gaming, State};	

gaming(#be_killed_s2c{creatureid = CreatureId}, State)->
	%%io:format("be_killed_s2c creatureid~p  get(role_id) ~p~n",[CreatureId, get(role_id)]),
	MyId = get(role_id),
	MyTarget = get(target),
	case CreatureId of
		MyTarget->
			put(target,0),
			%%put(next_action,random_move),
			%%start_random_move();
			MonsterAoi = lists:filter(fun({_,TypeTmp,_})->
					TypeTmp =:= ?CREATURE_MONSTER
				end,get(aoi_list)),
			Length = erlang:length(MonsterAoi),	
			if
				Length > 0-> 	
					Nth = random:uniform(Length),	
					{Objectid1,_,Pos1} = lists:nth(Nth,MonsterAoi),
					case get(target) of
						0->
							put(target,Objectid1),
							start_move(Pos1),
							put(next_action,{attack,Objectid1,Pos1});
						_->
							case get(next_action) of
								{attack,_Objectid,Pos}->
									start_move(Pos);
								_->
									put(target,0)
							end	
							%%start_random_move()
					end;
				true->
					start_random_move()
			end;

		MyId->	
			Msg = login_pb:encode_role_respawn_c2s(#role_respawn_c2s{type = 2}),			
			sendtoserver(self(), Msg),
			put(target,0),					
			start_random_move();
		_->
			nothing
	end,
	{next_state, gaming , State};	
	

gaming(#object_update_s2c{create_attrs = NewCommers,change_attrs = _Change, deleteids = Deletes}, State)->
	change_my_aoi(NewCommers,Deletes),
	{next_state, gaming, State};	

gaming(#role_move_fail_s2c{pos = #c{x=TmpX, y=TmpY} }, State)->
	put(pos,{TmpX,TmpY}),
	put(path,[]),
	put(target,0),
	start_random_move(),
	{next_state, gaming, State};

%%战场开启
gaming(#battle_start_s2c{type = Type,lefttime = LeftTime},State)->
	case get(in_battle) of
		true->
			nothing;
		_->
			timer:send_after(random:uniform(60)*1000,{join_battle})
	end,
	{next_state, gaming, State};
		
%%战场结束
gaming(#battle_end_s2c{},State)->
	case get(in_battle) of
		true->
			put(in_battle,false),
			Msg = login_pb:encode_battle_leave_c2s(#battle_leave_c2s{}),			
			sendtoserver(self(), Msg),
			start_random_move();
		_->
			nothing
	end,
	{next_state, gaming, State};
	
gaming({move_heartbeat,ReqList},State)->
	case ReqList =/= [] of 		%%寻路未跑完
		true->
			[#c{x = X,y=Y}|T] = ReqList,			
			put(pos,{X,Y}),
			gen_fsm:send_event_after(?MOVE_SPEED, {move_heartbeat, T}),
			NextState = gaming;
		_->			%%格跑完
			case get(path) of			
				[]->			%%路径跑完,做行动
					{PosX,PosY} = get(pos),
					%%io:format("stop_move_c2s ~p ~n",[get_now_time()]),
					Msg = login_pb:encode_stop_move_c2s(#stop_move_c2s{posx = PosX,posy = PosY,time = get_now_time()}),
					sendtoserver(self(),Msg), 
					case get(next_action) of
						random_move->
							range_alert(),
							NextState = gaming;%%战斗寻路或者继续随机寻路跑
						%Other->
						%	case Other of
								%{com_quest,2010001}->								
								%case get(pos) of
								%	{125,41}->										
								%		com_quest(2010001),
								%		NextState = gaming;
								%	_->											
								%		start_move({125,41}),
								%		NextState = gaming
								%end;		
								{attack,Objectid,_}->
									start_attack(Objectid),
									NextState = attacking
						%	end
					end;
				Path->				%%路径没跑完,继续跑
					move_request(Path),
					NextState = gaming
			end		
	end,			
	{next_state, NextState, State};
	

gaming(_Other, State)->
%% 	io:format("gaming,Other:~p~n",[Other]),	
	{next_state, gaming, State}.

attacking({attack_heartbeat,CreatureId}, State)->
 	%%io:format("attack_heartbeat begin ~n"),
	SkillList = get(roleskill),
	Random = random:uniform(erlang:length(SkillList)),
	SkillId = lists:nth(Random,SkillList),
	Message = login_pb:encode_role_attack_c2s(#role_attack_c2s{creatureid=CreatureId, skillid=SkillId}),
	sendtoserver(self(), Message),
	gen_fsm:send_event_after(1300,{attack_heartbeat,CreatureId}),
	{next_state, attacking, State};

attacking(#be_killed_s2c{creatureid = CreatureId}, State)->
 	%%io:format("be_killed_s2c creatureid~p  get(role_id) ~p~n",[CreatureId, get(role_id)]),
	MyId = get(role_id),
	case CreatureId of
		MyId->	
			my_respawn();
		_Other->
			nothing		 		
	end,

	put(target,0),
			%%put(next_action,random_move),
			%%start_random_move();
			MonsterAoi = lists:filter(fun({_,TypeTmp,_})->
					TypeTmp =:= ?CREATURE_MONSTER
				end,get(aoi_list)),
			Length = erlang:length(MonsterAoi),	
			if
				Length > 0-> 	
					Nth = random:uniform(Length),	
					{Objectid1,_,Pos1} = lists:nth(Nth,MonsterAoi),
					case get(target) of
						0->
							put(target,Objectid1),
							start_move(Pos1),
							put(next_action,{attack,Objectid1,Pos1});
						_->
							case get(next_action) of
								{attack,_Objectid,Pos}->
									start_move(Pos);
								_->
									put(target,0)
							end	
							%%start_random_move()
					end;
				true->
					start_random_move()
			end,

	{next_state, gaming  , State};	

attacking(#role_attack_s2c{result = Result,enemyid = CastId}, State)->
	%%io:format("role_attack_s2c Result:~p,curpos:~p~n",[Result,get(pos)]),
	case (get(role_id)=:= CastId) and (Result =/= 0) and (Result =/= 10012)of
		true->
			%%io:format("role_attack_s2c Error Result ~p~n",[Result]),
			put(target,0),
			NextState = gaming,
			range_alert();
			%%start_random_move();
		_->
			NextState  = attacking
	end,				 	 
	{next_state, NextState, State};


attacking(_Other, State)->
	ignor,	
	{next_state, attacking, State}.

handle_info({quit},StateName, State) ->
	#state{client_config=Client_config,socket=Socket} = State,    
	gen_tcp:close(Socket),
	timer:send_after(2000, {init}),
	{next_state, StateName, State};

handle_info({check_alive},StateName, State) ->
	case get(check_alive) of
		undefined->
			put(check_alive,now());
		Timer->
			DealyTime = timer:now_diff(now(),Timer),
			if 
				DealyTime > 10000*1000-> 				%%10s
					noting;
%%					 io:format("tcp not alive check_alive DealyTime ~p seconds~n",[DealyTime/1000000]);
%% 					 util:send_state_event(self(), {restart});
				true->
					nothing
			end
	end,
	timer:send_after(10000,{check_alive}),
	{next_state, StateName, State};

handle_info({speek_loop},StateName,State)->
	case random:uniform(100) > get(speek_rate) of
		true->
			nothing;
		_->
			speek_to_world()
	end,
	timer:send_after(10000,{speek_loop}),
	{next_state, StateName, State};

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
		io:format("yanzengyan, receive msg: ~p~n", [BinMsg]),
		util:send_state_event(self(), BinMsg)
	catch
		E:R->
			slogger:msg("tcp error record_name Binary E:~p,R~p,~p ~n",[E,R,Binary])
	end,			
	{next_state, StateName, State};	

handle_info({join_battle},StateName,State)->
	case get(in_battle) of
		true->
			nothing;
		_->
			put(in_battle,true),
			Msg = login_pb:encode_battle_join_c2s(#battle_join_c2s{type = ?TANGLE_BATTLE}),			
			sendtoserver(self(), Msg)
	end,
	{next_state, StateName, State};	

handle_info(Info, StateName,State) ->
	{next_state, StateName, State}.

handle_server_message(#other_role_move_s2c{})->	
	nothing;

handle_server_message(IgnorMessage)->
	io:format("IgnorMessage ~p~n",[IgnorMessage]).
	
send_quest_compelete()->
	todo.
	
move_to_target(NpcId)->
	todo.	
		
change_my_aoi(NewCommers,Deletes)->
	lists:foreach(fun(#o{objectid = Objectid,objecttype = _Type,attrs = _Attrs})->
						put(aoi_list,lists:keydelete(Objectid,1,get(aoi_list)))
				 end,Deletes),
	Npcs = lists:foldl(fun(#o{objectid = Objectid,objecttype = Type,attrs = Attrs}, NpcTmps)->
					{_,_,X} = lists:keyfind(?ROLE_ATTR_POSX,2,Attrs),
					{_,_,Y} = lists:keyfind(?ROLE_ATTR_POSY,2,Attrs),
					case lists:keyfind(?ROLE_ATTR_CREATURE_FLAG,2,Attrs) of
						false->
							NpcTmps;
						{_,_,CreatureType} ->	
							put(aoi_list,[ {Objectid,CreatureType,{X,Y}}| get(aoi_list)]),
							if
								(Type =:= ?UPDATETYPE_NPC) and(CreatureType =:= ?CREATURE_NPC)->											
									[ Objectid|NpcTmps ];							
								true->
									NpcTmps
							end
					end		
			end,[],NewCommers),
	if
		Npcs =/= []->
			send_query_npc_state(Npcs);
		true->
			nothing
	end. 
	
range_alert()->
	case get(map_id) of 
		101->
			nothing;
		_->
			MonsterAoi = lists:filter(fun({_,TypeTmp,_})->
					TypeTmp =:= ?CREATURE_MONSTER
				end,get(aoi_list)),
			Length = erlang:length(MonsterAoi),	
			if
				Length > 0-> 	
					Nth = random:uniform(Length),	
					{Objectid1,_,Pos1} = lists:nth(Nth,MonsterAoi),
					case get(target) of
						0->
							put(target,Objectid1),
							put(next_action,{attack,Objectid1,Pos1});
						_->
							nothing
					end;
				true->
					nothing
			end,
			%%
			%%战场中target可能是玩家
			%%
			case ( (get(target) =:= 0) and get(in_battle) ) of
				true->
					RoleAoi = lists:filter(fun({_,TypeTmp,_})->
						TypeTmp =:= ?UPDATETYPE_ROLE
					end,get(aoi_list)),
					Length1 = erlang:length(RoleAoi),	
					if
						Length1 > 0-> 	
							Nth1 = random:uniform(Length1),	
							{Objectid2,_,Pos2} = lists:nth(Nth1,RoleAoi),
							case get(target) of
								0->
									put(target,Objectid2),
									put(next_action,{attack,Objectid2,Pos2});
								_->
									nothing
							end;
						true->
							nothing
					end;
				_->
					nothing
			end					
	end,
				
	case get(target) of
		0->				%%没有敌人,继续跑
			case get(path) of
				[]->
					start_random_move();
				Path->
					move_request(Path)
			end;
		_->
			case get(next_action) of
				{attack,_Objectid,Pos}->
					start_move(Pos);
				_->
					put(target,0)
			end															
	end.	
	
send_query_npc_state(NpcIds)->
	Message = login_pb:encode_questgiver_states_update_c2s(#questgiver_states_update_c2s{npcid = NpcIds}),
	sendtoserver(self(), Message).
	
send_create_role_request()->	
	Name = get(role_name),
	Gender = get(gender),
	Class = get(class),
	%%io:format("send_create_role_request Gender ~p Class ~p ~n",[Gender,Class]),
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
	sendtoserver(self(), Message ).

query_time_c2s()->
	Message2 = login_pb:encode_query_time_c2s(#query_time_c2s{}),
	sendtoserver(self(), Message2 ),
	put(target,0),
	put(aoi_list,[]).

change_line(TargetLine)->
	Message = login_pb:encode_role_change_line_c2s(#role_change_line_c2s{lineid = TargetLine}),
	sendtoserver(self(), Message).
	
	
start_random_move() ->
	put(next_action,random_move),
	put(target,0),
	{X,Y} = path:random_pos(get(mapid)),
	CurPos = get(pos),
	TmpPath = path:path_find(CurPos,{X,Y},get(mapid)),
%%	io:format("tmppath:~p~n,curpos:~p,X,Y:~p~n",[TmpPath,CurPos,{X,Y}]),
	if
		TmpPath =:= []->
			if
				CurPos =:={X,Y}->
					start_random_move();
				true->
				%%	io:format("start_random_move curpos:~p,targetpos:~p~n",[CurPos,{X,Y}]),
					{NX,NY} = path:random_pos(get(mapid)),
					put(pos,{NX,NY}),
					gm_move(get(mapid),NX,NY)
			end;			
		true->
			Path = lists:map(fun({TmpX,TmpY})-> #c{x=TmpX, y=TmpY} end,TmpPath),
 			put(path,Path),
			move_request(Path)
	end.		
	
start_move(Pos) ->
	CurPos = get(pos),
 	FindPath = path:path_find(CurPos,Pos,get(mapid)),
	if
		FindPath =:= []->
			if
				Pos =:= CurPos->
					%%io:format("start_move curpos:~p,targetpos:~p~n",[CurPos,Pos]),
					util:send_state_event(self(), {move_heartbeat,[]});
				true->
					io:format("start_move curpos:~p,targetpos:~p~n",[CurPos,Pos]),
					start_random_move()
			end;
		true->
			Path1 = lists:map(fun({TmpX,TmpY})-> #c{x=TmpX, y=TmpY} end,FindPath),
			put(path,Path1),
			move_request(Path1)
	end.

move_request(Path)->		
	{ReqList,RemList} = lists:split(erlang:min(?MOVE_NUM,erlang:length(Path)),Path),
	put(path,RemList),
	if
		Path =/= []->				
			[NextPos|_RePath] =  ReqList,		
			{_,X,Y} = NextPos,
			{NowX,NowY} = get(pos),
			put(pos,{X,Y}),
			%%io:format("role_move_c2s ~p ~n",[get_now_time()]),					
			Message = login_pb:encode_role_move_c2s(#role_move_c2s{time = get_now_time(),posx = NowX,posy = NowY,path=ReqList}),
			sendtoserver(self(), Message);
		true->
			nothing
	end,
	util:send_state_event(self(), {move_heartbeat,ReqList}).		

get_now_time()->
	{Now,ServerTime } = get(server_time),
	trunc(timer:now_diff(now(),Now)/1000) +ServerTime.

com_quest(2010001)->
	%%io:format("com_quest 2010001~n"),
	Message = login_pb:encode_questgiver_complete_quest_c2s(#questgiver_complete_quest_c2s{npcid = 2010001,questid = 31401000,choiceslot = 0}),
	sendtoserver(self(), Message).

start_attack(CreatureId) ->
	util:send_state_event(self(), {attack_heartbeat,CreatureId}).

begin_auth(AccountName,UserId,ServerId)->
	SecretKey = "E3it45tiOjLi&fie8Hje56uMu67h",
	{MegaSecs, Secs, _MicroSecs} = now(),
	TimeSeconds = Secs+MegaSecs*1000000,
	Time = integer_to_list(TimeSeconds),
	BinName = case is_binary(AccountName) of
			  	  true-> AccountName;
				   _-> list_to_binary(AccountName)
			  end,
	NameEcode = auth_util:escape_uri(BinName),
	ValStr = UserId
					 ++ NameEcode ++ Time
					 ++ SecretKey ++ "1",
	MD5Bin = erlang:md5(ValStr),
	Md5Str = auth_util:binary_to_hexstring(MD5Bin),
	AuthTerm = #user_auth_c2s{username=UserId,
				serverId = ServerId,time = Time,sign = ValStr},
	Binary = login_pb:encode_user_auth_c2s(AuthTerm),
	sendtoserver(self(), Binary).

gm_move(MapId,X,Y)->
	Msg = ".zymove "++erlang:integer_to_list(MapId)++" "++erlang:integer_to_list(X)++" "++erlang:integer_to_list(Y),
	Message =  login_pb:encode_chat_c2s(#chat_c2s{type = ?CHAT_TYPE_INTHEVIEW, desrolename = 0, msginfo = Msg, details=0}),
	sendtoserver(self(), Message).

gm_levelup(Level)->
	Msg = ".zylevelup "++erlang:integer_to_list(Level),
	Message =  login_pb:encode_chat_c2s(#chat_c2s{type = ?CHAT_TYPE_INTHEVIEW, desrolename = 0, msginfo = Msg, details=0}),
	sendtoserver(self(), Message).

gm_moneychange(Money)->
	Msg = ".zymoney "++erlang:integer_to_list(Money),
	Message =  login_pb:encode_chat_c2s(#chat_c2s{type = ?CHAT_TYPE_INTHEVIEW, desrolename = 0, msginfo = Msg, details=0}),
	sendtoserver(self(), Message).

gm_goldchange(Gold)->
	Msg = ".zygold "++erlang:integer_to_list(Gold),
	Message =  login_pb:encode_chat_c2s(#chat_c2s{type = ?CHAT_TYPE_INTHEVIEW, desrolename = 0, msginfo = Msg, details=0}),
	sendtoserver(self(), Message).

%%获得物品
gm_getitem(ItemId)->
	Msg = ".zyitem "++erlang:integer_to_list(ItemId),
	Message =  login_pb:encode_chat_c2s(#chat_c2s{type = ?CHAT_TYPE_INTHEVIEW, desrolename = 0, msginfo = Msg, details=0}),
	sendtoserver(self(), Message).

%%喊话
speek_to_world()->
	Level = get(level),
	if 
		Level =< 10->
			Type = ?CHAT_TYPE_INTHEVIEW;
		true->
			Type = ?CHAT_TYPE_WORLD
	end,
	Msg = "我是"++ get(role_name)++" ++好友 ",
	Message =  login_pb:encode_chat_c2s(#chat_c2s{type = Type , desrolename = 0, msginfo = Msg, details=0}),
	sendtoserver(self(), Message).


my_respawn()->
	Msg = ".zyitem 14000020",
	Message =  login_pb:encode_chat_c2s(#chat_c2s{type = ?CHAT_TYPE_INTHEVIEW, desrolename = 0, msginfo = Msg, details=0}),
	sendtoserver(self(), Message),
	Msg1 = login_pb:encode_role_respawn_c2s(#role_respawn_c2s{type = 2}),			
	sendtoserver(self(), Msg1).

%%学习技能
learn_skill([])->
	nothing;
learn_skill([Skillid|ReMainSkill])->
	Message = login_pb:encode_skill_learn_item_c2s(#skill_learn_item_c2s{skillid = Skillid}),
	sendtoserver(self(), Message),
	learn_skill(ReMainSkill).

%%清理背包
clear_package()->
	destroy_item(?PACKAGE_INDEX+1,?ITEMNUM).
destroy_item(_PackageSlot,0)->
	nothing;
destroy_item(PackageSlot,ItemNum)->
	Message = login_pb:encode_destroy_item_c2s(#destroy_item_c2s{slot = PackageSlot}),
	sendtoserver(self(), Message),
	destroy_item(PackageSlot+1,ItemNum-1).

	

%% --------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% --------------------------------------------------------------------
terminate(Reason, _StateName, _StatData) ->
	io:format("process terminate Reason ~p~n",[Reason]),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% --------------------------------------------------------------------
code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}.	
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理其他事件
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_event(Event, StateName, StateData) ->
	{next_state, StateName, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 处理同步事件调用
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_sync_event(Event, From, StateName, StateData) ->
	Reply = ok,
	{reply, Reply, StateName, StateData}.		
		
		

