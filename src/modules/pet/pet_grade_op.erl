%% Author: Daiwenjie
%% Created: 2012-9-15
%% Description: TODO: Add description to pet_grade_op
-module(pet_grade_op).

-compile(export_all).
-include("pet_def.hrl").
-include("data_struct.hrl").
-include("common_define.hrl").
-include("mnesia_table_def.hrl").
-include("role_struct.hrl").
-include("pet_struct.hrl").
-include("error_msg.hrl").
-define(MAX_GRADE_UP,100).                  %% 最大可以升到的位阶
-define(ADVANCED_CHARACTER,11030101).       %% 进阶符的id
-define(INHERITANCE,11030101).              %% 传承丹的id
-define(ITEMNUMBER,1).                      %% 消耗道具的数量

-define(CONSUM_TYPE_ITEM, 0).               %% 消耗的是道具
-define(CONSUM_TYPE_GOLD, 1).               %% 消耗的是元宝

%% @doc 宠物成长处理函数
process_message(PetId,ExtItems, ConsumType, Up_type)->
    case travel_battle_op:is_in_zone() of
        false ->
            do_grade_riseup(PetId,ExtItems, ConsumType, Up_type);
        true ->
            Msg = pet_packet:encode_send_error_s2c(?TRAVEL_BATTLE_INVALID_OPERATION),
            role_op:send_data_to_gate(Msg)
    end.

%%验证是否可以提升成长点，消耗道具
can_riseup(NowGrade,NowQuality,ExtItems, ConsumType) ->
     case NowGrade<?MAX_GRADE_UP of
         true ->
             QualityInfo = pet_quality_proto_db:get_info(NowQuality),
             QualityProperties = pet_quality_proto_db:get_quality_properties_from_info(QualityInfo),
             QualityProperty = pet_quality_proto_db:get_quality_proto_property_from_properties(QualityProperties,1),
             {_,_,Min,Max} = QualityProperty,
             if
                 NowGrade<Max->
                      check_required_enough(NowGrade, ConsumType);
                 true->
                      ?ERROR_PET_GRADE_UP_TO_TOP
             end;
         false ->
              ?ERROR_PET_GRADE_UP_TO_TOP
    end.

 
%%验证(金钱和物品)/（金钱和元宝）是否足够
check_required_enough(NowGrade, ?CONSUM_TYPE_ITEM) ->
    GradeInfo = pet_grade_riseup_proto_db:get_grade_riseup_proto_info(NowGrade),
    [{CheckItems, BondItemsId, ItemCount}] = pet_grade_riseup_proto_db:get_required_items(GradeInfo),
    RequiredMoney = pet_grade_riseup_proto_db:get_money(GradeInfo),
    Has_Enough_Item = item_util:is_has_enough_item_in_package_by_class(CheckItems,ItemCount),
    Has_Enough_Money = role_op:check_money(?MONEY_BOUND_SILVER,RequiredMoney),
    case Has_Enough_Item  of
        true ->
              case Has_Enough_Money of
                  true ->
                      true;
                  false ->
                      ?ERROR_PET_NOT_ENOUGH_MONEY
              end;
        false ->
              ?ERROR_PET_NOT_ENOUGH_ITEM
    end;
check_required_enough(NowGrade, ?CONSUM_TYPE_GOLD) ->
    GradeInfo = pet_grade_riseup_proto_db:get_grade_riseup_proto_info(NowGrade),
    [{CheckItems, RequiredGold, ItemCount}] = pet_grade_riseup_proto_db:get_required_items(GradeInfo),
    RequiredMoney = pet_grade_riseup_proto_db:get_money(GradeInfo),
    Has_Enough_gold = role_op:check_money(?MONEY_GOLD,RequiredGold),
    Has_Enough_Money = role_op:check_money(?MONEY_BOUND_SILVER,RequiredMoney),

    case Has_Enough_gold  of
        true ->
              case Has_Enough_Money of
                  true ->
                      true;
                  false ->
                      ?ERROR_PET_NOT_ENOUGH_MONEY
              end;
        false ->
              ?TREASURE_CHEST_GOLD_NOT_ENOUGH
    end.

%% 根据成功率判断是否成功
is_success_by_probability(Probability)->
        Random_num = random:uniform(10000),
        if
                Random_num < Probability -> 
                     true;
                true -> 
                     false
        end.

