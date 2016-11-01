-ifndef(BASE_DEFINE_H).
-define(BASE_DEFINE_H,true).
%% 日志记录定义
-define(INFO(F,D), ( slogger:msg("Info: M :~p  , L:~p " ++ F, [?MODULE, ?LINE | D]) )).
-define(INFO(F),   ( slogger:msg("Info: M :~p  , L:~p " ++ F, [?MODULE, ?LINE]) )).

-define(ERLNULL,undefined).

-endif. % BASE_DEFINE_HRL