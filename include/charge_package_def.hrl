%% kebo
%%开服7天活动时间，默认的秒数
-define(START_SERVER_ACTIVITY_SECS,60 * 60 * 24 * 7).

-define(SUCCESS,1).	
%% 6重礼包策划定义表
-record(charge_package_proto,{id,gold,item_id}).
-record(charge_package_syschat_id_proto, {id, syschat_id}).
%% 6重礼包玩家信息表
-record(charge_package_info_db,{roleid,info}).

% 玩家6重礼包
-record(charge_package_init_c2s, {msgid=1880}).

%% 玩家6重礼包状态
-record(charge_package_init_s2c, {
	msgid=1881,
	gold, % 充值金币
	info  % 礼包状态
}).

%% 礼包领取信息
-record(get_charge_package_c2s, {
	msgid=1882,
	id % 领取6重礼包的id
}).

%% 礼包领取结果
-record(get_charge_package_s2c, {
	msgid=1883,
	res % 领取礼包结果
}).

% 充值元宝数变化
-record(charge_package_gold_change,{
	msgid=1884,
	gold
}).

%% 玩家充值活动金额，玩家id， 最后充值时间，账户充值总金额
-record(user_payment_active, {roleid, last_time, sumgold}).
%% 充值活动定义,活动id， 开始时间，持续天数
-record(payment_active_proto, {id = 0, start_time=0, days=0}).
