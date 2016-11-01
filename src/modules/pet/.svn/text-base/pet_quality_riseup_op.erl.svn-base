%% Author: Bergpoon
%% Created: 2012-9-11
%% Description: TODO:宠物品质升级模块
-module(pet_quality_riseup_op).

%-compile(export_all).
-export([quality_riseup/3]).
%%
%% Include files
%%
-include("pet_struct.hrl").
-include("pet_def.hrl").
-include("common_define.hrl").
-include("error_msg.hrl").
-include("role_struct.hrl").

-define(CONSUME_GOLD, 0).	% 消耗金币
-define(CONSUME_PROP, 1).	% 消耗道具
%%
%% Local Functions
%%
%%品质提升函数

%%%%%%%%%%%%%%%%%%分函数实现具体的信息%%%%%%%%%%%%%%%%%
%%根据传入的PetRiseUpList来判断是否满足升级条件，其中PetRiseUpList的形式如下
%%满足返回true,不满足返回false
check_item(Rlist) ->
	%%首先进行匹配得到所需要物品的列表
	BT = lists:all(fun({Template_id,Count}) ->
			HasItem = item_util:is_has_enough_item_in_package(Template_id,Count),
			if
				HasItem ->
              				true;
        		true->
              				false
			end
	end, Rlist),
	BT.

check_money(Cupro) ->
	CheckSilver = role_op:check_money(?MONEY_BOUND_SILVER, Cupro).

%%传入目前的品质和位阶，判断是否是最大值
%%是返回false,否返回true
check_maxquality(GmPetquality,GmPetgrade) ->
	GradeInfo = pet_quality_proto_db:get_info(GmPetgrade),
	QualityProperties = pet_quality_proto_db:get_quality_properties_from_info(GradeInfo),
	MaxNum = pet_quality_proto_db:get_max_quality_level_from_info(QualityProperties),
	if
		GmPetquality >=MaxNum ->
			false;
		true ->
			true
	end.

%%到人物节点中扣除相应的物品
%%传入升级所需要的物品列表
consume_items(Rlist,Silver) ->
	role_op:money_change(?MONEY_BOUND_SILVER,-Silver,pet_quality_riseup),
	%%在减去对应的物品	RequiredItems原型:[{7000001,1}]
	lists:foreach(fun({Template_id,Count}) ->
			item_util:consume_items_by_tmplateid(Template_id,Count)end,Rlist).

%%计算升级的概率
%%SuccessRate:升级的成功率,万分比
%%MinNum:最小次数
%%MaxNum:最大次数
%%CurrentNum:当前已经尝试的次数
%%这里遵循最小次数和最大次数的规则
random_rate_success(SuccessRate,MinNum,MaxNum,CurrentNum) ->
	if
		CurrentNum =< MinNum ->
			false;
		CurrentNum >= MaxNum ->
			true;
		true ->
			Seed = {random:uniform(99999), random:uniform(999999), random:uniform(999999)},
			random:seed(Seed), 
			R = random:uniform(9999),
			if
				R < SuccessRate ->
					true;
				true ->
					false
			end
	end.

%%get the lucky random number
get_the_random_num(Num) ->
	Seed = {random:uniform(99999), random:uniform(999999), random:uniform(999999)},
	random:seed(Seed),
	R = random:uniform(Num).

