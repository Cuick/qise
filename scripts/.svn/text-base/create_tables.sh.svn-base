#!/bin/bash

NODE=db@127.0.0.1
DBDIR=../dbfile
EBINDIR=../ebin
CONFIGDIR=../config

erl -mnesia dir "\"$DBDIR\"" -name $NODE -pa $EBINDIR -noshell -s config_db run $CONFIGDIR $EBINDIR -s init stop
echo "如果需要查询数据，请手动复制下面的命令并执行之"
echo "erl -mnesia dir '\"$DBDIR\"' -name $NODE -pa $EBINDIR"
