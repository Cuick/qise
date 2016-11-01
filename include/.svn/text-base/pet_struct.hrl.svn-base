-include("pet_define.hrl").

-record(gm_pet_info,{
					id,
					master,				%% 主人
					proto,				%% 宠物模板
					level,				%% 宠物级别
					name,				%% 姓名
					gender,				%% 性别
					life,				%% 当前血量
					mana,				%% 当前蓝量
					quality,			%% 品质
					exp,				%% 经验
					totalexp,			%% 总经验				
					hpmax,				%% 最大血量	
					mpmax,				%% 最大蓝量
					class,				%% 职业
					posx,
					posy,
					path,
					state,				%% 状态
					last_cast_time,		%% 攻击时间
					power,				%% 类型攻击	
					hitrate,			%% 命中
					criticalrate,		%% 暴击率
					criticaldamage, 	%% 暴击伤害	
					fighting_force,		%% 战斗力
					icon,				%% 称号		
					dodge,              %% 闪避
					defense,            %% 防御
					grade,              %% 成长阶数
					savvy,              %% 悟性
					magic_defense,		% 魔防
					far_defense,		% 远防
					near_defense,		% 近防
					magic_immunity,		% 魔免疫
					far_immunity,		% 远免疫
					near_immunity,		% 近免疫
					current_heart,		%%宠物心情
					can_buy_goods,		%%在宠物商店可以买的物品列表
					refresh_used,		%%已用刷新次数
					account,				%%宠物商店积分
					luck_high,    		%%幸运值
					refresh_defense		%%资质防御{magic_defense,far_defense,near_defense}
		       }).

create_petinfo(PetId, RoleId, Proto, Level, Name, Gender, Life, Mana, Quality, Hpmax, Mpmax, Class, State, {X,Y}, Exp, TotalExp, Power, HitRate, CriticalRate, CriticalDamage, Fighting_Force, Icon, Dodge, Defense, Grade,Savvy, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity, Heart_point, Can_buy_goods, Refresh_used, Account, Luck_high,Refresh_defense)->
	#gm_pet_info{
			id =PetId,
			master = RoleId,
			proto = Proto,
			level = Level,
			name = Name,
			gender = Gender,
			life = Life,
			mana = Mana,
			quality = Quality,
			exp = Exp,
			totalexp = TotalExp,
			hpmax = Hpmax,
			mpmax = Mpmax,
			class = Class,
			last_cast_time={0,0,0},
			path = [],
			state = State,
			posx = X,
			posy = Y,
			power = Power,				
			hitrate = HitRate,		
			criticalrate = CriticalRate,
			criticaldamage = CriticalDamage, 		
			fighting_force = Fighting_Force,
			icon = Icon,
			dodge = Dodge,
			defense = Defense,
			grade = Grade,
			savvy = Savvy,
			magic_defense = MagicDefense,
			far_defense = FarDefense,
			near_defense = NearDefense,
			magic_immunity = MagicImmunity,
			far_immunity = FarImmunity,
			near_immunity = NearImmunity,
			current_heart = Heart_point,
			can_buy_goods = Can_buy_goods,		
			refresh_used = Refresh_used,	
			account = Account,				
			luck_high =  Luck_high,
			refresh_defense = Refresh_defense
		}.

get_id_from_petinfo(PetInfo) ->
	#gm_pet_info{id=Id} = PetInfo,
	Id.
set_id_to_petinfo(PetInfo, Id) ->
	PetInfo#gm_pet_info{id=Id}.
	
get_master_from_petinfo(PetInfo) ->
	#gm_pet_info{master=Master} = PetInfo,
	Master.
set_master_to_petinfo(PetInfo, Master) ->
	PetInfo#gm_pet_info{master=Master}.

get_pos_from_petinfo(PetInfo) ->
	#gm_pet_info{posx=X} = PetInfo,
	#gm_pet_info{posy=Y} = PetInfo,
	{X,Y}.
set_pos_to_petinfo(PetInfo, {X,Y}) ->
	PetInfo#gm_pet_info{posx=X,posy = Y}.	
	
get_proto_from_petinfo(PetInfo) ->
	#gm_pet_info{proto=Proto} = PetInfo,
	Proto.
set_proto_to_petinfo(PetInfo, Proto) ->
	PetInfo#gm_pet_info{proto=Proto}.
	
get_level_from_petinfo(PetInfo) ->
	#gm_pet_info{level=Level} = PetInfo,
	Level.
