-module(giftcard_packet).

%%
%% Include files
%%

-export([		
		handle/2,
		encode_gift_card_apply_s2c/1,
		encode_gift_card_state_s2c/2
		]).

-include("login_pb.hrl").
-include("data_struct.hrl").

handle(#gift_card_apply_c2s{key=Key,type=Type},RolePid)->
	role_processor:gift_card_apply_c2s(RolePid,Key,Type).

encode_gift_card_apply_s2c(Errno)->
	login_pb:encode_gift_card_apply_s2c(#gift_card_apply_s2c{errno = Errno}).

encode_gift_card_state_s2c(WebUrl,State)->
	login_pb:encode_gift_card_state_s2c(#gift_card_state_s2c{weburl = WebUrl,state = State}).