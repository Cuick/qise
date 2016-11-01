-module (role_info_export).

-include ("mnesia_table_def.hrl").

-include_lib("stdlib/include/qlc.hrl").

-export ([export/0]).

export() ->
	{ok, File} = file:open("../config/role_export.txt", [write]),
	[do_export_roles(RoleTable, File) || RoleTable <- db_split:get_splitted_tables(roleattr)],
	file:close(File).

do_export_roles(RoleTable, File) ->
	F = fun()->
			mnesia:foldl(fun(RoleInfo,Acc)->
				Account = role_db:get_account(RoleInfo),
				RoleName = role_db:get_name(RoleInfo),
				RoleId = role_db:get_roleid(RoleInfo),
				RoleClass = role_db:get_class(RoleInfo),
				RoleGender = role_db:get_sex(RoleInfo),
				Silver = role_db:get_silver(RoleInfo),
				BoundSilver = role_db:get_boundsilver(RoleInfo),
				Level = role_db:get_level(RoleInfo),
				GuildId = role_db:get_guildid(RoleInfo),
				{ok, [AccountInfo]} = dal:read_rpc(account, Account),
				Gold = AccountInfo#account.gold,
				Ticket= role_db:get_currencygift(RoleInfo),
				io:format(File, "~s\t~s\t~p\t~p\t~p\t~p\t~p\t~p\t~p\t~p\t~p~n", 
					[Account,binary_to_list(RoleName),RoleId,RoleClass,RoleGender,Silver,
					BoundSilver,Level,0,Ticket,Gold]),
				Acc
			end,[],RoleTable)
	end,
	case mnesia:transaction(F) of
		{atomic,Result}->
			Result;
		Error->
			[]
	end.