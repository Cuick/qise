%% match mode
-define (TRAVEL_MATCH_TYPE_SINGLE, 1).
-define (TRAVEL_MATCH_TYPE_TEAM, 2).

%% match state
-define (TRAVEL_MATCH_STATE_NOT_START, -1).
-define (TRAVEL_MATCH_STATE_READY, -2).
-define (TRAVEL_MATCH_STATE_GOING, -3).
-define (TRAVEL_MATCH_STATE_END, -4).

%% match stage
-define (TRAVEL_MATCH_STAGE_REGISTER, 1).
-define (TRAVEL_MATCH_STAGE_AUDITION, 2).
-define (TRAVEL_MATCH_STAGE_TRIAL, 3).
-define (TRAVEL_MATCH_STAGE_REPLAY, 4).
-define (TRAVEL_MATCH_STAGE_SEMIFINAL, 5).
-define (TRAVEL_MATCH_STAGE_FINAL, 6).

%% rank 
-define (TRAVEL_MATCH_RANK_PROMOTION, -1).
-define (TRAVEL_MATCH_RANK_WAIT, -2).
-define (TRAVEL_MATCH_RANK_LOSS, -3).

-define (TRAVEL_MATCH_REGITSER_OK, 0).
-define (TRAVEL_MATCH_NOT_REGISTERED, 1).

-define (TRAVEL_MATCH_RESULT_WIN, 0).
-define (TRAVEL_MATCH_RESULT_LOSS, 1).

-record (stage_rank_info, {stage,points,rank}).
-record (level_awards, {champion = 0,second_place = 0,third_place = 0}).
-record (travel_match_player, {role_id,role_name,gender,class,level,fight_force}).
-record (travel_match_rank, {role_id,role_name,gender,class,level,fight_force,rank,gold}).