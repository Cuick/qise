%% Author: MacX
%% Created: 2010-11-16
%% Description: TODO: Add description to friend_op
-module(friend_op).

%%
%% Include files
%%
-include("friend_struct_def.hrl").
-include("title_def.hrl").
%%
%% Exported Functions
%%
-compile(export_all).
-export([load_friend_from_db/1,load_black_from_db/1,load_signature_from_db/1,
		 export_for_copy/0,load_by_copy/1,write_to_db/0]).
-export([add_friend_for_inner/2,change_role_name/2,add_intimacy/2,friend_add_intimacy/2,
		 handle_friend_offline/3,handle_friend_online/3,offline_notice/0,send_flowers/2,
		 delete_friend_by_name/2,detail_friend_by_name/2,position_friend_by_name/2,
		 get_friend_list/1,send_friend_list/0,is_friend_id/1,send_black_list/0,send_signature/0,
		 add_signature_c2s/2,get_friend_signature_c2s/2,set_black_c2s/2,revert_black_c2s/2,delete_black_c2s/2,
		 make_friends/1,update_friend_status/3,handle_other_inspect_you/2,delete_friends/6,is_friend_bilateral/1,
		 delete_friend_directly/1]).

-export([get_signature/0]).

-include("data_struct.hrl").
-include("error_msg.hrl").
-include("role_struct.hrl").
-include("map_info_struct.hrl").
-include("wedding_def.hrl").
-include("item_define.hrl").

%%
%% API Functions
%%
init()->
	put(myfriends,[]).

blackinit()->
	put(myblacks,[]).
signature_init()->
	put(signature,[]).

get_signature()->
	get(signature).

change_role_name(RoleId,NewName)->
	friend_db:change_role_name_in_db(RoleId,NewName),
	%%todo online proc
	todo.

is_friend_id(RoleId)->
	lists:keymember(RoleId,1,get(myfriends)).
is_friend(RoleName) ->
	lists:keymember(RoleName,2,get(myfriends)).

is_friend_bilateral(RoleName) when is_binary(RoleName)->
	case lists:keyfind(RoleName, 2, get(myfriends)) of
		false ->
			false;
		{_,_,_,_,_,_,_,Status} ->
			Status =:= ?BILATERAL_FRIENDS
	end;

is_friend_bilateral(RoleId) when is_integer(RoleId)->
	case lists:keyfind(RoleId, 1, get(myfriends)) of
		false ->
			false;
		{_,_,_,_,_,_,_,Status} ->
			Status =:= ?BILATERAL_FRIENDS
	end;

is_friend_bilateral(_) ->
	false.

get_friend(RoleName) when is_binary(RoleName) ->
	lists:keyfind(RoleName, 2, get(myfriends));

get_friend(RoleId) when is_integer(RoleId) ->
	lists:keyfind(RoleId, 1, get(myfriends)).

get_black(RoleName)->
	lists:keyfind(RoleName, 2, get(myblacks)).

update_friend(Fid,Fname,Fline)->
	case lists:keyfind(Fid, 1, get(myfriends)) of
		false->
			nothing;
		{_,_,FClass,FGender,_,Fsign,Intimacy,Status}->
			put(myfriends,lists:keyreplace(Fid, 1, get(myfriends), {Fid,Fname,FClass,FGender,Fline,Fsign,Intimacy,Status}))
	end.
%% new func
send_friend_request(TargetName) ->
	case travel_battle_util:is_travel_battle_server() of
		false ->
			do_send_friend_request(TargetName);
		true ->
			Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_INVALID_OPERATION),
			role_op:send_data_to_gate(Msg)
	end.

do_send_friend_request(TargetName) ->
	TargetName2 = list_to_binary(TargetName),
	Error = case role_pos_util:where_is_role(TargetName2) of
		[] ->
			?ERROR_ROLE_OFFLINE;
		RolePos ->
			RoleInfo = get(creature_info),
			case can_add_friend(RoleInfo,TargetName2) of
				ok ->	
					MyName = get_name_from_roleinfo(RoleInfo),
					Msg = friend_packet:encode_add_friend_s2c(MyName),
					role_pos_util:send_to_clinet_by_pos(RolePos, Msg),
					[];
				{error, ErrNo} ->
					ErrNo
			end
	end,
	if
		Error =/= [] ->
		    Msg2 = friend_packet:encode_add_friend_respond_s2c(TargetName2,Error),
			role_op:send_data_to_gate(Msg2);
		true ->
			nothing
	end.

