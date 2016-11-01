-module (open_service_packet).

-include ("login_pb.hrl").

-export ([handle/2, encode_query_open_service_time_s2c/1]).

handle(#query_open_service_time_c2s{}, RolePid) ->
	RolePid ! {query_open_service_time};
handle(_, _) ->
	nothing.

encode_query_open_service_time_s2c(OpenServiceTime) ->
	login_pb:encode_query_open_service_time_s2c(
		#query_open_service_time_s2c{time = OpenServiceTime}).