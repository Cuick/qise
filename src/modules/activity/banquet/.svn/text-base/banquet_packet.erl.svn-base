%% Author: MacX
%% Created: 2011-9-29
%% Description: TODO: Add description to banquet_packet
-module(banquet_packet).

%%
%% Include files
%%
-export([handle/2,process_banquet/1]).
-export([encode_banquet_start_notice_s2c/1,
		 encode_banquet_request_banquetlist_s2c/1,
		 encode_banquet_join_s2c/8,
		 encode_banquet_error_s2c/1,
		 encode_banquet_dancing_s2c/3,
		 encode_banquet_cheering_s2c/3,
		 encode_banquet_leave_s2c/0,
		 encode_banquet_stop_s2c/0,
		 encode_banquet_update_count_s2c/3,
		 encode_companion_dancing_apply_s2c/1,
		 encode_companion_dancing_result_s2c/1,
		 encode_companion_dancing_reject_s2c/1,
		 encode_banquet_pet_swanking_s2c/1,
		 encode_banquet_pets_s2c/2,
		 encode_companion_dancing_stop_s2c/0]).
-include("login_pb.hrl").
-include("data_struct.hrl").
%%
%% Exported Functions
%%


%%
%% API Functions
%%
handle(Message=#banquet_join_c2s{},RolePid)->
	RolePid!{banquet,Message};
handle(Message=#banquet_cheering_c2s{},RolePid)->
	RolePid!{banquet,Message};
handle(Message=#banquet_dancing_c2s{},RolePid)->
	RolePid!{banquet,Message};
handle(Message=#banquet_request_banquetlist_c2s{},RolePid)->
	RolePid!{banquet,Message};
handle(Message=#banquet_leave_c2s{},RolePid)->            %%Rolepid  A
	RolePid!{banquet,Message};
handle(Message=#companion_dancing_apply_c2s{},RolePid)->
	RolePid!{banquet,Message};
handle(Message=#companion_dancing_start_c2s{},RolePid)->
	RolePid!{banquet,Message};
handle(Message=#companion_dancing_reject_c2s{},RolePid)->
	RolePid!{banquet,Message};
handle(_Message,_RolePid)->
	ok.

process_banquet(#banquet_join_c2s{banquetid=BanquetId})->
	banquet_op:banquet_join_c2s(BanquetId);
process_banquet(#banquet_cheering_c2s{roleid=RoleId})->
	banquet_op:banquet_cheering_c2s(RoleId);
process_banquet(#banquet_dancing_c2s{roleid=RoleId,slot=Slot})->
	if
		Slot=:=0->
			banquet_op:banquet_dancing_with_gold(RoleId);
		true->
			item_banquet_soap:handle_banquet_soap(RoleId, Slot)
	end;
process_banquet(#banquet_request_banquetlist_c2s{})->
	banquet_op:banquet_request_banquetlist_c2s();

process_banquet(#banquet_leave_c2s{})->
	banquet_op:banquet_leave_c2s();

process_banquet(#companion_dancing_apply_c2s{roleid = RoleId}) ->   %% Roleid B
	banquet_op:companion_dancing_apply(RoleId);

process_banquet(#companion_dancing_start_c2s{roleid = RoleId}) ->   %% Roleid A
	SelfPid = self(),
	SelfPid ! {dancing_start, RoleId};                     

process_banquet(#companion_dancing_reject_c2s{roleid = RoleId}) ->
	banquet_op:companion_dancing_reject(RoleId);

process_banquet(_) ->
	nothing.
%%
%% Local Functions
%%
encode_banquet_start_notice_s2c(Level)->
	login_pb:encode_banquet_start_notice_s2c(#banquet_start_notice_s2c{level=Level}).
encode_banquet_request_banquetlist_s2c(Banquets)->
	login_pb:encode_banquet_request_banquetlist_s2c(#banquet_request_banquetlist_s2c{banquets=Banquets}).
encode_banquet_join_s2c(BanquetId,Cheering,Dancing,Peting,LeftTime,CheeringTime,DancingTime,PetingTime)->
	login_pb:encode_banquet_join_s2c(#banquet_join_s2c{banquetid=BanquetId,
											   cheering=Cheering,
											   dancing=Dancing,
											   peting=Peting,
											   lefttime=LeftTime,
											   dancingtime=DancingTime,
											   cheeringtime=CheeringTime,
											   petingtime = PetingTime}).
encode_banquet_dancing_s2c(Name,BeName,Remain)->
 	login_pb:encode_banquet_dancing_s2c(#banquet_dancing_s2c{name=Name,bename=BeName,remain=Remain}).
encode_banquet_dancing_start_s2c(Name,BeName,Remain)->
	login_pb:encode_banquet_dancing_start_s2c(#banquet_dancing_start_s2c{name=Name,bename=BeName,remain=Remain}).

encode_banquet_pet_swanking_s2c(Remain) ->
	login_pb:encode_banquet_pet_swanking_s2c(#banquet_pet_swanking_s2c{remain=Remain}).
encode_banquet_pets_s2c(Name,Pets) ->
	login_pb:encode_banquet_pets_s2c(#banquet_pets_s2c{name=Name,pets=Pets}).

encode_banquet_cheering_s2c(Name,BeName,Remain)->
	login_pb:encode_banquet_cheering_s2c(#banquet_cheering_s2c{name=Name,bename=BeName,remain=Remain}).
encode_banquet_update_count_s2c(NewDancing,NewCheering,NewSwanking)->
	login_pb:encode_banquet_update_count_s2c(#banquet_update_count_s2c{dancing=NewDancing,cheering=NewCheering,swanking = NewSwanking}).
encode_banquet_leave_s2c()->
	login_pb:encode_banquet_leave_s2c(#banquet_leave_s2c{}).
encode_banquet_stop_s2c()->
	login_pb:encode_banquet_stop_s2c(#banquet_stop_s2c{}).
encode_banquet_error_s2c(Reason)->
	login_pb:encode_banquet_error_s2c(#banquet_error_s2c{reason=Reason}).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

encode_companion_dancing_apply_s2c(RoleId)->
	login_pb:encode_companion_dancing_apply_s2c(#companion_dancing_apply_s2c{roleid = RoleId}).

encode_companion_dancing_result_s2c(RoleId)->
	login_pb:encode_companion_dancing_result_s2c(#companion_dancing_result_s2c{result = RoleId}).

encode_companion_dancing_reject_s2c(RoleName)->
	login_pb:encode_companion_dancing_reject_s2c(#companion_dancing_reject_s2c{rolename = RoleName}).

encode_companion_dancing_stop_s2c() ->
	login_pb:encode_companion_dancing_stop_s2c(#companion_dancing_stop_s2c{}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

