-module (mock_util).

-export ([get_mock_class/0, get_mock_gender/0, get_line_id/1]).

get_mock_gender() ->
	Num = random:uniform(100),
	if
		Num > 50 ->
			1;
		true ->
			0
	end.

get_mock_class() ->
	random:uniform(3).

get_line_id(Node) ->
	[LineId | _] = lists:filter(fun(LineIdTmp) ->
		node_util:check_match_map_and_line(Node, LineIdTmp)
	end, env:get(lines, [])),
	LineId.