-module (dead_valley_zone_manager_op).

-export ([init/0, start_instance/4, boss_init/2, boss_update/2, role_come/1]).

init() ->
	put(boss_info, []),
	put(map_proc, undefined).

start_instance(InstanceProc, MapId, CreatorTag, Duration) ->
	case map_manager:start_instance(InstanceProc, MapId, dead_valley, 
		CreatorTag, Duration) of
		ok ->
			put(map_proc, InstanceProc),
			ok;
		error ->
			error
	end.

boss_init(NpcId, HpMax) ->
	BossInfo = get(boss_info),
	BossInfo2 = case lists:keyfind(NpcId, 1, BossInfo) of
		false ->
			[{NpcId, HpMax, HpMax} | get(boss_info)];
		_ ->
			lists:keyreplace(NpcId, 1, BossInfo, {NpcId, HpMax, HpMax})
	end,
	put(boss_info, BossInfo2).

boss_update(NpcId, Hp) ->
	BossInfo = get(boss_info),
	BossInfo2 = case lists:keyfind(NpcId, 1, BossInfo) of
		false ->
			nothing;
		{NpcId, HpMax, _} ->
			case get(map_proc) of
				undefined ->
					nothing;
				MapProc ->
					RoleList = mapop:get_map_roles_id_by_proc(MapProc),
					Msg = dead_valley_packet:encode_dead_valley_boss_hp_update_s2c(NpcId, HpMax, Hp),
					lists:foreach(fun(RoleId) ->
						role_pos_util:send_to_role_clinet(RoleId, Msg)
					end, RoleList)
			end,
			lists:keyreplace(NpcId, 1, BossInfo, {NpcId, HpMax, Hp})
	end,
	put(boss_info, BossInfo2).

role_come(RoleId) ->
	lists:foreach(fun({NpcId, HpMax, Hp}) ->
		Msg = dead_valley_packet:encode_dead_valley_boss_hp_update_s2c(NpcId, HpMax, Hp),
		role_pos_util:send_to_role_clinet(RoleId, Msg)
	end, get(boss_info)).