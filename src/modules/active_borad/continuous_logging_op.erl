%% Author: SQ.Wang
%% Created: 2011-7-7
%% Description: TODO: Add description to continuous_logging_op
-module(continuous_logging_op).

%%
%% Include files
%%
-compile(export_all).
-export([load_from_db/1,export_for_copy/0,load_by_copy/1,continuous_logging_board_c2s/0,get_gift/2,clear_days/0,on_player_offline/0,process_message/1]).
-export([gm_test/1,mail_test/2,enable_continuous_logging_board/1]).

%%
%% Exported Functions
%%
-include("error_msg.hrl").
-include("data_struct.hrl").
-include("role_struct.hrl").
-include("active_board_define.hrl").
-include("string_define.hrl").
-include("login_pb.hrl").
-include("active_board_def.hrl").



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%role_continuous_info:																			%%
%%	{RoleId,NormalAwardDay,VipAwardDay,LoginTime,Days}),                 						%%
%%		LoginTime = {0,0,0}																		%%
%%  打开隐藏功能  by zhangting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
process_message({continuous_logging_gift_c2s,_,Type, GetDay})->
	get_gift(Type, GetDay);

%%  打开隐藏功能  by zhangting
process_message({continuous_logging_board_c2s,_})->
	 continuous_logging_board_c2s();

%% 0点重置  by zhangting
process_message({continuous_0hours_reset})->
    reset_login_time();

%%  打开隐藏功能  by zhangting
process_message({continuous_days_clear_c2s,_})->
    clear_days();


%%客户端发送获取收藏好礼消息  by zhangting
process_message({collect_page_c2s,_})-> 
	 get_favorite_gift();


process_message({activity_test01_recv_c2s,_,Index})->
	%%注销掉送元宝的功能%%
	%%%%get_activity_test01_gift(Index);%%%%
    nothing;

process_message({activity_test01_display,Index})->
	 send_activity_test01_display_s2c(Index);
	
process_message({activity_test01_hidden,Index})->
%%	  slogger:msg("continuous_logging_op  activity_test01_hidden  667788 Index:~p~n",[Index]),
     %% Message=continuous_logging_packet:encode_activity_test01_hidden_s2c(Index).
      %%role_op:send_data_to_gate(Message);
     nothing;

process_message(Msg)->
    nothing.

load_from_db_close(_RoleId)->
	 todo.

%%打开隐藏功能  by zhangting
load_from_db(RoleId)->
	 load_continuous_from_db(RoleId),
    load_favorite_from_db(RoleId).
     %% load_activity_test01_from_db(RoleId).


%%从数据库里装载收藏有礼信息
load_favorite_from_db(RoleId)->
	Info = continuous_logging_db:get_favorite_gift_info(RoleId),
	if Info =:=[]-> put(role_favorite_info,{RoleId,0});  true->put(role_favorite_info,Info) end,
    role_favorite_gift_s2c().

%%从数据库里装载送元宝数据
load_activity_test01_from_db(RoleId)->
	Info = continuous_logging_db:get_activity_test01_info(RoleId),
    put(activity_test01_role,Info),
    timer_activity_test01(RoleId).

