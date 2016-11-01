%% Author: SQ.Wang
%% Created: 2011-11-15
%% Description: TODO: Add description to pet_fighting_force
-module(pet_fighting_force).

%%
%% Include files
%%
-include("pet_struct.hrl").
-include("fighting_force_define.hrl").
%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%
hook_on_change_pet_fighting_force(PetId)->
	PetInfo = pet_op:get_pet_gminfo(PetId),
	#gm_pet_info{life = Life, power = Power, hitrate = Hitrate, criticalrate = Criticalrate, criticaldamage = Criticaldamage, dodge = Dodge, magic_defense = MagicDefense, far_defense = FarDefense, near_defense = NearDefense, magic_immunity = MagicImmunity, far_immunity = FarImmunity, near_immunity = NearImmunity,refresh_defense = {AddMagicDefense, AddFarDefense, AddNearDefense}} = PetInfo,
	Fighting_Force = computter_fight_force(Power, Hitrate, Dodge, Criticalrate, Criticaldamage, Life,AddMagicDefense + MagicDefense, AddFarDefense + FarDefense, AddNearDefense + NearDefense, MagicImmunity, FarImmunity, NearImmunity),
	pet_attr:only_self_update(PetId,[{fighting_force,Fighting_Force}]),
	% slogger:msg("aaaaaaaaaaaa Fighting_Force:~p,Power:~p,Criticalrate:~p~n",[Fighting_Force,Power,Criticalrate]),
	Fighting_Force.

%% @doc 计算战力
computter_fight_force(Power, Hitrate, Dodge, Criticalrate, Criticaldamage, Life, MagicDefense, FarDefense, NearDefense, MagicImmunity, FarImmunity, NearImmunity) ->
	trunc(Life * ?FIGHT_FORCE_HP + Power * ?FIGHT_FORCE_POWER + (MagicDefense + FarDefense + NearDefense) * ?FIGHT_FORCE_DEFINSES + erlang:max(0, (Hitrate)) * ?FIGHT_FORCE_HITRATE + Dodge * ?FIGHT_FORCE_DODGE + erlang:max(0, (Criticalrate)) * ?FIGHT_FORCE_CRITICALRATE + erlang:max(0, (Criticaldamage)) * ?FIGHT_FORCE_CRITICALDAMA + (MagicImmunity + FarImmunity + NearImmunity) * ?FIGHT_FORCE_IMMUNITY).
