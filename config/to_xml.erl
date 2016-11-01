-module(to_xml).
-export([start/1]).

start(File) ->
    case file:consult(File) of
        {ok,Contents} ->
            lists:foreach(fun(Content) ->
                              Content
            end,Contents);
        {error,Reason} ->
            Reason
    end.
   
   