timer_activity_test01(RoleId)->
    TestConf = continuous_logging_db:get_activity_test_info(1),
    case  element(#activity_test01.enabled,TestConf) of 
     1->timer_activity_test01_do(TestConf,RoleId);
      _->nothing
    end.

timer_activity_test01_do(TestConf,RoleId)->	
    TestInfo=get(activity_test01_role),
    NowTime =timer_center:get_correct_now(),
    Limit_times = element(#activity_test01.limit_times,TestConf),
    TestInfo1= if TestInfo =:=[] -> {NowTime,  erlang:make_tuple(length(Limit_times), 0)};
                  true->TestInfo 
                end,
    {LastTimeTmp,_}=TestInfo1, 
	NowTimeStd=calendar:now_to_local_time(NowTime),
	 {{NowY,NowM,NowD},{NowH,NowMi,NowS}} = NowTimeStd,
	
    {LastTmpDate,{_,_,_}} = calendar:now_to_local_time(LastTimeTmp),
     if LastTmpDate =:= {NowY,NowM,NowD}->
          NewTestInfo = TestInfo1;
     true->
          NewTestInfo  = {NowTime,  erlang:make_tuple(length(Limit_times), 0)}
     end,
	
     {LastTime,Flags}=NewTestInfo, 
     {{LastY,LastM,LastD},{LastH,LastMi,LastS}} = calendar:now_to_local_time(LastTime),
     {Ret,ValidIndex,NextIndex,Seq} = 
     lists:foldl(
		   fun({{StartH,StartMi},{EndH,EndMi}},{Ret0,ValidIndex0,NextIndex0,Seq0})->
           	IndexTmp =  Seq0+1,
              case Ret0 of 
              ok->  
                  if ValidIndex0 =:=NextIndex0 ->{ok,ValidIndex0,ValidIndex0+1,IndexTmp};
				            true->{ok,ValidIndex0,NextIndex0,IndexTmp} end;
                _->
	              if element(IndexTmp,Flags) =:=1  -> {Ret0,ValidIndex0,NextIndex0,IndexTmp};
	              true->
	                   CurrSecs = NowH*3600+NowMi*60+ NowS,
	                   if CurrSecs>= StartH*3600+StartMi*60 andalso   CurrSecs <EndH*3600+EndMi*60+59 ->
	                       {ok,IndexTmp,NextIndex0,IndexTmp};
	                   true->
                           if CurrSecs<StartH*3600+StartMi*60 andalso NextIndex0 <0 ->
                               {Ret0,ValidIndex0,IndexTmp,IndexTmp};
                           true ->
                               {Ret0,ValidIndex0,NextIndex0,IndexTmp}
                           end
	                   end
	              end
              end
		   end
		,{[],-1,-1,0}
		,Limit_times
	),
	
    if Ret =:= ok ->
         send_activity_test01_display_s2c(ValidIndex);
    true->
         nothing
    end,
    if    NextIndex>0 ->
         NextTimer1 =  lists:nth(NextIndex,Limit_times),
         send_activity_test01_timer(NowTimeStd,{activity_test01_display,NextIndex},element(1,NextTimer1),false);
     true-> nothing
    end,
    put(activity_test01_role,NewTestInfo),
    continuous_logging_db:sync_updata_new({RoleId,NewTestInfo},activity_test01_role)
   .

send_activity_test01_display_s2c(Index) ->	
	%%slogger:msg("continuous_logging_op:send_activity_test01_display_s2c 20120906c01 Index:~p ~n",[Index]),	
	 NowTime =timer_center:get_correct_now(),
	 NowTimeStd=calendar:now_to_local_time(NowTime),
	 TestConf = continuous_logging_db:get_activity_test_info(1),
     Limit_times = element(#activity_test01.limit_times,TestConf),
	 OkTimer1 = lists:nth(Index,Limit_times),
	 Message=continuous_logging_packet:encode_activity_test01_display_s2c(Index).
	 %%role_op:send_data_to_gate(Message),
	 %%send_activity_test01_timer(NowTimeStd,{activity_test01_hidden,Index},element(2,OkTimer1),true).
	  
	  
%%发送活动定时消息
send_activity_test01_timer(NowTimeStd,Msg,{HH,Mi},Add59s) ->		
		{{NowY,NowM,NowD},{NowH,NowMi,NowS}} = NowTimeStd,
       if Add59s ->NextDate={{NowY,NowM,NowD},{HH,Mi,59}};
       true ->NextDate={{NowY,NowM,NowD},{HH,Mi,0}}
       end,		
		IntervalSec= calendar:datetime_to_gregorian_seconds(NextDate) - calendar:datetime_to_gregorian_seconds(NowTimeStd),
		if IntervalSec>0 ->
 		   TimeRefNew = erlang:send_after(IntervalSec*1000, self(), {continuous_logging,Msg});
		true->nothing
		end.




    
get_activity_test01_gift(Index)->
	 {LastTime,Flags} = get(activity_test01_role),
	 
     if element(Index,Flags)=:=1 -> Result = ?ACTIVITY_TEST01_AWARDED;
     true->
          Result = ?AWARD_OK,
          TestConf = continuous_logging_db:get_activity_test_info(1),
      
          
          role_op:money_change(element(#activity_test01.money_type,TestConf)
							    , element(#activity_test01.money_count,TestConf)
							   , activity_test01_gift),
 
          NewTestInfo = {LastTime,setelement(Index,Flags,1)},

		   put(activity_test01_role,NewTestInfo),
		   continuous_logging_db:sync_updata_new({get(roleid),NewTestInfo},activity_test01_role),
          Message=continuous_logging_packet:encode_activity_test01_hidden_s2c((Index))
	%%	   role_op:send_data_to_gate(Message)      
	 end.

    
%%给客户端发送收藏有礼信息         
role_favorite_gift_s2c()->
	 {RoleId,Awarded} = get(role_favorite_info),
	 RoleLevel = get(level),
	 if RoleLevel < ?NEED_FAVORITE_LEVEL orelse Awarded=:=1 ->
		  %%Result = {?ERROR_NOT_REACH_LEVEL,Awarded};
          nothing;
 	 true->
         %%Result = {?AWARD_OK,Awarded}
	  	  Message = continuous_logging_packet:encode_favorite_gift_info_s2c(),
	 	  role_op:send_data_to_gate(Message)
	 end.

get_favorite_gift()->
	 {RoleId,Awarded} = get(role_favorite_info),
		 	 
     if Awarded=:=1 -> Result = ?FAVORITE_GIFT_AWARDED;
     true->
		   RoleLevel = get(level),
		   if RoleLevel < ?NEED_FAVORITE_LEVEL ->
				Result = ?ERROR_NOT_REACH_LEVEL;
		   true->	 
              Result = ?AWARD_OK,
              put(role_favorite_info,{RoleId,1}),
              continuous_logging_db:sync_updata_new({RoleId,1},role_favorite_gift_info),
		        %%策划认为该礼品很少变，可以写在程序里
              role_op:money_change(?MONEY_TICKET, 88, favorite_gift)    
		   end	  
	 end.
     %%前端要求不要返回消息
	 %%Message = continuous_logging_packet:encode_get_favorite_gift_result_s2c(Result),
	 %%role_op:send_data_to_gate(Message).      



%%当升级到指定的level时,提示客户端启用收藏好礼的按钮
enable_favorite_gift_board(NewLevel)->
    if  NewLevel < ?NEED_FAVORITE_LEVEL ->nothing;
    true->
		 role_favorite_gift_s2c()
    end.


%%从数据库里装载连续登录信息
load_continuous_from_db(RoleId)->
	NowTime = timer_center:get_correct_now(),
	Info = continuous_logging_db:get_continuous_logging_info(RoleId),
	case Info of
		[]->
			%%continuous_logging_db:sync_updata({RoleId,{0,?INIT_NORMAL_AWARD_DAY_LIST,0,NowTime,NowTime,0,0}}),
			put(role_continuous_info,{RoleId,0,?INIT_NORMAL_AWARD_DAY_LIST,0,NowTime,NowTime,0,0});
		{RoleId,{NormalAwardDay,NormalAwardDayList,VipAwardDay,_,OfflineTime,Days,LastDays}}->
			put(role_continuous_info,{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,NowTime,OfflineTime,Days,LastDays})
	end,
	RoleLevel = get(level),
   if  RoleLevel >= ?NEED_LEVEL ->init_continuous_times(NowTime); 
   true->continuous_logging_board_c2s()
   end.


%%0点重置登录次数，策划要求
reset_login_time()->
	 NowTime = timer_center:get_correct_now(),
    %%slogger:msg("continuous_logging_op:reset_login_time 20120723 01~n"),
	{{NowY,NowM,NowD},{NowH,NowMi,NowS}} = calendar:now_to_local_time(NowTime),
	%% slogger:msg("continuous_logging_op:reset_login_time 20120723 01 NowH:~p~n",[NowH]),
	if NowH > 0 -> nothing;
	true->
		{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Days,LastDays} = get(role_continuous_info),
		NowSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{NowH,NowMi,NowS}}),
		OffSecs = NowSecs-?ONEDAY-20,
	    put(role_continuous_info,{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,NowTime
								 ,timer_util:seconds_to_now(OffSecs) 
								 ,Days,LastDays}),
       init_continuous_times(NowTime) 
	end.

%%发送0点重置消息
send_0hours_reset_msg(NowTime) ->
		NowDateTime = calendar:now_to_local_time(NowTime),
		%%slogger:msg("continuous_logging_op:send_0hours_reset_msg 20120723 NowDateTime:~p ~n",[NowDateTime]),	
		{{NowY,NowM,NowD},{NowH,NowMi,NowS}} = NowDateTime,
		NextDate=dateutils:add({{NowY,NowM,NowD},{0,30,30}}, 1, days),
       %%NextDate=dateutils:add({{NowY,NowM,NowD},{NowH,NowMi,NowS}}, 2, minutes),
		%%slogger:msg("continuous_logging_op:send_0hours_reset_msg 20120723 NextDate:~p ~n",[NextDate]),	
		IntervalSec= calendar:datetime_to_gregorian_seconds(NextDate) - calendar:datetime_to_gregorian_seconds(NowDateTime),
		%%slogger:msg("continuous_logging_op:send_0hours_reset_msg 20120723 IntervalSec:~p ~n",[IntervalSec]),	
		TimeRefNew = erlang:send_after(IntervalSec*1000, self(), {continuous_logging,{continuous_0hours_reset}}).

	
%%设置进入次数
init_continuous_times(NowTime)->
	{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Days,LastDays} = get(role_continuous_info),
	Type1=check_login_times(OfflineTime),
	case Type1 of
		?CONTINUOUS_LOGIN ->
			if Days >= ?MAX_DAYS ->
                	 continuous_logging_db:sync_updata({RoleId,{NormalAwardDay,NormalAwardDayList,VipAwardDay,NowTime,NowTime,Days,LastDays}}),
			        put(role_continuous_info,{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,NowTime,NowTime,Days,LastDays});
 			   true ->
                  DaysNew=Days+1,
                  LastDaysNew =erlang:max(LastDays, DaysNew),
				    continuous_logging_db:sync_updata({RoleId,{NormalAwardDay,NormalAwardDayList,VipAwardDay,NowTime,NowTime,DaysNew,LastDaysNew}}),
			        put(role_continuous_info,{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,NowTime,NowTime,DaysNew,LastDaysNew})
			end;			
		?DISCONTINUOUS_LOGIN ->
		    if 	Days >= ?MAX_DAYS  -> nothing;
				 true->	
                   continuous_logging_db:sync_updata({RoleId, {NormalAwardDay, NormalAwardDayList, 0, NowTime, NowTime, LastDays + 1, LastDays}}),
		            put(role_continuous_info,{RoleId, NormalAwardDay, NormalAwardDayList, 0, NowTime, NowTime, LastDays + 1, LastDays})
            end;
		?SAMEDAY_LOGIN ->
           if Days=:=0 ->
				 continuous_logging_db:sync_updata({RoleId,{NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,1,1}}),
		        put(role_continuous_info,{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,1,1});
		    true -> nothing
           end
	end,
	case is_get_all(NormalAwardDayList) of
		true ->
			nothing;
		false ->
			send_0hours_reset_msg(NowTime),
			continuous_logging_board_c2s()
	end.
%	if Days >= ?MAX_DAYS ->nothing; true ->send_0hours_reset_msg(NowTime) end,
%	if NormalAwardDay < ?MAX_DAYS -> continuous_logging_board_c2s();true->nothing end.
   
% 累计登陆是否全部领取
is_get_all(NormalAwardDayList) ->
	is_get_all(NormalAwardDayList, true).

is_get_all([], Bool) ->
	Bool;
is_get_all([H|T], Bool) ->
	{_Day, Flag} = H,
	case Flag =:= 1 of
		true ->
			is_get_all(T, true);
		false ->
			false
	end.
%%return:
%%	?SAMEDAY_LOGIN|?CONTINUOUS_LOGIN|?DISCONTINUOUS_LOGIN
%%Args:
%%	{int,int,int}
check_login_times(OfflineTime)->
	{{OffY,OffM,OffD},_} = calendar:now_to_local_time(OfflineTime),
	OffSecs = calendar:datetime_to_gregorian_seconds({{OffY,OffM,OffD},{0,0,0}}),
	{{NowY,NowM,NowD},_} = calendar:now_to_local_time(timer_center:get_correct_now()),
	NowSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{0,0,0}}),
	if
		NowSecs - OffSecs < ?ONEDAY ->
			?SAMEDAY_LOGIN;
		(NowSecs - OffSecs >= ?ONEDAY) and (NowSecs - OffSecs < 2*?ONEDAY) ->
			?CONTINUOUS_LOGIN;
		true ->
			?DISCONTINUOUS_LOGIN
	end.

%%修改下，解决消息发早的问题,虽然不应该有这种问题； zhangting
continuous_logging_board_c2s()->
	Role_continuous_info= get(role_continuous_info),
	if Role_continuous_info=:=undefined -> nothing;
	true->   
        {RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Days,LastDays} = Role_continuous_info,
%	     continuous_logging_board_s2c(NormalAwardDay,VipAwardDay,erlang:max(Days, LastDays))
		{NormalAwardDayList1, _NormalAwardDayList2} = lists:split(Days, lists:keysort(1, NormalAwardDayList)),
		 {_NormalAwardDayListA, NormalAwardDayListB} = lists:unzip(NormalAwardDayList1),
	     continuous_logging_board_s2c(NormalAwardDayListB, VipAwardDay, Days)
	end.


%%升级到指定的级别时，启动连续登录的面板和收藏好礼的按钮%%
enable_continuous_favorite_board(NewLevel)->
	enable_continuous_logging_board(NewLevel),
	enable_favorite_gift_board(NewLevel).
	

%%当升级到指定的level时,提示客户端启用连续登录面板
enable_continuous_logging_board(NewLevel)->
    if  NewLevel < ?NEED_LEVEL ->nothing;
    true->
		   {RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Days,LastDays} = get(role_continuous_info),
		   if NormalAwardDay=:=0 andalso Days =:=0 ->
			    NowTime = timer_center:get_correct_now(),
		       init_continuous_times(NowTime);
			true->
				nothing
		   end	  
    end.	


%% 测试  by zhangting
mail_test(RoleId,Days) ->
	 {YY,MM,DD} = timer_center:get_correct_now(),
	 OfflineTime ={YY,MM-?ONEDAY-500,DD},
	 continuous_logging_db:sync_updata({RoleId,{0,?INIT_NORMAL_AWARD_DAY_LIST,0,0,OfflineTime,Days,Days}}).


gm_test(Day)->
	{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,_,_} = get(role_continuous_info),
	put(role_continuous_info,{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Day,Day}),
	continuous_logging_db:sync_updata({RoleId,{NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Day,Day}}).


export_for_copy()->
	[get(role_continuous_info),get(role_favorite_info),get(activity_test01_role)].


load_by_copy([Role_continuous_info,Role_favorite_info,Activity_test01_role])->
	put(role_continuous_info,Role_continuous_info),
	put(role_favorite_info,Role_favorite_info),
   put(activity_test01_role,Role_favorite_info)
  .


%% 按照文档逻辑，当天以前没领的礼物，发邮件  by zhangting
%% 这是正式功能函数
do_no_recv_gift(Days,NormalAwardDayList) ->
    NormalAwardDayList1 = 
    if  NormalAwardDayList=:=[] ->?INIT_NORMAL_AWARD_DAY_LIST;true->NormalAwardDayList end,
    lists:foldr(
		fun({KeyDay,Flag},Acc)->
				if  KeyDay>Days orelse Flag=:=1 ->[{KeyDay,Flag}|Acc];
					true->
						 if  KeyDay<Days ->
							 %%slogger:msg("continuous_logging_op:do_no_recv_gift 03 Days:~p, KeyDay:~p,NormalAwardDayList:~p   ~n",[Days,KeyDay,NormalAwardDayList]),	 
						     send_no_recv_award_mail(KeyDay); 
							 true->nothing 
						 end,
						 [{KeyDay,1}|Acc]
				end		
		    end
		,[]
		,NormalAwardDayList1
	).

%% 发邮件功能  by zhangting
send_no_recv_award_mail(Day)->
	RoleLevel = get(level),
	case RoleLevel >= ?NEED_LEVEL of
		true ->
	 		GiftTableInfo = continuous_logging_db:get_info(Day),
	 		GiftInfo = continuous_logging_db:get_normal_gift(GiftTableInfo),
	 		%%RewardType = active_board_util:get_reward_type(RoleLevel), %% zhangting add
			%%GiftList = get_adpat_reward(GiftInfo,RewardType),
           GiftList = GiftInfo,
	 		send_award_mail(GiftList,Day,?NORMAL);
		false ->
			nothing
	end.



%%Args:
%%	Type = 0|1,   0 = normal, 1 = vip
%%Fun:
%%	auto create and put adapt gift 
%%没有VIP   by zhangting  type changeTo  Type1
%%解决消息发早的问题,虽然不应该有这种问题； zhangting
%%
get_gift(Type, GetDay)->
    Role_continuous_info= get(role_continuous_info),
	if Role_continuous_info=:=undefined -> nothing;
	true->get_gift_tmp(Type, GetDay, Role_continuous_info)
   end.
         
	
%%解决消息发早的问题,虽然不应该有这种问题； zhangting
get_gift_tmp(Type, GetDay, Role_continuous_info)->
   {RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Days, LastDays} = Role_continuous_info,
%   DaysMax = erlang:max(Days, LastDays),
   {_,DoAwardFlag} =  lists:keyfind(GetDay, 1, NormalAwardDayList),
   
	RoleLevel = get(level),
   Type=?NORMAL, %% zhangting add,新需求没有vip功能
	case Type of  
		?NORMAL ->
			case RoleLevel >= ?NEED_LEVEL of
				true ->
					if NormalAwardDay =:= GetDay orelse DoAwardFlag=:=1 ->
							Result = ?ERROR_REWARDED_TODAY;
						true ->
							%% old NormalAwardDay+1
							NormalAwardDay1 = GetDay,
							GiftTableInfo = continuous_logging_db:get_info(NormalAwardDay1),
							GiftInfo = continuous_logging_db:get_normal_gift(GiftTableInfo),
							%%RewardType = active_board_util:get_reward_type(RoleLevel),  
							%%GiftList = get_adpat_reward(GiftInfo,RewardType),
							GiftList = GiftInfo,
							
							case check_package(GiftList) of
								false ->
									Result = ?ERROR_PACKEGE_FULL;
								true ->									
									lists:foreach(fun({Gift,Count})->
														role_op:auto_create_and_put(Gift,Count,continuous_logging_gift) end,GiftList),									
									%% zhangting 20120629 delete
									%%gm_logger_role:role_continuous_days_reward(RoleId,NormalAwardDay+1,false),  
									%% zhangting 20120629 add
                               % NormalAwardDayList1= do_no_recv_gift(DaysMax,NormalAwardDayList), 
									NewNormalAwardDayList = lists:keyreplace(GetDay, 1, NormalAwardDayList, {GetDay, 1}),
									continuous_logging_db:sync_updata({RoleId,{NormalAwardDay1,NewNormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Days, LastDays}}),
								    put(role_continuous_info,{RoleId,NormalAwardDay1,NewNormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Days, LastDays}),
									Result = ?AWARD_OK
							end
					end;
				false ->
					Result = ?ERROR_NOT_REACH_LEVEL
			end;				 
		?VIP ->
			case vip_op:is_vip() of
				false ->
			  		Result = ?ERROR_IS_NOT_VIP;
	   			true ->
					if VipAwardDay =:= Days ->
							Result = ?ERROR_REWARDED_TODAY;
						true ->
							GiftTableInfo = continuous_logging_db:get_info(VipAwardDay+1),
							GiftInfo = continuous_logging_db:get_vip_gift(GiftTableInfo),
							RewardType = active_board_util:get_reward_type(RoleLevel),
							GiftList = get_adpat_reward(GiftInfo,RewardType),
							case check_package(GiftList) of
								false ->
									Result = ?ERROR_PACKEGE_FULL;
								true ->
									lists:foreach(fun({Gift,Count})->
														role_op:auto_create_and_put(Gift,Count,continuous_logging_gift) end,GiftList),
									gm_logger_role:role_continuous_days_reward(RoleId,VipAwardDay+1,true),
									put(role_continuous_info,{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay+1,LoginTime,OfflineTime,Days}),
									Result = ?AWARD_OK
							end
					end
			end
	end,
	send_opt_result(Result).


get_adpat_reward(GiftInfo,RewardType)->
	case lists:nth(RewardType,GiftInfo) of
		false->
			[];
		ItemsList->
			ItemsList
	end.

check_package(GiftList) ->
	package_op:can_added_to_package_template_list(GiftList).

clear_days() ->
	{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,OfflineTime,Days,LastDays} = get(role_continuous_info),
	continuous_logging_db:sync_updata({RoleId,{0,?INIT_NORMAL_AWARD_DAY_LIST,0,LoginTime,OfflineTime,0,0}}),
	put(role_continuous_info,{RoleId,0,?INIT_NORMAL_AWARD_DAY_LIST,0,LoginTime,OfflineTime,0,0}),
	{_NormalAwardDayListA, NormalAwardDayListB} = lists:unzip(?INIT_NORMAL_AWARD_DAY_LIST),
	continuous_logging_board_s2c(NormalAwardDayListB, 0, 0).
	%%gm_logger_role:role_clear_continuous_days(RoleId,Days),
	%%send_award(NormalAwardDay,VipAwardDay,Days).


%%Fun:
%%	send award by mail
%%Args:
%%	int int int
%% zhangting add new fun.so old fun rename send_award_old
send_award(NormalAwardDay,VipAwardDay,Days)->
	RoleLevel = get(level),
	if NormalAwardDay >= Days ->
		   nothing;
	   true ->
			case RoleLevel >= ?NEED_LEVEL of
				true ->
		   			lists:foreach(fun(Day)-> 
								 		GiftTableInfo = continuous_logging_db:get_info(Day),
								 		GiftInfo = continuous_logging_db:get_normal_gift(GiftTableInfo),
								 		%%RewardType = active_board_util:get_reward_type(RoleLevel), %% zhangting add
										RewardType = ?CONTINUOUS_1,
								 		GiftList = get_adpat_reward(GiftInfo,RewardType),
								 		send_award_mail(GiftList,Day,?NORMAL)
									 end, lists:seq(NormalAwardDay+1,Days));
				false ->
					nothing
			end
	end.


%%Args:
%%	[{Gift1,Count1},{Gift2,Count2}]
send_award_mail(GiftList,Day,Type)->
	RoleName = get_name_from_roleinfo(get(creature_info)),
	FromName = language:get_string(?CONTINUOUS_FROMNAME),
	case Type of 
		?NORMAL ->
			Title = language:get_string(?CONTINUOUS_NORMAL_TITLE),
			ContextFormat = language:get_string(?CONTINUOUS_NORMAL_CONTEXT);
		?VIP ->
			Title = language:get_string(?CONTINUOUS_VIP_TITLE),
			ContextFormat = language:get_string(?CONTINUOUS_VIP_CONTEXT)
	end,
	Context = util:sprintf(ContextFormat,[Day]),
	lists:foreach(fun({ItemId,Count})->
			gm_op:gm_send_rpc(FromName,RoleName,Title,Context,ItemId,Count,0) end,GiftList).
	
on_player_offline()->
	todo.

on_player_offline_close()->
	{RoleId,NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,_,Days,LastDays} = get(role_continuous_info),
	{{LoginY,LoginM,LoginD},_} = calendar:now_to_local_time(LoginTime),
	NowTime = timer_center:get_correct_now(),
	LoginSecs = calendar:datetime_to_gregorian_seconds({{LoginY,LoginM,LoginD},{0,0,0}}),
	{{NowY,NowM,NowD},_} = calendar:now_to_local_time(NowTime),
	NowSecs = calendar:datetime_to_gregorian_seconds({{NowY,NowM,NowD},{0,0,0}}),
 	AddDays = trunc((NowSecs - LoginSecs)/?ONEDAY),
	if 
	    NowSecs - LoginSecs >= ?ONEDAY ->
		    NewDays = Days+AddDays-trunc((Days+AddDays)/?MAX_DAYS)*?MAX_DAYS,
			case NewDays =:= 0 of
				true ->
					continuous_logging_db:sync_updata({RoleId,{NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,NowTime,?MAX_DAYS_NEW,LastDays}});
				false ->
					case Days+AddDays > ?MAX_DAYS of
						true ->
							continuous_logging_db:sync_updata({RoleId,{0,[],0,LoginTime,NowTime,NewDays,LastDays}}),
							send_award(NormalAwardDay,VipAwardDay,?MAX_DAYS);
						false ->
							continuous_logging_db:sync_updata({RoleId,{NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,NowTime,NewDays,LastDays}})
					end
			end;
	  	true ->
		    continuous_logging_db:sync_updata({RoleId,{NormalAwardDay,NormalAwardDayList,VipAwardDay,LoginTime,NowTime,Days,LastDays}})
	end.
	
continuous_logging_board_s2c(NormalAwardDayList, VipAwardDay, Days)->
	Message = continuous_logging_packet:encode_continuous_logging_board_s2c(NormalAwardDayList,VipAwardDay,Days),
	role_op:send_data_to_gate(Message).

send_opt_result(Result)->
	Message = continuous_logging_packet:encode_continuous_opt_result_s2c(Result),
	role_op:send_data_to_gate(Message).

	
	
