%% Author: adrianx
%% Created: 2010-11-8
%% Description: TODO: Add description to role_util
-module(role_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).
-compile(export_all).

-record(gm_role_info, {gs_system_role_info, 
		       gs_system_map_info,
		       gs_system_gate_info,
		       pos, name, view, life, mana,
		       gender,				%%性别
		       icon,				%%头像
		       speed, state, skilllist, 
		       extra_states,
		       last_cast_time,
		       path, level,
		       silver,				%%游戏币,银币
		       gold,				%%元宝
		       ticket,				%%礼券
		       hatredratio,			%%仇恨比率
		       expratio,			%%经验比率
		       lootflag,			%%掉落系数
		       exp,					%%经验
		       levelupexp,			%%升级所需经验
		       agile,				%%敏
		       strength,			%%力
		       intelligence,		%%智
		       stamina,				%%体质
		       hpmax,		
		       mpmax,
		       hprecover,
		       mprecover,
		       power,				%%攻击力
		       class,				%%职业
		       commoncool,			%%公共冷却
		       immunes,				%%免疫力{魔，远，近}
		       hitrate,				%%命中
		       dodge,				%%闪避
		       criticalrate,		%%暴击
		       criticaldamage,		%%暴击伤害
		       toughness,			%%韧性
		       debuffimmunes,		%%debuff免疫{定身，沉默，昏迷，抗毒,一般}
		       defenses,			%%防御力{魔，远，近}
		       %%2010.9.20
		       buffer,				%%buffer
		       guildname,			%%公会名
		       guildposting,	    %%职位
		       cloth,				%%衣服
		       arm,					%%武器
		       pkmodel,				%%PK模式
		       crime,				%%罪恶值	
		       pet_name,
		       pet_id,
		       pet_proto,
		       pet_quality	
		       }).

%%
%% API Functions
%%
get_role_info()->
	get(creature_info).

get_level(RoleInfo) when is_record(RoleInfo, gm_role_info) ->
	erlang:element(#gm_role_info.level, RoleInfo).

set_level(RoleInfo,Level)when is_record(RoleInfo, gm_role_info) ->
	erlang:setelement(#gm_role_info.level, RoleInfo, Level).

get_class(RoleInfo) when is_record(RoleInfo, gm_role_info) ->
	erlang:element(#gm_role_info.class, RoleInfo).

get_name(RoleInfo)when is_record(RoleInfo, gm_role_info) ->
	erlang:element(#gm_role_info.name, RoleInfo).

get_id()->
    get(roleid).
%%
%% Local Functions
%%

