-define (DEAD_VALLEY_START_FORECAST, (5 * 60)).
-define (DEAD_VALLEY_END_FORECAST, (5 * 60 * 1000)).

-define (DEAD_VALLEY_EQUIPMENT_PICK_UP_RANGE, 10).

-define (DEAD_VALLEY_TRAP_TOUCH_RANGE, 5).
-define (DEAD_VALLEY_TRAP_LEAVE_RANGE, 2).

-define (DEAD_VALLEY_DATA_OVERDUE_TIME, 60 * 60 * 2).


-define (DEAD_VALLEY_BUFF_TIME, 60 * 2).

-record (dead_valley_zone, {id,num,max}).