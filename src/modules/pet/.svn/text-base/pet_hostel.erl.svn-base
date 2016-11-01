
-module(pet_hostel).

-compile(export_all).
-export([init_put/0,put_room_info/1,open_vip_room/1]).

-include("pet_def.hrl").
-include("pet_struct.hrl").
-include("mnesia_table_def.hrl").
-include("error_msg.hrl").
-include("role_struct.hrl").

% -include("pet_define.hrl").
-define(ROOM_TIME_COMMOM, 2).
-define(ROOM_TIME_HUMAN, 4).
-define(ROOM_TIME_GROUND, 6).
-define(ROOM_TIME_GOD, 8).
-define(ROOM_TIME_VIP_WEEK, 8).
-define(ROOM_TIME_VIP_MOON, 12).
-define(ROOM_TIME_VIP_YEAR, 24).

-define(ROOM_GOLD_HUMAN, {2,188}).
-define(ROOM_GOLD_GROUND, {2,388}).
-define(ROOM_GOLD_GOD, {2,588}).

-define(COMMOM_ROOM, 1).
-define(VIP_ROOM, [5,6,7]).
-define(MAKE_TIME, 1000000*60*20).
-define(MAKE_DAY, 1000000*60*60*24).



% 宠物到期，去结算 17000 
% 你没有这个宠物 17001
% 这个房间还没有开启 17002
% 你不能在这个房间住这么长时间 17003
% 宠物在别的房间休息	17004
% 屋子里面有人了	17005

% 钱不够	17006
% 房间已经被打开了	17007
% 你不是Vip，不能开这个房间 17008
% 房间里面没人  17009
% 这个宠物不存在	17010

init_put() ->
	put(active_room,[]),
	put(pet_hostel,[]).

put_room_info(Acctiveroom0) ->
	case Acctiveroom0 of
		[] ->
			todo;
		[Acctiveroom] ->
			#pet_room{start_time = Start_time,duration = Duration} = Acctiveroom,
			Diff = timer:now_diff(now(),Start_time),
			Used_time = trunc(Diff/(?MAKE_TIME)),
			if
				Used_time >=  Duration->
					send_to_client(17000);
				true ->
					no
			end,
			put(active_room,[Acctiveroom|get(active_room)]);
		#pet_room{start_time = Start_time,duration = Duration} = Acctiveroom ->
			Diff = timer:now_diff(now(),Start_time),
			Used_time = trunc(Diff/(?MAKE_TIME)),
			if
				Used_time >=  Duration->
					send_to_client(17000);
				true ->
					no
			end,
			put(active_room,[Acctiveroom|get(active_room)]);
		_ ->
			nothing
	end,
	Hostel_info = pet_hostel_db:get_role_hostel_info(get(roleid)),
	Petroom = pet_hostel_db:get_role_room(Hostel_info),
	NewPetroom = check_room(Petroom),
	put(pet_hostel,NewPetroom),
	open_vip_room(NewPetroom).

get_pet_room(PetId) ->
	Pet_hostel = get(active_room),
	lists:filter(fun(Petroom) ->
		PetId =:= Petroom#pet_room.pet_id	
	end,Pet_hostel).

pet_in_room(RoomId,PetId,Duration0) ->
	Duration = Duration0*3,
	case check_pet_room(RoomId,PetId,Duration0) of
		{error,ErrorCode} ->
			send_to_client(ErrorCode);
		true ->
			Active_room = creature_active_room(PetId,RoomId,now(),Duration),
			put(active_room,[Active_room|get(active_room)]),
			StartTime = Duration0*60*60,
			PetsMsg =pet_packet:encode_pet_into_room_s2c(RoomId,PetId,StartTime),
			role_op:send_data_to_gate(PetsMsg)
	end.

