-module (travel_match_zone_manager_op).

-include ("travel_battle_def.hrl").
-include ("npc_define.hrl").
-include ("common_define.hrl").

-export ([start_travel_match_unit_manager/6, stop_travel_match_unit_manager/2]).

start_travel_match_unit_manager(MapProc, Type, LevelZone, Stage, WaitMapId, Unit) ->
	CreatorTag = {?CREATOR_LEVEL_BY_SYSTEM,?CREATOR_BY_SYSTEM},
	map_sup:start_child(MapProc, {?TRAVEL_BATTLE_LINE_ID, WaitMapId},
		travel_match,CreatorTag,{Type, LevelZone}),
	UnitManagerProc = travel_match_unit_manager:make_unit_manager_proc_name(Unit),
	travel_match_unit_manager_sup:start_child(UnitManagerProc, Unit, Type, LevelZone, Stage).

stop_travel_match_unit_manager(MapProc, Unit) ->
	map_sup:stop_child(MapProc),
	UnitManagerProc = travel_match_unit_manager:make_unit_manager_proc_name(Unit),
	travel_match_unit_manager_sup:stop_child(UnitManagerProc).