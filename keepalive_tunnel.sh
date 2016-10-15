#!/usr/bin/env bash

# keepalive script for restarting python server when it breaks
# Usage: place in same dir as server.py and run from there

tunnel='ssh -D 8080 -f -C -q -N HS -p 22'

PID=""
if ! pgrep -f 'ssh -D 8080 -f -C -q -N HS -p 22' 2>&1 > /dev/null; then
	echo "tunnel wasn't running."
	echo "starting tunnel"
	$tunnel
	PID=$!
else
	echo "tunnel was already running"
	echo "attaching to tunnel process"
	PID=$(pgrep -f 'ssh -D 8080 -f -C -q -N HS -p 22')
fi


function terminate {
	kill $PID
	exit
}
trap terminate SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP


while true; do
	while pgrep -f 'ssh -D 8080 -f -C -q -N HS -p 22' 2>&1 > /dev/null; do
		sleep 1
	done

	echo -e "$(date): Restarting socks tunnel\n" >> ~/logs/socks_tunnel.log
	$tunnel
	PID=$!
done