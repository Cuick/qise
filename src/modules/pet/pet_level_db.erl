%% Author: zhang
%% Created: 2011-1-25
%% Description: TODO: Add description to pet_level_db
-module(pet_level_db).
%%
%% Include files
%%
-include("pet_def.hrl").
-define(PET_LEVEL_ETS,pet_level_ets).
-define(PET_HOSTEL_ETS,pet_hostel_ets).
-define(PET_ROOM_PRICE_ETS,pet_room_price_ets).
%%
%% Exported Functions
%%
-compile(export_all).
-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).
-export([init/0,create/0]).
-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(pet_level,record_info(fields,pet_level),[],set),
	db_tools:create_table_disc(room,record_info(fields,room),[],set),
	db_tools:create_table_disc(room_price,record_info(fields,room_price),[],set).

create_mnesia_split_table(_,_)->
	nothing.

tables_info()->
	[{pet_level,proto},{room,proto},{room_price,proto}].

delete_role_from_db(RoleId)->
	nothing.

create()->
	ets:new(?PET_LEVEL_ETS,[ordered_set,named_table]),
	ets:new(?PET_HOSTEL_ETS,[set,named_table]),
	ets:new(?PET_ROOM_PRICE_ETS,[set,named_table]).

init()->
	ets:delete_all_objects(?PET_LEVEL_ETS),
	ets:delete_all_objects(?PET_HOSTEL_ETS),
	ets:delete_all_objects(?PET_ROOM_PRICE_ETS),
	init_pet_open_room(),
	init_pet_level(),
	init_pet_room().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init_pet_level()->
	case dal:read_rpc(pet_level) of
		{ok,Pet_Levels}->
			Pet_Levels2 = lists:reverse(lists:keysort(#pet_level.level, Pet_Levels)),
			lists:foreach(fun(Term)-> add_pet_level_to_ets(Term) end, Pet_Levels2);
		_-> slogger:msg("init_pet_level failed~n")
	end.


init_pet_room() ->
	case dal:read_rpc(room) of
		{ok,Pet_Rooms}->
			lists:foreach(fun(Term)-> add_pet_room_to_ets(Term) end, Pet_Rooms);
		_-> slogger:msg("init_pet_room failed~n")
	end.


init_pet_open_room() ->
	case dal:read_rpc(room_price) of
		{ok,Room_prices}->
			lists:foreach(fun(Term)-> add_room_price_to_ets(Term) end, Room_prices);
		_-> slogger:msg("init_open_room failed~n")
	end.

add_pet_level_to_ets(Term)->
	try
		Id = erlang:element(#pet_level.level, Term),
 		ets:insert(?PET_LEVEL_ETS,{Id,Term})	
	catch
		_Error:Reason-> {error,Reason}
	end.

add_pet_room_to_ets(Term)->
	try
		Id = erlang:element(#room.room_standard, Term),
 		ets:insert(?PET_HOSTEL_ETS,{Id,Term})	
	catch
		_Error:Reason-> {error,Reason}
	end.

add_room_price_to_ets(Term)->
	try
		Id = erlang:element(#room_price.id, Term),
 		ets:insert(?PET_ROOM_PRICE_ETS,{Id,Term})	
	catch
		_Error:Reason-> {error,Reason}
	end.
%% 
%% get_info()
%% []
%% {...}
%%[error,....]
%%
get_info(Level)->
	try
		case ets:lookup(?PET_LEVEL_ETS,Level) of
			[]->[];
			[{_Level,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Pet level!"]
	end.
get_room_info(Room)->
	try
		case ets:lookup(?PET_HOSTEL_ETS,Room) of
			[]->#room{room_standard = {0,0},need_gold = 40,gain_exp = 18888};
			% [] -> [];
			[{_Room,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Pet room!"]
	end.

get_price_room_info(Room_id)->
	try
		case ets:lookup(?PET_ROOM_PRICE_ETS,Room_id) of
			[]->[];
			[{_Room_id,Value}] -> Value
		end
	catch
		_:_-> [error,"No this Pet room!"]
	end.
%%	 return : Value | []
%%
get_duration(Room_prices)->
	element(#room_price.duration,Room_prices).

get_choosetime(Room_prices)->
	element(#room_price.choosetime,Room_prices).


get_open_need_gold(Room_prices)->
	element(#room_price.need_gold,Room_prices).



get_add_exp(Room)->
	element(#room.gain_exp,Room).


get_exp_need_gold(Room)->
	element(#room.need_gold,Room).


get_level_and_exp(AllExp)->
	ets:foldr(fun({Level,Info},{LevelTmp,ExpTmp})->
					Exp = get_exp(Info),
			 		if 
						LevelTmp=/=0->
							{LevelTmp,ExpTmp};
						AllExp >= Exp->
							{Level ,AllExp - Exp};
						true->
							{0,0}
					end
			 end, {0,0}, ?PET_LEVEL_ETS).

get_exp(PetLevelInfo)->
	element(#pet_level.exp,PetLevelInfo).
%%
%%	 return : Value | []
%%
get_maxmp(PetLevelInfo)->
	element(#pet_level.maxhp,PetLevelInfo).
%%
%%	 return : Value | []
%%
get_sysaddattr(PetLevelInfo)->
	element(#pet_level.sysaddattr,PetLevelInfo).