send_friend_responds(TargetName,Result)->
	TargetName2 = list_to_binary(TargetName),
	RoleInfo = get(creature_info),
	MyName = get_name_from_roleinfo(RoleInfo),
	case role_pos_util:where_is_role(TargetName2) of
		[] ->
			Msg = friend_packet:encode_add_friend_respond_s2c(TargetName2, ?ERROR_ROLE_OFFLINE),
			role_op:send_data_to_gate(Msg);
		RolePos ->
			TargetId = role_pos_db:get_role_id(RolePos),
			if
				Result =:= 1 ->
					do_add_friend(TargetId, TargetName2);
				true ->
					nothing
			end,
			Msg = friend_packet:encode_add_friend_respond_s2c(MyName, Result),
			role_pos_util:send_to_role_clinet(TargetId, Msg)
	end.

do_add_friend(TargetId, TargetName) ->
	RoleInfo = get(creature_info),
	case can_add_friend(RoleInfo,TargetName) of
		ok ->
			MyName = get_name_from_roleinfo(RoleInfo),
			case call_make_friends_with_me(TargetId, MyName) of
				ok ->
					add_friend_for_inner(RoleInfo, TargetName);
				{error, Error} ->
					Error
			end;
		{error, ErrNo} ->
			ErrNo
	end.

