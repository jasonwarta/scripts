#!/bin/bash

rand=$RANDOM$RANDOM
progress_fname="progress_$rand.txt"
log_fname="log_$rand.txt"
HB_PID=0
TAIL_PID=0

confirm () {
    read -r -p "${1:-Would you like to continue? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

function cleanup {
	kill -15 $HB_PID 2>&1 >/dev/null
	kill -15 $TAIL_PID 2>&1 >/dev/null
	rm -f "$progress_fname" "$log_fname" > /dev/null;
	exit
}

trap cleanup SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP

args=("$@")
if [ $# -eq 0 ] || [ $# -eq 1 ]; then
	echo "Correct usage:"
	echo "  scriptname [output directory] [file list]"
else
	numOfElems=${#args[@]}
	outputDir=${args[0]}
	currentDirectory=`pwd`

	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
	echo "*"
	echo "* Input filetype:     $filetype"
	# get and print full output directory
	cd "$outputDir"; echo "* Output Directory:   $(pwd)"; cd "$currentDirectory"
	echo "* Number of files:    $(($numOfElems-1))"
	echo "* Files:"
	for (( i=1;i<$numOfElems;i++)); do
		echo "*   ${args[${i}]}"
	done
	echo "*"
	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"

	confirm &&

	for (( i=1;i<$numOfElems;i++)); do

		# echo "" > "$fname"
		echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		echo "*"
		echo "* Processing:"
		echo "*   `sed 's/\....//'<<<${args[$i]}`"
		echo "*"
		echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		# handbrakecli -e x264  -q 20.0 -r 30 --pfr  -a 1,1 -E ffaac,copy:ac3 -B 160,160 -6 dpl2,none -R Auto,Auto -D 0.0,0.0 --audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 -f mp4 -X 1920 -Y 1080 --decomb=fast --loose-anamorphic --modulus 2 -m --x264-preset medium --h264-profile high --h264-level 4.0 -i "${args[$i]}" -o $outputDir/"${args[$i]%.$filetype}.mp4" 1> "$progress_fname" 2> "$log_fname" &
		handbrakecli -Z "AppleTV 2" -i "${args[$i]}" -o $outputDir/"`sed 's/\....//'<<<${args[$i]}`.mp4" 1> "$progress_fname" 2> "$log_fname" &
		
		toggle=true
		sleep 1;
		HB_PID=$!

		while pgrep handbrakecli > /dev/null;
		do
			# check if tail has been started, start if not
			if $toggle; then
				tail -f -n 1 "$progress_fname" &
				toggle=false

				TAIL_PID=$!
			fi
			
			sleep 10;

			# if handbrake has finished running, stop tail
			if ! pgrep handbrakecli > /dev/null; then
				kill -15 $TAIL_PID 2>/dev/null
				wait $TAIL_PID 2>/dev/null
			fi
			
		done;
		
		rm -f "$progress_fname" "$log_fname" > /dev/null;
		echo "Finished converting ${args[$i]%.$filetype}";
		
	done;
fi