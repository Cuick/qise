%%%-------------------------------------------------------------------
%%% @author kebo
%%% @data  2012.09.12
%%% @doc vip相关,参考vip系统文档
%%% @end
%%%-------------------------------------------------------------------
-module(vip_op).

-export([export_for_copy/0,load_by_copy/1,write_to_db/0,
		 load_from_db/1,vip_init/0,
		 get_role_vip/0,get_role_vip_ext/1,
		 vip_ui_c2s/0,vip_reward_c2s/0,
		 login_bonus_reward_c2s/0,add_sum_gold/2,
		 get_addition_with_vip/1,
		 npc_function/0,check_vip_level/1,vip_level_up_s2c/0,
		 system_bodcast/2,viptag_update/0,
		 check_vip_level_up_of_pid/1,check_vip_level_up/2,
		 sys_cast/2,is_vip/0,get_role_sum_gold/1,get_role_viplevel/0,
		 get_adapt_flytimes/1,check_have_vip_addition/0,hook_on_offline/0,join_vip_map/1]).

%% vip进程字典数据相关
-export([set_player_vip/1, get_player_vip/0]).

-include("error_msg.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("common_define.hrl").
-include("system_chat_define.hrl").
-include("vip_define.hrl").
-include("mnesia_table_def.hrl").


-define(DEFAULT_VIP_DATA, []).

init_vip_role()->
	set_player_vip(?DEFAULT_VIP_DATA).

init_role_login_bonus(RoleId)->
	put(role_login_bonus,{RoleId,0}).

%% @doc 从数据库中加载玩家的vip数据，放在进程字典中。
%% 1. 获取vip数据，如果没有，则设置为空
%% 2. 如果玩家是vip用户
%% 2a. 检查是否过期，过期则置空
%% 2b. 未过期则判断最后登录使用时间是否为今天
%% 2b-1. 是今天 ，则设置vip数据
%% 2b-2  不是今天 ，则重新计算小飞鞋的使用类型，并保存
load_from_db(RoleId)->
	case vip_db:get_vip_role(RoleId) of
		% 1
		{ok,[]}->
			init_vip_role();
		% 2
		{ok, #vip_role{
				roleid = RoleId,
				start_time = StartTime,
				duration = Duration,
				level = Level,
				logintime = LoginTime
			} = VipRole
		}->
			Now = timer_center:get_correct_now(),
			{MSec,Sec,_}=Now,
			CurSec = MSec*1000000+Sec,
			if
				% 2a
				CurSec > StartTime + Duration->
					vip_db:delete_vip_role(RoleId),
					pet_hostel:delete_vip_room(Level),
					init_vip_role();
				% 2b
				true->
					case timer_util:check_same_day(Now, LoginTime) of
						true->
							% 2b-1
							set_player_vip(VipRole);
						_->
							% 2b-2
							FlyShoes = get_adapt_flytimes(Level),
							set_player_vip(VipRole#vip_role{flyshoes = FlyShoes,logintime=Now})
					end
			end;
		_->
			init_vip_role()
	end,

	case vip_db:get_role_login_bonus(RoleId) of
		{ok,[]}->
			init_role_login_bonus(RoleId),
			vip_db:sync_update_role_login_bonus_to_mnesia(RoleId, {RoleId,0});
		{ok,RoleLoginBonus}->
			{role_login_bonus,RoleId,LoginBonusTime} = RoleLoginBonus,			
			put(role_login_bonus,{RoleId,LoginBonusTime});
		_->
			init_role_login_bonus(RoleId)
	end.

%% @doc 根据vip等级获取玩家的小飞鞋使用次数
get_adapt_flytimes(Level)->
	case vip_db:get_vip_level_info(Level) of
		[]->
			{0,0};
		{_,_,_,Addition,_}->
			case lists:keyfind(flyshoes,1,Addition) of
				false->
					{0,0};
				{_,{Type,Times}}->
					{Type,Times}
			end
	end.
%% @doc 获取玩家的vip等级
get_role_viplevel()->
	case get_player_vip() of
		[]->
			0;
		#vip_role{level = Level}->
			Level
	end.
%% @doc 离线回调，把vip状态同步写到mnesia数据库中
hook_on_offline()->
	case get_player_vip() of
		[]->
			ignor;
		#vip_role{roleid = RoleId} = VipRole->
			vip_db:sync_update_vip_role_to_mnesia(RoleId, VipRole)
	end.
%% @doc 检查登录奖励次数
check_login_bonus_time()->
	case get(role_login_bonus) of
		{_RoleId,LoginBonusTime}->
			case check_bonus_date(LoginBonusTime) of
				true->
					0;
				false->
					1
			end;
		_->
			0
	end.
%% @doc 玩家vip数据初始化
vip_init()->
	LoginBonus = check_login_bonus_time(),
	case get_player_vip() of
		[]->
			vip_init_s2c(0,0,LoginBonus);
		#vip_role{level = Level, bonustime = BonusTime} ->
			case check_bonus_date(BonusTime) of
				true->
					vip_init_s2c(Level,0,LoginBonus);
				false->
					vip_init_s2c(Level,1,LoginBonus)
			end
	end.
%%　@doc 获取玩家的vip等级，接口用
get_role_vip()->
	get_role_viplevel().

%%vip level ext {1,2,3,4}={HALFYEAR,SEASON,MONTH,WEEK}
%% @doc 根据vip等级计算vip卡的类型
get_role_vip_ext(VipLevel)->
	case VipLevel of
		?ITEM_TYPE_VIP_CARD_MONTH->
			3;
		?ITEM_TYPE_VIP_CARD_SEASON->
			2;
		?ITEM_TYPE_VIP_CARD_HALFYEAR->
			1;
		?ITEM_TYPE_VIP_CARD_WEEK->
			4;
		?ITEM_TYPE_VIP_CARD_NEW_MONTH->
			3;
		?ITEM_TYPE_VIP_CARD_NEW_SEASON->
			2;
		?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR->
			1;
		_->
			0
	end.

%% @doc 判断玩家是否为vip用户，如果vip等级为0，则不是，否则就是
is_vip()->
	get_role_vip() =/=0 .
	% case get_role_vip() of
	% 	0->
	% 		false;
	% 	_->
	% 		true
	% end.

%%Msg=kill_monster|block_training|enchantment|
%%{instance,InstanceID}|flyshoes|pet_slot_lock
get_addition_with_vip(Msg)->
	case get_player_vip() of
		[]->
			0;
		#vip_role{roleid = RoleId, start_time = StartTime, 
				  duration = Duration, 
				  level = Level
		} ->
			{MSec,Sec,_}=timer_center:get_correct_now(),
			CurSec = MSec*1000000+Sec,
			if
				CurSec < StartTime+Duration->
					case vip_db:get_vip_level_info(Level) of
						[]->
							0;
						{_,_,_,Addition,_}->
							case Msg of
								{instance,InstanceID}->
									case lists:keyfind(instance, 1, Addition) of
										false->
											0;
										{instance,InstanceList}->
											case lists:keyfind(InstanceID, 1, InstanceList) of
												false->
													0;
												{_,Value}->
													Value
											end
									end;
								_->
									case lists:keyfind(Msg, 1, Addition) of
										false->
											0;
										{_,Value}->
											Value
									end
							end
					end;
				true->
					vip_db:delete_vip_role(RoleId),
					init_vip_role(),
					viptag_update(),
					0
			end
	end.

