%% Author: duanzhichao
%% Created: 2012-9-10
%% Description:宠物资质相关逻辑

-module(pet_quality_value_op).


%%
%% Exported Functions
%%
-export([qualification_upgrade_logic/2]).

%%
%% Include files
%%
-include("pet_def.hrl").
-include("common_define.hrl").
-include("pet_struct.hrl").
-include("error_msg.hrl").

%%
%% Local Functions
%%

%% 是否到达资质上限
is_max_qualification(Index, My_pet_info)->
	Quality_value_info = get_quality_value_info_from_mypetinfo(My_pet_info),
	Quality_value = element(Index, Quality_value_info),  
	Quality_value_up = get_quality_value_up_info_from_mypetinfo(My_pet_info),
    Quality_value >= Quality_value_up.

%% 检测前端数据是否合法
is_legitimate(Index, My_pet_info)->
	Quality_value_info = get_quality_value_info_from_mypetinfo(My_pet_info),
	Range = size(Quality_value_info),
	Range >= Index.  

check_max_qualification(Cur_qualification, Max_qualification)->
	if
		Cur_qualification >= Max_qualification ->
			Max_qualification;
		true->
			Cur_qualification
	end.
	
%% 是否可以提升 
check_qualification_upgrade(Index, Gm_pet_info, My_pet_info)->
	Grade = get_grade_from_petinfo(Gm_pet_info),                       
	Quality = get_quality_from_petinfo(Gm_pet_info),
	Money = pet_quality_value_riseup_proto_db:get_riseup_money(Grade, Quality),
	[{Template_id,Need_number}] = pet_quality_value_riseup_proto_db:get_riseup_iteminfo(Grade, Quality),
	Is_legitimate = not is_legitimate(Index, My_pet_info),
	Is_not_money = not role_op:check_money(?MONEY_BOUND_SILVER,Money),
	Is_not_item = not package_op:check_item_by_template_id(Template_id, Need_number),
	Is_max = is_max_qualification(Index, My_pet_info),
	if 
		Is_legitimate->?ERROR_UNKNOWN;                           % 非法数据
		Is_not_money->?ERROR_LESS_MONEY;                         % 钱不够 
		Is_not_item->?ERROR_MISS_ITEM;                           % 道具不够 
		Is_max->?ERROR_PET_QUALIFICATION_MAX;                    % 已经最大值
		true->?ERROR_PET_QUALIFICATION_SUCCESS                   % 可以提升
	end.

%% 提升资质方法
qualification_upgrade(Gm_pet_info, My_pet_info, Index)->
	% 得到将要提升的属性值和上限
	Quality_value_info = get_quality_value_info_from_mypetinfo(My_pet_info),
	Quality_value = element(Index, Quality_value_info),                 
	Quality_value_up = get_quality_value_up_info_from_mypetinfo(My_pet_info),
	
	% 得到提升的百分比,所需的金钱和道具信息
	Grade = get_grade_from_petinfo(Gm_pet_info),                       
	Quality = get_quality_from_petinfo(Gm_pet_info),
	Riseup_percent = pet_quality_value_riseup_proto_db:get_riseup_percent(Grade, Quality),
	Money = pet_quality_value_riseup_proto_db:get_riseup_money(Grade, Quality),
	Iteminfo = pet_quality_value_riseup_proto_db:get_riseup_iteminfo(Grade, Quality),
	Success_rate = pet_quality_value_riseup_proto_db:get_riseup_success_rate(Grade, Quality),
	
	case util:is_success_by_probability(Success_rate) of   % 根据成功率判断是否成功
		true->
			% 得到提升后的属性值和Quality_value_info
			New_quality_value0 = Quality_value + Quality_value_up * (Riseup_percent / 10000),
			New_quality_value1 = check_max_qualification(New_quality_value0, Quality_value_up),
			New_quality_value_info = setelement(Index, Quality_value_info, New_quality_value1),   
		
		    % 得到提升后的My_pet_info
			New_my_pet_info = set_quality_value_info_to_mypetinfo(My_pet_info, New_quality_value_info),
			slogger:msg("New_my_pet_info---New_quality_value1--New_quality_value_info--Quality_value_up----------------------------------~p~n",[New_my_pet_info,New_quality_value1,New_quality_value_info,Quality_value_up]),
			% 保存
			pet_op:update_pet_info_all(New_my_pet_info),
			PetId = New_my_pet_info#my_pet_info.petid,
		    pet_op:save_pet_to_db(PetId),
			
			% 重新计算属性
			pet_util:recompute_attr(quality_value,PetId),
			
			?ERROR_PET_QUALIFICATION_SUCCESS;    % 成功
		false->
			?ERROR_PET_QUALIFICATION_FAILED     % 失败
	end.

%%
%% API Functions
%%

%% 宠物资质提升逻辑
%% 参数说明：Index ：1:攻击，2:命中，3:闪避，4:暴击，5:暴伤，6:生命，7：防御。
qualification_upgrade_logic(PetId, Index)->
%% 	slogger:msg("qualification_upgrade_logic-----------------------------------------~p~n",[Index]),
	Gm_pet_info = pet_op:get_pet_gminfo(PetId),
	My_pet_info = pet_op:get_pet_info(PetId),
%% 	slogger:msg("Gm_pet_info-----------------------------------------~p~n",[get(gm_pets_info)]),
%% 	slogger:msg("My_pet_info-----------------------------------------~p~n",[get(pets_info)]),
	case check_qualification_upgrade(Index, Gm_pet_info, My_pet_info) of     % 检测是否可以提升
		?ERROR_PET_QUALIFICATION_SUCCESS->
			% 消耗道具
			Grade = get_grade_from_petinfo(Gm_pet_info),                       
			Quality = get_quality_from_petinfo(Gm_pet_info),
			[{Template_id, Need_number}] = pet_quality_value_riseup_proto_db:get_riseup_iteminfo(Grade, Quality),
			role_op:consume_items(Template_id, Need_number),
            
			%% 提升资质
			Is_success = qualification_upgrade(Gm_pet_info, My_pet_info, Index);
		Check_code->
			Is_success = Check_code
	end,
	
	% 发送前端数据
	Message = pet_packet:encode_pet_qualification_upgrade_s2c(Is_success),
%% 	slogger:msg("Message-----------------------------------------~p~n",[Message]),
	role_op:send_data_to_gate(Message).

