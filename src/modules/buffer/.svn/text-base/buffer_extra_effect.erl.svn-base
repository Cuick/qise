%%
%%
-module(buffer_extra_effect).
%%
%% Exported Functions
%%
-export([remove/2,remove_ext_state/3,add/2,add_ext_state/3]).
%%
%% Include files
%%
-include("skill_define.hrl").
-include("data_struct.hrl").
-include("npc_struct.hrl").
-include("role_struct.hrl").

remove(CreatureInfo,BufferInfo)->
	remove_ext_state(buffer_db:get_buffer_resist_type(BufferInfo),CreatureInfo,BufferInfo).
add(CreatureInfo,BufferInfo)->
	add_ext_state(buffer_db:get_buffer_resist_type(BufferInfo),CreatureInfo,BufferInfo).

add_ext_state(?BUFF_FREEZING, CreatureInfo,_) ->
	creature_op:add_extra_state_to_creature_info(CreatureInfo, freezing);
add_ext_state(?BUFF_SILENT, CreatureInfo,_) ->
	creature_op:add_extra_state_to_creature_info(CreatureInfo, silent);     
add_ext_state(?BUFF_COMA, CreatureInfo,_) ->
	creature_op:add_extra_state_to_creature_info(CreatureInfo, coma);       
add_ext_state(?BUFF_GOD, CreatureInfo,_) ->
	creature_op:add_extra_state_to_creature_info(CreatureInfo, god);  
add_ext_state(?BUFF_IMMUNE_CTRL,CreatureInfo,_) ->
	creature_op:add_extra_state_to_creature_info(CreatureInfo, immune_ctrl);  
add_ext_state(?BUFF_IMMUNE_SKILL,CreatureInfo,_) ->
	creature_op:add_extra_state_to_creature_info(CreatureInfo, immune_skill);  
add_ext_state(?BUFF_HOLD,CreatureInfo,_) ->
	creature_op:add_extra_state_to_creature_info(CreatureInfo, hold);  
add_ext_state(_, CreatureInfo,_BufferInfo) when is_record(CreatureInfo, gm_npc_info) ->
	CreatureInfo;
%% role effect only:
add_ext_state(?BUFF_HATREDRATIO,RoleInfo,BufferInfo) ->
	[AddRadio] = buffer_db:get_buffer_effect_arguments(BufferInfo),
	NewHatredratio = creature_op:get_hatredratio_from_creature_info(RoleInfo) + AddRadio/100, 
	creature_op:set_hatredratio_to_creature_info(RoleInfo, NewHatredratio);
add_ext_state(?BUFF_EXPRATIO,RoleInfo,BufferInfo)->
%%	[AddRadio] = buffer_db:get_buffer_effect_arguments(BufferInfo),	
%%	NewExpratio = get_expratio_from_roleinfo(RoleInfo) + AddRadio/100,
	AddRadioList = buffer_db:get_buffer_effect_arguments(BufferInfo),
	OldExpList = get_expratio_from_roleinfo(RoleInfo),
	NewExpratio = lists:foldl(fun({Type,Value},Acc)-> 
							case lists:keyfind(Type,1,Acc) of
								false->
									[{Type,Value}|Acc];
								{_,OldValue}->
									lists:keyreplace(Type,1,Acc,{Type,Value+OldValue})
							end
						end,[],OldExpList ++ AddRadioList),
	set_expratio_to_roleinfo(RoleInfo, NewExpratio);
add_ext_state(block_training, RoleInfo,_)->
	add_extra_state_to_roleinfo(RoleInfo, block_training);
add_ext_state(?BUFF_PETEXPRATIO,RoleInfo,BufferInfo)->
	[AddRadio] = buffer_db:get_buffer_effect_arguments(BufferInfo),	
	NewExpratio = get_petexpratio_from_roleinfo(RoleInfo) + AddRadio/100,
	set_petexpratio_to_roleinfo(RoleInfo, NewExpratio);
%% effect end
add_ext_state(_, RoleInfo,_) ->
	RoleInfo.

remove_ext_state(?BUFF_GOD, CreatureInfo,_BufferInfo) ->
	creature_op:remove_extra_state_from_creature_info(CreatureInfo, god);
remove_ext_state(?BUFF_FREEZING, CreatureInfo,_BufferInfo) ->
	creature_op:remove_extra_state_from_creature_info(CreatureInfo, freezing);
remove_ext_state(?BUFF_SILENT, CreatureInfo,_BufferInfo) ->
	creature_op:remove_extra_state_from_creature_info(CreatureInfo, silent);
remove_ext_state(?BUFF_COMA, CreatureInfo,_BufferInfo) ->
	creature_op:remove_extra_state_from_creature_info(CreatureInfo, coma);
remove_ext_state(?BUFF_IMMUNE_CTRL,CreatureInfo,_BufferInfo) ->
	creature_op:remove_extra_state_from_creature_info(CreatureInfo, immune_ctrl);
remove_ext_state(?BUFF_IMMUNE_SKILL,CreatureInfo,_BufferInfo) ->
	creature_op:remove_extra_state_from_creature_info(CreatureInfo, immune_skill);   
remove_ext_state(?BUFF_HOLD,CreatureInfo,_BufferInfo) ->
	creature_op:remove_extra_state_from_creature_info(CreatureInfo, hold);
remove_ext_state(_, CreatureInfo,_BufferInfo) when is_record(CreatureInfo, gm_npc_info) ->
	CreatureInfo;
%% role effect only:
remove_ext_state(?BUFF_HATREDRATIO, RoleInfo,BufferInfo) ->
	[AddRadio] = buffer_db:get_buffer_effect_arguments(BufferInfo),
	NewHatredratio = creature_op:get_hatredratio_from_creature_info(RoleInfo) - AddRadio/100, 
	creature_op:set_hatredratio_to_creature_info(RoleInfo, NewHatredratio);
remove_ext_state(?BUFF_EXPRATIO, RoleInfo,BufferInfo) ->	
	AddRadioList = buffer_db:get_buffer_effect_arguments(BufferInfo),
	OldExpratio = get_expratio_from_roleinfo(RoleInfo),
	NewExpratio = lists:foldl(fun({Type,Value},Acc)->
								case lists:keyfind(Type,1,Acc) of
									false->
										Acc;
									{_,OldValue}->
										if
											Value >= OldValue ->
												lists:keydelete(Type,1,Acc);
											true->
												lists:keyreplace(Type,1,Acc,{Type,OldValue - Value})
										end
								end	 
							end, OldExpratio, AddRadioList),	
	set_expratio_to_roleinfo(RoleInfo, NewExpratio);
remove_ext_state(block_training, RoleInfo,_BufferInfo) ->
	remove_extra_state_to_roleinfo(RoleInfo, block_training);
remove_ext_state(?BUFF_PETEXPRATIO, RoleInfo,BufferInfo) ->	
	[AddRadio] = buffer_db:get_buffer_effect_arguments(BufferInfo),
	NewExpratio = erlang:max(get_petexpratio_from_roleinfo(RoleInfo) - AddRadio/100,1),
	set_petexpratio_to_roleinfo(RoleInfo, NewExpratio);
%% effect end
remove_ext_state(_, CreatureInfo,_) ->
	CreatureInfo.
