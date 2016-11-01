%% Author: SQ.Wang
%% Created: 2011-7-14
%% Description: TODO: Add description to module_money_rank
-module(module_money_rank).

%%
%% Include files
%%
-include("login_pb.hrl").
-include("game_rank_define.hrl").
-include("title_def.hrl").

-define(MONEY_RANK_LIST,money_rank_list).
-define(MONEY_TOP_LIST,money_top_list).
-define(COLLECT_MONEY_LIST,collect_money_list).
-define(RANK_FRESH_MONEY_LIST,rank_fresh_money_list).
-define(MONEY_LOST_LIST,money_lost_list).
%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,refresh_gather/0,
	is_top/1,after_gather/0]).

%%
%% API Functions
%%
load_from_data(Data) ->
	game_rank_collect_util:load_from_data(Data,?MONEY_RANK_LIST,?MONEY_TOP_LIST,?RANK_FRESH_MONEY_LIST,
		?COLLECT_MONEY_LIST,?RANK_TYPE_ROLE_SILVER).

%%Return:
%%	true|false
%%Args:
%%	Moneys = int
can_challenge_rank(Moneys)->
	todo.

%%Return:
%%	ok|failed
%%Args:
%%	RoleId
%%	Moneys = int
challenge_rank(RoleId,Moneys) ->
	todo.

is_top(RoleId)->
	game_rank_collect_util:is_top(RoleId,?MONEY_TOP_LIST).

gather(RoleId,Money)->
	game_rank_collect_util:gather(RoleId,Money,?MONEY_RANK_LIST,?MONEY_TOP_LIST,?RANK_FRESH_MONEY_LIST,
		?COLLECT_MONEY_LIST,?RANK_TYPE_ROLE_SILVER,?MONEY_LOST_LIST).

refresh_gather()->
	game_rank_collect_util:refresh_gather(?MONEY_RANK_LIST,?MONEY_TOP_LIST,?RANK_FRESH_MONEY_LIST,
		?COLLECT_MONEY_LIST,?RANK_TYPE_ROLE_SILVER,?MONEY_LOST_LIST).

send_rank_list(RoleId) ->
	RankList = get(?MONEY_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({RoleIdTemp,Infos,_})->
							  		case game_rank_manager_op:get_role_baseinfo(RoleIdTemp) of
								  		[] ->
									  		game_rank_packet:make_mparam([],1,1,1,1,[]);
								  		{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}->
							  		  		game_rank_packet:make_mparam(RoleIdTemp,RoleName,GuildName,RoleClass,RoleServerId,[Infos])
							  		end
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_moneys_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).

after_gather() ->
    update_role_title().


update_role_title() ->
	Fun = fun(RoleId, Rank) ->
		case role_pos_util:is_role_online(RoleId) of
			true ->
				role_pos_util:send_to_role(RoleId, 
					{title_condition_change, 
					?TITLE_TYPE_MONEY, Rank});
			false ->
				title_op:hook_on_condition_change_offline(
					?TITLE_TYPE_MONEY, RoleId, Rank)
		end
	end,
	lists:foreach(fun(RoleId) ->
		Fun(RoleId, -1)
	end, get(?MONEY_LOST_LIST)),
	lists:foldl(fun({RoleId, _, _}, Rank) ->
		Fun(RoleId, Rank),
		Rank + 1
	end, 1, get(?MONEY_TOP_LIST)).

















