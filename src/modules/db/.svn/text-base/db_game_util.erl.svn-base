-module(db_game_util).


-export([delete_all_unuesd_role/0]).
-export([rename_guild_in_db/2,rename_role_in_db/2]).
-export([export_check_file/1, db_check/1]).


-include("guild_define.hrl").
-include("mnesia_table_def.hrl").

-define(OFFLINE_TIME_DURATION,2592000000000).		%%30day

delete_all_unuesd_role()->
	AllDeleteRoles = get_all_unused_role(),
	lists:foreach(fun(RoleId)->delete_roleid_from_db(RoleId) end, AllDeleteRoles),
	AllDeleteRoles.	

rename_role_in_db(RoleId,NewName)->
	%%1.roleattr
	RoleInfoDB = role_db:get_role_info(RoleId),
	RoleInfoInDB1 = role_db:put_name(RoleInfoDB,NewName),
	role_db:flush_role(RoleInfoInDB1),
	%%2.friend,black
	friend_db:change_role_name_in_db(RoleId,NewName).
	
rename_guild_in_db(GuildId,NewName)->
	guild_spawn_db:set_guild_name(GuildId,NewName).

delete_roleid_from_db(RoleId)->
	mod_util:behaviour_apply(db_operater_mod,delete_role_from_db,[RoleId]).

get_all_unused_role()->
	A = lists:foldl(fun(Table,Acc)->Acc++get_unused_roles_in_table(Table) end, [], db_split:get_splitted_tables(roleattr)),
	B = get_robot_roleids(),
	sets:to_list(sets:from_list(A ++ B)).

get_unused_roles_in_table(RoleDbTab)->
	F = fun()->
			mnesia:foldl(fun(RoleInfo,AccRoles)-> 
					case is_unused_role(RoleInfo) of
						true->
					  		[role_db:get_roleid(RoleInfo)|AccRoles];
						_->
							AccRoles
					end end,[],RoleDbTab)
		end,
	case mnesia:transaction(F) of
		{atomic,Result}->
			Result;
		Error->
			slogger:msg("get_unused_role_in_table RoleDbTab ~p Error ~p ~n",[RoleDbTab,Error]),
			[]
	end.

% 按条件删除角色
is_unused_role(RoleInfo)->
	RoleId = role_db:get_roleid(RoleInfo),
	LeveCheck = role_db:get_level(RoleInfo)=<40,
	TimeCheck = (timer:now_diff(now(),role_db:get_offline(RoleInfo)) >= ?OFFLINE_TIME_DURATION),
	GoldCheck = role_db:get_currencygold(RoleInfo) =:=0,
	GoldSumCheck = 	
		case vip_db:get_role_sum_gold(RoleId) of
			{ok,[]}->
				true;
			{ok,RoleSumInfo}->
				vip_db:get_sumgold_from_suminfo(RoleSumInfo)=:=0;
			_->
				true
		end,
	VipCheck = 
			case vip_db:get_vip_role(RoleId) of
				{ok,[]}->
					true;
				{ok,VipInfo}->
					vip_db:get_vip_level(VipInfo)=:=0;
				_->
					true
			end,
	GuildLeaderCheck = 
		case guild_spawn_db:get_guildinfo_of_member(RoleId) of
			[]->
				true;
			GuildMemberInfo->
				guild_spawn_db:get_authgroup_by_memberinfo(GuildMemberInfo) >= ?GUILD_POSE_MEMBER
		end,
	
	LeveCheck and TimeCheck and GoldCheck and GoldSumCheck and VipCheck and GuildLeaderCheck.

get_robot_roleids() ->
	F = fun()->
			mnesia:foldl(fun(Account,AccRoles)->
				Flag = Account#account.flag,
				if
					Flag =:= 0 ->
						AccRoles ++ Account#account.roleids;
					true ->
						AccRoles
				end
			end, [], account)
		end,
	case mnesia:transaction(F) of
		{atomic,Result}->
			Result;
		Error->
			[]
	end.

	
export_check_file(CheckFileName) ->
	F = fun() ->
		{ok, File} = file:open(CheckFileName, [write]),
		mnesia:foldl(fun(Account, Acc) ->
			AccountName = Account#account.username,
			[RoleId | _] = Account#account.roleids,
			RoleInfo = role_db:get_role_info(RoleId),
			RoleName = binary_to_list(role_db:get_name(RoleInfo)),
			io:format(File, "~s\t~p\t~s~n", [AccountName, RoleId, RoleName]),
			Acc
		end, [], account),
		file:close(File),
		ok
	end,
	mnesia:transaction(F).


db_check(CheckFileName) ->
	{ok, File} = file:open(CheckFileName, [read]),
	do_db_check(File),
	file:close(File).

do_db_check(File) ->
	case io:get_line(File, "") of
        {error, Reason} ->
            slogger:msg("db check read file error, Reason: ~p~n", [Reason]);
        eof ->
            nothing;
        Data ->
            case string:substr(Data, 1, length(Data) - 1) of
            	[] ->
            		nothing;
            	RoleInfo ->
            		[AccountName, RoleIdTmp, RoleName] = string:tokens(RoleInfo, "\t"),
            		RoleId = list_to_integer(RoleIdTmp),
            		case dal:read(account, AccountName) of
	            	{ok, []} ->
	            		slogger:msg("fatal error, combine server failed, Account lost: ~p~n", [AccountName]);
	            	{ok, [Account | _]} ->
	            		[RoleId2 | _] = Account#account.roleids,
	            		RoleInfo2 = role_db:get_role_info(RoleId2),
	            		RoleName2 = binary_to_list(role_db:get_name(RoleInfo2)),
	            		if
	            			RoleId =:= RoleId2, RoleName =:= RoleName2 ->
	            				nothing;
	            			true ->
	            				slogger:msg("error, combine server failed, Role Id or Name diff, 
	            					Account: ~p, RoleId: ~p, RoleName: ~p, RoleId2: ~p, RoleName2: ~p~n", 
	            					[AccountName, RoleId, RoleName, RoleId2, RoleName2])
	            		end,
	            		do_db_check(File)
	            end
	        end
    end.