%% @doc 使用玩家的小飞鞋次数一次
check_have_vip_addition()->
	case get_player_vip() of
		[]->
			false;
		#vip_role{level = Level,
				  flyshoes = {Type,FlyShoes}
		} = VipRole ->
			case Type of
				?INFINITE->
					true;
				_->
					case FlyShoes > 0 of
						true->
							set_player_vip(VipRole#vip_role{flyshoes = {Type, FlyShoes-1}}),
							{_,TotleNum}= get_adapt_flytimes(Level),
							Message = vip_packet:encode_vip_role_use_flyshoes_s2c(FlyShoes-1,TotleNum),
							role_op:send_data_to_gate(Message),
							true;
						_->
							false
					end
			end
	end.
%% @doc 根据玩家等级计算奖励中应该发给玩家的奖励
get_bonus_from_db_term(Bonus)->
	RoleLevel=get_level_from_roleinfo(get(creature_info)),
	GetBonusFun=fun({{StartLevel,EndLevel},BonusTerm},Acc)->
				if 
					RoleLevel>=StartLevel,RoleLevel=<EndLevel->
						Acc++BonusTerm;
					true->
						Acc
				end
			end,
	case lists:keyfind(0, 1, Bonus) of
		{_KeyClass,ZeroBonusList}->
			lists:foldl(GetBonusFun, [], ZeroBonusList);
		false->
			RoleClass = get_class_from_roleinfo(get(creature_info)),
			case lists:keyfind(RoleClass, 1, Bonus) of
				{_KeyClass,ClassBonusList}->
					lists:foldl(GetBonusFun, [], ClassBonusList);
				false->
					[]
			end
	end.

%%　@doc 给玩家发送vip初始信息
vip_init_s2c(VipLevel,Type,Type2)->
	Message = vip_packet:encode_vip_init_s2c(VipLevel,Type,Type2),
	role_op:send_data_to_gate(Message).

%% @doc 拷贝的方式导出用户的vip数据	
export_for_copy()->
	{get_player_vip(), get(role_login_bonus)}.

%% @doc	
write_to_db()->
	nothing.
%% @doc 拷贝的方式重新加载，一般在跨服，跨线时使用
load_by_copy({RoleVip,RoleLoginBonus})->
	put(role_vip,RoleVip),
	put(role_login_bonus,RoleLoginBonus).

%% @doc 给玩家发送vip数据，包括等级，元宝，过期时间
vip_ui_c2s()->
	case get_player_vip() of
		[]->
			vip_ui_s2c(0,0,0);
		#vip_role{start_time = StartTime, duration = Duration, level = Level} ->
			vip_ui_s2c(Level,get_role_sum_gold(get(roleid)),StartTime+Duration)
	end.
%% @doc 获取玩家的元宝总数
get_role_sum_gold(RoleId)->
	case vip_db:get_role_sum_gold(RoleId) of
		{ok,[]}->
 			0;
		{ok,RoleSumGold}->
			{role_sum_gold,_,Gold,ODurationGold} = RoleSumGold,
			Gold
	end.
%% @doc vip奖励
vip_reward_c2s()->
	case get_player_vip() of
		[]->
			Errno=?ERROR_IS_NOT_VIP;
		#vip_role{roleid = RoleId, 
				level = Level, 
				bonustime = BonusTime
		} = VipRole ->
			case check_bonus_date(BonusTime) of
				true->
					NowTime = timer_center:get_correct_now(),
					case vip_db:get_vip_level_info(Level) of
						[]->
							Errno=?ERRNO_NPC_EXCEPTION;
						{_,_,_,_,Bonus}->
							BonusList = get_bonus_from_db_term(Bonus),
							case package_op:get_empty_slot_in_package(erlang:length(BonusList)) of
								0->
									Errno=?ERROR_PACKEGE_FULL;
								_->	
									Errno=[],
									achieve_op:achieve_bonus(BonusList,vip_bonus),
									VipRole2 = VipRole#vip_role{bonustime = NowTime},
									set_player_vip(VipRole2),
									vip_db:sync_update_vip_role_to_mnesia(RoleId, VipRole2)
							end 
					end;
				false->
					Errno=?ERROR_VIP_REWARDED_TODAY
			end
	end,
	if 
		Errno =/= []->
			Message_failed = vip_packet:encode_vip_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

