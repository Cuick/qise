%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module (mock_manager_type_1).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include ("mock_def.hrl").

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0, create_all_mocks/0, stop/0]).

%% for testing function.

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {}).

%%servers_index : [{serverid,curindex}]

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->
	gen_server:start({local,?MODULE}, ?MODULE, [], []).

create_all_mocks() ->
	gen_server:cast(?MODULE, {create_all_mocks}).

stop() ->
	gen_server:cast(?MODULE, {stop_all_mocks}).

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	mock_processor_sup_type_1:start_link(),
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_cast({create_all_mocks}, State) ->
	case get(mock_list) of
		undefined ->
			do_create_all_mocks();
		_ ->
			nothing
	end,
	{noreply, State};

handle_cast({stop_all_mocks}, State) ->
	lists:foreach(fun(MockId) ->
		MockProc = mock_processor_type_1:make_proc_name(MockId),
		mock_processor_type_1:stop(MockProc),
		mock_processor_sup_type_1:stop_child(MockProc)
	end, get(mock_list)),
	erase(mock_list),
	{noreply, State};

handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.


do_create_all_mocks() ->
	LineId = mock_util:get_line_id(node()),
	MockList = lists:foldl(fun(MockInfo, Acc) ->
		ProtoId = mock_db:get_mock_id_type_1(MockInfo),
		Class = mock_util:get_mock_class(),
		MapId = mock_db:get_mock_map_id_type_1(MockInfo),
		Gender = if
			MapId =:= ?BORN_MAP_MALE ->
				1;
			MapId =:= ?BORN_MAP_FEMALE ->
				0;
			true ->
				mock_util:get_mock_gender()
		end,
		MockId = mock_id_generator:gen_newid(),
		Name = mock_name_generator:gen_new_name(Gender),
		MockProc = mock_processor_type_1:make_proc_name(MockId),
		mock_processor_sup_type_1:start_mock_type_1(MockProc, MockId, ProtoId, Name, Gender, Class, LineId),
		[MockId | Acc]
	end, [], mock_db:get_all_mock_type_1()),
	put(mock_list, MockList).