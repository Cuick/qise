%% Author: MacX
%% Created: 2011-1-10
%% Description: TODO: Add description to vip_card_script
-module(vip_card_script).

-export([use_item/1]).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").
-include("system_chat_define.hrl").
-include("vip_define.hrl").
-include("mnesia_table_def.hrl").
-include("base_define.hrl").


use_item(ItemInfo)->
	RoleId = get(roleid),
	%%RoleName = get_name_from_roleinfo(get(creature_info)),
	VipCard = get_states_from_iteminfo(ItemInfo),
	{MSec,Sec,_}=timer_center:get_correct_now(),
	CurSec=MSec*1000000+Sec,
	Duration = case VipCard of
		[?ITEM_TYPE_VIP_CARD_MONTH]->
			CardType=?ITEM_TYPE_VIP_CARD_MONTH,
			CompareType=4,
			60*60*24*30;
		[?ITEM_TYPE_VIP_CARD_SEASON]->
			CardType=?ITEM_TYPE_VIP_CARD_SEASON,
			CompareType=5,
			60*60*24*30*3;
		[?ITEM_TYPE_VIP_CARD_HALFYEAR]->
			CardType=?ITEM_TYPE_VIP_CARD_HALFYEAR,
			CompareType=6,
			60*60*24*30*6;
		[?ITEM_TYPE_VIP_CARD_WEEK]->
			CardType=?ITEM_TYPE_VIP_CARD_WEEK,
			CompareType=3,
			60*60*24*7;
		[?ITEM_TYPE_VIP_CARD_NEW_MONTH]->
			CardType=?ITEM_TYPE_VIP_CARD_NEW_MONTH,
			CompareType=4,
			60*60*24*30;
		[?ITEM_TYPE_VIP_CARD_NEW_SEASON]->
			CardType=?ITEM_TYPE_VIP_CARD_NEW_SEASON,
			CompareType=5,
			60*60*24*30*3;
		[?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR]->
			CardType=?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR,
			CompareType=6,
			60*60*24*30*6;
		[?ITEM_TYPE_VIP_CARD_EXPERIENCE]->
			CardType=?ITEM_TYPE_VIP_CARD_EXPERIENCE,
			CompareType=1,
			60*30;
		[?ITEM_TYPE_VIP_CARD_3DAY]->
			CardType=?ITEM_TYPE_VIP_CARD_3DAY,
			CompareType=2,
			60*60*24*3;
		_->
			CardType=0,
			CompareType=0,
			false
	end,
	case Duration of 
		false->
			false;
		DTime->
			case get(role_vip) of
				[]->
					FlyTimes = vip_op:get_adapt_flytimes(CardType),
					VipRole = #vip_role{
							roleid = RoleId, 		
							start_time = CurSec,		
							duration = DTime,		
							level = CardType,    % 这个地方可能是疑问		
							bonustime = 0,		
							logintime = now(),		
							flyshoes = FlyTimes      
					},
					vip_op:set_player_vip(VipRole),
					% put(role_vip,{RoleId,CurSec,DTime,CardType,0,now(),FlyTimes}),
					banquet_op:hook_on_vip_up(0,CardType),
