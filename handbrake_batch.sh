#!/bin/bash
args=("$@")
if [ $# -eq 0 ] || [ $# -eq 1 ] || [ $# -eq 2 ]; then
	echo "Correct usage:"
	echo "  scriptname [intput filetype (mkv,avi,wav...)] [output directory] [file list]"
else
	numOfElems=${#args[@]}
	filetype=${args[0]}
	outputDir=${args[1]}
	currentDirectory=`pwd`

	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
	echo "*"
	echo "* Input filetype:     $filetype"
	# get and print full output directory
	cd "$outputDir"; echo "* Output Directory:   $(pwd)"; cd "$currentDirectory"
	echo "* Number of files:    $(($numOfElems-2))"
	echo "* Files:"
	for (( i=2;i<$numOfElems;i++)); do
		echo "*   ${args[${i}]}"
	done
	echo "*"
	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"

	read -p "Press ENTER to continue processing or Ctrl+C to quit..."

	for (( i=2;i<$numOfElems;i++)); do
		rand=$RANDOM$RANDOM
		progress_fname="progress_$rand.txt"
		log_fname="log_$rand.txt"

		echo "" > "$fname"
		echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		echo "*"
		echo "* Processing:"
		echo "*   ${args[$i]%.$filetype}"
		echo "*"
		echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		handbrakecli -Z "AppleTV 2" -i "${args[$i]}" -o $outputDir/"${args[$i]%.$filetype}.mp4" 1> "$progress_fname" 2> "$log_fname" &
		
		toggle=true
		sleep 1;
		HB_PID=$!
		TAIL_PID=0

		while pgrep handbrakecli > /dev/null;
		do
			# check if tail is running, start if not
			if $toggle; then
				tail -f -n 1 "$progress_fname" &
				toggle=false

				TAIL_PID=$!
			fi
			
			sleep 5;

			# if handbrake has finished running, stop tail
			if ! pgrep handbrakecli > /dev/null; then
				kill $TAIL_PID
				wait $TAIL_PID 2>/dev/null
			fi
			
		done;
		
		rm "$progress_fname" "$log_fname" > /dev/null;
		echo "Finished converting ${args[$i]%.$filetype}";
		
	done;
fi