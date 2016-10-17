#!/usr/bin/env bash

# keepalive script for restarting a process when it breaks
# Usage: pass in a 

if [ $# -eq 0 ] || [ $# -gt 1 ]; then
	echo "Correct usage:"
	echo "  keepalive [script/process]"
else 
	process=${args[0]}

	PID=""
	if ! pgrep -f '$process' 2>&1 > /dev/null; then
		echo "$process wasn't running."
		echo "starting $process"
		$process
		PID=$!
	else
		echo "$process was already running"
		echo "attaching to $process"
		PID=$(pgrep -f 'ssh -D 8080 -f -C -q -N HS -p 22')
	fi

	function terminate {
		kill $PID
		exit
	}
	trap terminate SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP


	while true; do
		while pgrep -f '$process' 2>&1 > /dev/null; do
			sleep 1
		done

		echo -e "$(date): Restarting $process\n" >> ~/logs/keepalive.log
		$process
		PID=$!
	done
fi