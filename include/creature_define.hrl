%%生物状态
-define(CREATURE_STATE_DEAD,0).						%%死亡
-define(CREATURE_STATE_GAME,1).						%%正常
-define(CREATURE_STATE_BLOCK_TRAINING,2).			%%密修打坐
-define(CREATURE_STATE_SITDOWN,3).					%%打坐
-define(CREATURE_STATE_DANCING,4).					%%跳舞

%%生物标志
-define(CREATURE_ROLE,0).				        %%玩家
-define(CREATURE_NPC,1).				        %%npc
-define(CREATURE_MONSTER,2).			        %%怪物
-define(CREATURE_COLLECTION,3).			        %%可采集的物体
-define(CREATURE_PET,4).				        %%宠物
-define(CREATURE_YHZQ_NPC,5).			        %%永恒之旗战场特殊NPC
-define(CREATURE_THRONE,6).				        %%战场王座
-define(CREATURE_KING_STATUE,7).		        %%国王雕像
-define(CREATURE_PICKUP_BUFF,8).                %%BUFF NPC
-define(CREATURE_EFFECT,10).                    %%特效 NPC
-define(CREATURE_DEAD_VALLEY_BOSS,-1).          %%死亡之谷BOSS
-define(CREATURE_DEAD_VALLEY_MONSTER,-2).       %%死亡之谷小怪
-define(CREATURE_EQUIPMENT,12).                 %%装备
-define(CREATURE_TRAP,13).                      %%陷阱

-define(DEFAULT_MAX_DISTANCE,10000000).	%%查找最近时的默认距离