login_bonus_reward_c2s()->
	case check_login_bonus_time() of
		1->
			Errno=?ERROR_VIP_REWARDED_TODAY;
		0->
			NowTime = timer_center:get_correct_now(),
			case vip_db:get_vip_level_info(0) of
				[]->
					Errno=?ERRNO_NPC_EXCEPTION;
				{_,_,_,_,Bonus}->
					BonusList = get_bonus_from_db_term(Bonus),
					case package_op:get_empty_slot_in_package(erlang:length(BonusList)) of
						0->
							Errno=?ERROR_PACKEGE_FULL;
						_->	
							Errno=[],
							{RoleId,_} = get(role_login_bonus),
							achieve_op:achieve_bonus(BonusList,login_bonus),
							put(role_login_bonus,{RoleId,NowTime}),
							vip_db:sync_update_role_login_bonus_to_mnesia(RoleId, {RoleId,NowTime})
					end 
			end
	end,
	if 
		Errno =/= []->
			Message_failed = vip_packet:encode_vip_error_s2c(Errno),
			role_op:send_data_to_gate(Message_failed);
 		true->
			nothing
	end.

vip_ui_s2c(Vip,Gold,EndTime)->
	Message = vip_packet:encode_vip_ui_s2c(Vip,Gold,EndTime),
	role_op:send_data_to_gate(Message).