%% 判断是否升阶成功
%% 1. 如果尝试次数小于最小次数则失败，大于最大次数则一定成功
%% 2. 如果成功概率是满足的，则成功，否则失败
is_success(Min_Retries, Max_Retries, Probability, Retries)->
    IsSuccess = is_success_by_probability(Probability),
    if
        Retries =< Min_Retries -> 
            false;
        Retries >= Max_Retries -> 
            true;
        IsSuccess == true ->
            true;
        IsSuccess == false ->
            false
    end.


%%扣除必须的进阶消耗的道具
%% 优先消耗非绑定物品
consum_items(Growth,ExtItems, ?CONSUM_TYPE_ITEM)->
       GradeInfo = pet_grade_riseup_proto_db:get_grade_riseup_proto_info(Growth),
       Money = pet_grade_riseup_proto_db:get_money(GradeInfo),
       [{ItemsId, _GoldNum, ItemNum}] = pet_grade_riseup_proto_db:get_required_items(GradeInfo),
       role_op:consume_items_by_classid(ItemsId, ItemNum),
       role_op:money_change(?MONEY_BOUND_SILVER, -Money, pet_growth_riseup);
%% 消耗元宝
consum_items(Growth,ExtItems, ?CONSUM_TYPE_GOLD)->
       GradeInfo = pet_grade_riseup_proto_db:get_grade_riseup_proto_info(Growth),
       Money = pet_grade_riseup_proto_db:get_money(GradeInfo),
       [{_ItemsId, GoldNum, ItemNum}] = pet_grade_riseup_proto_db:get_required_items(GradeInfo),
       slogger:msg("CONSUM_TYPE_GOLD:~p GoldNum:~p ~n", [Money, GoldNum]),
       role_op:money_change(?MONEY_GOLD, -GoldNum, pet_growth_riseup),
       role_op:money_change(?MONEY_BOUND_SILVER, -Money, pet_growth_riseup).

%%扣除额外进阶消耗的道具
consum_extitems(ExtItems) ->
      case ExtItems of 
         0 ->
           nothing;
         1 ->
           item_util:consume_items_by_tmplateid(?ADVANCED_CHARACTER, ?ITEMNUMBER)
      end.
 

%% 更新技能
new_skill(PetId)->
     %pet_skill_op:delete_pet(PetId),
     %Random = random:uniform(100),
     nothing.

%%进阶失败，幸运值增加，进阶次数的保存
fail_to_do(MyPetInfo,Grade) ->
     GradeInfo = pet_grade_riseup_proto_db:get_grade_riseup_proto_info(Grade),
     RandomNum = pet_grade_riseup_proto_db:get_random_num(GradeInfo),
     MaxLucky = pet_grade_riseup_proto_db:get_max_lucky(GradeInfo),
     Grade_False_Num = get_grade_riseup_retries_from_mypetinfo(MyPetInfo),
     MyPetInfo1 = set_grade_riseup_retries_to_mypetinfo(MyPetInfo, Grade_False_Num+1),
     Lucky = get_grade_riseup_lucky_from_mypetinfo(MyPetInfo1),
     Lucky1 = Lucky + random:uniform(RandomNum),
     NewLucky = min(MaxLucky,Lucky1),
     NewMyPetInfo = set_grade_riseup_lucky_to_mypetinfo(MyPetInfo1, NewLucky), 
     NewMyPetInfo.

%%进阶成功，幸运值和进阶的次数清零
success_to_do(MyPetInfo) ->
     MyPetInfo1 =   set_grade_riseup_retries_to_mypetinfo(MyPetInfo, 0),
     NewMyPetInfo = set_grade_riseup_lucky_to_mypetinfo(MyPetInfo1, 0),
     NewMyPetInfo.

