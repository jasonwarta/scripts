#!/bin/bash

args=("$@")
if [ $# -eq 0 ] || [ $# -eq 1 ]; then
	echo "Correct usage:"
	echo "  scriptname [output directory] [file list]"
else
	numOfElems=${#args[@]}
	outputDir=${args[0]}

	for (( i=1;i<$numOfElems;i++ )); do

		size="$(stat --format="%s" "${args[${i}]}")"
		if [ "$size" = "0" ];then
			# echo "size 0: ${args[${i}]}"
			rm "${args[${i}]}"
			continue
		fi

		name="$(mediainfo "${args[${i}]}"|grep -e 'Track name *: '|sed 's/Track name *: //')" 2>/dev/null
		name="$(sed 's,/,-,'<<<$name)"
		# echo "$name"
		artist="$(mediainfo "${args[${i}]}"|grep -e '^Performer *: '|sed 's/^Performer *: //')" 2>/dev/null
		# echo "$artist"
		album="$(mediainfo "${args[${i}]}"|grep -e 'Album *: '|sed 's/Album *: //')" 2>/dev/null
		# echo "$album"
		track="$(mediainfo "${args[${i}]}"|grep -e 'Track name/Position *: '|sed "s,Track name/Position *: ,,")" 2>/dev/null
		printf -v track "%02d" $track
		# echo "$track"
		ext="$(sed 's/.*\(\....$\)/\1/'<<<${args[${i}]})"
		# echo "$ext"

		fpath="$artist/$album"
		fname="$track - $name$ext"

		# echo "Path: $fpath"
		# echo "Name: $fname"
		
		if [ -z "$name" ];then
			echo "couldn't get info for $file"
		else
			mkdir -p "$outputDir/$fpath"
			mv "${args[${i}]}" "$fname" 2>/dev/null
			mv "$fname" "$outputDir/$fpath/" 
			echo "${args[${i}]}  >>>>  $outputDir/$fpath/$fname"
		fi
	done
fi