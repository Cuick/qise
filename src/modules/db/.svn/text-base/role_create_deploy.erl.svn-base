%% Author: adrianx
%% Created: 2011-1-7
%% Description: TODO: Add description to role_create_deploy
-module(role_create_deploy).

%%
%% Include files
%%
-include("error_msg.hrl").
%%
%% Exported Functions
%%
-export([create/9]).

%%
%% API Functions
%%

%%
%% Local Functions
%%

create(AccountId,AccountName,RoleName,Gender,ClassId,CreateIp,ServerId,Pf,Flag)->
	case db_template:create_template_role({Gender,ClassId},RoleName, AccountName,ServerId) of
		{ok,RoleId}-> slogger:msg("role_create_deploy, pos 1~n"),case RoleName of
						  {visitor,RName} ->
							  gm_logger_role:create_role(AccountName,AccountId,RName,RoleId,ClassId,Gender,Pf,CreateIp,(1 - Flag));
						  _->
							  gm_logger_role:create_role(AccountName,AccountId,RoleName,RoleId,ClassId,Gender,Pf,CreateIp,(1 - Flag))
					  end,
					  {ok,RoleId};
		T-> {failed,?ERR_CODE_CREATE_ROLE_INTERL}
	end.
