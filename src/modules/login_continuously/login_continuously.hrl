%% Copyright
-record(logincontinuously, {day, normal_rward, pay_rward}).

-record(role_logincontinuously, {roleid, login_date, counte, normal_log, pay_log}).

-record(role_logincnt_table, {tablename, roleid, login_date, counter, normal_log, pay_log}).

-define(CONFIG, logincontinuously).
-define(ROLEDATA, role_logincontinuously).
-define(ROLETABLE, role_logincnt_table).

-define(GET_FAIL, 1).
-define(GET_SUCC, 2).

-define(NORMAL, 0).
-define(PAY, 1).

-define(HASGOTGIFT_Y, 1).
-define(HASGOTGIFT_N, 0).
