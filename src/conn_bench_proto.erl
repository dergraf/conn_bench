-module(conn_bench_proto).
-behaviour(ranch_protocol).

-export([start_link/4,
         init/4,
         loop/2]).

start_link(Ref, Socket, Transport, Opts) ->
    Pid = spawn_link(?MODULE, init, [Ref, Socket, Transport, Opts]),
    {ok, Pid}.

init(Ref, Socket, Transport, _Opts = []) ->
    ok = ranch:accept_ack(Ref),
    inet:setopts(Socket, [{active, once}]),
    loop(Socket, Transport).

loop(Socket, Transport) ->
    receive
        {tcp, Socket, _Data} ->
            inet:setopts(Socket, [{active, once}]),
            loop(Socket, Transport);
        {tcp_closed, Socket} ->
            io:format("[~p] got tcp closed~n", [self()]);
        {tcp_error, Socket, Reason} ->
            io:format("[~p] got tcp error ~p~n", [self(), Reason]);
        Msg ->
            io:format("[~p] got unknown message ~p~n", [self(), Msg])
    end.
