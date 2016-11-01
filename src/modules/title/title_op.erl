-module (title_op).

-include ("title_def.hrl").

-export ([load_from_db/1, export_for_copy/0, load_by_copy/1, save_to_db/0, hook_offline/0, 
	get_title_add_attr/0, change_show/2, hook_on_condition_change/3,
	hook_on_condition_change_offline/3,hook_guild_battle_title/2,lose_guild_battle_title/0,
	guild_battle_title/1]).

-include ("role_struct.hrl").

load_from_db(RoleId) ->
	Info = case role_title_db:get_role_title_info(RoleId) of
		[] ->
			[];
		{_, RoleId, TitleInfo} ->
			TitleInfo
	end,
	compute_attrs(Info),
	Info.

export_for_copy() ->
	get(title_attrs).

load_by_copy(Attrs) ->
	put(title_attrs, Attrs).

save_to_db() ->
	RoleId = get(roleid),
	Info = get_icon_from_roleinfo(get(creature_info)),
	role_title_db:save_role_title_info(RoleId, Info).

hook_offline() ->
	save_to_db().

get_title_add_attr() ->
	get(title_attrs).

change_show(Info, ShowList) ->
	ShowList2 = [TitleId || TitleId <- ShowList, lists:keymember(TitleId, 1, Info)],
	case show_base_check(ShowList2) of
		true ->
			Info2 = lists:map(fun({TitleId2, _}) ->
				case lists:member(TitleId2, ShowList2) of
					true ->
						{TitleId2, ?TITLE_SHOW};
					false ->
						{TitleId2, ?TITLE_HIDE}
				end
			end, Info),
			{ok, Info2};
		false ->
			false
	end.