set_level_to_petinfo(PetInfo, Level) ->
	PetInfo#gm_pet_info{level=Level}.
	
get_name_from_petinfo(PetInfo) ->
	#gm_pet_info{name=Name} = PetInfo,
	Name.
set_name_to_petinfo(PetInfo,Name) ->
	PetInfo#gm_pet_info{name=Name}.
	
get_gender_from_petinfo(PetInfo) ->
	#gm_pet_info{gender=Gender} = PetInfo,
	Gender.
set_gender_to_petinfo(PetInfo, Gender) ->
	PetInfo#gm_pet_info{gender=Gender}.
	
get_life_from_petinfo(PetInfo) ->
	#gm_pet_info{life=Life} = PetInfo,
	Life.
set_life_to_petinfo(PetInfo, Life) ->
	PetInfo#gm_pet_info{life=Life}.
	
get_mana_from_petinfo(PetInfo) ->
	#gm_pet_info{mana=Mana} = PetInfo,
	Mana.
set_mana_to_petinfo(PetInfo, Mana) ->
	PetInfo#gm_pet_info{mana=Mana}.
	
get_quality_from_petinfo(PetInfo) ->
	#gm_pet_info{quality=Quality} = PetInfo,
	Quality.
set_quality_to_petinfo(PetInfo, Quality) ->
	PetInfo#gm_pet_info{quality=Quality}.
	
get_exp_from_petinfo(PetInfo) ->
	#gm_pet_info{exp=Exp} = PetInfo,
	Exp.
set_exp_to_petinfo(PetInfo, Exp) ->
	PetInfo#gm_pet_info{exp=Exp}.

get_totalexp_from_petinfo(PetInfo) ->
	#gm_pet_info{totalexp=Exp} = PetInfo,
	Exp.
set_totalexp_to_petinfo(PetInfo, Exp) ->
	PetInfo#gm_pet_info{totalexp=Exp}.	
	
get_hpmax_from_petinfo(PetInfo) ->
	#gm_pet_info{hpmax=Hpmax} = PetInfo,
	Hpmax.
set_hpmax_to_petinfo(PetInfo, Hpmax) ->
	PetInfo#gm_pet_info{hpmax=Hpmax}.
	
get_mpmax_from_petinfo(PetInfo) ->
	#gm_pet_info{mpmax=Mpmax} = PetInfo,
	Mpmax.
set_mpmax_to_petinfo(PetInfo, Mpmax) ->
	PetInfo#gm_pet_info{mpmax=Mpmax}.
	
get_class_from_petinfo(PetInfo) ->
	#gm_pet_info{class=Class} = PetInfo,
	Class.
set_class_to_petinfo(PetInfo, Class) ->
	PetInfo#gm_pet_info{class=Class}.
	
get_last_cast_time_from_petinfo(PetInfo) ->
	#gm_pet_info{last_cast_time=Last_cast_time} = PetInfo,
	Last_cast_time.
set_last_cast_time_to_petinfo(PetInfo, Last_cast_time) ->
	PetInfo#gm_pet_info{last_cast_time=Last_cast_time}.	

get_state_from_petinfo(PetInfo) ->
	#gm_pet_info{state=State} = PetInfo,
	State.
set_state_to_petinfo(PetInfo, State) ->
	PetInfo#gm_pet_info{state=State}.
	
get_path_from_petinfo(PetInfo) ->
	#gm_pet_info{path=Path} = PetInfo,
	Path.			
set_path_to_petinfo(PetInfo, Path) ->
	PetInfo#gm_pet_info{path=Path}.

get_power_from_petinfo(PetInfo)->
	#gm_pet_info{power=Power} = PetInfo,
	Power.	
set_power_to_petinfo(PetInfo,Power)->
	PetInfo#gm_pet_info{power=Power}.

get_hitrate_from_petinfo(PetInfo)->
	#gm_pet_info{hitrate=Hitrate} = PetInfo,
	Hitrate.	
set_hitrate_to_petinfo(PetInfo,Hitrate)->
	PetInfo#gm_pet_info{hitrate=Hitrate}.

get_criticalrate_from_petinfo(PetInfo)->
	#gm_pet_info{criticalrate=Criticalrate} = PetInfo,
	Criticalrate.	
set_criticalrate_to_petinfo(PetInfo,Criticalrate)->
	PetInfo#gm_pet_info{criticalrate=Criticalrate}.

get_criticaldamage_from_petinfo(PetInfo)->
	#gm_pet_info{criticaldamage=Value} = PetInfo,
	Value.	
