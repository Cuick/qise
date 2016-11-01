-module(online_update_code).

-export([update_code/1, update_code_temp/1, safe_update_code/1]).

% 临时使用
update_code_temp(Module) ->
	Module2 = list_to_atom(Module),
	case code:get_object_code(Module2) of
		error ->
			error;
		{Module2, Binary, Filename} ->
			[rpc:call(Node, code, load_binary, [Module2, Filename, Binary]) || Node <- nodes()]
	end.

update_code( Mod ) ->
	[{Node, rpc:call(Node, ?MODULE, safe_update_code, [ Mod ])} || Node <- nodes()].

safe_update_code( Mod ) ->
	code:soft_purge( Mod ) andalso code:load_file( Mod ).