hook_on_condition_change(?TITLE_GUILD_BATTLE, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_GUILD_BATTLE, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(?TITLE_TYPE_PETNUM, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_TYPE_PETNUM, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(?TITLE_TYPE_FRIEND, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_TYPE_FRIEND, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(?TITLE_TYPE_CRIME, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_TYPE_CRIME, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(?TITLE_TYPE_GUILD, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_TYPE_GUILD, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(?TITLE_TYPE_ANSWER, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_TYPE_ANSWER, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(?TITLE_TYPE_MONEY, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_TYPE_MONEY, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(?TITLE_TYPE_FIGHT_FORCE, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_TYPE_FIGHT_FORCE, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(?TITLE_TYPE_LEVEL, Rank, OldInfo) ->
	case do_on_condition_change(?TITLE_TYPE_LEVEL, Rank, OldInfo) of
		not_change ->
			not_change;
		Info ->
			compute_attrs(Info),
			Info
	end;
hook_on_condition_change(_, _, _) ->
	not_change.
hook_on_condition_change_offline(?TITLE_GUILD_BATTLE, RoleId, Rank) ->
	Info = case role_title_db:get_role_title_info(RoleId) of
		[] ->
			[];
		{_, RoleId, TitleInfo} ->
			TitleInfo
	end,
	case do_on_condition_change(?TITLE_GUILD_BATTLE, Rank, Info) of
		not_change ->
			nothing;
		Info2 ->
			role_title_db:save_role_title_info(RoleId, Info2)
	end;
hook_on_condition_change_offline(?TITLE_TYPE_GUILD, RoleId, Rank) ->
	Info = case role_title_db:get_role_title_info(RoleId) of
		[] ->
			[];
		{_, RoleId, TitleInfo} ->
			TitleInfo
	end,
	case do_on_condition_change(?TITLE_TYPE_GUILD, Rank, Info) of
		not_change ->
			nothing;
		Info2 ->
			role_title_db:save_role_title_info(RoleId, Info2)
	end;
hook_on_condition_change_offline(?TITLE_TYPE_MONEY, RoleId, Rank) ->
	Info = case role_title_db:get_role_title_info(RoleId) of
		[] ->
			[];
		{_, RoleId, TitleInfo} ->
			TitleInfo
	end,
	case do_on_condition_change(?TITLE_TYPE_MONEY, Rank, Info) of
		not_change ->
			nothing;
		Info2 ->
			role_title_db:save_role_title_info(RoleId, Info2)
	end;
hook_on_condition_change_offline(?TITLE_TYPE_ANSWER, RoleId, Rank) ->
	Info = case role_title_db:get_role_title_info(RoleId) of
		[] ->
			[];
		{_, RoleId, TitleInfo} ->
			TitleInfo
	end,
	case do_on_condition_change(?TITLE_TYPE_ANSWER, Rank, Info) of
		not_change ->
			nothing;
		Info2 ->
			role_title_db:save_role_title_info(RoleId, Info2)
	end;
hook_on_condition_change_offline(?TITLE_TYPE_FIGHT_FORCE, RoleId, Rank) ->
	Info = case role_title_db:get_role_title_info(RoleId) of
		[] ->
			[];
		{_, RoleId, TitleInfo} ->
			TitleInfo
	end,
	case do_on_condition_change(?TITLE_TYPE_FIGHT_FORCE, Rank, Info) of
		not_change ->
			nothing;
		Info2 ->
			role_title_db:save_role_title_info(RoleId, Info2)
	end;
hook_on_condition_change_offline(?TITLE_TYPE_LEVEL, RoleId, Rank) ->
	Info = case role_title_db:get_role_title_info(RoleId) of
		[] ->
			[];
		{_, RoleId, TitleInfo} ->
			TitleInfo
	end,
	case do_on_condition_change(?TITLE_TYPE_LEVEL, Rank, Info) of
		not_change ->
			nothing;
		Info2 ->
			role_title_db:save_role_title_info(RoleId, Info2)
	end;
hook_on_condition_change_offline(_, _, _) ->
	nothing.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% locals
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

compute_attrs(Info) ->
	Fun = fun(TitleId) ->
		TitleProto = title_db:get_title_proto(TitleId),
		HpMax = title_db:get_title_hpmax(TitleProto),
		MagicPower = title_db:get_title_magic_power(TitleProto),
		RangePower = title_db:get_title_range_power(TitleProto),
		MeleePower = title_db:get_title_melee_power(TitleProto),
		MagicDefense = title_db:get_title_magic_defense(TitleProto),
		RangeDefense = title_db:get_title_range_defense(TitleProto),
		MeleeDefense = title_db:get_title_melee_defense(TitleProto),
		HitRate = title_db:get_title_hitrate(TitleProto),
		Dodge = title_db:get_title_dodge(TitleProto),
		CriticalRate = title_db:get_title_criticalrate(TitleProto),
		CriticalDestroyRate = title_db:get_title_criticaldestroyrate(TitleProto),
		Toughness = title_db:get_title_toughness(TitleProto),
		MagicImmune = title_db:get_title_magic_immune(TitleProto),
		RangeImmune = title_db:get_title_range_immune(TitleProto),
		MeleeImmune = title_db:get_title_melee_immune(TitleProto),
		[{hpmax, HpMax}, 
		{magicpower, MagicPower}, 
		{rangepower, RangePower},
		{meleepower, MeleePower}, 
		{magicdefense, MagicDefense}, 
		{rangedefense, RangeDefense},
		{meleedefense, MeleeDefense}, 
		{hitrate, HitRate}, 
		{dodge, Dodge}, 
		{criticalrate, CriticalRate},
		{criticaldestroyrate, CriticalDestroyRate},
		{toughness, Toughness}, 
		{magicimmunity, MagicImmune}, 
		{rangeimmunity, RangeImmune}, 
		{meleeimmunity, MeleeImmune}
		]
	end,
	TitleList = [TitleId2 || {TitleId2, _} <- Info],
	Attrs = lists:foldl(fun(TitleId3, Acc) ->
		Fun(TitleId3) ++ Acc
	end, [], TitleList),
	put(title_attrs, effect:combin_effect(Attrs)).

do_on_condition_change(?TITLE_GUILD_BATTLE, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(guild_battle, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);
do_on_condition_change(?TITLE_TYPE_PETNUM, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(petnum, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);
do_on_condition_change(?TITLE_TYPE_FRIEND, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(friend, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);
do_on_condition_change(?TITLE_TYPE_CRIME, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(crime, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);
do_on_condition_change(?TITLE_TYPE_GUILD, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(guild_rank, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);
do_on_condition_change(?TITLE_TYPE_ANSWER, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(answer_rank, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);
do_on_condition_change(?TITLE_TYPE_MONEY, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(money_rank, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);
do_on_condition_change(?TITLE_TYPE_FIGHT_FORCE, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(fight_force_rank, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);
do_on_condition_change(?TITLE_TYPE_LEVEL, Rank, OldInfo) ->
	{TitleId, Exclude} = get_best_fit_title(level_rank, Rank),
	do_on_condition_change2(TitleId, Exclude, OldInfo);

do_on_condition_change(_, _, _) ->
	not_change.

do_on_condition_change2([], Exclude, OldInfo) ->
	ChangeCheck = lists:any(fun(TitleId) ->
		lists:keymember(TitleId, 1, OldInfo)
	end, Exclude),
	if
		ChangeCheck ->
			lists:foldl(fun(TitleId, Acc) ->
				lists:keydelete(TitleId, 1, Acc)
			end, OldInfo, Exclude);
		true ->
			not_change
	end;
do_on_condition_change2(TitleId, Exclude, OldInfo) ->
	case lists:keymember(TitleId, 1, OldInfo) of
		false ->
			Info2 = lists:filter(fun({TitleId2, _}) ->
				not lists:member(TitleId2, Exclude)
			end, OldInfo),
			case get(creature_info) of
				undefined ->
					nothing;
				_ ->
					TitleProto = title_db:get_title_proto(TitleId),
					Flag = title_db:get_title_flag(TitleProto),
					case Flag of
						1 ->
							creature_sysbrd_util:sysbrd({title,TitleId},nothing);
						_ ->
							nothing
					end
			end,
			[{TitleId, ?TITLE_HIDE} | Info2];
		true ->
			not_change
	end.

do_check(Value, eq, Param) ->
	Value =:= Param;
do_check(Value, lt, Param) ->
	Value < Param;
do_check(Value, le, Param) ->
	Value =< Param;
do_check(Value, ge, Param) ->
	Value >= Param;
do_check(Value, gt, Param) ->
	Value > Param;
do_check(_, _, _) ->
	false.

check_condition({guild_battle, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition({petnum, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition({friend, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition({crime, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition({guild_rank, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition({answer_rank, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition({fight_force_rank, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition({level_rank, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition({money_rank, {Op, Param}}, Value) ->
	do_check(Value, Op, Param);
check_condition(_, _) ->
	false.

get_best_fit_title(Type, Value) ->
	TitleProtoListType = title_db:get_title_proto_type(Type),
	TitleProtoListFit = lists:filter(fun(TitleProto) ->
		Condition = title_db:get_title_condition(TitleProto),
		check_condition(Condition, Value)
	end, TitleProtoListType),
	Length = length(TitleProtoListFit),
	if
		Length =:= 0 ->
			Exclude = [title_db:get_title_id(X) ||
				X <- TitleProtoListType],
			{[], Exclude};
		true ->
			TitleProtoFit = if
				Length =:= 1 ->
					[H | _] = TitleProtoListFit,
					H;
				true ->
					get_best_fit_proto(TitleProtoListFit)
			end,
			TitleId = title_db:get_title_id(TitleProtoFit),
			Exclude = title_db:get_title_exclude(TitleProtoFit),
			{TitleId, Exclude}
	end.

get_best_fit_proto(TitleProtoListFit) ->
	AllExclude = lists:foldl(fun(TitleProto, Acc) ->
		Exclude = title_db:get_title_exclude(TitleProto),
		Exclude ++ Acc
	end, [], TitleProtoListFit),
	AllFit = lists:filter(fun(TitleProto) ->
		TitleId = title_db:get_title_id(TitleProto),
		not lists:member(TitleId, AllExclude)
	end, TitleProtoListFit),
	[H | _] = AllFit,
	H.

show_base_check(ShowList) ->
	case length(ShowList) =< ?TITLE_SHOW_LENGTH of
		true ->
			ShowList2 = lists:filter(fun(TitleId) ->
				TitleProto = title_db:get_title_proto(TitleId),
				Flag = title_db:get_title_flag(TitleProto),
				Flag =/= ?TITLE_SUPER
			end, ShowList),
			TypeCount = lists:foldl(fun(TitleId, Acc) ->
				TitleProto = title_db:get_title_proto(TitleId),
				Type = title_db:get_title_type(TitleProto),
				case lists:keyfind(Type, 1, Acc) of
					false ->
						[{Type, 1} | Acc];
					{Type, Count} ->
						lists:keyreplace(Type, 1, Acc, {Type, Count + 1})
				end
			end, [], ShowList2),
			lists:all(fun({_, Count}) ->
				Count =< 1
			end, TypeCount);
		false ->
			false
	end.

%称号七色国主
hook_guild_battle_title(LeaderId,Newleader) ->
	TitleRole=title_db:get_title_role(?TITLE_GUILD_BATTLE),
	case TitleRole of
    	[] ->
    	    nothing;
    	_ ->
	        {_,_,RoleId}=TitleRole,        
			% {_,_,RoleId}=TitleRole,
			case RoleId of
				[] ->
					nothing;
				_ ->
					if
						RoleId=:=LeaderId ->
							%失去称号七色国主
							lose_guild_battle_title(),
			                %获得称号七色国主
			                case Newleader of
			                	0 ->
			                		nothing;
			                	_ ->
			                		guild_battle_title(Newleader)
			                end;
			        	true ->
			           		nothing
					end
			end
	end.


%失去称号七色国主
lose_guild_battle_title() ->
    TitleRole=title_db:get_title_role(?TITLE_GUILD_BATTLE),
    case TitleRole of
    	[] ->
    	    nothing;
    	_ ->
	        {_,_,RoleId}=TitleRole,
	        case RoleId of
	        	[] ->
	        	    nothing;
	        	_ ->
	        		title_db:delete_role_from_db(?TITLE_GUILD_BATTLE),
                    case role_pos_util:is_role_online(RoleId) of
	                   	true ->
			                role_pos_util:send_to_role(RoleId, 
			                	{title_condition_change, 
			                	?TITLE_GUILD_BATTLE, -1});
	                  	false ->
		                	title_op:hook_on_condition_change_offline(
			                	?TITLE_GUILD_BATTLE, RoleId, -1)
	                end
	        end
	end.

%获得称号七色国主
guild_battle_title(RoleId) ->
	title_db:save_title_role(?TITLE_GUILD_BATTLE,RoleId),
	role_pos_util:send_to_role(RoleId,{title_condition_change,?TITLE_GUILD_BATTLE, 1}).