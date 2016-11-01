-module (wedding_handle).

-include ("wedding_def.hrl").
-include ("login_pb.hrl").

-export ([process_client_msg/1, handle_other_role_msg/1]).

% process_client_msg(#wedding_apply_c2s{role_name = RoleName}) ->
% 	wedding_op:apply(list_to_binary(RoleName));

% process_client_msg(#wedding_apply_agree_c2s{role_name = RoleName}) ->
% 	wedding_op:agree(list_to_binary(RoleName));

% process_client_msg(#wedding_apply_refused_c2s{role_name = RoleName}) ->
% 	wedding_op:refuse(list_to_binary(RoleName));

% process_client_msg(#wedding_ceremony_time_available_c2s{}) ->
% 	wedding_op:get_ceremony_time_time_available();

% process_client_msg(#wedding_ceremony_select_c2s{type = Type, time = Time}) ->
% 	wedding_op:ceremony_select(Type, Time);

process_client_msg(_) ->
	nothing.

handle_other_role_msg({add_wedding_role,RoleId}) ->
	wedding_op:wedding_with_role(RoleId);

handle_other_role_msg({wedding_check}) ->
	wedding_op:do_wedding_check();

handle_other_role_msg(_) ->
	nothing.