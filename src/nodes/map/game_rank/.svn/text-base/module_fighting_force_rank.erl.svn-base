%% Author: SQ.Wang
%% Created: 2011-11-5
%% Description: TODO: Add description to module_fighting_force_rank
-module(module_fighting_force_rank).

%%
%% Include files
%%
-define(FIGHTING_FORCE_RANK_LIST,fight_force_rank_list).
-define(FIGHTING_FORCE_TOP_LIST,fight_force_top_list).
-define(RANK_FRESH_FIGHTING_FORCE_LIST,rank_fresh_fighting_force_list).
-define(COLLECT_FIGHTING_FORCE_LIST,collect_fighting_force_list).
-define(FIGHTING_FORCE_LOST_LIST,fight_force_lost_list).
-include("login_pb.hrl").
-include("game_rank_define.hrl").
-include("title_def.hrl").
%%
%% Exported Functions
%%
-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,
	refresh_gather/0,is_top/1,after_gather/0]).

%%
%% API Functions
%%
load_from_data(Data) ->
	game_rank_collect_util:load_from_data(Data,?FIGHTING_FORCE_RANK_LIST,?FIGHTING_FORCE_TOP_LIST,
		?RANK_FRESH_FIGHTING_FORCE_LIST,?COLLECT_FIGHTING_FORCE_LIST,?RANK_TYPE_FIGHTING_FORCE).

can_challenge_rank(_)->
	todo.

challenge_rank(_,_) ->
	todo.

is_top(RoleId)->
	game_rank_collect_util:is_top(RoleId,?FIGHTING_FORCE_TOP_LIST).

gather(RoleId,FightForce)->
	game_rank_collect_util:gather(RoleId,FightForce,?FIGHTING_FORCE_RANK_LIST,?FIGHTING_FORCE_TOP_LIST,
		?RANK_FRESH_FIGHTING_FORCE_LIST,?COLLECT_FIGHTING_FORCE_LIST,?RANK_TYPE_FIGHTING_FORCE,
		?FIGHTING_FORCE_LOST_LIST).
			
refresh_gather()->
	game_rank_collect_util:refresh_gather(?FIGHTING_FORCE_RANK_LIST,?FIGHTING_FORCE_TOP_LIST,
		?RANK_FRESH_FIGHTING_FORCE_LIST,?COLLECT_FIGHTING_FORCE_LIST,?RANK_TYPE_FIGHTING_FORCE,
		?FIGHTING_FORCE_LOST_LIST).

send_rank_list(RoleId) ->
	RankList = get(?FIGHTING_FORCE_RANK_LIST),
	case RankList of
		[] ->
			Param = [];
		_ ->
			Param = lists:map(fun({RoleIdTemp,Infos,_})->
									  case game_rank_manager_op:get_role_baseinfo(RoleIdTemp) of
								  		[] ->
									  		game_rank_packet:make_param([],1,1,1,1,[]);
								  		{RoleName,RoleClass,RoleGender,RoleServerId,GuildName}->
							  		  		game_rank_packet:make_param(RoleIdTemp,RoleName,GuildName,RoleClass,RoleServerId,[Infos])
							  		end
								end,RankList)
	end,
	Message = game_rank_packet:encode_rank_fighting_force_s2c(Param),
	role_pos_util:send_to_role_clinet(RoleId,Message).

after_gather() ->
	update_role_title(),
    RankList = get(?FIGHTING_FORCE_RANK_LIST),
    case RankList of
        undefined ->
            nothing;
        [] ->
            nothing;
        _ ->
            lists:foreach(fun({RoleId, Value, _}) ->
                                  gm_logger_role:refresh_fight_force_rank_log(RoleId, Value)
                          end, RankList)
    end.

update_role_title() ->
	Fun = fun(RoleId, Rank) ->
		case role_pos_util:is_role_online(RoleId) of
			true ->
				role_pos_util:send_to_role(RoleId, 
					{title_condition_change, 
					?TITLE_TYPE_FIGHT_FORCE, Rank});
			false ->
				title_op:hook_on_condition_change_offline(
					?TITLE_TYPE_FIGHT_FORCE, RoleId, Rank)
		end
	end,
	lists:foreach(fun(RoleId) ->
		Fun(RoleId, -1)
	end, get(?FIGHTING_FORCE_LOST_LIST)),
	lists:foldl(fun({RoleId, _, _}, Rank) ->
		Fun(RoleId, Rank),
		Rank + 1
	end, 1, get(?FIGHTING_FORCE_TOP_LIST)).