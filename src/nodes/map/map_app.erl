%% Author: adrian
%% Created: 2010-4-11
%% Description: TODO: Add description to map_app
-module(map_app).

-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("reloader.hrl").

%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 start/2,
	 stop/1,
	 start/0
        ]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------


%% ====================================================================!
%% External functions
%% ====================================================================!
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, _StartArgs) ->
	case util:get_argument('-line') of
		[]->  slogger:msg("Missing --line argument input the nodename");
		[CenterNode|_]->
			filelib:ensure_dir("../log/"),
			FileName = "../log/"++atom_to_list(node_util:get_node_sname(node())) ++ "_node.log", 
			error_logger:logfile({open, FileName}),
			?RELOADER_RUN,
			ping_center:wait_all_nodes_connect(),
			db_operater_mod:start(),
			global_util:global_proc_wait(),
			timer_center:start_at_app(),
			dbsup:start_dal_dmp(),
			%%wait all db table
			slogger:msg("wait_for_all_db_tables ing ~n"),
			applicationex:wait_ets_init(),
			slogger:msg("wait_for_all_db_tables end ~n"),
			role_pos_db:unreg_role_pos_to_mnesia_by_node(node()),
			role_app:start(),
			lines_manager:wait_lines_manager_loop(),
			%%load map
			start_map_sup(),
			start_map_manager_sup(),
			npc_function_frame:init_all_functions_after_ets_finish(),
			start_treasure_spawns_sup(),
			guild_instance_sup:start_link(),
			mock_app:start(),
			top_bar_manager_op:check_open_server_activities(),
			top_bar_manager_op:check_combine_server_activities(),
			case travel_battle_util:is_travel_battle_server() of
				false->
					travel_battle_deamon_sup:start_link();
				true->
					case node_util:check_snode_match(map_travel, node()) of
						true->
							travel_battle_zone_manager_sup:start_link(),
							travel_match_zone_manager_sup:start_link(),
							dead_valley_zone_manager_sup:start_link();
						false->
							nothing
					end		
			end,
			case node_util:check_snode_match(battle_ground_manager, node()) of
				true->
					start_battle_ground_sup(),
					start_battle_ground_manager_sup();
				false->
					start_battle_ground_sup()
			end,
			case node_util:check_snode_match(guildbattle_manager, node()) of
				true->
					start_guildbattle_manager_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(auction_manager, node()) of
				true->
					start_auction_manager_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(game_rank_manager, node()) of
				true->
					start_game_rank_manager_sup();
				false->
					nothing
			end,
			
			case node_util:check_snode_match(group_manager, node()) of
				true->
					start_group_manager_sup();
				_->
					nothing
			end,
			case node_util:check_snode_match(activity_manager, node()) of
				true->
					start_activity_manager_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(answer_processor, node()) of
				true->
					start_answer_sup();
				_->
					nothing
			end,
			case node_util:check_snode_match(dragon_fight_processor, node()) of
				true->
					start_dragon_fight_sup();
				false->
					nothing
			end,
			
			case node_util:check_snode_match(map_travel, node()) of
				true->
					start_travel_battle_map_travel_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(guild_instance_processor, node()) of
				true->
					start_guild_instance_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(loop_instance_mgr, node()) of
				true->
					start_loop_instance_proc_sup(),
					start_loop_instance_mgr_sup();
				false->
					start_loop_instance_proc_sup()
			end,
			case node_util:check_snode_match(travel_battle_manager, node()) of
				true ->
					start_travel_battle_manager_sup();
				false ->
					nothing
			end,
			% case node_util:check_snode_match(travel_match_manager, node()) of
			% 	true ->
			% 		start_travel_match_manager_sup();
			% 	false ->
			% 		nothing
			% end,
			case node_util:check_snode_match(wedding_ceremony_manager, node()) of
				true->
					start_wedding_ceremony_manager_sup();
				false->
					nothing
			end,
			% case node_util:check_snode_match(open_service_auction_manager, node()) of
			% 	true->
			% 		start_open_service_auction_manager_sup();
			% 	false->
			% 		nothing
			% end,
			case node_util:check_snode_match(top_bar_manager, node()) of
				true->
					start_top_bar_manager_sup();
				false->
					nothing
			end,
			case node_util:check_snode_match(dead_valley_manager, node()) of
				true ->
					start_dead_valley_manager_sup();
				false ->
					nothing
			end,
			case node_util:check_snode_match(travel_tangle_manager, node()) of
				true ->
					start_travel_tangle_manager_sup();
				false ->
					nothing
			end,
			{ok, self()}
	end.

start()->
	applicationex:start(?MODULE).
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
	ok.

%% ====================================================================
%% Internal functions
%% ====================================================================

start_map_sup()->
	case map_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

start_map_manager_sup()->
	case map_manager_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

start_battle_ground_manager_sup()->
	case battle_ground_manager_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_battle_ground_manager_sup error!! ~p ~n",[Error])
	end.

start_guildbattle_manager_sup()->
	case guildbattle_manager_sup:start_link() of
		{ok,Pid}->
			slogger:msg("start_guildbattle_manager_sup success!! ~p ~n",[Pid]),
			{ok,Pid};
		Error->
			slogger:msg("start_guildbattle_manager_sup error!! ~p ~n",[Error])
	end.

start_battle_ground_sup()->
	case battle_ground_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_battle_ground_sup error!! ~p ~n",[Error])
	end.

start_answer_sup()->
	case answer_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_answer_sup error!! ~p ~n",[Error])
	end.

start_activity_manager_sup()->
	case activity_manager_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_activity_manager_sup error!! ~p ~n",[Error])
	end.
	
start_treasure_spawns_sup()->
	case treasure_spawns_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_battle_ground_sup error!! ~p ~n",[Error])
	end.
 
start_dragon_fight_sup()->
	case dragon_fight_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_battle_ground_sup error!! ~p ~n",[Error])
	end.

start_treasure_transport_sup()->
	case treasure_transport_sup:start_link() of
		{ok,Pid}->
			{ok,Pid};
		Error->
			slogger:msg("start_treasure_transport_sup error!! ~p ~n",[Error])
	end.

start_mapdb_sup()->
	case mapdb_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_auction_manager_sup()->
	case auction_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_group_manager_sup()->
	case group_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.	

start_travel_battle_map_travel_sup()->
	case travel_battle_map_travel_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_game_rank_manager_sup()->
	case game_rank_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_guild_instance_sup()->
	case guild_instance_processor_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_loop_instance_mgr_sup()->
	case loop_instance_mgr_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_loop_instance_proc_sup()->
	case loop_instance_proc_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_travel_battle_manager_sup() ->
	case travel_battle_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_travel_match_manager_sup() ->
	case travel_match_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_wedding_ceremony_manager_sup()->
	case wedding_ceremony_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_open_service_auction_manager_sup()->
	case open_service_auction_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_top_bar_manager_sup() ->
	case top_bar_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_dead_valley_manager_sup() ->
	case dead_valley_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.

start_travel_tangle_manager_sup() ->
	case travel_tangle_manager_sup:start_link() of
		{ok,Pid} ->
			{ok,Pid};
		Error ->
			Error
	end.