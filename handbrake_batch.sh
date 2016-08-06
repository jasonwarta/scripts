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
	cd $outputDir; echo "* Output Directory:   $(pwd)"; cd $currentDirectory
	echo "* Number of files:    $(($numOfElems-2))"
	echo "* Files:"
	for (( i=2;i<$numOfElems;i++)); do
		echo "*   ${args[${i}]}"
	done
	echo "*"
	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"

	read -p "Press ENTER to continue processing or Ctrl+C to quit..."

	for (( i=2;i<$numOfElems;i++)); do
		echo "" > progress.txt
		echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		echo "*"
		echo "* Processing:"
		echo "*   ${args[$i]%.$filetype}"
		echo "*"
		echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
		handbrakecli -Z "AppleTV 2" -i "${args[$i]}" -o $outputDir/"${args[$i]%.$filetype}.mp4" 1> progress.txt 2> log.txt &
		
		HBpid=`pgrep handbrakecli`
		toggle=true
		sleep 1;

		while pgrep handbrakecli > /dev/null
		do
			# check if tail is running, start if not
			if $toggle; then
				tail -f -n 1 progress.txt &
				toggle=false
			fi

			# if handbrake has finished running, stop tail
			if ! pgrep handbrakecli > /dev/null; then
				kill `pgrep tail`
			fi
			sleep 5;
		done
		
		rm progress.txt;
	done;
fi