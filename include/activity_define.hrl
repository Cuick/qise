%%@spec activity define
-define(BUFFER_TIME_S,120).
-define(ACTIVITY_STATE_START,1).
-define(ACTIVITY_STATE_STOP,2).
-define(ACTIVITY_STATE_REWARD,3).
-define(ACTIVITY_STATE_INIT,4).
-define(ACTIVITY_STATE_SIGN,5).
-define(ACTIVITY_STATE_END,6).
-define(CANDIDATE_NODES_NUM,2).
-define(START_TYPE_DAY,1).
-define(START_TYPE_WEEK,2).
-define(CHECK_TIME,10000). %%check per 10s
%%
%%add new activity  please modify ACTIVITY_MAX_INDEX !!!!!!!
%%
-define(ANSWER_ACTIVITY,1).
-define(TEASURE_SPAWNS_ACTIVITY,2).
-define(TANGLE_BATTLE_ACTIVITY,3).
-define(YHZQ_BATTLE_ACTIVITY,4).
-define(DRAGON_FIGHT_ACTIVITY,5).
-define(STAR_SPAWNS_ACTIVITY,6).
-define(RIDE_SPAWNS_ACTIVITY,7).
-define(TREASURE_TRANSPORT_ACTIVITY,8).
-define(BANQUET_ACTIVITY,9).
-define(JSZD_BATTLE_ACTIVITY,10).
-define(GUILD_INSTANCE_ACTIVITY,11).
-define(CAMP_BATTLE_ACTIVITY,12).
-define(ACTIVITY_MAX_INDEX,?CAMP_BATTLE_ACTIVITY).  %% !!!!!!!!!!!!!!!!!

%%banquet
-define(BANQUET_DEFAULT_ID,1).
-define(BANQUET_PASSIVE_COUNT,10).
-define(BANQUET_COOL_TIME,120000).
-define(BANQUET_ROLE_STATE_JOIN,1).
-define(BANQUET_ROLE_STATE_LEAVE,0).
-define(BANQUET_TOUCH_TYPE_DANCING,1).
-define(BANQUET_TOUCH_TYPE_CHEERING,2).
-define(BANQUET_TYPE_PET_SPAWNING,3).
%%treasure_spawns
-define(TREASURE_SPAWNS_DEFAULT_LINE,1).
-define(TREASURE_SPAWNS_TYPE_CHEST,1).		%%treasure chest
-define(TREASURE_SPAWNS_TYPE_STAR,2).		%%treasure star
-define(TREASURE_SPAWNS_TYPE_RIDE,3).		%%treasure ride

-define(ACTIVITY_FORECAST_TIME_S,5*60). 	%%5min

-define(ANSWER_DOUBLE, 3).					% 答题双倍次数
-define(ANSWER_AUTO, 3).					% 自动答题次数

-define(TANGLE_BATTLE_BUFFER_TIME_S, 6).
-define(CAMP_BATTLE_BUFFER_TIME_S, 6).
%%
-define(TYPE_CHRISTMAS_ACTIVITY,1).
