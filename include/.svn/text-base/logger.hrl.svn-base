%% Copyright
-author("zhuo.yan").

%%-----------------------------------------------------------------
%% ?LOG_INFO("~p", ["test"]) -> test.
%% ?LOG_INFO("test") -> test.
%% ?LOG_INFO2([a, b, c]) -> a b c.
%%-----------------------------------------------------------------

%% -ifdef(ldebug).
-define(LOG_INFO(FORMAT, DATA), erlang:apply(error_logger, info_msg, [lists:concat(["[INFO]		module: ", ?MODULE, "~n		line: ", ?LINE, "~n", FORMAT, "~n"]), DATA])).
-define(LOG_INFO(Str), ?LOG_INFO(Str, [])).
-define(LOG_INFO2(L), ?LOG_INFO(lists:concat(lists:duplicate(erlang:length(L), "~p ")), L)).
%% -else.
%% -define(LOG_INFO(FORMAT, DATA), ok).
%% -define(LOG_INFO(Str), ok).
%% -define(LOG_INFO2(L), ok).
%% -endif.