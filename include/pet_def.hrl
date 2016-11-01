%%
%%pet table define
%%
-record(pet_proto,{
					protoid,				%%模板id
					name,					%%宠物姓名
					species,				%%物种
					femina_rate,			%%雌性概率
					class,					%%魔|远|攻
					min_take_level,			%%最低携带玩家等级
					quality_to_growth,		%%品质对应成长值段[{品质,{资质下限,资质上限},{成长值}}]
					born_abilities,			%%出生能力值 {生命，攻击，命中，闪避，暴击，暴伤，韧性}
					born_attr,				%%出生属性点 {攻击点,命中点,暴击点,体质加成点}
					born_talents,			%%出生天赋 {{攻击下限,攻击上限},{命中下限,命中上限},{暴击下限,暴击上限},{体质加成下限,体质上限}}
					born_skills,			%%出生随机技能列表[{技能id,概率},....]
					happiness_cast,			%%欢乐度消耗概率{概率,消耗点数}
					born_quality,			%%出生资质	[{品质,[{{下限,上限},概率(1-100)}]}]		
					born_quality_up,		%%出生资质上限 [{品质,[{{下限,上限},概率(1-100)}]}]
					can_delete,				%%放生标志 1为可放生
					can_explore				%%探险标志 1为可探险	
				}).

%% 宠物id映射定义
-record(pet_mapping_proto,{
			grade_quality,          % 阶和品质的元组，如{1, 7}
			protoid	                % 模板id，如20000001
		}).

-record(pets,{petid,masterid,protoid,petinfo,skillinfo,equipinfo,ext1,ext2}).

-record(pet_level,{level,exp,maxhp,sysaddattr}).

-record(pet_slot,{slot,price}).
-record(pet_skill_slot,{index,rate}).
-record(pet_skill_fuse,{index,skillid}).
-record(pet_growth_riseup_proto,{growth,grade_riseup_success_rate,money,required_items,min_retries,max_retries,random_num,max_lucky}).
% id,{生命，攻击，命中，闪避，暴击，暴伤，韧性}
-record(pet_growth_proto, {id, pet_attrs}). 
-record(pet_quality_proto,{grade,quality_properties}).
% 宠物品质进阶
-record(pet_quality_riseup_proto,{
		quality,					% 宠物的品质
		quality_riseup_properties	% properties
	}).
-record(properties,{grade,success_rate,money,required_items,gold,min_retries,max_retries,random_num,max_lucky}).
-record(pet_quality_value_riseup_proto,{grade,quality_value_riseup_properties}).
-record(pet_savvy_riseup_proto, {grade, savvy_riseup_properties}).

% 宠物商店
-record(pet_shop_config, {
		pet_template_id,
		price,
		rate,
		type
	}).

% 宠物类型转换
-record(pet_type_change_config, {
		type,						% 类型
		prop_list,					% 道具([ClassId, Num])
		gold						% 花费金币
	}).

% 宠物精炼属性
-record(pet_type_attr_value_config, {
		index,					% {精炼类型, 属性id}
		random_attr_value		% 属性值随机范围([{Value, Prob}, ....])
	}).

% 宠物精炼属性锁定
-record(pet_type_attr_lock_config, {
		index,					% {精炼类型, 锁定条数}
		prop_list,				% 道具([{ClassId, Num}, .....])
		gold					% 花费金币
	}).
%%config
-record(room, {
		room_standard,           % {room_id,pet_level}
		need_gold,				%at_once_get_exp_price
		gain_exp             % 
}).
		% {roomid,need_gold,choosetime,duration}
-record(room_price, {
		id,           % 
		need_gold,				%open_price
		choosetime,
		duration             % /tian
}).

%%on_role
-record(pet_room, {
		pet_id,
		room_id,   	%
		start_time,			%开始时间
		duration           % 过期时间 /20Minute

}).
