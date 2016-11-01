-module(magic_shield).
-include("data_struct.hrl").
-include("common_define.hrl").
-include("item_struct.hrl").
-include("role_struct.hrl").

-compile(export_all).

%%return:new ChangedAttr

%%抵挡伤害
hook_on_beattack(OriDamage,_OriChangeAttr,{BuffId,BuffLevel})->
	CurMp = creature_op:get_mana_from_creature_info(get(creature_info)),
	CurHp = creature_op:get_life_from_creature_info(get(creature_info)),
	BuffInfo = buffer_db:get_buffer_info(BuffId,BuffLevel),
	[AssValue,Rate]= buffer_db:get_buffer_effect_arguments(BuffInfo),
	MaxAssDamage = CurMp*Rate,
	AssRate = (1 - AssValue/100),
	ChangedAttr = 
	if
		OriDamage*AssRate + MaxAssDamage =< 0->		%%吸干我 ,还不够你吸的
			LossMp = -CurMp,
			LossHp = trunc(OriDamage + MaxAssDamage),
			NewLift = erlang:max(CurHp + LossHp, 0),
			role_op:remove_buffer({BuffId,BuffLevel}),
			[{hp,NewLift},{mp,0}];
		true->									%%当前蓝还够吸
			LossHp = trunc(OriDamage*AssRate),
			LossMp = trunc((OriDamage-LossHp)/Rate),
			%%丢失蓝 = 吸收伤害/蓝伤害比率
			NewLift = erlang:max(CurHp + LossHp, 0),
			[{hp,NewLift},{mp,CurMp+LossMp}]
	end,
	if
		LossMp=/= 0->
			Message = role_packet:encode_buff_affect_attr_s2c(get(roleid),[role_attr:to_role_attribute({mp,LossMp}),role_attr:to_role_attribute({hp,LossHp})]),
			role_op:send_data_to_gate(Message ),
			role_op:broadcast_message_to_aoi_client(Message);
		true->
			nothing
	end,			 			
 	ChangedAttr.