%%修改宠物对应的属性
change_new_data(PetId) ->
	GmPetInfo = pet_op:get_pet_gminfo(PetId),
	MyPetInfo = pet_op:get_pet_info(PetId),
	%%得到目前的品质
	OldQuality =get_quality_from_petinfo(GmPetInfo),
	%%根据品质得到相应的资质
    %先取新的品质+位阶资质范围定义
	%%资质信息{攻击，命中，闪避，暴击，暴伤，生命，防御}
	OldQualityValue =get_quality_value_info_from_mypetinfo(MyPetInfo),
	{Power,HitRate,Dodge,CriticalRate,CriticalDamage,Life,Defense} = OldQualityValue,
	%%然后得到提品之后的资质上限最小值和最大值
	GradeInfo = pet_quality_proto_db:get_info(GmPetInfo#gm_pet_info.grade),
	QualityProperties = pet_quality_proto_db:get_quality_properties_from_info(GradeInfo),
	Property = pet_quality_proto_db:get_quality_proto_property_from_properties(QualityProperties,OldQuality+1),
	{MinQualityValue,MaxQualityValue} = pet_quality_proto_db:get_min_max_quality_value_from_property(Property),
	%%判断当前资质跟最小的资质之间的关系
	NewPower = max(Power,MinQualityValue),
	NewHitRate = max(HitRate,MinQualityValue),
	NewDodge = max(Dodge,MinQualityValue),
	NewCriticalRate = max(CriticalRate,MinQualityValue),
	NewCriticalDamage = max(CriticalDamage,MinQualityValue),
	NewLife = max(Life,MinQualityValue),
	NewDefense = max(Defense,MinQualityValue),
	%%清零当前尝试次数
	MyPetInfo_1 = set_quality_riseup_retries_to_mypetinfo(MyPetInfo,0),
	%%更新品质等级
	NewQuality = OldQuality + 1,
	GmPetInfo_1 = set_quality_to_petinfo(GmPetInfo,NewQuality),
	%%更新最小资质值
	NewQualityValue = {NewPower,NewHitRate,NewDodge,NewCriticalRate,NewCriticalDamage,NewLife,NewDefense},
	MyPetInfo_2 = set_quality_value_info_to_mypetinfo(MyPetInfo_1,NewQualityValue),
	%%更新最大资质上限
	NewMaxQualityValue = MaxQualityValue,
	MyPetInfo_3 = set_quality_value_up_info_to_mypetinfo(MyPetInfo_2,NewMaxQualityValue),	
	MyPetInfo_4 = set_quality_riseup_lucky_to_mypetinfo(MyPetInfo_3,0),
	{GmPetInfo_1,MyPetInfo_4}.

send_message(Is_Success, PetId, Lucky) ->
    PetsMsg = pet_packet:encode_pet_quality_riseup_s2c(Is_Success, PetId, Lucky),
    role_op:send_data_to_gate(PetsMsg).

%%进阶失败，幸运值增加，进阶次数的保存
fail_to_do(MyPetInfo, Property) ->
    RandomNum = pet_quality_riseup_proto_db:get_random_num_from_riseup_property(Property),
    MaxLucky = pet_quality_riseup_proto_db:get_max_lucky_from_riseup_property(Property),
    {FailNum, Luck} = get_quality_riseup_lucky_from_mypetinfo(MyPetInfo),
    Luck1 = Luck + random:uniform(RandomNum),
    NewLucky = min(MaxLucky,Luck1),
    set_quality_riseup_lucky_to_mypetinfo(MyPetInfo, {FailNum+1, NewLucky}).


%%进阶成功，幸运值和进阶的次数清零
success_to_do(MyPetInfo) ->
    set_quality_riseup_lucky_to_mypetinfo(MyPetInfo, {0, 0}).

quality_riseup(PetId, Flag, Up_type) ->
	case travel_battle_op:is_in_zone() of
		false ->
			do_quality_riseup(PetId, Flag, Up_type);
		true ->
			Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_INVALID_OPERATION),
			role_op:send_data_to_gate(Msg)
	end.


