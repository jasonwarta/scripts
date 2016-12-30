#!/bin/bash

args=("$@")
if [ $# -eq 0 ] || [ $# -eq 1 ]; then
	echo "Correct usage:"
	echo "  scriptname [output directory] [file list]"
else
	numOfElems=${#args[@]}
	outputDir=${args[0]}

	for (( i=1;i<$numOfElems;i++ )); do
		name="$(mediainfo "${args[${i}]}"|grep -e 'Track name *: '|sed 's/Track name *: //')"
		# echo "$name"
		artist="$(mediainfo "${args[${i}]}"|grep -e '^Performer *: '|sed 's/^Performer *: //')"
		# echo "$artist"
		album="$(mediainfo "${args[${i}]}"|grep -e 'Album *: '|sed 's/Album *: //')"
		# echo "$album"
		track="$(mediainfo "${args[${i}]}"|grep -e 'Track name/Position *: '|sed "s,Track name/Position *: ,,")"
		printf -v track "%02d" $track
		# echo "$track"
		ext="$(sed 's/.*\(\....$\)/\1/'<<<${args[${i}]})"
		# echo "$ext"

		fpath="$artist/$album"
		fname="$track - $name$ext"

		# echo "Path: $fpath"
		# echo "Name: $fname"

		mkdir -p "$outputDir/$fpath"
		mv "${args[${i}]}" "$fname" 2>/dev/null
		mv "$fname" "$outputDir/$fpath/" 
		echo "${args[${i}]}  >>>>  $outputDir/$fpath/$fname"
	done
fi