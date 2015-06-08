-module(conn_bench_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ListenerConfig = application:get_env(conn_bench, ranch_listener_config, [{port, 5555}]),
    {ok, _} = ranch:start_listener(conn_bench_tcp, 1,
                                   ranch_tcp, ListenerConfig, conn_bench_proto, []),
    ranch:set_max_connections(conn_bench_tcp, 1000000),
    conn_bench_sup:start_link().

stop(_State) ->
    ok.
