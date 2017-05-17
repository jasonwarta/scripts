#!/bin/bash
sleep 20s
id=$(drutil status |grep -m1 -o '/dev/disk[0-9]*')

if [ -z "$id" ]; then
    echo "No Media Inserted" 
else 
    volName=`df | grep "$id" |grep -o /Volumes.* | cut -f2- -d'/' | cut -f2- -d'/'`
fi

fpath="/Users/jasonwarta/vidout/$volName"

if [ -n "$volName" ]; then
	mkdir "$fpath" >/dev/null
	makemkvcon mkv disc:0 all --minlength 1800 --messages=-stdout --progress=-stdout --cache=512 "$fpath"

	diskutil eject $id
	osascript /Users/jasonwarta/scripts/sendMessage.scpt 9077076314 "Done processing DVD"
else
	echo "Couldn't process disk"
fi