-module(conn_bench).
-export([start/0,
         stop/0]).

start() ->
    application:ensure_all_started(conn_bench).

stop() ->
    application:stop(conn_bench),
    application:stop(ranch).
