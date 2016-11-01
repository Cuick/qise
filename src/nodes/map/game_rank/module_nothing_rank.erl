-module (module_nothing_rank).

-export([load_from_data/1,can_challenge_rank/1,challenge_rank/2,send_rank_list/1,gather/2,refresh_gather/0,is_top/1,after_gather/0]).

%%
%% API Functions
%%
load_from_data(_) ->
	nothing.

fold_list(_)->
	nothing.

make_rank(_)->
	nothing.

can_challenge_rank(_)->
	nothing.

challenge_rank(_,_) ->
	nothing.

is_top(RoleId)->
	nothing.

gather(RoleId,Score)->
	nothing.

refresh_gather()->
	nothing.
	
send_rank_list(RoleId) ->
	nothing.

after_gather() ->
    nothing.