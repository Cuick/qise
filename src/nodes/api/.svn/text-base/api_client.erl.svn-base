%%% -------------------------------------------------------------------
%%% Author  : adrian
%%% Description :
%%%
%%% Created : 2010-4-19
%%% -------------------------------------------------------------------
-module(api_client).

-behaviour(gen_fsm).
-include("network_setting.hrl").


%% External exports
-export([start_link/0,
	 send_data/2,
	 send_data/3,
	 shutown_client/1]).

-export([init/1, handle_event/3,
	 handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-export([connecting/2,socket_ready/3,socket_disable/3]).


-export([connected/2]).

-export([managing/2]).

-export([kick_client/2]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================

%% Event: socket ok
socket_ready(APINode,APIProc,ClientSocket)->
	APIPid = APIProc,
	util:send_state_event(APIPid, {socket_ready,ClientSocket}).

socket_disable(APINode,APIProc,ClientSocket)->
	APIPid = APIProc,   
	util:send_state_event(APIPid, {socket_disable,ClientSocket}).

start_link()->
	gen_fsm:start_link(?MODULE, [], []).

init([]) ->
	timer_center:start_at_process(),
	process_flag(trap_exit, true),
	{ok, connecting, #state{}}.

send_data(APIPid,Data) ->
	try 
		case Data of
			<<>> ->
				throw("error: empty data to api client");
			[] ->
				throw("error: empty data to api client");
			_ ->
				APIPid! {send_to_client,Data}			
		end
	catch 
		Error ->
			slogger:msg("~p~n", [erlang:get_stacktrace()])
	end.


send_data(APINode,APIProc,Data)->
	APIPid = APIProc,
	case Data of
		<<>> ->
			throw("error: empty data to api client");
		[] ->
			throw("error: empty data to api client");
		_ ->
			gs_rpc:cast(APIPid, {send_to_client,Data})
	end.

shutown_client(Pid) ->
	Pid!{shutdown}.

kick_client(APINode,APIProc)->
	APIPid = APIProc,
	gs_rpc:cast(APIPid, {kick_client}).


connecting({socket_ready,CliSocket},StateData)->
	OkIpList = env:get(apiiplist, []),
	{PeerAddress, _PeerPort} = inet_op(fun () -> inet:peername(CliSocket) end),

	FilterFun = fun({IpStr1,IpStr2})->
						ipfilter:match_tupleip(PeerAddress,IpStr1, IpStr2)
				end,
	
	case lists:any(FilterFun, OkIpList) of
		true->
			%%ProcName = make_client_name(CliSocket),
			%%erlang:register(ProcName,self()),
			inet:setopts(CliSocket, ?TCP_CLIENT_SOCKET_OPTIONS),
			put(clientsock, CliSocket),
			put(clientaddr, PeerAddress);
			%%put(procname, ProcName);
		_->
			self()!{kick_client,"Gm Error Ip login"}
	end,

	{next_state, managing, StateData};

connecting({socket_disable,CliSocket},StateData)->
	self()!{kick_client,"socket is disable "},
	put(clientsock, CliSocket),
	{stop, normal, StateData};

connecting(Event,StateData)->
	{next_state, connecting, StateData}.

connected(Event,State) ->
	{next_state, connected, State}.

managing({Cmd,JsonObj},StateData) ->
	case Cmd of
		{ok, "charge"} ->
			api_op:user_charge(JsonObj);
		{ok, "role_check"} ->
			api_op:role_check(JsonObj);
		{ok, "order_query"} ->
			api_op:order_query(JsonObj);
		{ok, "role"} ->
			api_op:user_info(JsonObj);
		_ ->
			ignor
	end,
	{next_state, managing, StateData};
managing(Event,State)->
	{next_state, managing, State}.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  send by gen_fsm:sync_send_all_state_event/2,3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_event(stop, StatName , StateData)->
	{stop, normal, StateData};

handle_event(Event, StateName, StateData) ->
	{next_state, StateName, StateData}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sync event: send by gen_fsm:send_all_state_event/2,3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_sync_event(Event, From, StateName, StateData) ->
	Reply = ok,
	{reply, Reply, StateName, StateData}.

%%
%% game GM need to send data
handle_info({send_to_client, Data}, StateName, StateData) ->
	gen_tcp:send(get(clientsock), Data),
	{next_state, StateName, StateData};

handle_info({tcp, Socket, BinData}, StateName, StateData) ->
	slogger:msg("tcp,socket"),
	handle_client_json(BinData),
	inet:setopts(Socket, [{active, once}]),
	{next_state, StateName, StateData};

handle_info({tcp_closed, _Socket}, StateName, StateData) ->
	{stop, normal, StateData};

handle_info({shutdown},StateName,StateData)->
	{stop, normal, StateData};

handle_info({kick_client},StateName,StateData)->
	slogger:msg("receive need kick client, maybe error client!\n"),
	inet:tcp_close(get(clientsock)),
	{next_state,StateName, StateData};	

handle_info({kick_client,Reason},StateName,StateData)->
	slogger:msg("receive need kick api :~p!\n",[Reason]),
	inet:tcp_close(get(clientsock)),
	{next_state,StateName, StateData};	

handle_info(Info, StateName, StateData) ->
	{next_state, StateName, StateData}.

%% --------------------------------------------------------------------
%% Func: terminate/3
%% Purpose: Shutdown the fsm
%% Returns: any
%% --------------------------------------------------------------------
terminate(Reason, StateName, StatData) ->
	%%add for terminat
	ok.

%% --------------------------------------------------------------------
%% Func: code_change/4
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState, NewStateData}
%% --------------------------------------------------------------------
code_change(OldVsn, StateName, StateData, Extra) ->
	{ok, StateName, StateData}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

inton({A,B,C,D},P)->
	integer_to_list(A) ++ "_" ++ integer_to_list(B) ++ "_" ++ 
		integer_to_list(C) ++ "_" ++ integer_to_list(D) 
		++ "_" ++ integer_to_list(P).

make_client_name(Socket)->
	case inet:peername(Socket) of
		{error, _ } -> undefined;
		{ok,{Address,Port}}->
			ProcName = "zygmagent_"++inton(Address,Port),
			list_to_atom(ProcName)
	end.


throw_on_error(E, Thunk) ->
    case Thunk() of
        {error, Reason} -> throw({E, Reason});
        {ok, Res}       -> Res;
        Res             -> Res
    end.
inet_op(F) -> throw_on_error(inet_error, F).



handle_client_json(Bin)->
% slogger:msg("aaaaaaaaaaBin:~p~n",[Bin]),
	case util:json_decode(Bin) of
		{ok,JsonObj}-> 
			handle_json(JsonObj);
		{error}-> ignor;
		_-> exception
	end.

handle_json({struct,_JsonMember} = JsonObj)->
	% slogger:msg("aaaaaaaaaaJsonObj:~p~n",[JsonObj]),
	Cmd = util:get_json_member(JsonObj,"cmd"),
	case Cmd of
		{ok,Str}->
			gen_fsm:send_event(self(), {Cmd,JsonObj});
		_ ->
			ignor
	end.

