%%%----------------------------------------------------------------------
%%%
%%% @copyright wg
%%%
%%% @author huang.kebo@gmail.com
%%% @doc wg header file used by user
%%%
%%%----------------------------------------------------------------------
-ifndef(WG_HRL).
-define(WG_HRL, true).

-ifdef(EUNIT).
-include_lib("eunit/include/eunit.hrl").
-endif.

%% Print in standard output
-define(PRINT(Format, Args),
    io:format(Format, Args)).

%% syntax similar with ?: in c
-ifndef(IF).
-define(IF(C, T, F), (case (C) of true -> (T); false -> (F) end)).
-endif.

%% 如果条件为true就执行，否则返回false
-ifndef(IF2).
-define(IF2(C, T), ((C) andalso (T))).
-endif.

%% some convert macros
-define(B2S(B), (binary_to_list(B))).
-define(S2B(S), (list_to_binary(S))).
-define(N2S(N), integer_to_list(N)).
-define(S2N(S), list_to_integer(S)).
-define(N2B(N), ?S2B(integer_to_list(N))).
-define(B2N(B), list_to_integer(?B2S(B))).

-define(A2S(A), atom_to_list(A)).
-define(S2A(S), list_to_atom(S)).
-define(S2EA(S), list_to_existing_atom(S)).

%%
%% 当进行dialyzer时用来屏蔽ets concurrency_read属性
%%
%%-ifdef(DIALYZER).
%-define(ETS_CONCURRENCY, {write_concurrency, true}).
-define(ETS_CONCURRENCY, {read_concurrency, true}).
%-else.
%-define(ETS_CONCURRENCY, {read_concurrency, true}, {write_concurrency, true}).
%-endif.

-define(NOW, (timer_util:now_to_seconds(timer_center:get_correct_now()))).

%% 退出
-define(EXIT(C), timer:sleep(100), init:stop(C)).


-endif. % WG_HRL