check_pet_room(RoomId,PetId,Time) ->
	case Time =< 0 of
		false ->
			case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
				false->
					% slogger:msg("pet_rename error PetId ~p Roleid ~p ~n",[PetId,get(roleid)]),{room_price,2,{2,188},4,30}
					{error,17001};
				_ ->
					case pet_op:is_out_pet(PetId) of
						true ->
							{error,?ERROR_PET_NO_PACKAGE};
						false ->
							Active_room = get(active_room),
							case lists:keyfind(PetId,#pet_room.pet_id, Active_room) of
								false ->
									case lists:keyfind(RoomId,#pet_room.room_id, Active_room) of
										false ->
											OpenRooms = get(pet_hostel),
											Rooms = [Room||{Room,Time0} = Openroom<-OpenRooms],
											% slogger:msg("adsafdfsdafsd:~p~n,pet:~p~n",[Rooms,RoomId]),
											case lists:keyfind(RoomId,#room_price.id,Rooms) of
												false ->
													{error,17002};
												[OpenRoom] ->
													Thoosetime = OpenRoom#room_price.choosetime,
													if
														Time >  Thoosetime->
															{error,17003};
														true ->
															true
													end;
												OpenRoom ->
													Thoosetime = OpenRoom#room_price.choosetime,
													if
														Time >  Thoosetime->
															{error,17003};
														true ->
															true
													end
											end;
										_ ->
											{error,17004}
									end;
								_ ->
									{error,17005}
							end
					end
			end;
		_ ->
		{error,17003}
	end.
send_pet_room_data() ->
	SendPets = lists:map(fun(Active_room)->	
		pet_packet:make_rooom(Active_room) 
		end, get(active_room)),
	PetsMsg =pet_packet:encode_pet_room_s2c(SendPets),
	role_op:send_data_to_gate(PetsMsg).

send_opend_room_data() ->
	Opendrooms = get(pet_hostel),
	% slogger:msg("33333333333333333333~p~n",[Opendrooms]),
	NewRooms = [RoomMsg||{RoomMsg,Time} = Room <- Opendrooms],
	RoomMsg = pet_packet:encode_pet_opend_room_s2c(NewRooms),
	role_op:send_data_to_gate(RoomMsg).
% get_room_id(Room) ->
% 	slogger:msg("33333333333333333333~p~n",[Room]),
% 	case Room of
% 		[]  ->
% 			[];
% 		_  ->
% 			Room
% 	end.
handle_balance(RoomId,PetId,Gold) ->
	Pet_hostel = get(active_room),

	% case lists:keyfind(RoomId,#pet_room.room_id,Pet_hostel) of
	% 	false ->
	% 		send_to_client(17009);
	% 	 #pet_room{pet_id = Pet_id, room_id =Room_id, start_time = Start_time, duration = Duration} = Petroom ->
	% 	 	Diff = timer:now_diff(now(),Start_time),
	% 		Used_time = trunc(Diff/(?MAKE_TIME)),
	% 		give_exp(RoomId,PetId,Used_time,Duration,Gold)
	% end.
	case lists:member(RoomId,?VIP_ROOM) of
		false ->
			case lists:keyfind(RoomId,#pet_room.room_id,Pet_hostel) of
				false ->
					send_to_client(17009);
				 #pet_room{pet_id = Pet_id, room_id =Room_id, start_time = Start_time, duration = Duration} = Petroom ->
				 	Diff = timer:now_diff(now(),Start_time),
					Used_time = trunc(Diff/(?MAKE_TIME)),
					give_exp(RoomId,PetId,Used_time,Duration,Gold)
			end;
		true ->
			lists:foreach(fun(VipRoomId)->
				case lists:keyfind(VipRoomId,#pet_room.room_id,Pet_hostel) of
					false ->
						nothing;
					 #pet_room{pet_id = Pet_id, room_id =Room_id, start_time = Start_time, duration = Duration} = Petroom ->
					 	Diff = timer:now_diff(now(),Start_time),
						Used_time = trunc(Diff/(?MAKE_TIME)),
						give_exp(VipRoomId,Pet_id,Used_time,Duration,Gold)
				end
			end,?VIP_ROOM)
	end. 
	% lists:foreach(fun(Petroom) ->
	% 	#pet_room{pet_id = Pet_id, room_id =Room_id, start_time = Start_time, duration = Duration} = Petroom,
	% 	if
	% 		PetId =:= Pet_id andalso RoomId =:= Room_id->
	% 			Diff = timer:now_diff(now(),Start_time),
	% 			Used_time = trunc(Diff/(?MAKE_TIME)),
	% 			give_exp(RoomId,PetId,Used_time,Duration,Gold);
	% 		true ->	
	% 			send_to_client(17009)
	% 	end	
	% end,Pet_hostel).

% min(M,N) ->
% 	if M > N -> N; true ->M end.

give_exp(RoomId,PetId,Used_time,Duration,Gold_flag) ->
	 case lists:keyfind(PetId,#gm_pet_info.id, get(gm_pets_info)) of
		false->
			send_to_client(17010);
		GmPetInfo->
			Level = get_level_from_petinfo(GmPetInfo),
			{Gold_time,Need_gold} = 
				if
					Used_time >= Duration ->
						{0,false};
					true ->
						{Duration - Used_time,true}
				end,
			case pet_level_db:get_room_info({RoomId,Level}) of
			 [] ->
					slogger:msg("error:can find room,~p,pet  level,~p.~n",[RoomId,Level]);
			 Room_info ->
			 	BaseExp = (pet_level_db:get_add_exp(Room_info))*Used_time,
			 	Exp = (pet_level_db:get_add_exp(Room_info))*Duration,
			 	Gold = (pet_level_db:get_exp_need_gold(Room_info))*Gold_time,

			 	do_give_exp(Need_gold,Gold,BaseExp,Exp,GmPetInfo,Gold_flag,RoomId,PetId)
			end
	end.

do_give_exp(Need_gold,Gold,BaseExp,Exp,GmPetInfo,Gold_flag,RoomId,PetId) ->
	if
		Need_gold ->
			case Gold_flag of
				0 ->
					RoleLeve = get_level_from_roleinfo(get(creature_info)),
					ToatlExp = get_totalexp_from_petinfo(GmPetInfo),
					{NewLevel,NewExp} =  pet_level_db:get_level_and_exp(ToatlExp+Exp),
					if
						NewLevel > RoleLeve->
							Tag = 1;
						true->
							Tag = 0
					end,
					GoldMsg = pet_packet:encode_gold_get_exp_s2c(RoomId,PetId,Gold,Tag),
					role_op:send_data_to_gate(GoldMsg);
				-1 ->
					give_exp_ok(GmPetInfo,BaseExp,RoomId);
				_ ->
					money_change(Gold,GmPetInfo,Exp,RoomId)
			end;	
		true ->
			% slogger:msg("bbbbbbbbbbbbbbbbbbbbbbbGmPetInfo:~p,Exp:~p~n",[GmPetInfo,Exp]),
			give_exp_ok(GmPetInfo,Exp,RoomId)
	end.

money_change(Gold,GmPetInfo,Exp,RoomId) ->
	case role_op:check_money(2, Gold) of
		true->
			case role_op:money_change(2, -Gold,pet_gold_speedup) of
				ok ->
					give_exp_ok(GmPetInfo,Exp,RoomId);
				 _ ->
					send_to_client(17006)
			end;
		false ->
			send_to_client(17006)
	end.
give_exp_ok(GmPetInfo,Exp,RoomId) ->
	Petid = get_id_from_petinfo(GmPetInfo),
	ActiveRoomList = get(active_room),
	NewRoom = lists:keydelete(Petid,#pet_room.pet_id,ActiveRoomList),
	put(active_room,NewRoom),
	pet_level_op:obt_exp_hostel(GmPetInfo,Exp),
	ExpMsg = pet_packet:encode_room_balance_s2c(RoomId,Petid),
	role_op:send_data_to_gate(ExpMsg).

creature_room(RoomId,Price,Times,Duration) ->
	#room_price{id = RoomId,need_gold = Price,choosetime = Times,duration = Duration}.
creature_active_room(Pet_id,Room_id,Start_time,Duration) ->
	#pet_room{pet_id = Pet_id,room_id = Room_id,start_time = Start_time,duration = Duration}.

balance(RoomId) ->
	Active_room = get(active_room),
	lists:foreach(fun(Petroom) ->
		#pet_room{pet_id = Pet_id, room_id =Room_id, start_time = Start_time, duration = Duration} = Petroom,
		if
			RoomId =:= Room_id->
				Diff = timer:now_diff(now(),Start_time),
				Used_time = trunc(Diff/(?MAKE_TIME)),
				Time = min(Used_time,Duration),
				give_exp(RoomId,Pet_id,Time,Time,0),
				NewRooms = lists:keydelete(Pet_id,#pet_room.pet_id,Active_room),
				put(active_room,NewRooms);
			true ->	
				do_no
		end	
	end,Active_room).
send_to_client(ErrCode) ->
	ErrorMsg = pet_packet:encode_pet_opt_error_s2c(ErrCode),
	role_op:send_data_to_gate(ErrorMsg).
open_room(RoomId) ->	
	OpenRoom = get(pet_hostel),
	case chacke_room(RoomId,OpenRoom) of
		{error,ErrorCode} ->
			send_to_client(ErrorCode);
		{true,Price} ->
			{MoneyType, CostMoney} = Price,
			MoneyChangeReason = atom_to_list(pet_hostel) ++ "|" ++ integer_to_list(RoomId),
			case role_op:money_change(MoneyType, -CostMoney,list_to_atom(MoneyChangeReason)) of
				ok ->
					RoomInfo = pet_level_db:get_price_room_info(RoomId),
					NewOpenRoom = lists:flatten(OpenRoom ++ [{RoomInfo,now()}]),
					put(pet_hostel,NewOpenRoom),
					pet_op:save_to_db(),
					PetsMsg =pet_packet:encode_pet_open_room_s2c([RoomInfo]),
					role_op:send_data_to_gate(PetsMsg);
				 _ ->
					send_to_client(?ERROR_LESS_GOLD)
			end;
		ok ->
			ok

	end.
	% pet_hostel_db:save_role_hostel_info(get(roleid),get(pet_hostel)).

chacke_room(RoomId,OpenRoom) ->
	Rooms = [Room||{Room,_Time}=Room0<-OpenRoom],
	case lists:keyfind(RoomId,#room_price.id,Rooms) of
		false  ->
			if  RoomId =:= ?COMMOM_ROOM ->
					RoomInfo = creature_room(RoomId,{2,0},?ROOM_TIME_COMMOM,0),
					NewRooms = lists:flatten(OpenRoom ++ [{RoomInfo,now()}]),
					put(pet_hostel,NewRooms),
					PetsMsg =pet_packet:encode_pet_open_room_s2c([RoomInfo]),
					role_op:send_data_to_gate(PetsMsg),
					ok;
				true ->
					Bool = lists:any(fun(N) -> N =:= RoomId end,?VIP_ROOM),
					case Bool of
						true ->
							open_vip_room(OpenRoom);
						_ ->
							if
								RoomId > 0 ->
									RoomInfo = pet_level_db:get_price_room_info(RoomId),
									{MoneyType, CostMoney} = pet_level_db:get_open_need_gold(RoomInfo),
									case role_op:check_money(MoneyType, CostMoney) of
										true->
										 	{true,{MoneyType, CostMoney}};
										false ->
											{error,17006}
									end;
								true ->
									{error, 17008}
							end
					end
				end;
		_ ->
			{error,17007}
	end.

open_vip_room(OpenRoom) ->
	case get(role_vip) of
		#vip_role{
				roleid = _RoleId,
				start_time = _StartTime,
				duration = _Duration,
				level = Level,
				logintime = _LoginTime
			} = VipRole ->
				% 346,
				RoomId = get_vip_room_id(Level),
				case RoomId < 0 of
					true ->
						{error,17008};
					_ ->
						Rooms = [Room||{Room,_Time}=Room0<-OpenRoom],
						case lists:keyfind(RoomId,#room_price.id,Rooms) of
							false ->
								RoomInfo = pet_level_db:get_price_room_info(RoomId),
								NewOpenRoom = lists:flatten(OpenRoom ++ [{RoomInfo,now()}]),
								put(pet_hostel,NewOpenRoom),
								PetsMsg =pet_packet:encode_pet_open_room_s2c([RoomInfo]),
								role_op:send_data_to_gate(PetsMsg),
								ok;
							_ ->
								{error,17007}	
						end
				end;
				
		_ ->
			{error,17008}
	end.
get_vip_room_id(VipLevel) ->
	case VipLevel of
		% 所有的VIP都改为用7号仙仆客栈房间
		% 4 ->
		% 	5;
		% 5 ->
		% 	6;
		% 6 ->
		% 	7;
		1 ->
			7;
		2 ->
			7;
		3 ->
			7;
		4 ->
			7;
		5 ->
			7;
		6 ->
			7;
		7 ->
			7;
		9 ->
			7;
		8 ->
			-5
	end.

delete_vip_room(VipLevel) ->
	RoomId = get_vip_room_id(VipLevel),
	balance(RoomId),
	OpenRoom = get(pet_hostel),
	case OpenRoom of
		[] ->
			body;
		_ ->
			NewRooms = lists:foldl(fun({Room_price,Time},Acc) ->
					if
						Room_price#room_price.id =:=  RoomId->
							Acc;
						true ->
							[{Room_price,Time}|Acc]
					end
				end,[],	OpenRoom),

			put(pet_hostel,NewRooms)
	end.

check_room(Petroom) ->
	case Petroom of
		[] ->
			[{creature_room(?COMMOM_ROOM,{2,0},?ROOM_TIME_COMMOM,0),{0,0,0}}];
		_ ->
			Bool = lists:any(fun({Room_price,_Start_time}) -> 
						Room_price#room_price.id =:= ?COMMOM_ROOM
					 end,Petroom),
			case Bool of
				true ->
					NewRooms = Petroom;
				false ->
					NewRooms = Petroom ++ [{creature_room(?COMMOM_ROOM,{2,0},?ROOM_TIME_COMMOM,0),{0,0,0}}]
			end,
			lists:foldl(fun({Room_price,Start_time},Acc) ->
				Duration = Room_price#room_price.duration,
				RoomId = Room_price#room_price.id,
				Diff = timer:now_diff(now(),Start_time),
				Used_time = trunc(Diff/(?MAKE_DAY)),
					if
						RoomId =:= ?COMMOM_ROOM ->
							[{Room_price,Start_time}|Acc];
						Duration <  Used_time->
							balance(RoomId),
							Acc;
						true ->
							[{Room_price,Start_time}|Acc]
					end
				end,[],	NewRooms)
	end.
add_common_room() ->
	Petroom = get(pet_hostel),
	NewPetroom = case lists:member(?COMMOM_ROOM,Petroom) of 
		true ->
			Petroom;
		false ->
			NewRooms = Petroom ++ [{creature_room(?COMMOM_ROOM,{2,0},?ROOM_TIME_COMMOM,0),{0,0,0}}]
	end,
	put(pet_hostel,NewPetroom),
	open_vip_room(NewPetroom),
	send_opend_room_data().

check_pet_in_room(PetId) ->
	Active_room = get(active_room),
	lists:foldl(fun(Petroom,Acc) ->
		#pet_room{pet_id = Pet_id} = Petroom,
		if
			PetId =:= Pet_id->
				false;
			true ->	
				Acc
		end	
	end,true,Active_room).
