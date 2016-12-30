#!/bin/bash

#mediainfo AAAL.mp3|grep -e 'Track name *:'|sed 's/Track name *: //'

#get filename
f="$1"


echo $f

args=("$@")
if [ $# -eq 0 ] || [ $# -eq 1 ]; then
	echo "Correct usage:"
	echo "  scriptname [output directory] [file list]"
else
	numOfElems=${#args[@]}
	outputDir=${args[0]}

	for (( i=1;i$numOfElems;i++ )); do
		name="$(mediainfo "${args[${i}]}"|grep -e 'Track name *: '|sed 's/Track name *: //')"
		artist="$(mediainfo "${args[${i}]}"|grep -e 'Performer *: '|sed 's/Performer *: //')"
		album="$(mediainfo "${args[${i}]}"|grep -e 'Album *: '|sed 's/Album *: //')"

		echo "$artist - $album - $name"
	done
fi