add_sum_gold(RoleId,Gold)->
	case vip_db:get_role_sum_gold(RoleId) of
		{ok,[]}->
%% 			NewGold=Gold,
			vip_db:sync_update_role_sum_gold_to_mnesia(RoleId, {RoleId,Gold,0});
		{ok,RoleSumGold}->
			{role_sum_gold,_,OGold,ODurationGold} = RoleSumGold,
			NewGold=OGold+Gold,
			vip_db:sync_update_role_sum_gold_to_mnesia(RoleId, {RoleId,NewGold,ODurationGold})
	end.
%%2011-04-08
%% 	check_vip_level_up(RoleId,NewGold).
%% @doc 级需要升级则升级
check_vip_level_up(RoleId,CheckGold)->
	case vip_db:get_vip_role(RoleId) of
		{ok,[]}->
			nothing;
		{ok, #vip_role{
				roleid = RoleId,
				start_time = StartTime,
				duration = Duration,
				level = Level
			} = VipRole
		} ->
			NewLevel = check_vip_level(CheckGold),
			{MSec,Sec,_} = timer_center:get_correct_now(),
			CurSec = MSec*1000000+Sec,
			if 
				NewLevel>Level,CurSec<StartTime+Duration->
					VipRole2 = VipRole#vip_role{level = NewLevel},
					vip_db:sync_update_vip_role_to_mnesia(RoleId, VipRole2);
				true->
					nothing
			end
	end.

check_vip_level_up_of_pid(CheckGold)->
	case get_player_vip() of
		[]->
			nothing;
		#vip_role{
				roleid = RoleId,
				level = Level
		} = VipRole ->
		%{RoleId,StartTime,Duration,Level,BonusTime,LoginTime,FlyShoes}->
			NewLevel = check_vip_level(CheckGold),
%% 			RoleName = get_name_from_roleinfo(get(creature_info)),
			if 
				NewLevel>Level->
					VipRole2 = VipRole#vip_role{level = NewLevel},
					set_player_vip(VipRole2),
					% put(role_vip,{RoleId,StartTime,Duration,NewLevel,BonusTime,LoginTime,FlyShoes}),
					viptag_update(),
					vip_db:sync_update_vip_role_to_mnesia(RoleId, VipRole2),
					sys_cast(NewLevel,get(creature_info)),
					vip_level_up_s2c();
				true->
					nothing
			end
	end.

vip_level_up_s2c()->
	Message = vip_packet:encode_vip_level_up_s2c(),
	role_op:send_data_to_gate(Message).

vip_npc_enum_s2c(Vip,Bonus)->
	if Bonus=:=[]->
		   Bon=[];
	   true->
		   Bon=util:term_to_record_for_list(Bonus, l)
	end,
	Message = vip_packet:encode_vip_npc_enum_s2c(Vip,Bon),
	role_op:send_data_to_gate(Message).

npc_function()->
	case get_player_vip() of
		[]->
			vip_npc_enum_s2c(0,[]);
		#vip_role{
				level = Level,
				bonustime = BonusTime
		} ->
			case check_bonus_date(BonusTime) of
				true->
					case vip_db:get_vip_level_info(Level) of
						[]->
							vip_npc_enum_s2c(0,[]);
						{_,_,_,_,Bonus}->
							BonusList = get_bonus_from_db_term(Bonus),
							vip_npc_enum_s2c(Level,BonusList)
					end;
				false->
					vip_npc_enum_s2c(Level,[])
			end
	end.
