%%% -------------------------------------------------------------------
%%% Author  : kebo
%%% @doc 首充6重礼包相关
%%% @end
%%% Created : 2012-9-11
%%% -------------------------------------------------------------------
-module(charge_package_db).

-export([start/0,create_mnesia_table/1,delete_role_from_db/1,tables_info/0,create_mnesia_split_table/2]).
-export([init/0,create/0]).

%% 礼包相关
-export([get_charge_package_proto_info/1,
		get_all_charge_package_proto_info/0,
		get_charge_package_info/1,
		sync_updata/2,
		get_active_start_time/0, 
		get_active_end_time/0, 
		add_payment_gold/2, 
		reset_payment_gold/1, 
		load_player_payment_gold/1,
		get_current_payment_active/0,
        get_charge_package_syschat_id_proto_info/1
	]).
%% 礼包ets表
-define(ETS_TABLE_NAME,'charge_package_proto_ets').
-define(PAYMENT_ACTIVE_TNAME, 'payment_active_proto_ets').
-define(ETS_CHARGE_PACKAGE_SYSCHAT_ID_PROTO, charge_package_syschat_id_proto_ets).

-include("charge_package_def.hrl").
-include("base_define.hrl").
-include("wg.hrl").


-behaviour(db_operater_mod).
-behaviour(ets_operater_mod).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 				behaviour functions 回调函数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start()->
	db_operater_mod:start_module(?MODULE,[]).

create_mnesia_table(disc)->
	db_tools:create_table_disc(charge_package_proto, record_info(fields,charge_package_proto), [], set),
	db_tools:create_table_disc(payment_active_proto, record_info(fields,payment_active_proto), [], set),
	db_tools:create_table_disc(user_payment_active, record_info(fields,user_payment_active), [], set),
	db_tools:create_table_disc(charge_package_info_db, record_info(fields, charge_package_info_db), [], set),
    db_tools:create_table_disc(charge_package_syschat_id_proto, record_info(fields, charge_package_syschat_id_proto), [], set).
	
tables_info()->
	[{charge_package_proto, proto}, {payment_active_proto, proto}, {user_payment_active, disc}, 
	{charge_package_info_db, disc}, {charge_package_syschat_id_proto, disc},
	{charge_package_time, proto}].

delete_role_from_db(RoleId)->
	 dal:delete_rpc(charge_package_info_db,RoleId).


create_mnesia_split_table(_,_)->
	nothing.

create()->
	ets:new(?PAYMENT_ACTIVE_TNAME,[public,set,named_table]),
	ets:new(?ETS_TABLE_NAME,[public,set,named_table]),
    ets:new(?ETS_CHARGE_PACKAGE_SYSCHAT_ID_PROTO, [public,set,named_table]).

