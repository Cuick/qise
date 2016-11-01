-module(role_game_rank).

-include("error_msg.hrl").
-include("login_pb.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("pet_struct.hrl").
-include("game_rank_define.hrl").
-include("common_define.hrl").
-define(EVALUATION_MAX_NUM,10).
-define(DISDAIN_NEED_LEVEL,30).

-compile(export_all).


load_from_db(RoleId)->
	case rank_judge_db:get_role_judge_left_num(RoleId) of
		[]->
			rank_judge_db:add_to_judge_left_num(RoleId,{?EVALUATION_MAX_NUM,{0,0,0}}),
			put(judge_left_num,{RoleId,?EVALUATION_MAX_NUM,{0,0,0}});
		{RoleId,{Left_num,Last_time}} ->
			put(judge_left_num,{RoleId,Left_num,Last_time})
	end,
	init_evaluation_num().

export_for_copy()->
	get(judge_left_num).

load_by_copy(JudgeInfo)->
	put(judge_left_num,JudgeInfo).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                  judge begin                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init_evaluation_num() ->
	{RoleId,Leftnum,LastTime} = get(judge_left_num),
	{{LastY,LastM,LastD},_} = calendar:now_to_local_time(LastTime),
	Now = timer_center:get_correct_now(),
	{{NowY,NowM,NowD},_} = calendar:now_to_local_time(Now),
	if
		NowD =/= LastD->
			put(judge_left_num,{RoleId,?EVALUATION_MAX_NUM,Now});
		true->
			nothing
	end.

watch_rank_roleinfo(Watched_RoleId)->
	{RoleId,Leftnum,LastTime} = get(judge_left_num),
	{{LastY,LastM,LastD},_} = calendar:now_to_local_time(LastTime),
	Now = timer_center:get_correct_now(),
	{{NowY,NowM,NowD},_} = calendar:now_to_local_time(Now),
	if 
		NowD =/= LastD ->
			put(judge_left_num,{RoleId,?EVALUATION_MAX_NUM,Now}),
			game_rank_manager:watch_roleinfo(RoleId,Watched_RoleId,?EVALUATION_MAX_NUM);
		true ->
			game_rank_manager:watch_roleinfo(RoleId,Watched_RoleId,Leftnum)
	end.

disdain(Disdan_RoleId) ->
	{RoleId,Left_num,_} = get(judge_left_num),
	RoleLevel = get(level),
	Nowtime = now(),
	MyName = get_name_from_roleinfo(get(creature_info)),
	case RoleLevel >= ?DISDAIN_NEED_LEVEL of
		true ->
			case RoleId =:= Disdan_RoleId of
				true ->
					nothing;
				_ ->
					case Left_num > 0 of
						true ->
							NewLeftNum = Left_num - 1,
							put(judge_left_num,{RoleId,NewLeftNum,Nowtime}),
							game_rank_manager:disdain_role(RoleId,Disdan_RoleId,NewLeftNum,MyName);
						_ ->
							nothing
					end
			end;
		_ ->
			nothing
	end.

praised(Parised_RoleId) ->
	{RoleId,Left_num,_} = get(judge_left_num),
	RoleLevel = get(level),
	Nowtime = now(),
	MyName = get_name_from_roleinfo(get(creature_info)),
	case RoleLevel >= ?DISDAIN_NEED_LEVEL of
		true ->
			case RoleId =:= Parised_RoleId of
				true ->
					nothing;
				_ ->
					case Left_num > 0 of
						true ->
							NewLeftNum = Left_num - 1,
							put(judge_left_num,{RoleId,NewLeftNum,Nowtime}),
							game_rank_manager:praised_role(RoleId,Parised_RoleId,NewLeftNum,MyName);
						_ ->
							nothing
					end
			end;
		_ ->
			nothing
	end.

on_player_offline()->
	{RoleId,Left_num,LastTime} = get(judge_left_num),
	rank_judge_db:add_to_judge_left_num(RoleId,{Left_num,LastTime}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%						data gather begin							  				  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gather_role_rank()->
	BoundSilver = get_boundsilver_from_roleinfo(get(creature_info)),
	Silver = get_silver_from_roleinfo(get(creature_info)),
	case get(level) >= ?CAN_CHALLENGE_NEED_LEVEL of
		true->
			Fighring_Force = role_fighting_force:hook_on_change_role_fight_force(),
			GatherList = [{get(roleid),?RANK_TYPE_ROLE_SILVER,Silver+BoundSilver},{get(roleid),?RANK_TYPE_FIGHTING_FORCE,Fighring_Force}],
			game_rank_manager:mul_gather(GatherList);
		_->
			ignor
	end.

hook_on_levelup(NewLevel)->
	game_rank_manager:challenge(get(roleid),?RANK_TYPE_ROLE_LEVEL,NewLevel).

%%Info:{Num,Time}
hook_on_new_tower_master(Info)->
	game_rank_manager:challenge(get(roleid),?RANK_TYPE_LOOP_TOWER_MASTER,Info).

hook_on_tower_num(TowerNum)->
	game_rank_manager:challenge(get(roleid),?RANK_TYPE_LOOP_TOWER_NUM,TowerNum).

%%Info:{Count,Time}
%% hook_on_chess_spirits(Info)->
%% 	game_rank_manager:challenge(get(roleid),?RANK_TYPE_CHESS_SPIRITS_SINGLE,Info).

%TangList:{RoleId,Num}	call in tangle_battle processor
% hook_on_tangle_kill_log(TangList)->
% 	GatherList = lists:map(fun({RoleId,KillNum})-> {RoleId,?RANK_TYPE_ROLE_TANGLE_KILL,KillNum} end, TangList),	
% 	game_rank_manager:mul_gather(GatherList).

hook_on_tangle_kill_log(TangList)->
	GatherList = 
	lists:foldl(fun({RoleId,KillNum},TangList1)->
		ServerId = travel_battle_util:get_serverid_by_roleid(RoleId),
		case lists:keyfind(ServerId,1,TangList1) of
			{ServerId,List} ->
				% {ServerId,[{RoleId,?RANK_TYPE_ROLE_TANGLE_KILL,KillNum}|List]},
				lists:keyreplace(ServerId,1,TangList1,{ServerId,[{RoleId,?RANK_TYPE_ROLE_TANGLE_KILL,KillNum}|List]});
			_->
				[{ServerId,[{RoleId,?RANK_TYPE_ROLE_TANGLE_KILL,KillNum}]}|TangList1]
		end
	end,[],TangList),
	lists:map(fun({ServerId,GatherList1})-> 
		Node = travel_battle_map_travel_op:get_source_node_by_serverid(ServerId),
		try
			rpc:call(Node,game_rank_manager,mul_gather,[GatherList1])
		catch
			E:R ->
				slogger:msg("hook_on_tangle_kill_log E:~p,Node:~p,R:~p~n",[E,Node,R]),
				0
		end
	end,GatherList).
	% game_rank_manager:mul_gather(GatherList).
%%AnswerList:{RoleId,Score} call in answer processor
hook_on_answer_log(AnswerList)->
	GatherList = lists:map(fun({RoleId,Score})-> {RoleId,?RANK_TYPE_ANSWER,Score} end, AnswerList),	
	game_rank_manager:mul_gather(GatherList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%			===============    		data gather        ===============				  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


handle_info(#rank_get_rank_c2s{type = ?RANK_TYPE_GUILD})->
	%%guild_manager:get_recruite_info(get(roleid));
	guild_handle:handle_guild_recruite_info_c2s();

handle_info(#rank_get_rank_c2s{type = Type})->
	game_rank_manager:watch_rank(get(roleid),Type);

handle_info(#rank_get_rank_role_c2s{roleid = RoleId})->
	watch_rank_roleinfo(RoleId);

handle_info(#rank_disdain_role_c2s{roleid = RoleId})->
	disdain(RoleId);														  
									   
handle_info(#rank_praise_role_c2s{roleid = RoleId})->
	praised(RoleId);	

handle_info(#rank_get_main_line_rank_c2s{type=Type,chapter=Chapter,festival=Festival,difficulty=Difficulty})->
	game_rank_manager:watch_rank({Chapter,Festival,Difficulty,get(roleid)},Type);

handle_info(_) ->
	nothing.

hook_on_role_name_change(NewNameStr)->
	game_rank_manager:on_role_change_name(get(roleid),NewNameStr).