set_criticaldamage_to_petinfo(PetInfo,Value)->
	PetInfo#gm_pet_info{criticaldamage=Value}.

get_fighting_force_from_petinfo(PetInfo)->
	#gm_pet_info{fighting_force = Fighting_Force} = PetInfo,
	Fighting_Force.

set_fighting_force_to_petinfo(PetInfo,Fighting_Force)->
	PetInfo#gm_pet_info{fighting_force = Fighting_Force}.
	
get_icon_from_pet_info(PetInfo)->
	#gm_pet_info{icon = Icon} = PetInfo,
	Icon.
	
set_icon_to_petinfo(PetInfo,Icon)->
	PetInfo#gm_pet_info{icon = Icon}.

get_dodge_from_petinfo(PetInfo)->
    #gm_pet_info{dodge = Dodge} = PetInfo,
    Dodge.

set_dodge_to_petinfo(PetInfo,Dodge)->
    PetInfo#gm_pet_info{dodge = Dodge}.

get_defense_from_petinfo(PetInfo)->
    #gm_pet_info{defense = Defense} = PetInfo,
    Defense.

set_defense_to_petinfo(PetInfo,Defense)->
    PetInfo#gm_pet_info{defense = Defense}.

get_grade_from_petinfo(PetInfo)->
    #gm_pet_info{grade = Grade} = PetInfo,
    Grade.

set_grade_to_petinfo(PetInfo,Grade)->
    PetInfo#gm_pet_info{grade = Grade}.

get_savvy_from_petinfo(PetInfo)->
    #gm_pet_info{savvy = Savvy} = PetInfo,
    Savvy.

set_savvy_to_petinfo(PetInfo,Savvy)->
    PetInfo#gm_pet_info{savvy = Savvy}.

get_heart_from_petinfo(PetInfo)->
    #gm_pet_info{current_heart = Heart} = PetInfo,
    Heart.

set_heart_to_petinfo(PetInfo,Heart)->
    PetInfo#gm_pet_info{current_heart = Heart}.

get_goods_from_petinfo(PetInfo)->
    #gm_pet_info{can_buy_goods = Can_buy_goods} = PetInfo,
    Can_buy_goods.

set_goods_to_petinfo(PetInfo,Can_buy_goods)->
    PetInfo#gm_pet_info{can_buy_goods = Can_buy_goods}.

get_refresh_from_petinfo(PetInfo)->
    #gm_pet_info{refresh_used = Refresh_used} = PetInfo,
    Refresh_used.

set_refresh_to_petinfo(PetInfo,Refresh_used)->
    PetInfo#gm_pet_info{refresh_used = Refresh_used}.

get_account_from_petinfo(PetInfo)->
    #gm_pet_info{account = Account} = PetInfo,
    Account.

set_account_to_petinfo(PetInfo,Account)->
    PetInfo#gm_pet_info{account = Account}.

get_luck_from_petinfo(PetInfo)->
    #gm_pet_info{luck_high = Luck_high} = PetInfo,
    Luck_high.

set_luck_to_petinfo(PetInfo,Luck_high)->
    PetInfo#gm_pet_info{luck_high = Luck_high}.

get_refresh_defense_petinfo(PetInfo)->
    #gm_pet_info{refresh_defense = Refresh_defense} = PetInfo,
    Refresh_defense.

set_refresh_defense_to_petinfo(PetInfo,Refresh_defense)->
    PetInfo#gm_pet_info{refresh_defense = Refresh_defense}.  

-record(my_pet_info,{
			petid,	
			attr,					%%宠物自身属性点{攻击,命中,闪避，暴击,暴伤，生命，防御}
			equipinfo,				%%宠物装备信息
			trade_lock,				%%交易锁
			changenameflag,			%%是否修改过名字
			quality_value_info,     %%资质信息{攻击，命中，闪避，暴击，暴伤，生命，防御} (注:暂时摒弃不用,使用默认值)
			quality_value_up_info,  %%资质上限信息,是一个数值，因为所有的资质上限一样 (注:暂时摒弃不用,使用默认值)
			grade_riseup_retries,   %% 宠物成长失败次数
			grade_riseup_lucky,     %%宠物位成长失败所提高的幸运值
			quality_riseup_retries, %%宠物品质升级失败次数 (注:改为品阶阶数)
%% 			quality_riseup_lucky   %%宠物品质升级失败所提高的幸运值 (注:暂时摒弃不用,使用默认值)
            quality_riseup_lucky    %% {Failnum, Luck} 失败次数 幸运值

		}).
