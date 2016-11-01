%%% -------------------------------------------------------------------
%%% Author  : yanzengyan
%%% Description :
%%%
%%% Created : 2014-2-26
%%% -------------------------------------------------------------------
-module(mock_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/0]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================
start_link()->	
	supervisor:start_link({local,?MODULE}, ?MODULE, []).

%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init([]) ->
	ChildSpec =[{mock_id_generator,{mock_id_generator,start_link,[]},permanent,2000,worker,[mock_id_generator]},
	{mock_name_generator,{mock_name_generator,start_link,[]},permanent,2000,worker,[mock_name_generator]},
	{mock_manager_type_1,{mock_manager_type_1,start_link,[]},permanent,2000,worker,[mock_manager_type_1]},
	{mock_manager_type_2,{mock_manager_type_2,start_link,[]},permanent,2000,worker,[mock_manager_type_2]},
	{mock_manager_type_3,{mock_manager_type_3,start_link,[]},permanent,2000,worker,[mock_manager_type_3]},
	{mock_manager_type_6,{mock_manager_type_6,start_link,[]},permanent,2000,worker,[mock_manager_type_6]}], 
	{ok,{{one_for_all,10,10}, ChildSpec}}.

%% ====================================================================
%% Internal functions
%% ====================================================================
