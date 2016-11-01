-module(charge_reward_packet).

-include("login_pb.hrl").

-compile(export_all).


%% @doc 获取6重礼包领取状态
handle(Message=#charge_reward_init_c2s{},RolePid)->
	RolePid ! {charge_reward_init};
%% @doc 领取6重礼包
handle(Message=#get_charge_reward_c2s{id=Id},RolePid)->
	RolePid ! {get_charge_reward, Id}.

%% @doc 返回6重礼包领取状态s-->c
encode_charge_reward_init_s2c(ChargeNum,State) ->
	login_pb:encode_charge_reward_init_s2c(#charge_reward_init_s2c{chargenum=ChargeNum,state=State}).

%% @doc 领取6重礼包结果
encode_get_charge_reward_s2c(Result,ChargeNum,State)->
	login_pb:encode_get_charge_reward_s2c(#get_charge_reward_s2c{res=Result,chargenum=ChargeNum,state=State}).
