%% Author: MacX
%% Created: 2010-11-16
%% Description: TODO: Add description to friend_packet
-module(friend_packet).

%%
%% Include files
%%
-compile(export_all).
-export([handle/2,process_friend/1]).
-export([encode_myfriends_s2c/1,encode_becare_s2c/2,
		 encode_add_friend_failed_s2c/1,encode_add_friend_success_s2c/1,
		 encode_delete_friend_failed_s2c/1,encode_delete_friend_success_s2c/1,
		 encode_detail_friend_s2c/1,encode_detail_friend_failed_s2c/1,
		 encode_position_friend_s2c/1,encode_position_friend_failed_s2c/1,
		 encode_online_friend_s2c/1,encode_offline_friend_s2c/1,encode_set_black_s2c/1,
		 encode_black_list_s2c/1,encode_init_signature_s2c/1,encode_get_friend_signature_s2c/1,
		 encode_delete_black_s2c/1,encode_revert_black_s2c/1,encode_add_black_s2c/1,
		 encode_friend_send_flowers_s2c/1,encode_friend_add_intimacy_s2c/2,
		 encode_friend_send_flowers_notify_s2c/2]).
-include("login_pb.hrl").
-include("data_struct.hrl").

%%
%% Exported Functions
%%
handle(Message=#myfriends_c2s{}, RolePid) ->
	RolePid!{friend,Message};

handle(Message=#add_friend_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#add_friend_respond_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#delete_friend_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#detail_friend_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#position_friend_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#add_signature_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#get_friend_signature_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#set_black_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#revert_black_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#delete_black_c2s{},RolePid)->
	RolePid!{friend,Message};

handle(Message=#friend_send_flowers_c2s{},RolePid) ->
	RolePid!{friend, Message};

handle(_Message,_RolePid)->
	ok.

process_friend(#myfriends_c2s{ntype=Ntype})->
	Message = friend_packet:encode_myfriends_s2c(friend_op:get_friend_list(Ntype)),
	role_op:send_data_to_gate(Message);

process_friend(#add_friend_c2s{target_name=TargetName})->
	friend_op:send_friend_request(TargetName);

process_friend(#add_friend_respond_c2s{target_name=TargetName,result=Result})->
	friend_op:send_friend_responds(TargetName,Result);

process_friend(#delete_friend_c2s{fn=FriendName})->
	friend_op:delete_friend_by_name(get(creature_info),FriendName);
process_friend(#detail_friend_c2s{fn=FriendName})->
	friend_op:detail_friend_by_name(get(creature_info),FriendName);
process_friend(#position_friend_c2s{fn=FriendName})->
	friend_op:position_friend_by_name(get(creature_info),FriendName);
process_friend(#add_signature_c2s{signature=Signature})->
	friend_op:add_signature_c2s(get(creature_info),Signature);
process_friend(#get_friend_signature_c2s{fn=Fname})->
	friend_op:get_friend_signature_c2s(get(creature_info),Fname);
process_friend(#set_black_c2s{fn=Fname})->
	friend_op:set_black_c2s(get(creature_info),Fname);
process_friend(#revert_black_c2s{fn=Fname})->
	friend_op:revert_black_c2s(get(creature_info),Fname);
process_friend(#delete_black_c2s{fn=Fname})->
	friend_op:delete_black_c2s(get(creature_info),Fname);
process_friend(#friend_send_flowers_c2s{target_name = RoleName, num = Num}) ->
	friend_op:send_flowers(RoleName, Num);
process_friend(_)->
	nothing.
%%
%% API Functions
%%
encode_myfriends_s2c(FriendList)->
	login_pb:encode_myfriends_s2c(#myfriends_s2c{friendinfos = FriendList}).
encode_black_list_s2c(BlackList)->
	login_pb:encode_black_list_s2c(#black_list_s2c{friendinfos = BlackList}).
encode_init_signature_s2c(Signature)->
	login_pb:encode_init_signature_s2c(#init_signature_s2c{signature = Signature}).
encode_add_friend_success_s2c(FriendInfo)->
	login_pb:encode_add_friend_success_s2c(#add_friend_success_s2c{friendinfo=FriendInfo}).
encode_add_friend_failed_s2c(Reason)->
	login_pb:encode_add_friend_failed_s2c(#add_friend_failed_s2c{reason=Reason}).
encode_delete_friend_success_s2c(Fname)->
	login_pb:encode_delete_friend_success_s2c(#delete_friend_success_s2c{fn=Fname}).
encode_delete_friend_failed_s2c(Reason)->
	login_pb:encode_delete_friend_failed_s2c(#delete_friend_failed_s2c{reason=Reason}).
encode_becare_s2c(FriendId,FriendName)->
	login_pb:encode_becare_friend_s2c(#becare_friend_s2c{fn=FriendName,fid=FriendId}).
encode_detail_friend_s2c(DetailFriendInfo)->
	login_pb:encode_detail_friend_s2c(#detail_friend_s2c{defr=DetailFriendInfo}).
encode_detail_friend_failed_s2c(Reason)->
	login_pb:encode_detail_friend_failed_s2c(#detail_friend_failed_s2c{reason=Reason}).
encode_position_friend_s2c(PositionFriendInfo)->
	login_pb:encode_position_friend_s2c(#position_friend_s2c{posfr=PositionFriendInfo}).
encode_position_friend_failed_s2c(Reason)->
	login_pb:encode_position_friend_failed_s2c(#position_friend_failed_s2c{reason=Reason}).
encode_online_friend_s2c(FriendName)->
	login_pb:encode_online_friend_s2c(#online_friend_s2c{fn=FriendName}).
encode_offline_friend_s2c(FriendName)->
	login_pb:encode_offline_friend_s2c(#offline_friend_s2c{fn=FriendName}).
encode_get_friend_signature_s2c(Signature)->
	login_pb:encode_get_friend_signature_s2c(#get_friend_signature_s2c{signature=Signature}).
encode_set_black_s2c(Name)->
	login_pb:encode_set_black_s2c(#set_black_s2c{target_name = Name}).
encode_revert_black_s2c(FriendInfo)->
	login_pb:encode_revert_black_s2c(#revert_black_s2c{friendinfo=FriendInfo}).
encode_delete_black_s2c(TargetName)->
	login_pb:encode_delete_black_s2c(#delete_black_s2c{target_name = TargetName}).
encode_add_black_s2c(BlackInfo)->
	login_pb:encode_add_black_s2c(#add_black_s2c{blackinfo=BlackInfo}).
encode_add_friend_s2c(Source_name)->
	login_pb:encode_add_friend_s2c(#add_friend_s2c{source_name=Source_name}).
encode_add_friend_respond_s2c(Source_name,Result)->
	login_pb:encode_add_friend_respond_s2c(#add_friend_respond_s2c{source_name=Source_name,result=Result}).
encode_delete_friend_beidong_s2c(Fname)->
	login_pb:encode_delete_friend_beidong_s2c(#delete_friend_beidong_s2c{fname = Fname}).
encode_friend_send_flowers_s2c(Result) ->
	login_pb:encode_friend_send_flowers_s2c(#friend_send_flowers_s2c{result = Result}).
encode_friend_add_intimacy_s2c(TargetName, Intimacy) ->
	login_pb:encode_friend_add_intimacy_s2c(#friend_add_intimacy_s2c{target_name = TargetName, intimacy = Intimacy}).
encode_friend_send_flowers_notify_s2c(RoleName, Num) ->
	login_pb:encode_friend_send_flowers_notify_s2c(#friend_send_flowers_notify_s2c{role_name = RoleName, num = Num}).


