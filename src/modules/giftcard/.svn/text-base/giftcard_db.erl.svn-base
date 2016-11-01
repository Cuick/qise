%% Author: adrianx
%% Created: 2011-4-8
%% Description: TODO: Add description to giftcard_db
-module(giftcard_db).

%%
%% Include files
%%
-include("giftcard_def.hrl").
%%
%% Exported Functions
%%
-export([import/1,make_card1/3,make_card2/3]).
-export([get_role_status/2,get_card_status/2,write_card_status/2,write_data/3,add_giftcard_by_gm/1]).
-export([add_giftcard_to_mnesia/1]).


-export([start/0,create_mnesia_table/1,create_mnesia_split_table/2,delete_role_from_db/1,tables_info/0]).

-behaviour(db_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(giftcards, record_info(fields,giftcards), [roleid], set),
	db_tools:create_table_disc(giftcards2, record_info(fields,giftcards2), [roleid], set).

create_mnesia_split_table(_,_)->
	nothing.

delete_role_from_db(_)->
	nothing.

tables_info()->
	[{giftcards,disc}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
%% Local Functions
%%

import(File)->
	dal:clear_table(giftcards2),
	case file:consult(File) of
		{ok, Terms} ->
			add_giftcard_to_mnesia(Terms);
		{error, Reason} ->
			slogger:msg("import giftcards error:~p~n",[Reason])
	end.
	
add_giftcard_to_mnesia(Terms)->
	MnesiaObjcts = lists:map(fun({Term})->
						{giftcards2,Term,Term} end, Terms),
	list_util:foreach_step(300,fun(L)->write_table_data(L) end,MnesiaObjcts).



add_giftcard_by_gm(Terms)->
	MnesiaObjcts = lists:map(fun(Term)->
						{giftcards2,Term,Term} end, Terms),
	list_util:foreach_step(300,fun(L)->write_table_data(L) end,MnesiaObjcts).

  
write_table_data(L)->
	lists:foreach(fun(X)-> dal:write_rpc(X) end, L).

get_role_status(RoleId, 1)->
	case dal:read_index_rpc(giftcards, RoleId, #giftcards.roleid) of
		{ok,[]}->
			false; %% have not got
		{ok,[_]}->
			true; %%have got gift
		_->exception
	end;
get_role_status(RoleId, 2)->
	case dal:read_index_rpc(giftcards2, RoleId, #giftcards.roleid) of
		{ok,[]}->
			false; %% have not got
		{ok,[_]}->
			true; %%have got gift
		_->exception
	end.

get_card_status(Card, 1)->
	try 
		case dal:read_rpc(giftcards, Card) of
			{ok,[]}->
				case check_auto_card_process(Card) of 
					true->
						havenotgot;
					false->
						nocard
				end;
			_->exception
		end
	catch
		_E:R->
			slogger:msg("giftcard_db get_card_status error,reason:~p~n",[R]),
			nocard
	end;
get_card_status(Card, 2)->
	try 
		case dal:read_rpc(giftcards2, Card) of
			{ok,[{_,Card,RoleId}]}->
				if
					is_list(RoleId)->
						havenotgot;
					true->
						havegot
				end;
			_->exception
		end
	catch
		_E:R->
			slogger:msg("giftcard_db get_card_status error,reason:~p~n",[R]),
			nocard
	end.

% check_auto_card_process(Card)->
% 	slogger:msg("card:~p~n",[Card]),
% 	ServerId = server_travels_util:get_serverid_by_roleid(get(roleid)),
% 	slogger:msg("giftcard,serverid:~p~n",[ServerId]),
% 	BaseServerId = env:get(baseserverid,0),
%  	GiftCardKey = env:get(gift_card_key,[]),
% 	ServerNum = ServerId-BaseServerId,
% 	Account = get(account_id),
% 	PlatForm = env:get(platform,[]),
% 	Md5Str1 = make_card1(Account,ServerNum,GiftCardKey),
% 	Md5Str2 = make_card2(PlatForm,ServerNum,Account),
% 	Md5Str3 = make_card_baidu(Account,ServerNum),
% 	Ret = (check_card(Md5Str1,Card)) or (check_card(Md5Str2, Card)) or (check_card(Md5Str3,Card)),
% 	Ret.
check_auto_card_process(Card)->
	slogger:msg("card:~p~n",[Card]),
	ServerId = travel_battle_util:get_serverid_by_roleid(get(roleid)),
	Account = get(account_id),
	Md5Str1 = make_card(Account,ServerId),
	Ret = (check_card(Md5Str1,Card)),
	Ret.

check_card(Md5Str,KeyStr)->
	 TmpAuthStr = string:to_upper(KeyStr),
	 HalfMd5 = string:sub_string(Md5Str,1,trunc(string:len(Md5Str)/2)),
	 Ret = string:equal(TmpAuthStr, HalfMd5),
	if
		Ret->
			true;
		true->
			false
	end.
make_card(Account,ServerId)->
	ValStr = Account++"_"++env:get2(platform_key, get(pf), []),
	MD5Bin = erlang:md5(ValStr),
	Md5Str = auth_util:binary_to_hexstring(MD5Bin),
	% slogger:msg("s1_guoqites_s1:~p,url:~p,Md5Str:~p~n",[["s1_guoqites_s1"=:=ValStr],http_uri:encode(ValStr),Md5Str]),
	Md5Str.

make_card1(Account,ServerNum,GiftCardKey)->
	BinName = case is_binary(Account) of
						  true-> Account;
						  _-> list_to_binary(Account)
					  end,
	NameEcode = auth_util:escape_uri(BinName),
	ValStr = NameEcode++"S"++integer_to_list(ServerNum)++GiftCardKey,
	MD5Bin = erlang:md5(ValStr),
	Md5Str = auth_util:binary_to_hexstring(MD5Bin),
	Md5Str.

make_card2(PlatForm,ServerNum,Account)->
%% 	slogger:msg("platform:~p,servernum:~p,account:~p~n",[PlatForm,ServerNum,Account]),
	BinName = case is_binary(Account) of
						  true-> Account;
						  _-> list_to_binary(Account)
					  end,
	NameEcode = auth_util:escape_uri(BinName),
%% 	slogger:msg("NameEcode:~p~n",[NameEcode]),
	ValStr = atom_to_list(PlatForm)++NameEcode++integer_to_list(ServerNum)++"card_ooiui%^2IPlKm",
%% 	slogger:msg("ValStr:~p~n",[ValStr]),
	MD5Bin = erlang:md5(ValStr),
	Md5Str = auth_util:binary_to_hexstring(MD5Bin),
	Md5Str.
	
make_card_baidu(Account,ServerNum)->
	BinName = case is_binary(Account) of
						  true-> Account;
						  _-> list_to_binary(Account)
					  end,
	NameEcode = auth_util:escape_uri(BinName),
	ValStr = NameEcode++"_"++integer_to_list(ServerNum),
	MD5Bin = erlang:md5(ValStr),
	Md5Str = auth_util:binary_to_hexstring(MD5Bin),
	Md5Str.
	


write_card_status(RoleId,Card)->
	case dal:write_rpc(giftcards, Card, #giftcards.roleid, RoleId) of
		{ok}-> ok;
		{failed,Reason}->slogger:msg("Write card failed :~p ~n", [Reason]),havegot;
		_-> exception
	end.


write_data(Card,RoleId, 1)->
	case dal:write_rpc({giftcards,Card,RoleId}) of
		{failed,_Reason}->
			failed;
		{ok}->
			ok
	end;
write_data(Card,RoleId, 2)->
	case dal:write_rpc({giftcards2,Card,RoleId}) of
		{failed,_Reason}->
			failed;
		{ok}->
			ok
	end.