%% 					vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,CurSec,DTime,CheckLevel,0}),
					gm_logger_role:role_vip(RoleId,CardType,get(level)),
 					vip_db:sync_update_vip_role_to_mnesia(RoleId, VipRole),
					vip_op:vip_ui_c2s(),
					vip_op:viptag_update(),
					sys_cast(CardType,get(creature_info)),
					pet_hostel:open_vip_room(get(pet_hostel)),
					true;
				#vip_role{
						roleid = _RoleId,  
						start_time = StartTime, 
						duration = DurationTime, 
						level = VipLevel, 
						bonustime = BonusTime, 
						logintime = LoginTime, 
						flyshoes = FlyShoes
				} ->
				%{_,StartTime,DurationTime,VipLevel,BonusTime,LoginTime,FlyShoes}->
					banquet_op:hook_on_vip_up(VipLevel,CardType),
					FlyTimes = vip_op:get_adapt_flytimes(CardType),
					case VipLevel of
						?ITEM_TYPE_VIP_CARD_NEW_HALFYEAR->
							CompareLevel = 6;
						?ITEM_TYPE_VIP_CARD_NEW_SEASON->
							CompareLevel = 5;
						?ITEM_TYPE_VIP_CARD_NEW_MONTH->
							CompareLevel = 4;
						?ITEM_TYPE_VIP_CARD_WEEK->
							CompareLevel = 3;
						?ITEM_TYPE_VIP_CARD_HALFYEAR->
							CompareLevel=6;
						?ITEM_TYPE_VIP_CARD_SEASON->
							CompareLevel=5;
						?ITEM_TYPE_VIP_CARD_MONTH->
							CompareLevel=4;
						?ITEM_TYPE_VIP_CARD_EXPERIENCE->
							CompareLevel=1;
						?ITEM_TYPE_VIP_CARD_3DAY->
							CompareLevel=2
					end,
					if 
						CurSec<(StartTime+DurationTime)->
							%　未过期
							Flag=true,
							NewStartTime = StartTime,
							NewDuration = DurationTime+DTime; % 时间延长
						true->
							% 过期
							Flag=false,
							NewStartTime = CurSec,
							NewDuration = DTime
					end,
					if
						% 新卡级别大于旧卡级别
						CompareType > CompareLevel->
							sys_cast(CardType,get(creature_info)),
							put(role_vip,{vip_role, RoleId,NewStartTime,NewDuration,CardType,BonusTime,LoginTime,FlyTimes}),
							gm_logger_role:role_vip(RoleId,CardType,get(level)),
							vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,NewStartTime,NewDuration,CardType,BonusTime,LoginTime,FlyTimes});
						true->
							if
								% 前一个未过期
								Flag->
									vip_op:sys_cast(CardType,get(creature_info)),
									put(role_vip,{vip_role, RoleId,NewStartTime,NewDuration,VipLevel,BonusTime,LoginTime,FlyShoes}),
									gm_logger_role:role_vip(RoleId,CardType,get(level)),
									vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,NewStartTime,NewDuration,VipLevel,BonusTime,LoginTime,FlyShoes});
								%　前一个vip卡过期
								true->
									sys_cast(CardType,get(creature_info)),
									put(role_vip,{vip_role, RoleId,NewStartTime,NewDuration,CardType,BonusTime,LoginTime,FlyTimes}),
									gm_logger_role:role_vip(RoleId,CardType,get(level)),
									vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,NewStartTime,NewDuration,CardType,BonusTime,LoginTime,FlyTimes})
							end
					end,
%% 					put(role_vip,{RoleId,NewStartTime,NewDuration,VipLevel,BonusTime}),
%% 					vip_db:sync_update_vip_role_to_mnesia(RoleId, {RoleId,NewStartTime,NewDuration,VipLevel,BonusTime}),
					vip_op:vip_ui_c2s(),
					vip_op:viptag_update(),
					pet_hostel:open_vip_room(get(pet_hostel)),
					true;
				_->
					false
			end
	end.

sys_cast(CT,RoleInfo)->
	case CT of
		0->
			nothing;
		CardType->
			if
				CardType=:=1->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_1, RoleInfo);
				CardType=:=2->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_2, RoleInfo);
				CardType=:=3->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_3, RoleInfo);
				CardType=:=4->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_4, RoleInfo);
				CardType=:=5->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_1, RoleInfo);
				CardType=:=6->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_2, RoleInfo);
				CardType=:=7->
					vip_op:system_bodcast(?SYSTEM_CHAT_VIP_LEVEL_3, RoleInfo);
				true->
					nothing
			end
	end.

	

%%
%% Local Functions
%%

