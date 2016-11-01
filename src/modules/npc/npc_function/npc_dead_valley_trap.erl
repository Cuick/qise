-module (npc_dead_valley_trap).

-export([proc_special_msg/1,init/0]).

-include ("npc_struct.hrl").

init() ->
	case random:uniform(100) =< 50 of
		true ->
			self() ! {trap_show};
		false ->
			self() ! {trap_hide}
	end.

proc_special_msg({trap_show}) ->
	show();
proc_special_msg({trap_hide}) ->
	hide();
proc_special_msg(_) ->
	nothing.

show() ->
	NpcInfo = get(creature_info),
	SelfId = get(id),
	NpcInfoDB = get(npcinfo_db), 
	npc_manager:regist_npcinfo(NpcInfoDB, SelfId, NpcInfo),
	creature_op:join(NpcInfo, get(map_info)),
	RoleList = lists:filter(fun({Id, _}) ->
		creature_op:what_creature(Id) =:= role
	end, get(aoi_list)),
	lists:foreach(fun({RoleId, _}) ->
		role_pos_util:send_to_role(RoleId, {dead_valley_trap_show, SelfId})
	end, RoleList),
	ProtoId = get_templateid_from_npcinfo(NpcInfo),
	TrapInfo = dead_valley_db:get_trap_info(ProtoId),
	{Min, Max} = dead_valley_db:get_trap_hide(TrapInfo),
	NextHide = Min + random:uniform(Max - Min),
	erlang:send_after(NextHide, self(), {trap_hide}).

hide() ->
	NpcInfo = get(creature_info),
	RoleList = lists:filter(fun({Id, _}) ->
		creature_op:what_creature(Id) =:= role
	end, get(aoi_list)),
	SelfId = get(id),
	NpcInfoDB = get(npcinfo_db), 
	npc_manager:unregist_npcinfo(NpcInfoDB, SelfId),
	lists:foreach(fun({RoleId, _}) ->
		role_pos_util:send_to_role(RoleId, {dead_valley_trap_hide, SelfId})
	end, RoleList),
	creature_op:leave_map(NpcInfo,get(map_info)),
	ProtoId = get_templateid_from_npcinfo(NpcInfo),
	TrapInfo = dead_valley_db:get_trap_info(ProtoId),
	{Min, Max} = dead_valley_db:get_trap_show(TrapInfo),
	NextShow = Min + random:uniform(Max - Min),
	erlang:send_after(NextShow, self(), {trap_show}).
