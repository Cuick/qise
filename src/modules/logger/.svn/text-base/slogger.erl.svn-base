%%%-------------------------------------------------------------------
%%% File    : slogger.erl
%%% Author  : tengjiaozhao <tengjiaozhao@aialgo-lab>
%%% Description : 
%%%
%%% Created : 28 Apr 2010 by tengjiaozhao <tengjiaozhao@aialgo-lab>
%%%-------------------------------------------------------------------
-module(slogger).

-compile(export_all).

msg(Format, Data) ->
	error_logger:info_msg(Format, Data).

msg(Format) ->
	error_logger:info_msg(Format).

msg_filter(Id,Format,Data)->
	if Id== 2030096->
		   msg(Format,Data);
	   true->
		   ok
	end.



