%%%----------------------------------------------------------------------
%%%
%%% @author  kebo
%%% @date  2012.09.17
%%% @doc 首充6重礼包相关
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(charge_package_packet).

-include("charge_package_def.hrl").

-compile(export_all).


%% @doc 获取6重礼包领取状态
handle(Message=#charge_package_init_c2s{},RolePid)->
	RolePid ! {charge_package_init};
%% @doc 领取6重礼包
handle(Message=#get_charge_package_c2s{id=Id},RolePid)->
	RolePid ! {get_charge_package, Id}.

%% @doc 返回6重礼包领取状态s-->c
encode_charge_package_init_s2c(Gold,Info) ->
	Info2 = [{0, Id, Status} ||{Id, Status} <- Info],
	login_pb:encode_charge_package_init_s2c(#charge_package_init_s2c{gold=Gold,info=Info2}).

%% @doc 领取6重礼包结果
encode_get_charge_package_s2c(Res)->
	login_pb:encode_get_charge_package_s2c(#get_charge_package_s2c{res=Res}).

%% @doc 玩家平台充值后，通知前端金额改变信息
encode_charge_package_gold_change_s2c(Gold)->
	login_pb:encode_charge_package_gold_change_s2c(#charge_package_gold_change{gold=Gold}).

	
	
	
	
	