% my_pet_info,{petid,attr,equipinfo,trade_lock,changenameflag,quality_value_info,quality_value_up_info,grade_riseup_retries,grade_riseup_lucky,quality_riseup_retries,quality_riseup_lucky}

get_id_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{petid = Value} = MyPetInfo,
	Value.
set_id_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{petid = Value}.

get_attr_from_mypetinfo(MyPetInfo)->	
	#my_pet_info{attr = Value} = MyPetInfo,
	Value.
set_attr_to_mypetinfo(MyPetInfo,Value)->
	MyPetInfo#my_pet_info{attr = Value}.

get_equipinfo_from_mypetinfo(PetInfo)->	
	#my_pet_info{equipinfo = Value} = PetInfo,
	Value.
set_equipinfo_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{equipinfo = Value}.	

get_trade_lock_from_mypetinfo(PetInfo)->	
	#my_pet_info{trade_lock = Value} = PetInfo,
	Value.
set_trade_lock_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{trade_lock = Value}.

get_changenameflag_from_mypetinfo(PetInfo)->	
	#my_pet_info{changenameflag = Value} = PetInfo,
	Value.
set_changenameflag_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{changenameflag = Value}.

get_quality_value_info_from_mypetinfo(PetInfo)->
	#my_pet_info{quality_value_info=QualityValueInfo} = PetInfo,
	QualityValueInfo.	
set_quality_value_info_to_mypetinfo(PetInfo,QualityValueInfo)->
	PetInfo#my_pet_info{quality_value_info=QualityValueInfo}.

get_quality_value_up_info_from_mypetinfo(PetInfo)->
	#my_pet_info{quality_value_up_info = Value} = PetInfo,
	Value.	
set_quality_value_up_info_to_mypetinfo(PetInfo,Value)->
	PetInfo#my_pet_info{quality_value_up_info = Value}.
	

get_grade_riseup_retries_from_mypetinfo(PetInfo)->
    #my_pet_info{grade_riseup_retries = Value} = PetInfo,
    Value.

set_grade_riseup_retries_to_mypetinfo(PetInfo,Value)->
    PetInfo#my_pet_info{grade_riseup_retries = Value}.

get_grade_riseup_lucky_from_mypetinfo(PetInfo)->
    #my_pet_info{grade_riseup_lucky = Value} = PetInfo,
    Value.

set_grade_riseup_lucky_to_mypetinfo(PetInfo,Value)->
   PetInfo#my_pet_info{grade_riseup_lucky = Value}.


get_quality_riseup_retries_from_mypetinfo(PetInfo)->
    #my_pet_info{quality_riseup_retries = Value} = PetInfo,
    Value.

set_quality_riseup_retries_to_mypetinfo(PetInfo,Value)->
    PetInfo#my_pet_info{quality_riseup_retries = Value}.

get_quality_riseup_lucky_from_mypetinfo(PetInfo)->
    case PetInfo#my_pet_info.quality_riseup_lucky of
      {FailNum, Luck} -> {FailNum, Luck};
      _ -> {0, 0}
    end.

set_quality_riseup_lucky_to_mypetinfo(PetInfo,Value) ->
	PetInfo#my_pet_info{quality_riseup_lucky = Value}.

create_mypetinfo(PetId,Quality_Value_Info,Quality_Value_Up_Info,
				Attr,TradeLock,Equipinfo,ChangeNameFlag,
                Grade_Riseup_Retries,Grade_Riseup_Lucky,Quality_Riseup_Retries,Quality_Riseup_Lucky)->
	#my_pet_info{
			petid = PetId,
			attr = Attr,		
			quality_value_info = Quality_Value_Info,
			quality_value_up_info = Quality_Value_Up_Info,					
			equipinfo = Equipinfo,
			changenameflag = ChangeNameFlag,
            grade_riseup_retries = Grade_Riseup_Retries,
            grade_riseup_lucky = Grade_Riseup_Lucky,
            quality_riseup_retries = Quality_Riseup_Retries,
            quality_riseup_lucky = Quality_Riseup_Lucky
	}.

% 宠物商店倒计时
-record(pet_shop, {
		role_id,
		end_time = 0,			% 本轮刷新结束时间
		pet_goods_list = [],	% 本轮刷新出的宠物商品([{PetTemplateId, Price}, .....])
		buy_pet = [],			% 本轮购买宠物
		% 一下为预留字段
		obligate,
		obligate2,
		obligate3,
		obligate4,				%account
		obligate5    			%luck value
	}).
