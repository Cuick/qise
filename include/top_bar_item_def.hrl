%% top bar item type
-define (HOT_BAR_ITEM_PERMANENT, 1).
-define (HOT_BAR_ITEM_CONDITION, 2).
-define (HOT_BAR_ITEM_ACTIVITY, 3).
-define (HOT_BAR_ITEM_INSTANCE_NORMAL, 4).
-define (HOT_BAR_ITEM_INSTANCE_LOOP, 5).

%% top bar item id
-define (TOP_BAR_ITEM_TARGET, 1).
-define (TOP_BAR_ITEM_PET_HOTEL, 2).
-define (TOP_BAR_ITEM_PET_SHOP, 3).
-define (TOP_BAR_ITEM_JACKAROO, 4).
-define (TOP_BAR_ITEM_FIRST_CHARGE, 5).
-define (TOP_BAR_ITEM_REPEAT_CHARGE, 6).
-define (TOP_BAR_ITEM_LEVEL_GIFT, 7).
-define (TOP_BAR_ITEM_OPEN_SERVER, 8).
-define (TOP_BAR_ITEM_COMBINE_SERVER, 9).
-define (TOP_BAR_ITEM_LOTTERY, 10).
-define (TOP_BAR_ITEM_TRAVEL_BATTLE, 11).
-define (TOP_BAR_ITEM_AUCTION, 12).
-define (TOP_BAR_ITEM_FESTIVAL_1, 15).
-define (TOP_BAR_ITEM_FESTIVAL_2, 16).
-define (TOP_BAR_ITEM_FESTIVAL_3, 17).
-define (TOP_BAR_ITEM_TRAVEL_MATCH_1, 18).
-define (TOP_BAR_ITEM_DEAD_VALLEY, 21).
-define (TOP_BAR_ITEM_INSTANCE_CHESS_SPIRIT, 80).                 %% 杀手楼
-define (TOP_BAR_ITEM_INSTANCE_LEVEL_40, 81).                     %% 红魔溪
-define (TOP_BAR_ITEM_INSTANCE_TRAILNING, 82).                    %% 围猎场
-define (TOP_BAR_ITEM_INSTANCE_SUPPORT_OFFICE, 83).               %% 内务府
-define (TOP_BAR_ITEM_INSTANCE_50, 84).                           %% 冰蛇帐
-define (TOP_BAR_ITEM_INSTANCE_MONEY, 85).                        %% 销金窟
-define (TOP_BAR_ITEM_INSTANCE_FIRE_CAVE, 86).                    %% 烈火溶洞                
-define (TOP_BAR_ITEM_INSTANCE_LEVEL_60, 87).                     %% 火蜥沼泽
-define (TOP_BAR_ITEM_INSTANCE_LEVEL_70, 88).                     %% 毛任丘
-define (TOP_BAR_ITEM_INSTANCE_LEVEL_TOWER, 89).                  %% 断金山


%% activity type
-define (ACTIVITY_FIGHT_FORCE_RANK, 1).
-define (ACTIVITY_LEVEL_RANK, 2).
-define (ACTIVITY_GOLD_EQUIPMENTS, 3).
-define (ACTIVITY_CHARGE, 4).
-define (ACTIVITY_CONSUMPTION, 5).
-define (ACTIVITY_LOTTERY, 6).
-define (ACTIVITY_ALL_USER, 7).
-define (ACTIVITY_MALL_UP_SALE,8).
-define (ACTIVITY_CONFIG_UPDATE,9).
-define (ACTIVITY_DOUBLE_EXP,10).
-define (ACTIVITY_JUST_FOR_SHOW,11).
-define (ACTIVITY_GOD_TREE,12).
-define (ACTIVITY_FESTIVAL_OF_LANTERNS,13).
-define (ACTIVITY_REWARD_ARM,14).

%% activity award way
-define (ACTIVITY_AWARD_CLICK, 1).
-define (ACTIVITY_AWARD_MAIL, 2).
-define (ACTIVITY_AWARD_PACKAGE, 3).
-define (ACTIVITY_AWARD_NOTHING, 4).

%% activity award get times
-define (ACTIVITY_AWARD_MANY_TIMES, 1).
-define (ACTIVITY_AWARD_ONE_TIME, 2).
-define (ACTIVITY_AWARD_ONE_TIME_PER_DAY, 3).

%% activity award time
-define (ACTIVITY_AWARD_LOGIN, 0).
-define (ACTIVITY_AWARD_PROMPT, 1).
-define (ACTIVITY_AWARD_DEADLINE, 2).
-define (ACTIVITY_AWARD_LOGIN_OR_DELAY, 3).
-define (ACTIVITY_AWARD_DEADLINE_OR_DELAY, 4).
-define (ACTIVITY_AWARD_ANYTIME, 5).
-define (ACTIVITY_AWARD_LOGIN_OR_PROMPT, 6).
-define (ACTIVITY_AWARD_DURATION, 7).

-define (ACTIVITY_STATE_OPEN, 1).
-define (ACTIVITY_STATE_WAIT, 0).

-define(EQUIP_TYPE_GOLD,4).         %%金装的品质

-define (ACTIVITY_AWARD_SHOW_NORMAL, 1).
-define (ACTIVITY_AWARD_SHOW_MULTI, 2).

-record (temp_activity_content, {activity_id, type, start_time, end_time, award_show_type, awards, send_type, sid ,condition}).
-record (awards_struct, {min, max, item_list}).
-record (ac, {id,duration,pos}).
