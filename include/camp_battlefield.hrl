-define(GOD_GROUP, 10).			% 仙方
-define(DEVIL_GROUP, 20).		% 魔方

-record(camp_battlefield_minor_config, {
		counter,					% 玩家死亡次数(-1表示玩家离开战场)
		buffer_list					% buffer列表
	}).
