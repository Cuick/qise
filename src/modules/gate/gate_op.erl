%%% File    : gate_op.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%% Created : 10 May 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>

-module(gate_op).

-compile(export_all).

-include("mnesia_table_def.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").

get_role_list(AccountName,ServerId)->
	AllRoles = role_db:get_role_list_by_account_rpc(AccountName),
	lists:filter(fun(LoginRole)->
						 RoleId = pb_util:get_role_id_from_logininfo(LoginRole),
						 ServerId =:= travel_battle_util:get_serverid_by_roleid(RoleId)
				 end,AllRoles).
	
get_last_mapid(RoleId) ->
	case role_db:get_role_info(RoleId) of
		[]-> 100;			%%born map
		RoleInfo->
			role_db:get_mapid(RoleInfo)		
	end.
%%
%%

create_role(AccountId,AccountName,RoleName,Gender,ClassType,CreateIp,ServerId,Pf,Flag)->
	RegisterSwitch = env:get(register_enable,?REGISTER_ENABLE),
	RoleNum = length(get_role_list(AccountName,ServerId)),	
	if
		RoleNum >= 1 ->
			slogger:msg("account ~p ~p one role exist ~n",[AccountId,AccountName]),
			{failed,?ERR_CODE_CREATE_ROLE_EXISTED};
		RegisterSwitch =:= ?REGISTER_ENABLE ->
			case senswords:word_is_sensitive(RoleName)of
				false-> 
					case role_db:create_role_rpc(AccountId,AccountName,RoleName,Gender,ClassType,CreateIp,ServerId,Pf,Flag) of
						{ok,Result}->
							case dal:read_rpc(account,AccountName) of
								{ok,[AccountInfo]}->
									#account{roleids = OldRoleIds}  = AccountInfo,
									NewAccount = AccountInfo#account{roleids = [Result|OldRoleIds]},
									NewAccount;
								_->
									NewAccount = #account{username=AccountName,roleids=[Result],gold=0,flag=Flag},
									NewAccount
							end,
							dal:write_rpc(NewAccount),
							{ok,Result};
						{failed,Reason}-> 
					                {failed,Reason};
							_Any->{failed,?ERR_CODE_CREATE_ROLE_INTERL}
					end;
				_-> slogger:msg("senswords:word_is_sensitive :failed~n"),
					{failed,?ERR_CODE_ROLENAME_INVALID}
			end;
		true->
			{failed,?ERR_CODE_CREATE_ROLE_REGISTER_DISABLE}	
	end.

create_role(AccountId,AccountName,CreateIp,ServerId)->
	RoleName = binary_to_list(<<"游客">>)++ util:make_int_str3(AccountId),
	Gender = random:uniform(2)-1,
	ClassType = random:uniform(3),
	RegisterSwitch = env:get(register_enable,?REGISTER_ENABLE),
	if
		RegisterSwitch =:= ?REGISTER_ENABLE ->	
			case role_db:create_role_rpc(AccountId,AccountName,{visitor,RoleName},Gender,ClassType,CreateIp,ServerId) of
				{ok,Result}->{ok,Result};
				{failed,Reason}-> {failed,Reason};
				_Any->{failed,?ERR_CODE_CREATE_ROLE_INTERL}
			end;
		true->
			{failed,?ERR_CODE_CREATE_ROLE_REGISTER_DISABLE}	
	end.

get_socket_peer(Socket)->
	case inet:peername(Socket) of
		{error, _ } -> [];
		{ok,{Address,_Port}}->
			{A1,A2,A3,A4}= Address,
			string:join([integer_to_list(A1),
						 integer_to_list(A2),
						 integer_to_list(A3),
						 integer_to_list(A4)], ".")
	end.
	
trans_addr_to_list({A1,A2,A3,A4})->
	string:join([integer_to_list(A1),integer_to_list(A2),integer_to_list(A3),integer_to_list(A4)], ".").	
	
check_socket(Socket)->
	case get_socket_peer(Socket) of
		[]-> false;
		IpAddress->
			Ret = gm_block_db:check_block_info(IpAddress,connect),
			if Ret >=0 -> false;
			   true-> true
			end
	end.
