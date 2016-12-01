#!/bin/bash

rand=$RANDOM$RANDOM
fname="list_$rand.txt"

function cleanup {
	kill -15 $HB_PID 2>&1 >/dev/null
	kill -15 $TAIL_PID 2>&1 >/dev/null
	rm -f "$fname" > /dev/null;
	exit
}

trap cleanup SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP

args=("$@")

numOfElems=${#args[@]}

for (( i=0;i<$numOfElems;i++)); do
	echo "* ${args[${i}]}"
	echo "file '${args[${i}]}'" >> $fname
done

ext=$(sed 's/.*\(\....\)/\1/'<<<${args[0]})

ffmpeg -f concat -i $fname -c copy "output$ext"
rm "$fname"