do_grade_riseup(PetId,ExtItems, ConsumType, Up_type) ->
    quest_op:pet_grep_check(),
    try
        case pet_op:get_pet_info(PetId) of 
            []->
                throw({?ERROR_GRADEPET_NOEXIST,PetId});
             MyPetInfo->           
                 GmPetInfo = pet_op:get_pet_gminfo(PetId),
                 % 成长等级
                 NowGrade = get_grade_from_petinfo(GmPetInfo),
                 NowQuality = get_quality_from_petinfo(GmPetInfo),               %获取当前的品质
                 GradeInfo = pet_grade_riseup_proto_db:get_grade_riseup_proto_info(NowGrade),
                 MinRetries = pet_grade_riseup_proto_db:get_min_retries(GradeInfo),
                 MaxRetries = pet_grade_riseup_proto_db:get_max_retries(GradeInfo),
                 Probability = pet_grade_riseup_proto_db:get_grade_riseup_success_rate(GradeInfo),
                 Retries = get_grade_riseup_retries_from_mypetinfo(MyPetInfo), %已经进阶的次数
                 ReturnCode = can_riseup(NowGrade,NowQuality,ExtItems, ConsumType),
                %%玩家ID
                RoleId = get(roleid),
                %%玩家名称
                RoleInfo = get(creature_info),
                RoleName = get_name_from_roleinfo(RoleInfo),
                % 仙仆名称
                PetName = get_name_from_petinfo(GmPetInfo),
                 case ReturnCode of
                     true->
                         consum_items(NowGrade,ExtItems, ConsumType),    %扣除进阶消耗的道具或者元宝
                         case is_success(MinRetries, MaxRetries, Probability, Retries) of     %根据成功率判断是否成功
                             true ->  
                                 % NowQuality = get_quality_from_petinfo(GmPetInfo),              %获取当前的品质    
                                 GmPetInfo1 = set_grade_to_petinfo(GmPetInfo,NowGrade+1),       %更新位阶
                                 NewMyPetInfo = success_to_do(MyPetInfo),
                                 pet_op:update_gm_pet_info_all(GmPetInfo1),
                                 pet_op:update_pet_info_all(NewMyPetInfo),
                                 pet_util:recompute_attr(grade_and_quality,PetId),
                                 pet_op:save_pet_to_db(PetId),
                                 Grade = get_grade_from_petinfo(GmPetInfo1),
                                 broadcast_op:pet_grade(GmPetInfo1, Grade),
                                 Is_success = ?ERROR_PET_GRADE_UP_OK,
                                 Lucky = get_grade_riseup_lucky_from_mypetinfo(NewMyPetInfo),
                                %提升成功还是失败,1成功,0失败
                                RiseupStatus = 1,
                                FieldValue = [RoleId,RoleName,PetId,PetName,ConsumType,RiseupStatus,NowGrade,Grade],
                                gm_logger_role:insert_log_pet_grade_riseup(FieldValue),

                                 Message = pet_packet:encode_pet_grade_riseup_s2c(PetId, Is_success, Lucky),  
                                 role_op:send_data_to_gate(Message);
                             false ->
                                 NewMyPetInfo = fail_to_do(MyPetInfo,NowGrade),
                                 pet_op:update_pet_info_all(NewMyPetInfo),
                                 pet_op:save_pet_to_db(PetId),
                                 pet_util:recompute_attr(grade_and_quality,PetId),
                                 Is_success = ?ERROR_PET_GRADE_UP_FAILED,
                                 Lucky = get_grade_riseup_lucky_from_mypetinfo(NewMyPetInfo),
                                 Message = pet_packet:encode_pet_grade_riseup_s2c(PetId, Is_success, Lucky),  
                                 role_op:send_data_to_gate(Message),
                                %提升成功还是失败,1成功,0失败
                                RiseupStatus = 0,
                                FieldValue = [RoleId,RoleName,PetId,PetName,ConsumType,RiseupStatus,NowGrade,NowGrade],
                                gm_logger_role:insert_log_pet_grade_riseup(FieldValue),
                                 case Up_type of
                                      1 ->
                                       ok;
                                     0 ->
                                         process_message(PetId,ExtItems, ConsumType, Up_type) 
                                 end
                        end;
                     _ ->
                         throw({ReturnCode,PetId})
                 end
         end        
    catch
        E:R->
            case E of
                 throw->
                    {Reason,PetId} = R,
                    New_PetInfo = pet_op:get_pet_info(PetId),
                    NewLucky = get_grade_riseup_lucky_from_mypetinfo(New_PetInfo),
                    Message_failed = pet_packet:encode_pet_grade_riseup_s2c(PetId, Reason,NewLucky),
                    role_op:send_data_to_gate(Message_failed);
                 _->
                    slogger:msg("~p equipment_riseup role ~p E ~p R ~p S ~p \n",[?MODULE,get(roleid),E,R,erlang:get_stacktrace()])  
            end
    end. 