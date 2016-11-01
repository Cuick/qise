-module(version).
-include("login_pb.hrl").
-define(VERSION,"12.06.06.1809-DEBUG").
-export([make_version/0,version/0]).
make_version()->
	login_pb:encode_server_version_s2c(#server_version_s2c{v = ?VERSION}).
	

version()->
	?VERSION.