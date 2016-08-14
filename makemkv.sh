#!/bin/bash
id=$(drutil status |grep -m1 -o '/dev/disk[0-9]*')

if [ -z "$id" ]; then
    echo "No Media Inserted" 
else 
    volName=`df | grep "$id" |grep -o /Volumes.* | cut -f2- -d'/' | cut -f2- -d'/'`
fi

if [ -n "$volName" ]; then
	mkdir /Volumes/JasonsMedia/vidout/$volName
	makemkvcon mkv disc:0 all --minlength 3600 /Volumes/JasonsMedia/vidout/$volName 1>/Volumes/JasonsMedia/vidout/$volName/log.txt 2>/Volumes/JasonsMedia/vidout/$volName/error.txt
	diskutil eject $id
else
	echo "Couldn't process disk"
fi