call_make_friends_with_me(TargetId, MyName) ->
	RoleRef = case creature_op:get_creature_info(TargetId) of
		undefined ->
			role_pos_util:get_role_pos(TargetId);
		RoleInfo ->
			get_pid_from_roleinfo(RoleInfo)
	end,
	try
		role_processor:make_friends(RoleRef, MyName)
	catch
		E : R ->
			slogger:msg("call_make_friends_with_me error ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
			{error, ?ERROR_UNKNOWN}
	end.

make_friends(FriendName) ->
	RoleInfo = get(creature_info),
	add_friend_for_inner(RoleInfo, FriendName),
	ok.

add_friend_for_inner(RoleInfo,Fname) when is_list(Fname)->
	add_friend_for_inner(RoleInfo,list_to_binary(Fname));
add_friend_for_inner(RoleInfo,Fname) when is_binary(Fname)->
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	MyRoleName = get_name_from_roleinfo(RoleInfo),
	case role_pos_util:where_is_role(Fname) of
		[] -> %%role offline
			?ERROR_FRIEND_OFFLINE;
		RolePos ->
			FriendId = role_pos_db:get_role_id(RolePos),
			FriendName = role_pos_db:get_role_rolename(RolePos),
			FriendLine = role_pos_db:get_role_lineid(RolePos),
			FriendNode = role_pos_db:get_role_mapnode(RolePos),
			OtherRoleInfo = role_manager:get_role_remoteinfo_by_node(FriendNode,FriendId),
			FriendClass = get_class_from_othernode_roleinfo(OtherRoleInfo),
			FriendGender = get_gender_from_othernode_roleinfo(OtherRoleInfo),
			insert(FriendId,FriendName,FriendClass,FriendGender,FriendLine,0,?BILATERAL_FRIENDS),
			FriendObject = #friend{owner=MyRoleId,fid=FriendId,fname=FriendName,finfo={FriendClass,FriendGender},intimacy=0,status=?BILATERAL_FRIENDS},
			friend_db:add_friend_to_mnesia(FriendObject),
			FriendInfo = util:term_to_record(lists:keyfind(FriendId, 1, get(myfriends)), fr),
			Message_success = friend_packet:encode_add_friend_success_s2c(FriendInfo),
			role_op:send_data_to_gate(Message_success),
			FriendLength = length(get(myfriends)),
			% case FriendLength of
			% 	5 ->
			% 		role_pos_util:send_to_role(get(roleid),{title_condition_change,?TITLE_TYPE_FRIEND, 5});
			% 	50 ->
			% 		role_pos_util:send_to_role(get(roleid),{title_condition_change,?TITLE_TYPE_FRIEND, 50});
			% 	_ ->
			% 		nothing
			% end,
			achieve_op:achieve_update({add_friend}, [0], FriendLength + 1),
			[]
	end.
can_add_friend(RoleInfo,Fname) ->
	MyRoleName = get_name_from_roleinfo(RoleInfo),
	IsOwn = MyRoleName =/= Fname,
	if IsOwn ->
		case get_black(Fname) of
			false ->
				case is_friend(Fname) of
					false ->
	   					ok;	%% to check length				
					true ->
						{error, ?ERROR_FRIEND_EXIST}
				end;
			_ ->
				{error, ?ERROR_FRIEND_EXIST} %%?ERROR_ISBLACK
		end;
	   true ->
		   {error, ?ERROR_FRIEND_MYSELF} 
	end.

add_signature_c2s(RoleInfo,Signature)->
	case length(Signature) >= 50 of
		true->
			slogger:msg("add_signature_c2s hack error Signature Length RoleId ~p ~n",get(roleid));
		_->
			MyRoleId = get_id_from_roleinfo(RoleInfo),
			insert_sign(Signature),
			SignatureToDB = #signature{roleid=MyRoleId,sign=Signature},
			friend_db:add_signature_to_mnesia(SignatureToDB),
			send_signature()
	end.

get_friend_signature_c2s(_RoleInfo,Fname)->
	case lists:keyfind(list_to_binary(Fname), 2, get(myfriends)) of
		false->
			Errno = ?ERROR_FRIEND_NOEXIST;
		{Fid,_,_,_,_,_,_,_} ->
			case friend_db:get_signature_by_roleid(Fid) of
				{ok,[]}->
					Errno = ?ERROR_FRIEND_NO_SIGNATURE;
				{ok,[#signature{sign=Signature}]}->
					Errno = [],
					Message_success = friend_packet:encode_get_friend_signature_s2c(Signature),
					role_op:send_data_to_gate(Message_success)
			end
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_add_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

set_black_c2s(RoleInfo,Name)->
	Name2 = list_to_binary(Name),
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	Errno = case length(get(myblacks))<100 of
		true->
			case is_friend(Name2) of
				true ->
					MyRoleId = get_id_from_roleinfo(RoleInfo),
					MyRoleName = get_name_from_roleinfo(RoleInfo),
					MyClass = get_class_from_roleinfo(RoleInfo),
					MyGender = get_gender_from_roleinfo(RoleInfo),
					{Fid,Fname,FClass,FGender,_,_,Intimacy,Status} = get_friend(Name2),
					NewStatus = if 
						Status =:= ?BILATERAL_FRIENDS ->
							?UNILATERAL_FRIEND;
						true ->
							?BILATERAL_BLACKS
					end,
					Result = case role_pos_util:where_is_role(Name2) of
						[] ->
							if
								Status =:= ?BILATERAL_FRIENDS ->
									DObject = #friend{owner=Fid, fid = MyRoleId, fname = MyRoleName, finfo = {MyClass, MyGender},
										intimacy = Intimacy, status = Status},
									friend_db:delete_friend_to_mnesia(DObject),
									AObject = DObject#friend{intimacy = 0, status = NewStatus},
									friend_db:add_friend_to_mnesia(AObject);
								true ->
									DObject = #black{owner=Fid, fid = MyRoleId, fname = MyRoleName, finfo = {MyClass, MyGender},
										status = Status},
									friend_db:delete_black_to_mnesia(DObject),
									AObject = DObject#black{status = NewStatus},
									friend_db:add_black_to_mnesia(AObject)
							end,
							ok;
						RolePos ->
							{Pid, Node} = role_pos_util:get_role_pos(Name2),
							RoleRef = case node() of
								Node ->
									Pid;
								_ ->
									{Pid, Node}
							end,
							try
								role_processor:update_friend_status(RoleRef, MyRoleName, Status, NewStatus)
							catch
								E : R ->
									slogger:msg("update_friend_status error ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
									{error, ?ERROR_UNKNOWN}
							end
					end,
					case Result of
						ok ->
							DeleteObject = #friend{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender},intimacy=Intimacy,status=Status},
							friend_db:delete_friend_to_mnesia(DeleteObject),
							remove(Fname),
							BlackObject = #black{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender},status=NewStatus},
							friend_db:add_black_to_mnesia(BlackObject),
							insert_black(Fid,Fname,FClass,FGender,NewStatus),
							Message_success = friend_packet:encode_set_black_s2c(Name2),
							role_op:send_data_to_gate(Message_success),
							[];
						{error, ErrNo2} ->
							ErrNo2
					end;
				false->
					?ERROR_FRIEND_NOEXIST
			end;
		_->
			slogger:msg("set_black_c2s too long RoleId ~p ~n",[MyRoleId]),
			?ERROR_BLACK_FULL
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_delete_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

update_friend_status(RoleName, Status, NewStatus) ->
	RoleInfo = get(creature_info),
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	case Status of
		?BILATERAL_FRIENDS ->
			{Fid,Fname,FClass,FGender,LineId,Sign,Intimacy,Status} = get_friend(RoleName),
			DObject = #friend{owner=MyRoleId, fid = Fid, fname = Fname, finfo = {FClass, FGender},
				intimacy = Intimacy, status = Status},
			friend_db:delete_friend_to_mnesia(DObject),
			AObject = DObject#friend{intimacy = 0, status = NewStatus},
			friend_db:add_friend_to_mnesia(AObject),
			remove(RoleName),
			insert(Fid,Fname,FClass,FGender,LineId,0,NewStatus);
		?UNILATERAL_FRIEND ->
			case NewStatus of
				?BILATERAL_BLACKS ->
					{Fid,Fname,FClass,FGender,Status} = get_black(RoleName),
					DObject = #black{owner=MyRoleId, fid = Fid, fname = Fname, finfo = {FClass, FGender},
						status = Status},
					friend_db:delete_black_to_mnesia(DObject),
					AObject = DObject#black{status = NewStatus},
					friend_db:add_black_to_mnesia(AObject),
					remove_black(RoleName),
					insert_black(Fid,Fname,FClass,FGender,NewStatus);
				?BILATERAL_FRIENDS ->
					{Fid,Fname,FClass,FGender,LineId,Sign,0,Status} = get_friend(RoleName),
					DObject = #friend{owner=MyRoleId, fid = Fid, fname = Fname, finfo = {FClass, FGender},
						intimacy = 0, status = Status},
					friend_db:delete_friend_to_mnesia(DObject),
					AObject = DObject#friend{status = NewStatus},
					friend_db:add_friend_to_mnesia(AObject),
					remove(RoleName),
					insert(Fid,Fname,FClass,FGender,LineId,0,NewStatus)
			end;
		?BILATERAL_BLACKS ->
			{Fid,Fname,FClass,FGender,Status} = get_black(RoleName),
			DObject = #black{owner=MyRoleId, fid = Fid, fname = Fname, finfo = {FClass, FGender},
				status = Status},
			friend_db:delete_black_to_mnesia(DObject),
			AObject = DObject#black{status = NewStatus},
			friend_db:add_black_to_mnesia(AObject),
			remove_black(RoleName),
			insert_black(Fid,Fname,FClass,FGender,NewStatus)
	end,
	ok.

