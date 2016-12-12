#!/bin/bash

confirm () {
    read -r -p "${1:-Is this correct? [Y/n]} " response </dev/tty
    case $response in
        [yY][eE][sS]|[yY]|"") 
            true
            ;;
        *)
            false
            ;;
    esac
}

ls {*.mp4,*.mkv,*.avi,*.m4v,*.srt} 2>/dev/null |
while read file;do
	# parse filename
	parsedName=$(sed 's/\....$//;s/\./ /g;s/\([A-Za-z'\''0-9'-']*\([ ]*[A-Za-z'\''0-9'-']\)*\).*/\1/'<<<$file)
	# build url with title extracted from file
	url="http://omdbapi.com/?t=$(sed 's/\....$//;s/\./ /g;s/ /+/g'<<<$parsedName)"
	# get json from url
	response=`curl -s "$url"`
	# parse out title and year from response
	title=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "\"Title\":\""|sed 's/\"Title\":\"//;s/\"//')
	year=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "Year"|sed 's/\"Year\":\"//;s/\"//')
	# get file extension
	ext=$(sed 's/.*\(\....\)$/\1/'<<<$file)
	
	# handle movie rename
	if [ -z "$title" ]; then
		echo "Couldn't find data for $file"
	else
		echo "$file ==> $parsedName"
		fname="$title ($year)$ext"
		echo $fname
		confirm && mv "$file" "$fname" && echo "renamed \"$file\" to \"$fname\""
	fi
done