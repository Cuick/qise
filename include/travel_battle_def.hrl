-define (TRAVEL_BATTLE_ROLE_NOT_IN_RANK, -1).
-define (TRAVEL_BATTLE_ROLE_RANK_NOT_AVAILIABLE, -2).

-define (TRAVEL_BATTLE_REGISTER_SUCESS, 1).
-define (TRAVEL_BATTLE_REGISTER_WAIT, 2).

-define (TRAVEL_BATTLE_OVERLOAD_CHECK_INTERVAL, 10000).

-define (TRAVEL_BATTLE_INSTANCE_ROLE_NUM, 3).

-define (TRAVEL_BATTLE_ROLE_MATCH, 0).
-define (TRAVEL_BATTLE_ROLE_BATTLE, 1).
-define (TRAVEL_BATTLE_ROLE_FAILED, 2).

-define (TRAVEL_BATTLE_DEAD_LEAVE_MAP_TIME, 2000).

-define (TRAVEL_BATTLE_FORECAST_BEGIN_TIME, 2 * 60).
-define (TRAVEL_BATTLE_FORECAST_END_TIME, 5 * 60).

-define (NPC_TRAVEL_BATTLE_CHECK_INTERVAL, 1000).
-define (NPC_TRAVEL_BATTLE_SECTION_PREPARE, 0).

-define (NPC_TRAVEL_BATTLE_SECTION_BATTLE, 1).

-define (TRAVEL_BATTLE_BUFF_SHOW_DURATION, 60).

-define (TRAVEL_BATTLE_END_CHECK_DELAY, 500).

-define (TRAVEL_BATTLE_PICKUP_BUFF_RANGE, 10).

-define (TRAVEL_BATTLE_RANK_LENGTH, 100).

-define (TRAVEL_BATTLE_PAGE_SHOW_COUNT, 9).

-define (TRAVEL_BATTLE_RANK_INTERVAL, (10 * 60 * 1000)).

-define (TRAVEL_BATTLE_RANK_RECOMPUTE_NUM, 30).

-define (TRAVEL_BATTLE_SERIAL_WIN_AWARD_NONE, 0).
-define (TRAVEL_BATTLE_SERIAL_WIN_AWARD_PACKAGE, 1).
-define (TRAVEL_BATTLE_SERIAL_WIN_AWARD_MAIL, 2).

-define (TRAVEL_BATTLE_RESULT_WINNER, 1).
-define (TRAVEL_BATTLE_RESULT_LOSSER, 2).

-define (TRAVEL_BATTLE_NEXT_SECTION_CHECK_TRUE, 0).
-define (TRAVEL_BATTLE_NEXT_SECTION_CHECK_FALSE, 1).

-define (TRAVEL_BATTLE_SHOP_BUY_BROADCAST_BASE, 1000).
-define (TRAVEL_BATTLE_SERIAL_WIN_OVER_BASE, 3).

-define (TRAVEL_BATTLE_BUFF_TIME, 2 * 60).

-record (travel_battle_role_rank_info, {name,gender,class,scores,sid}).

%% 跨服战公告类型
-define (TRAVEL_BATTLE_NOTICE_SERIAL_WIN, 1).
-define (TRAVEL_BATTLE_NOTICE_SERIAL_OVER, 2).
-define (TRAVEL_BATTLE_NOTICE_STAGE_RANK, 3).
-define (TRAVEL_BATTLE_NOTICE_MONTH_RANK, 4).
-define (TRAVEL_BATTLE_NOTICE_SHOP_BUY, 5).