do_quality_riseup(PetId, Flag, Up_type) ->
	quest_op:pet_quality_check(),
	%%获取宠物的基本信息
	GmPetInfo = pet_op:get_pet_gminfo(PetId),
	MyPetInfo = pet_op:get_pet_info(PetId),
    {Retries, Luck} = get_quality_riseup_lucky_from_mypetinfo(MyPetInfo),
    % slogger:msg("aaaaaaaaaaFlag: ~p.~n", [Flag]),
	try
		if
			GmPetInfo =/= [] orelse MyPetInfo =/= [] ->
				% 获取对应宠物的品质、阶数
				GmPetquality = get_quality_from_petinfo(GmPetInfo),
				MyPetStage = get_quality_riseup_retries_from_mypetinfo(MyPetInfo),
				% 该宠物品质阶数是否达到最大
				case pet_quality_riseup_proto_db:is_max_quality_grade(GmPetquality, MyPetStage) of
					{error, Code} ->
						throw({Code, PetId, Luck});
					true ->
						% 是否达到当前品质最大阶数
						case pet_quality_riseup_proto_db:is_current_max_quality_grade(GmPetquality, MyPetStage) of
							true ->
								PetQuality = GmPetquality + 1,
								PetStage = 1;
							false ->
								PetQuality = GmPetquality,
								PetStage = MyPetStage + 1
						end,
						% 消耗类型
						case Flag =/= ?CONSUME_GOLD andalso Flag =/= ?CONSUME_PROP of
							true ->
								throw({?ERROR_SYSTEM, PetId, Luck});
							false ->
								%%玩家ID
		  						RoleId = get(roleid),
		  						%%玩家名称
		  						RoleInfo = get(creature_info),
		  						RoleName = get_name_from_roleinfo(RoleInfo),
		  						% 仙仆名称
		  						PetName = get_name_from_petinfo(GmPetInfo),
								% 获取宠物的gradeinfo
								GradeInfo = pet_quality_riseup_proto_db:get_info(PetQuality),
								% 该品质对应的进阶信息
								QualityProperties = pet_quality_riseup_proto_db:get_quality_riseup_properties_from_info(GradeInfo),
								case pet_quality_riseup_proto_db:get_quality_riseup_property_from_properties(QualityProperties, PetStage) of
									false ->
										throw({?ERROR_SYSTEM, PetId, Luck});
									Property ->
										% 花费
										Cupro = pet_quality_riseup_proto_db:get_money_from_riseup_property(Property),
                                        % 获取成功率
                                        PetRiseUpSuccessRate = pet_quality_riseup_proto_db:get_success_rate_from_riseup_property(Property),
                                        MinRetries = pet_quality_riseup_proto_db:get_min_retries_from_riseup_property(Property),
                                        MaxRetries = pet_quality_riseup_proto_db:get_max_retries_from_riseup_property(Property),
                                        % slogger:msg("retries luck : ~p ~p", [Retries, Luck]),
                                        % slogger:msg("success rate ~p", [PetRiseUpSuccessRate]),
										if
											Flag =:= ?CONSUME_PROP ->
												% 获取道具
												Rlist = pet_quality_riseup_proto_db:get_required_items_from_riseup_property(Property),
												% 道具是否充足
												case equipment_move:prop_enough(Rlist) of
													false ->
														throw({?ERROR_MISS_ITEM, PetId, Luck});
													true ->
														case check_money(Cupro) of
															false ->
                                                                throw({?ERROR_LESS_MONEY, PetId, Luck});
															true ->
																% 扣除道具
																ok = equipment_move:delete_prop(Rlist),
																% 扣除货币
																role_op:money_change(?MONEY_BOUND_SILVER, -Cupro, pet_quality_riseup),
																% 判断是否升级成功
                                                                case random_rate_success(PetRiseUpSuccessRate, MinRetries, MaxRetries, Retries) of
																	false ->
                                                                        NewMyPetInfo = fail_to_do(MyPetInfo, Property),
                                                                        pet_op:update_pet_info_all(NewMyPetInfo),
                                                                        pet_op:save_pet_to_db(PetId),
                                                                        {_, NewLuck} = get_quality_riseup_lucky_from_mypetinfo(NewMyPetInfo),
                                                                        send_message(?ERROR_PET_QUALITY_RISEUP_FAIL, PetId, NewLuck),
                                                                        %%
                                                                        %提升成功还是失败,1成功,0失败
		                      					  						RiseupStatus = 0,
		                      					  						% 进阶成功后获取对应宠物的品质、阶数
																		NewGmPetquality = GmPetquality,
																		NewMyPetStage = MyPetStage,
																		
		                      					  						FieldValue = [RoleId,RoleName,PetId,PetName,Flag,RiseupStatus,GmPetquality,MyPetStage,NewGmPetquality,NewMyPetStage],
		                      					  						gm_logger_role:insert_log_pet_quality_riseup(FieldValue),
		                      					  						%%
																		case Up_type of
		                         											   1 ->
		                               												 ok;
		                           											   0 ->
		                              												 quality_riseup(PetId, Flag, Up_type)
		                      					  						end;
																	true ->
																		NewGmPetInfo = set_quality_to_petinfo(GmPetInfo, PetQuality),
																		NewMyPetInfo = set_quality_riseup_retries_to_mypetinfo(MyPetInfo, PetStage),
                                                                        NewMyPetInfo1 = success_to_do(NewMyPetInfo),
                                                                        %%
                                                                        % 进阶成功后获取对应宠物的品质、阶数
																		NewGmPetquality = get_quality_from_petinfo(NewGmPetInfo),
																		NewMyPetStage = get_quality_riseup_retries_from_mypetinfo(NewMyPetInfo1),
																		%提升成功还是失败,1成功,0失败
		                      					  						RiseupStatus = 1,

		                      					  						FieldValue = [RoleId,RoleName,PetId,PetName,Flag,RiseupStatus,GmPetquality,MyPetStage,NewGmPetquality,NewMyPetStage],
		                      					  						gm_logger_role:insert_log_pet_quality_riseup(FieldValue),
		                      					  						%%
																		% 更新内存数据
																		pet_op:update_gm_pet_info_all(NewGmPetInfo),
																		pet_op:update_pet_info_all(NewMyPetInfo1),
																		%%把更改后的值传入重新计算函数,并且保存到数据库
																		pet_util:recompute_attr(grade_and_quality, PetId),
																		%%发送数据到前端
                                                                        {_, NewLuck} = get_quality_riseup_lucky_from_mypetinfo(NewMyPetInfo1),
																		send_message(?ERROR_PET_QUALITY_RISEUP_OK, PetId, NewLuck),
                                                                        broadcast_op:pet_quality_riseup(NewGmPetInfo, PetStage)
                                                                        
																end
																
														end
												end;
											Flag =:= ?CONSUME_GOLD ->
												% 花费金币
												Gold = pet_quality_riseup_proto_db:get_gold_from_riseup_property(Property),
												% 金币是否充足
												case role_op:check_money(?MONEY_GOLD, Gold) of
													false ->
														throw({?ERROR_LESS_GOLD, PetId, Luck});
													true ->
														case check_money(Cupro) of
															false ->
																throw({?ERROR_LESS_MONEY, PetId, Luck});
															true ->
																role_op:money_change(?MONEY_BOUND_SILVER, -Cupro, pet_quality_riseup),
																% 扣除金币
																role_op:money_change(?MONEY_GOLD, -Gold, pet_quality_riseup),
																% 判断是否升级成功
                                                                case random_rate_success(PetRiseUpSuccessRate, MinRetries, MaxRetries, Retries) of
																	false ->
                                                                        NewMyPetInfo = fail_to_do(MyPetInfo, Property),
                                                                        % slogger:msg("aaaaaaaaaNewMyPetInfo:~p~n", [NewMyPetInfo]),
                                                                        pet_op:update_pet_info_all(NewMyPetInfo),
                                                                        pet_op:save_pet_to_db(PetId),
                                                                        {_, NewLuck} = get_quality_riseup_lucky_from_mypetinfo(NewMyPetInfo),
                                                                        send_message(?ERROR_PET_QUALITY_RISEUP_FAIL, PetId, NewLuck),
		                      					  						
		                      					  						%提升成功还是失败,1成功,0失败
		                      					  						RiseupStatus = 0,
		                      					  						% 进阶成功后获取对应宠物的品质、阶数
																		NewGmPetquality = GmPetquality,
																		NewMyPetStage = MyPetStage,
																		
		                      					  						FieldValue = [RoleId,RoleName,PetId,PetName,Flag,RiseupStatus,GmPetquality,MyPetStage,NewGmPetquality,NewMyPetStage],
		                      					  						gm_logger_role:insert_log_pet_quality_riseup(FieldValue),
		                      					  						% slogger:msg("aaaaaaaaaFieldValue~p~n", [FieldValue]),
		                                                                case Up_type of
		                         											   1 ->
		                               												 ok;
		                           											   0 ->
		                              												 quality_riseup(PetId, Flag, Up_type)
		                      					  						end;
																	true ->
																		NewGmPetInfo = set_quality_to_petinfo(GmPetInfo, PetQuality),
																		NewMyPetInfo = set_quality_riseup_retries_to_mypetinfo(MyPetInfo, PetStage),
                                                                        NewMyPetInfo1 = success_to_do(NewMyPetInfo),
                                                                        % 进阶成功后获取对应宠物的品质、阶数
																		NewGmPetquality = get_quality_from_petinfo(NewGmPetInfo),
																		NewMyPetStage = get_quality_riseup_retries_from_mypetinfo(NewMyPetInfo1),
																		%提升成功还是失败,1成功,0失败
		                      					  						RiseupStatus = 1,

		                      					  						FieldValue = [RoleId,RoleName,PetId,PetName,Flag,RiseupStatus,GmPetquality,MyPetStage,NewGmPetquality,NewMyPetStage],
		                      					  						gm_logger_role:insert_log_pet_quality_riseup(FieldValue),
																		% slogger:msg("aaaaaaaaaNewGmPetquality:~p,GmPetquality~p,NewMyPetStage~p,MyPetStage~p~n", [NewGmPetquality,GmPetquality,NewMyPetStage,MyPetStage]),
																		% 更新内存数据
																		pet_op:update_gm_pet_info_all(NewGmPetInfo),
																		pet_op:update_pet_info_all(NewMyPetInfo1),
																		%%把更改后的值传入重新计算函数,并且保存到数据库
																		pet_util:recompute_attr(grade_and_quality, PetId),
																		%%发送数据到前端
                                                                        {_, NewLuck} = get_quality_riseup_lucky_from_mypetinfo(NewMyPetInfo1),
																		send_message(?ERROR_PET_QUALITY_RISEUP_OK, PetId, NewLuck),
                                                                        broadcast_op:pet_quality_riseup(NewGmPetInfo, PetStage)
																end
														end
												end
										end
								end
						end
				end;
			true ->
				throw({?ERROR_PET_QUALITY_RISEUP_INIT_FAILED, PetId, Luck})
		end
	catch
		E:R->
            case E of
                 throw->
                 	% slogger:msg("111111111111111111111111Reason:~p",[R]),
                    {Reason2, PetId2, Luck2} = R,
                    % slogger:msg("error is here:~p",[R]),
                    send_message(Reason2, PetId2, Luck2);
                 _->
                    slogger:msg("~p pet_quality_riseup ~p E ~p R ~p S ~p \n",[?MODULE,get(roleid),E,R,erlang:get_stacktrace()])  
            end
	end.