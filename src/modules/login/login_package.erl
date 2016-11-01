%% Author: adrian
%% Created: 2010-4-16
%% Description: TODO: Add description to login_package
-module(login_package).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("login_def.hrl").
%%
%% Exported Functions
%%
-export([handle/3]).

-define(AUTH_FAILED,-1).
%%
%% API Functions
%%

handle(#user_auth_c2s{username=Account,serverId = ServerId,adult = Adult,
	pf = Pf, time = Time,sign = Sign,flag = Flag},FromProcName,RolePid)->
	tcp_client:start_auth(node(), FromProcName, Account, ServerId, Adult, Pf, Time, Sign, Flag);

handle(#player_select_role_c2s{roleid=RoleId,lineid=LineId},FromProcName,_RolePid)->
	tcp_client:role_into_map_request(node(), FromProcName, RoleId,LineId);

handle(#role_line_query_c2s{mapid=MapId},FromProcName,_RolePid)->
	tcp_client:line_info_request(node(), FromProcName,MapId );
 
handle(#create_role_request_c2s{role_name=RoleName,gender=Gender,classtype=ClassType},FromProcName,_RolePid)->
	tcp_client:role_create_request(node(), FromProcName,RoleName,Gender,ClassType);

%% handle(#is_visitor_c2s{t=Time,f=Flag},FromProcName,_RolePid)->
%% 	tcp_client:start_auth(node(), FromProcName,Time,Flag);

%% handle(#is_finish_visitor_c2s{t=Time,f=Flag,u=AccountName},FromProcName,_RolePid)->
%% 	auth_processor:auth(node(), FromProcName, Time, Flag, AccountName);

handle(#reset_random_rolename_c2s{},FromProcName,_RolePid)->
	tcp_client:reset_random_rolename(node(), FromProcName);


handle(_Msg,_Proc,_Context)->
	ok.
%%
%% Local Functions
%%

