-module(media_card_op).

-include("error_msg.hrl").

-export([media_card_apply_c2s/2]).


media_card_apply_c2s(KeyStr,Type) ->
	case Type of
		2 ->
			Log = media_card_info,
			TableName = db_split:get_owner_table(media_card_info, get(roleid));
		3 ->
			Log = mystical_card_info,
			TableName = db_split:get_owner_table(mystical_card_info, get(roleid));
		4 ->
			Log = mystical2_card_info,
			TableName = db_split:get_owner_table(mystical2_card_info, get(roleid));
		_ ->
			Log = mystical3_card_info,
			TableName = db_split:get_owner_table(mystical3_card_info, get(roleid))
	end,
	case dal:read_rpc(TableName, get(roleid)) of
		{ok,[R]}->
			Errno = ?ERROR_CARD_HAVE_GIFT;
		{ok,[]}->
			case package_op:get_empty_slot_in_package() of
				0 ->
					Msg1 = pet_packet:encode_send_error_s2c(?ERROR_PACKAGE_FULL),
					role_op:send_data_to_gate(Msg1),
					Errno = -1;
				_ ->
			case get_card_status(KeyStr,Type) of
				ok ->
					case env:get(gift_card_itemid, []) of
						[]->
							Errno = ?ERROR_CARD_UNKNOWN;
						{_, MediaCardId,MysticalCardId,MysticalCardId2,MysticalCardId3}->
							ItemProtoId =
							case Type of
								2 ->
									MediaCardId;
								3 ->
									MysticalCardId;
								4 ->
									MysticalCardId2;
								_ ->
									MysticalCardId3
							end,
							case role_op:auto_create_and_put(ItemProtoId,1,Log) of
								{ok,_}->
									Errno = 0,
									
									case Type of
										2 ->
											role_media_card_db:save_media_card_info(get(roleid), KeyStr);
										3 ->
											role_mystical_card_db:save_mystical_card_info(get(roleid), KeyStr);
										4 ->
											role_mystical2_card_db:save_mystical_card_info(get(roleid), KeyStr);
										_ ->
											role_mystical3_card_db:save_mystical_card_info(get(roleid), KeyStr)
									end;
								_->
									Errno = ?ERROR_CARD_UNKNOWN
							end
					end;
				Errno ->
					nothing
			end
			end;
		_ ->
			Errno = ?ERROR_CARD_UNKNOWN
	end,
	if
		Errno =/=-1 ->
			Msg = giftcard_packet:encode_gift_card_apply_s2c(Errno),
			role_op:send_data_to_gate(Msg);
		true->
			nothing
	end.

get_card_status(KeyStr,Type) ->
	% UrlPath = "/v3/pay/get_balance",
	UrlPath = env:get(media_card_url,[]),
	Pf = get(pf),
	Roleid = get(roleid),
	Host = env:get(media_card_host,[]),
	Port = env:get(media_card_port,[]),
	% case Type of
	% 	2 ->
	% 		Pf1 = Pf ++ "m";
	% 	_ ->
	% 		Pf1 = Pf ++ "s"
	% end,
	case do_get_balance(UrlPath, Host, Pf, KeyStr,Roleid,Port,Type) of
		{ok, Balance} ->
			case Balance of
				1 ->
					% bad card
					?ERROR_CARD_NUMBER;
				2 ->
					% be use
					?ERROR_CARD_HAVE_BEEN_GIFT;
				3 ->
					ok;
				_ ->
					?ERROR_CARD_UNKNOWN
			end;
		Abc ->
			?ERROR_CARD_UNKNOWN
	end.

do_get_balance(UrlPath, Host, Pf, KeyStr,Roleid,Port,Type) ->
	Params = "keyStr=" ++ KeyStr ++"&pf=" ++ Pf ++ "&roleid=" ++ integer_to_list(Roleid) ++ "&type=" ++ integer_to_list(Type) ++ "\n",
	SendUrl = "GET " ++ UrlPath ++ "?" ++ Params ++ " " ++ "HTTP/1.1\r\nHost:" ++ Host
	++"\r\n\r\n",
	try
		case gen_tcp:connect(Host, Port, [{packet,0},binary,{active, true}], 10000) of
			{ok, Socket} ->
				Result = case gen_tcp:send(Socket,SendUrl) of
			        ok ->
				        receive
					        {tcp, _, Bin} ->
					        	Bin1 = binary_to_list(Bin),
					        	Bin2 = list_to_integer(Bin1),
						        {ok, Bin2}
				        after 1000 ->
					        {error, tcp, read_timeout}
				        end;
			        {error, Reason} ->
			            {error, tcp, Reason}
		        end,
		        gen_tcp:close(Socket),
		        Result;
		    {error, Reason1} ->
		        {error, tcp1, Reason1}
		end
	catch
		E : R ->
		{error, E, R}
	end.