revert_black_c2s(RoleInfo,Name)->
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	Name2 = list_to_binary(Name),
	Errno = case get_black(Name2) of
		false->
			?ERROR_BLACK_NOEXIST;
		{Fid,Fname,FClass,FGender,Status}->
			FriendLength = length(get(myfriends)),
			if FriendLength < 100 ->
				NewStatus = if 
					Status =:= ?BILATERAL_BLACKS ->
						?UNILATERAL_FRIEND;
					true ->
						?BILATERAL_FRIENDS
				end,
				MyRoleId = get_id_from_roleinfo(RoleInfo),
				MyRoleName = get_name_from_roleinfo(RoleInfo),
				MyClass = get_class_from_roleinfo(RoleInfo),
				MyGender = get_gender_from_roleinfo(RoleInfo),
				Result = case role_pos_util:where_is_role(Name2) of
					[] ->
						FriendLine = 0,
						if
							Status =:= ?BILATERAL_BLACKS ->
								DObject = #black{owner=Fid, fid = MyRoleId, fname = MyRoleName, finfo = {MyClass, MyGender},
									status = Status},
								friend_db:delete_black_to_mnesia(DObject),
								AObject = DObject#black{status = NewStatus},
								friend_db:add_black_to_mnesia(AObject);
							true ->
								DObject = #friend{owner=Fid, fid = MyRoleId, fname = MyRoleName, finfo = {MyClass, MyGender},
									intimacy = 0, status = Status},
								friend_db:delete_friend_to_mnesia(DObject),
								AObject = DObject#friend{status = NewStatus},
								friend_db:add_friend_to_mnesia(AObject)
						end,
						ok;
					RolePos ->
						FriendLine = role_pos_db:get_role_lineid(RolePos),
						{Pid, Node} = role_pos_util:get_role_pos(Name2),
						RoleRef = case node() of
							Node ->
								Pid;
							_ ->
								{Pid, Node}
						end,
						try
							role_processor:update_friend_status(RoleRef, MyRoleName, Status, NewStatus)
						catch
							E : R ->
								slogger:msg("update_friend_status error ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
								{error, ?ERROR_UNKNOWN}
						end
				end,
				case Result of
					ok ->
						DeleteObject = #black{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender},status=Status},
						friend_db:delete_black_to_mnesia(DeleteObject),
						remove_black(Fname),
						FriendObject = #friend{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender},intimacy=0,status=NewStatus},
						friend_db:add_friend_to_mnesia(FriendObject),
						insert(Fid,Fname,FClass,FGender,FriendLine,0,NewStatus),
						FriendInfo = util:term_to_record(lists:keyfind(Fid, 1, get(myfriends)), fr),
						Message_success = friend_packet:encode_revert_black_s2c(FriendInfo),
						role_op:send_data_to_gate(Message_success),
						[];
					{error, ErrNo2} ->
						ErrNo2
				end;
	   		true ->
		   		?ERROR_FRIEND_FULL
			end
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_add_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

delete_friend_by_name(RoleInfo,Name)->
	Name2 = list_to_binary(Name),
	ErrNo = case is_friend(Name2) of
		true ->
			MyRoleId = get_id_from_roleinfo(RoleInfo),
			MyRoleName = get_name_from_roleinfo(RoleInfo),
			MyClass = get_class_from_roleinfo(RoleInfo),
			MyGender = get_gender_from_roleinfo(RoleInfo),
			{Fid,Fname,FClass,FGender,_Fline,_,Intimacy,Status} = get_friend(Name2),
			Result = case role_pos_util:where_is_role(Name2) of
				[] ->
					AnotherDeleteObject = #friend{owner=Fid,fid=MyRoleId,fname=MyRoleName,finfo={MyClass,MyGender},intimacy=Intimacy,status=Status},
					friend_db:delete_friend_to_mnesia(AnotherDeleteObject),
					AnotherBlackObject = #black{owner=Fid,fid=MyRoleId,fname=MyRoleName,finfo={MyClass,MyGender},status=Status},
					friend_db:delete_black_to_mnesia(AnotherBlackObject),
					ok;
				RolePos ->
					{Pid, Node} = role_pos_util:get_role_pos(Name2),
					RoleRef = case node() of
						Node ->
							Pid;
						_ ->
							{Pid, Node}
					end,
					try
						role_processor:delete_friends(RoleRef, MyRoleId, MyRoleName, MyClass, MyGender, Intimacy, Status)
					catch
						E : R ->
							slogger:msg("delete_friends error ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
							{error, ?ERROR_UNKNOWN}
					end


			end,
			case Result of
				ok ->
					DeleteObject = #friend{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender},intimacy=Intimacy,status=Status},
					friend_db:delete_friend_to_mnesia(DeleteObject),
					remove(Fname),
					Msg = friend_packet:encode_delete_friend_success_s2c(Fname),
					role_op:send_data_to_gate(Msg),
					[];
				{error, ErrNo2} ->
					ErrNo2
			end;
		false ->
			?ERROR_FRIEND_NOEXIST
	end,
	if
		ErrNo =/= [] ->
			MsgFailed = friend_packet:encode_delete_friend_failed_s2c(ErrNo),
			role_op:send_data_to_gate(MsgFailed);
		true ->
			nothing
	end.

delete_friend_directly(RoleId) ->
	{Fid,Fname,FClass,FGender,_,_,Intimacy,Status} = get_friend(RoleId),
	DeleteObject = #friend{owner=get(roleid),fid=Fid,fname=Fname,finfo={FClass,FGender},intimacy=Intimacy,status=Status},
	friend_db:delete_friend_to_mnesia(DeleteObject),
	remove(Fname).

delete_friends(FId, FName, FClass, FGender, Intimacy, Status) ->
	RoleInfo = get(creature_info),
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	MyRoleName = get_name_from_roleinfo(RoleInfo),
	MyClass = get_class_from_roleinfo(RoleInfo),
	MyGender = get_gender_from_roleinfo(RoleInfo),
	case is_friend(FName) of
		true ->
			DeleteObject = #friend{owner=MyRoleId,fid=FId,fname=FName,finfo={FClass,FGender},intimacy=Intimacy,status=Status},
			friend_db:delete_friend_to_mnesia(DeleteObject),
			remove(FName),
			Msg = friend_packet:encode_delete_friend_success_s2c(FName),
			role_op:send_data_to_gate(Msg);
		false ->
			BlackObject = #black{owner=MyRoleId,fid=FId,fname=FName,finfo={FClass,FGender},status=Status},
			friend_db:delete_black_to_mnesia(BlackObject),
			remove_black(FName),
			Msg = friend_packet:encode_delete_black_s2c(FName),
			role_op:send_data_to_gate(Msg)
	end,
	ok.


delete_black_c2s(RoleInfo,Name)->	
	Name2 = list_to_binary(Name),
	ErrNo = case get_black(Name2) of
		{Fid,Fname,FClass,FGender,Status} ->
			MyRoleId = get_id_from_roleinfo(RoleInfo),
			MyRoleName = get_name_from_roleinfo(RoleInfo),
			MyClass = get_class_from_roleinfo(RoleInfo),
			MyGender = get_gender_from_roleinfo(RoleInfo),
			Result = case role_pos_util:where_is_role(Name2) of
				[] ->
					AnotherDeleteObject = #friend{owner=Fid,fid=MyRoleId,fname=MyRoleName,finfo={MyClass,MyGender},intimacy=0,status=Status},
					friend_db:delete_friend_to_mnesia(AnotherDeleteObject),
					AnotherBlackObject = #black{owner=Fid,fid=MyRoleId,fname=MyRoleName,finfo={MyClass,MyGender},status=Status},
					friend_db:delete_black_to_mnesia(AnotherBlackObject),
					ok;
				RolePos ->
					{Pid, Node} = role_pos_util:get_role_pos(Name2),
					RoleRef = case node() of
						Node ->
							Pid;
						_ ->
							{Pid, Node}
					end,
					try
						role_processor:delete_friends(RoleRef, MyRoleId, MyRoleName, MyClass, MyGender, 0, Status)
					catch
						E : R ->
							slogger:msg("delete_back error ~p:~p ~p ~n",[E,R,erlang:get_stacktrace()]),
							{error, ?ERROR_UNKNOWN}
					end


			end,
			case Result of
				ok ->
					DeleteObject = #black{owner=MyRoleId,fid=Fid,fname=Fname,finfo={FClass,FGender},status=Status},
					friend_db:delete_black_to_mnesia(DeleteObject),
					remove_black(Fname),
					Msg = friend_packet:encode_delete_black_s2c(Fname),
					role_op:send_data_to_gate(Msg),
					[];
				{error, ErrNo2} ->
					ErrNo2
			end;
		false ->
			?ERROR_BLACK_NOEXIST
	end,
	if
		ErrNo =/= [] ->
			MsgFailed = friend_packet:encode_delete_friend_failed_s2c(ErrNo),
			role_op:send_data_to_gate(MsgFailed);
		true ->
			nothing
	end.

detail_friend_by_name(RoleInfo,Name)->
	MyRoldId = get_id_from_roleinfo(RoleInfo),
	case is_friend(list_to_binary(Name)) of
		true ->
			{Fid,_,_,_,_,_,_} = get_friend(list_to_binary(Name)),
			case role_pos_util:where_is_role(Fid) of
			[]->%%role offline
				Errno = ?ERROR_FRIEND_OFFLINE;
			RolePos->
				FriendId = role_pos_db:get_role_id(RolePos),
				Errno=[],
				role_pos_util:send_to_role(FriendId,{other_friend_inspect_you,{MyRoldId,0}})
		 	end;
		false->
			Errno = ?ERROR_FRIEND_NOEXIST
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_detail_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

position_friend_by_name(RoleInfo,Name)->
	MyRoldId = get_id_from_roleinfo(RoleInfo),
	case is_friend(list_to_binary(Name)) of
		true ->
			{Fid,_,_,_,_,_,_} = get_friend(list_to_binary(Name)),
			case role_pos_util:where_is_role(Fid) of
			[]->%%role offline
				Errno = ?ERROR_FRIEND_OFFLINE;
			RolePos->
				Errno=[],
				role_pos_util:send_to_role_by_pos(RolePos,{other_friend_inspect_you,{MyRoldId,1}})
		 	end;
		false->
			Errno = ?ERROR_FRIEND_NOEXIST
	end,
	if 
		Errno =/= []->
			Message_failed = friend_packet:encode_detail_friend_failed_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

handle_friend_online(Fid,Fname,Fline)->
	update_friend(Fid,Fname,Fline),
	MessageOnline = friend_packet:encode_online_friend_s2c(Fname),
	role_op:send_data_to_gate(MessageOnline).

handle_friend_offline(Fid,Fname,Fline)->
	update_friend(Fid,Fname,Fline),
	MessageOffline = friend_packet:encode_offline_friend_s2c(Fname),
	role_op:send_data_to_gate(MessageOffline).

handle_other_inspect_you(RoldId,Ntype)->
	case Ntype of
		0->
			RoleInfo = get(creature_info),
			FName = get_name_from_roleinfo(RoleInfo),
			FLever = get_level_from_roleinfo(RoleInfo),
			FGender = get_gender_from_roleinfo(RoleInfo),
			FGuildName = get_guildname_from_roleinfo(RoleInfo),
			FJob = get_class_from_roleinfo(RoleInfo),
			DetailFriendInfo = {dfr,FName,FLever,FJob,FGuildName,FGender},
			Message = friend_packet:encode_detail_friend_s2c(DetailFriendInfo),	
			role_pos_util:send_to_role_clinet(RoldId,Message);
		1->
			RoleInfo = get(creature_info),
			MapInfo = get(map_info),
			Fline = get_lineid_from_mapinfo(MapInfo),
			Fmap = get_mapid_from_mapinfo(MapInfo),
			FName = get_name_from_roleinfo(RoleInfo),
			{PosX,PosY} = get_pos_from_roleinfo(RoleInfo),
			PositionFriendInfo = {pfr,FName,Fline,Fmap,PosX,PosY},
			Message = friend_packet:encode_position_friend_s2c(PositionFriendInfo),	
			role_pos_util:send_to_role_clinet(RoldId,Message);
		_->
			nothing
	end.

insert(RoleId,RoleName,RoleClass,RoleGender,LineId,Intimacy,Status) ->
	case friend_db:get_signature_by_roleid(RoleId) of
		{ok,[]}->
			Sign = "";
		{ok,[#signature{sign=Signature}]}->
			Sign = Signature
	end,
	case lists:keyfind(RoleId,1,get(myfriends)) of
		false->
			put(myfriends,get(myfriends)++[{RoleId,RoleName,RoleClass,RoleGender,LineId,Sign,Intimacy,Status}]);	
		_ ->
			nothing
	end.

insert_sign(Signature)->
	put(signature,Signature).

insert_black(RoleId,RoleName,RoleClass,RoleGender,Status)->
	case lists:keyfind(RoleId,1,get(myblacks)) of
		false->
			put(myblacks,get(myblacks)++[{RoleId,RoleName,RoleClass,RoleGender,Status}]);	
		_ ->
			nothing
	end.
	
remove(RoleName)->
	put(myfriends,lists:keydelete(RoleName,2,get(myfriends))).

remove_black(RoleName)->
	put(myblacks,lists:keydelete(RoleName,2,get(myblacks))).

load_friend_from_db(RoleId)->
	case friend_db:get_friend_by_type(0, RoleId) of
		{ok,[]}->
			init();
		{ok,FriendList}->
			CreatureInfo = get(creature_info),
			MyRoleId = get_id_from_roleinfo(CreatureInfo),
			MyRoleName = get_name_from_roleinfo(CreatureInfo),
			MyLineId = get_lineid_from_mapinfo(get(map_info)),
			FRole = fun({friend,_Owner,Fid,Fname,{Fclass,Fgender},Intimacy,Status},Acc) ->
						case friend_db:get_signature_by_roleid(Fid) of
							{ok,[]}->
								Sign = "";
							{ok,[#signature{sign=Signature}]}->
								Sign = Signature
						end,
						case role_pos_util:where_is_role(Fid) of
							[]->
								Acc ++ [{Fid,Fname,Fclass,Fgender,0,Sign,Intimacy,Status}];
							RolePos->
								LineId = role_pos_db:get_role_lineid(RolePos),
								role_pos_util:send_to_role_by_pos(RolePos,{other_friend_online,{MyRoleId,MyRoleName,MyLineId}}),
								Acc ++ [{Fid,Fname,Fclass,Fgender,LineId,Sign,Intimacy,Status}]
						end
					end,
			FriendInfos = lists:foldl(FRole, [], FriendList),
			put(myfriends,FriendInfos)
	end.

load_black_from_db(RoleId)->
	case friend_db:get_friend_by_type(1, RoleId) of
		{ok,[]}->
			blackinit();
		{ok,BlackList}->
			FRole = fun({black,_Owner,Fid,Fname,{Fclass,Fgender},Status}) ->
						{Fid,Fname,Fclass,Fgender,Status}
					end,
			BlackInfos = lists:map(FRole, BlackList),
			put(myblacks,BlackInfos)
	end.

load_signature_from_db(RoleId)->
	case friend_db:get_signature_by_roleid(RoleId) of
		{ok,[]}->
			signature_init();
		{ok,[#signature{sign=Signature}]}->
			put(signature,Signature)
	end.

offline_notice()->
	MyRoleId = get(roleid),
	MyRoleName = get_name_from_roleinfo(get(creature_info)),
	NoticeFriends = get(myfriends),
		NoticeFun = fun({Fid,_Fname,_FClass,_FGender,_Fline,_,_,_}) ->
						case role_pos_util:where_is_role(Fid) of
							[] ->
								nothing;
							RolePos->
								role_pos_util:send_to_role_by_pos(RolePos, {other_friend_offline,{MyRoleId,MyRoleName,0}})
						end
				end,
	lists:foreach(NoticeFun,NoticeFriends).

export_for_copy()->
	{get(myfriends),get(myblacks),get(signature)}.

write_to_db()->
	nothing.

load_by_copy({FriendInfos,BlackInfos,Signature})->
	put(myfriends,FriendInfos),
	put(myblacks,BlackInfos),
	put(signature,Signature).

get_friend_list(Ntype)->
	case Ntype of
		0 ->%%friendlist 
			util:term_to_record_for_list(get(myfriends), fr);
		1 ->%%blacklist
			util:term_to_record_for_list(get(myblacks), br);
		_ ->
			[]
	end.

send_friend_list()->
	Message = friend_packet:encode_myfriends_s2c(get_friend_list(0)),
	role_op:send_data_to_gate(Message).

send_black_list()->
	Message = friend_packet:encode_black_list_s2c(get_friend_list(1)),
	role_op:send_data_to_gate(Message).

send_signature()->
	Message = friend_packet:encode_init_signature_s2c(get(signature)),
	role_op:send_data_to_gate(Message).

add_intimacy(RoleId, Intimacy) ->
	RoleInfo = get(creature_info),
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	case role_pos_util:where_is_role(RoleId) of
		[] ->
			slogger:msg("add_intimacy, role offline~n"),
			?ERROR_ROLE_OFFLINE;
		RolePos ->
			role_pos_util:send_to_role_by_pos(RolePos, {friend_add_intimacy, MyRoleId, Intimacy}),
			{Fid,FName,FClass,FGender,FriendLine,_,OldIntimacy,Status} = get_friend(RoleId),
			DeleteObject = #friend{owner=MyRoleId,fid=Fid,fname=FName,finfo={FClass,FGender},intimacy=OldIntimacy,status=Status},
			friend_db:delete_friend_to_mnesia(DeleteObject),
			remove(FName),
			NewIntimacy = OldIntimacy + Intimacy,
			AddObject = DeleteObject#friend{intimacy=NewIntimacy},
			friend_db:add_friend_to_mnesia(AddObject),
			insert(Fid,FName,FClass,FGender,FriendLine,NewIntimacy,Status),
			Msg = friend_packet:encode_friend_add_intimacy_s2c(FName,NewIntimacy),
			role_op:send_data_to_gate(Msg)
	end.

friend_add_intimacy(RoleId, Intimacy) ->
	RoleInfo = get(creature_info),
	MyRoleId = get_id_from_roleinfo(RoleInfo),
	case get_friend(RoleId) of
		false ->
			case role_pos_util:where_is_role(RoleId) of
				[] ->
					nothing;
				RolePos ->
					role_pos_util:send_to_role_by_pos(RolePos, {delete_friend_directly, MyRoleId})
			end;
		{Fid,FName,FClass,FGender,FriendLine,_,OldIntimacy,Status} ->
			DeleteObject = #friend{owner=MyRoleId,fid=Fid,fname=FName,finfo={FClass,FGender},intimacy=OldIntimacy,status=Status},
			friend_db:delete_friend_to_mnesia(DeleteObject),
			remove(FName),
			NewIntimacy = OldIntimacy + Intimacy,
			AddObject = DeleteObject#friend{intimacy=NewIntimacy},
			friend_db:add_friend_to_mnesia(AddObject),
			insert(Fid,FName,FClass,FGender,FriendLine,NewIntimacy,Status),
			Msg = friend_packet:encode_friend_add_intimacy_s2c(FName,NewIntimacy),
			role_op:send_data_to_gate(Msg)
	end.

send_flowers(RoleName, Num) when is_list(RoleName) ->
	send_flowers(list_to_binary(RoleName), Num);

send_flowers(RoleName, Num) when is_binary(RoleName) ->
	ErrorNo = case role_pos_util:where_is_role(RoleName) of
		[] ->
			?ERROR_FRIEND_OFFLINE;
		RolePos ->
			case item_util:is_has_enough_item_in_package_by_class(?ITEM_TYPE_ADD_INTIMACY, Num) of
				true->
					item_util:consume_items_by_classid(?ITEM_TYPE_ADD_INTIMACY, Num),
					IntimacyInfo = wedding_db:get_intimacy_info(?WEDDING_INTIMACY_BY_FLOWER),
					IntimacyValue = wedding_db:get_intimacy_value(IntimacyInfo),
					AddValue = Num * IntimacyValue,
					RoleInfo = get(creature_info),
					MyRoleId = get_id_from_roleinfo(RoleInfo),
					MyRoleName = get_name_from_roleinfo(RoleInfo),
					role_pos_util:send_to_role_by_pos(RolePos, {friend_add_intimacy, MyRoleId, AddValue}),
					{Fid,FName,FClass,FGender,FriendLine,_,OldIntimacy,Status} = get_friend(RoleName),
					DeleteObject = #friend{owner=MyRoleId,fid=Fid,fname=FName,finfo={FClass,FGender},intimacy=OldIntimacy,status=Status},
					friend_db:delete_friend_to_mnesia(DeleteObject),
					remove(FName),
					NewIntimacy = OldIntimacy + AddValue,
					AddObject = DeleteObject#friend{intimacy=NewIntimacy},
					friend_db:add_friend_to_mnesia(AddObject),
					insert(Fid,FName,FClass,FGender,FriendLine,NewIntimacy,Status),
					Msg2 = friend_packet:encode_friend_send_flowers_notify_s2c(MyRoleName, Num),
					role_pos_util:send_to_clinet_by_pos(RolePos,Msg2),
					0;
				false ->
					?ERROR_MISS_ITEM
			end
	end,
	Msg = friend_packet:encode_friend_send_flowers_s2c(ErrorNo),
	role_op:send_data_to_gate(Msg).