init()->
	db_operater_mod:init_ets(payment_active_proto, ?PAYMENT_ACTIVE_TNAME,#payment_active_proto.id),
	db_operater_mod:init_ets(charge_package_proto, ?ETS_TABLE_NAME,#charge_package_proto.id),
    db_operater_mod:init_ets(charge_package_syschat_id_proto, ?ETS_CHARGE_PACKAGE_SYSCHAT_ID_PROTO,#charge_package_syschat_id_proto.id).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%% 				behaviour functions end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc 根据id获取6重礼包信息	
get_charge_package_proto_info(Id)->
	case ets:lookup(?ETS_TABLE_NAME,Id) of
		[]->[];
		[{_Id,Info}] -> Info
	end.

%% @doc 根据id获取6重礼包的广播信息
get_charge_package_syschat_id_proto_info(Id) ->
    case ets:lookup(?ETS_CHARGE_PACKAGE_SYSCHAT_ID_PROTO, Id) of
        []->[];
        [{_Id,Info}] -> Info
    end.

%% @doc 获取所有的6重礼包信息
get_all_charge_package_proto_info()->
	case ets:tab2list(?ETS_TABLE_NAME) of
		[]->[];
        OriInfos-> [ Info || {_Id, Info} <- OriInfos]
	end.

get_current_payment_active() ->
	case ets:tab2list(?PAYMENT_ACTIVE_TNAME) of
		[]-> 
			#payment_active_proto{};
        [{Id,PaymentInfo}] -> 
        	#payment_active_proto{start_time = StartTime} = PaymentInfo,
         	Dlocal= calendar:universal_time_to_local_time({{1970, 1, 1},{0,0,0}}),  %当地1970年
    		D1970 = calendar:datetime_to_gregorian_seconds(Dlocal),
    		StartTime0   = calendar:datetime_to_gregorian_seconds(StartTime),
    		ServerStartSecs = StartTime0 - D1970,
        	PaymentInfo#payment_active_proto{start_time = ServerStartSecs}
        	
	end.

%% @doc 根据角色id获取玩家6重礼包领取信息
get_charge_package_info(RoleId)->
	case dal:read_rpc(charge_package_info_db,RoleId) of
		{ok,[]}-> [];
		{ok,[Info]}-> Info;
		{failed,badrpc,Reason}-> slogger:msg("get_invite_friend_bonus failed ~p:~p~n",[badrpc,Reason]),[];
		{failed,Reason}-> slogger:msg("get_invite_friend_bonus failed :~p~n",[Reason]),[]
	end.
%% @doc 把term写到数据库中。
sync_updata(_RoleId, Term) when is_record(Term,charge_package_info_db) ->
	try
		dal:write_rpc(Term) 
	catch
		E:R->
			?INFO("error ~p reason~p~n ", [E, R]),
			error
	end;
sync_updata(RoleId, Term) ->
	try
		Object = util:term_to_record({RoleId,Term},charge_package_info_db),
		dal:write_rpc(Object)
	catch
		E:R->
			?INFO("error ~p reason~p~n ", [E, R]),
			error
	end.

%% @doc获取充值活动开启时间(秒)
get_active_start_time() ->
	#payment_active_proto{start_time = StartTime} = get_current_payment_active(),
	StartTime.
%% @doc 获取充值互动结束时间(秒)
get_active_end_time() ->
	#payment_active_proto{start_time = StartTime, days = Days} = get_current_payment_active(),
	StartTime + Days* 24* 60* 60.

%% @doc 添加玩家的充值活动金额
add_payment_gold(NewQqGold, RoleId) ->
	case dal:read_rpc(user_payment_active,RoleId) of
		{ok,[]}-> 
			Object  = #user_payment_active{roleid = RoleId, last_time = ?NOW, sumgold = NewQqGold},
			?INFO(" player payment active:~p,~n", [Object]),
			dal:write_rpc(Object);
		{ok,[Info]}-> 
			#user_payment_active{last_time = LastTime, sumgold = Sumgold} = Info,
			Info2 = case (LastTime >= get_active_start_time() andalso LastTime =<  get_active_end_time()) of
					true ->
						Info#user_payment_active{last_time = ?NOW, sumgold = Sumgold + NewQqGold};
					false ->
						Info#user_payment_active{last_time = ?NOW, sumgold = NewQqGold}
					end,
			dal:write_rpc(Info2);
		{failed,badrpc,Reason}-> slogger:msg("get_invite_friend_bonus failed ~p:~p~n",[badrpc,Reason]),[];
		{failed,Reason}-> slogger:msg("get_invite_friend_bonus failed :~p~n",[Reason]),[]
	end.

%% @doc 重置玩家的充值活动金额记录
reset_payment_gold(RoleId) ->
	Object  = #user_payment_active{roleid = RoleId, last_time = ?NOW, sumgold = 0},
	?INFO(" player payment active:~p,~n", [Object]),
	dal:write_rpc(Object).

%% @doc 玩家的活动期间的充值总金额
load_player_payment_gold(RoleId) ->	
	case dal:read_rpc(user_payment_active,RoleId) of
		{ok,[]}-> 
			0;			
		{ok,[Info]}-> 
			#user_payment_active{last_time = LastTime, sumgold = Sumgold} = Info,
			Sumgold;
		{failed,badrpc,Reason}-> throw({error, 'badrpc'});
		{failed,Reason}-> throw({error, Reason})
	end.
