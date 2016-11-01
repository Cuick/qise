
%% Author:yao
%% Des:functional up.
%%
-module(pet_savvy_up_op).

-export([pet_savvy_up/1]).

-include("pet_struct.hrl").
-include("error_msg.hrl").
-include("common_define.hrl").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Macro                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-define(SAVVY_MAX_VALUE, 100).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          API                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Des: return PetId's newest status and send to client.
%% 
%%init(PetId) ->
%%	PetGmInfo = pet_op:get_pet_gminfo(PetId),
%%
%%	Savvy = get_savvy_from_petinfo(PetGmInfo),
%%	SucessRate = get_sucess_rate(),
%%	RequiredMoney = 0,
%%	[{RequiredItem, _Count}] = get_required_items(),
               
%%	SavvyInfo = {Savvy, RequiredMoney, RequiredItem, SucessRate},	
%%	format()       		
%%	SavvyInfoToSend = pet_package:encode_savvy_up_s2c(SavvyInfo),       
%%	role_op:send_data_to_gate(SavvyInfoToSend)
%%	end. 
%%
%% Des: try to riseup PetId's savvy,may sucess or fail.
%%	
pet_savvy_up(PetId) ->
	try              
	Rst = case pet_op:get_pet_gminfo(PetId) of
	[] -> SavvyMaxValue = 0, 
		?ERROR_PET_NOEXIST;
	PetGmInfo  ->
		Savvy = get_savvy_from_petinfo(PetGmInfo),
		Quality = get_quality_from_petinfo(PetGmInfo),		
		Grade = get_grade_from_petinfo(PetGmInfo),

		%%get pet savvy riseup property
		GradeInfo = pet_savvy_up_proto_db:get_info(Grade),
		Properties = pet_savvy_up_proto_db:get_properties_from_grade_info(GradeInfo),
		Property = pet_savvy_up_proto_db:get_property_from_properties(Properties, Quality),	
		
		SavvyMaxValue = get_max_value(Property),

		if
		Savvy =:= SavvyMaxValue -> ?ERROR_PET_SAVVY_UP_TOP;	
		true -> 
			RequiredItems = get_required_items(Property),
			RequiredMoney = get_required_money(Property),
			CheckItem = check_item_required(RequiredItems),
			CheckMoney = check_money_required(RequiredMoney),
			if 
			not CheckItem -> 
				?ERROR_MISS_ITEM;
			not CheckMoney ->
				?ERROR_LESS_MONEY;
			true ->		  
				consume_item_required(RequiredItems),		
				consume_money_required(RequiredMoney),

				SucessRate = get_sucess_rate(Property),
				CheckSucessRst = check_sucess_rate(SucessRate),
				
				NewSavvy = Savvy + get_add_savvy(CheckSucessRst),
				SavvyAdd = format_new_savvy(NewSavvy),
				NewGmInfo = set_savvy_to_petinfo(PetGmInfo, SavvyAdd),	
				update_gm_info(PetId, NewGmInfo),
				pet_util:recompute_attr(savvy, PetId),
				
				{ok, CheckSucessRst, SavvyAdd}
			end
		end
	end,
	
	%%reply to client
	case Rst of
	{ok, true, SavvyRep} -> 
		ReplyData = pet_packet:encode_pet_savvy_up_s2c(?ERROR_PET_SAVVY_UP_OK,  
								SavvyRep, SavvyMaxValue );
	{ok, false, SavvyRep} -> 
		ReplyData = pet_packet:encode_pet_savvy_up_s2c(?ERROR_PET_SAVVY_UP_FAIL, 0, SavvyMaxValue);
	Error -> 
		ReplyData = pet_packet:encode_pet_savvy_up_s2c(Error, 0, 0 )
	end,
	role_op:send_data_to_gate(ReplyData)
	
	catch
	E:R ->  slogger:msg("pet_savvy_up_op: Unkown error", [E]),
		slogger:msg("pet_savvy_up_op: ", [R])		
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Internal Function                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% Des:get sucess rate and check whether sucess.
%%
check_sucess_rate(SucessRate) ->
	Random = random:uniform(10000),
	if 
	Random < SucessRate -> 
		true;
	true -> false
	end.    	
%%
%% Des: if NewSavvy bigger than 100,return 100,else itself.
%%
format_new_savvy(NewSavvy) ->
	if 
	NewSavvy > 100 -> 100;
	true -> NewSavvy
	end.

%%
%% Des: get item required by savvy up.
%%
get_required_items(Property) ->
	pet_savvy_up_proto_db:get_required_items(Property).

%%
%% Des: save the new GmInfo to process dict and disc copy.
%%
update_gm_info(PetId, NewGmInfo) ->
	pet_op:update_gm_pet_info_all(NewGmInfo),
	pet_op:save_pet_to_db(PetId).

%%
%% Des:check the needed item whether enough
%% Ret:{item, num}
check_item_required(RequiredItem) ->
	Fun = fun(TemplateId, Count) ->
		Ret = item_util:is_has_enough_item_in_package(TemplateId,Count),
		Ret
	end,
	traverse_items_by_fun(Fun, RequiredItem).
%%
%% Des:consume the required items
%% 
consume_item_required(RequiredItem) ->
	Fun = fun(TemplateId, Count) ->
		item_util:consume_items_by_tmplateid(TemplateId,Count),
		true 
	end,

	traverse_items_by_fun(Fun, RequiredItem).


traverse_items_by_fun(Fun, []) -> true;
traverse_items_by_fun(Fun, [{TemplateId, Count}|T]) ->
	case Fun(TemplateId, Count) of
	true ->	traverse_items_by_fun(Fun, T);
	false -> false
	end.
	
	
%%
%% Des: if SucessRateRst=true return a random integer between 2-5.
%%	else  return 0;
%
get_add_savvy(SucessRateRst) ->
	case SucessRateRst of
	true ->
		Num = random:uniform(5),
		if 
		1 =:= Num ->3;
		true -> Num
		end;
	_Other -> 0
	end.
%%
%% Des: get required money.
%%
get_required_money(Property) ->
	pet_savvy_up_proto_db:get_required_money(Property).
%%
%% Des: check required money.
%%
check_money_required(RequiredMoney) ->
	role_op:check_money(?MONEY_BOUND_SILVER, RequiredMoney).
%%
%% Des: consume money required 
%%
consume_money_required(RequiredMoney) ->
	role_op:money_change(?MONEY_BOUND_SILVER, -RequiredMoney, pet_savvy_up).
	
%%
%% Des: get sucess_rate 
%%
get_sucess_rate(Property) ->
	pet_savvy_up_proto_db:get_sucess_rate(Property).
%%
%% Des: get max savvy value.
%%
get_max_value(Property) ->
	pet_savvy_up_proto_db:get_max_savvy_value(Property).
