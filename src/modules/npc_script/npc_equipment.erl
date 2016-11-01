-module (npc_equipment).

-export ([init/0]).

init() ->
	ProtoInfo = dead_valley_db:get_proto_info(),
	ExpireTime = dead_valley_db:get_expire_time(ProtoInfo),
	erlang:send_after(ExpireTime, self(), {forced_leave_map}).