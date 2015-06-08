# Connection Bench

The title is misleading, since the project isn't really calculating any 
results... yet.

The goal is to provide a simple TCP server application (using ranch) that accepts
thousands of connections, and a simple client application that opens connections
and sends a random fixed-size payload in a fixed interval to the server.

The scenario resembles a metering application which has thousands of meters
sending values in a fixed interval.

The aim of this project is to figure out proper VM/TCP/OS settings to optimally
reduce overall CPU usage of the server application. 


compile the project:

    ./rebar3 compile

run the server on localhost:5555

    erl -pa _build/default/lib/*/ebin +K -s conn_bench
    
run the test senders (20000 connection, sending 10 random bytes every 250ms)

    erl -pa _build/default/lib/*/ebin +K true \
        -eval "conn_bench_connect:start(5555, 20000, 250, 10)"
