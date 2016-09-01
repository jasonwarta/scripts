#!/bin/bash
id=$(drutil status |grep -m1 -o '/dev/disk[0-9]*')

if [ -z "$id" ]; then
    echo "No Media Inserted" 
else 
    volName=`df | grep "$id" |grep -o /Volumes.* | cut -f2- -d'/' | cut -f2- -d'/'`
fi

if [ -n "$volName" ]; then
	mkdir /Volumes/JasonsMedia/vidout/"$volName" >/dev/null
	makemkvcon mkv disc:0 all --minlength 3600 --messages=-stdout --progress=-stdout --cache=512 /Volumes/JasonsMedia/vidout/"$volName"

	# toggle=true
	# sleep 1;

	# while pgrep makemkvcon > /dev/null;
	# do
	# 	# check if tail is running, start if not
	# 	if $toggle; then
	# 		tail -f -n 1 /Volumes/JasonsMedia/vidout/$volName/log.txt & 
	# 		toggle=false
	# 	fi
		
	# 	sleep 5;

	# 	# if handbrake has finished running, stop tail
	# 	if ! pgrep makemkvcon > /dev/null; then
	# 		kill $!
	# 		wait $! 2>/dev/null
	# 	fi
		
	# done;

	diskutil eject $id
else
	echo "Couldn't process disk"
fi