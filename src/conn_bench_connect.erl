-module(conn_bench_connect).

-export([start/4,
         start_connections/3,
         send_loop/3,
         loop/1]).

start(Port, NrOfConns, Interval, MsgSize) ->
    Pid = spawn_link(?MODULE, start_connections, [self(), Port, NrOfConns]),
    receive
        done ->
            spawn_link(?MODULE, send_loop, [Pid, Interval, MsgSize]);
        M ->
            io:format("got unknown cmd ~p~n", [M])
    end.

send_loop(Pid, Interval, MsgSize) ->
    Msg = crypto:rand_bytes(MsgSize),
    Pid ! {msg, Msg},
    timer:sleep(Interval),
    send_loop(Pid, Interval, MsgSize).

start_connections(MainPid, Port, NrOfConns) ->
    start_connections(MainPid, Port, NrOfConns, []).

start_connections(MainPid, _, 0, Acc) ->
    MainPid ! done,
    ctrl_loop(Acc);
start_connections(MainPid, Port, NrOfConns, Acc) ->
    {ok, Socket} = gen_tcp:connect({127,0,0,1}, Port, [binary, {active, once}]),
    Pid = spawn_link(?MODULE, loop, [Socket]),
    gen_tcp:controlling_process(Socket, Pid),
    start_connections(MainPid, Port, NrOfConns - 1, [Pid|Acc]).

ctrl_loop(Acc) ->
    receive
        {msg, M} ->
            lists:foreach(fun(Pid) ->
                                  Pid ! {msg, M}
                          end, Acc),
            ctrl_loop(Acc);
        _ ->
            ok
    end.

loop(Socket) ->
    receive
        {msg, M} ->
            gen_tcp:send(Socket, M),
            loop(Socket);
        M ->
            io:format("[~p] go down due to ~p~n", [self(), M])
    end.