%% @doc 检查奖励时间		
check_bonus_date(BonusTime)->
	if
		BonusTime=:=0->
			true;
		true->
			BonusDate = calendar:now_to_local_time(BonusTime),
			{{_BonusY,_BonusM,BonusD}, _} = BonusDate, 
			NowTime = timer_center:get_correct_now(),
			NowDate = calendar:now_to_local_time(NowTime),
			{{_NowY,_NowM,NowD}, _} = NowDate,
			if
				NowD =/= BonusD->
					true;
				true->
					false
			end
	end.
%% @doc 根据元宝，计算等级
check_vip_level(CheckGold)->
	if
		CheckGold>0,CheckGold<2000->
			NewLevel=1;
		CheckGold>=2000,CheckGold<8000->
			NewLevel=2;
		CheckGold>=8000->
			NewLevel=3;
		%%CheckGold>=8000,CheckGold<40000->
		%%	NewLevel=3;
		%%CheckGold>=40000,CheckGold<200000->
		%%	NewLevel=4;
		%%CheckGold>=200000,CheckGold<1000000->
		%%	NewLevel=5;
		%%CheckGold>=1000000->
		%%	NewLevel=6;
		true->
			NewLevel=1
	end,
	NewLevel.
%%　@doc 系统广播
sys_cast(CL,RoleInfo)->
	case CL of
		0->
			nothing;
		CurLevel->
			if
				CurLevel=:=1->
				    system_bodcast(?SYSTEM_CHAT_VIP_1, RoleInfo);
				CurLevel=:=2->
				    system_bodcast(?SYSTEM_CHAT_VIP_2, RoleInfo);
				CurLevel=:=3->
				    system_bodcast(?SYSTEM_CHAT_VIP_3, RoleInfo);
				CurLevel=:=4->
					system_bodcast(?SYSTEM_CHAT_VIP_4, RoleInfo);
				CurLevel=:=5->
					system_bodcast(?SYSTEM_CHAT_VIP_1, RoleInfo);
				CurLevel=:=6->
					system_bodcast(?SYSTEM_CHAT_VIP_2, RoleInfo);
				CurLevel=:=7->
					system_bodcast(?SYSTEM_CHAT_VIP_3, RoleInfo);
				true->
					nothing
			end
	end.

%% @doc 系统广播
system_bodcast(SysId,RoleInfo) ->
	ParamRole = system_chat_util:make_role_param(RoleInfo),
	system_chat_op:system_broadcast(SysId,[ParamRole]).

%% @doc vip标记更新
viptag_update()->
	Viptag = get_role_vip(),
	put(creature_info,set_viptag_to_roleinfo(get(creature_info),Viptag)),
	role_op:update_role_info(get(roleid),get(creature_info)),
	role_op:self_update_and_broad([{viptag,Viptag}]).
	
%% @doc 传送到vip地图
join_vip_map(TransportId)->
	case get_player_vip() of
		[]->
			nothing;
		_->
			case transport_op:can_directly_telesport() of
				true ->
					RoleInfo = get(creature_info),
					Flag = lists:any(fun(E) -> RoleInfo#gm_role_info.gs_system_map_info#gs_system_map_info.map_id =:=E end,env:get(travel_battle_map1, [])),
					if
						Flag ->
							Msg = pet_packet:encode_send_error_s2c(?PLEASE_LEAVE_VIPMAP),
							role_op:send_data_to_gate(Msg);
							% transport_op:teleport(get(creature_info), get(map_info),TransportId);
						true ->
							transport_op:travel_teleport(get(creature_info), get(map_info),TransportId)
					end;
					% transport_op:travel_teleport(get(creature_info), get(map_info),TransportId);
				false ->
					nothing
			end
	end.
	
	

%% @doc 设置玩家的vip数据
set_player_vip(Vips) when is_list(Vips)->
	erlang:put(role_vip, Vips);
set_player_vip(Vips) when is_tuple(Vips)->
	erlang:put(role_vip, Vips).

%% @doc 从进程字典中获取vip数据
get_player_vip() ->
	get(role_vip).

	
