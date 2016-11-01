%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2010-8-6
%%% -------------------------------------------------------------------
-module (mock_name_generator).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include ("mock_def.hrl").

%% --------------------------------------------------------------------
%% External exports
-export([start_link/0, gen_new_name/1, return_name_back/2]).

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


%% ====================================================================
%% Server functions
%% ====================================================================
gen_new_name(Gender)->
	gen_server:call(?MODULE, {gen_new_name, Gender}).

return_name_back(Gender, Name) ->
	gen_server:call(?MODULE, {return_name_back, Gender, Name}).
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	put(male, []),
	put(female, []),
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
handle_call({gen_new_name, Gender}, _, State) ->
	DicName = if
		Gender =:= 0 ->
			female;
		true ->
			male
	end,
	NameList = get(DicName),
	case lists:keyfind(?NAME_NOT_USE, 2, NameList) of
		false ->
			{Gname, Bname} = autoname_op:init_autoname_s2c(),
			Name = if
				Gender =:= 0 ->
					put(DicName, [{Gname, ?NAME_IN_USE} | NameList]),
					Gname;
				true ->
					put(DicName, [{Bname, ?NAME_IN_USE} | NameList]),
					Bname
			end,
			autoname_db:sync_update_autoname_used_to_mnesia({Name,-1,[]}),
			Reply = Name;
		{Name, _} ->
			Reply = Name,
			put(DicName, lists:keyreplace(Name, 1, NameList, {Name, ?NAME_IN_USE}))
	end,
    {reply, Reply, State};

handle_call({return_name_back, Gender, Name}, _, State) ->
	DicName = if
		Gender =:= 0 ->
			female;
		true ->
			male
	end,
	NameList = get(DicName),
	put(DicName, lists:keyreplace(Name, 1, NameList, {Name, ?NAME_NOT_USE})),
	{reply, ok, State};

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

