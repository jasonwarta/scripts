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
	# echo $response
	valid=$(sed 's/.*"Response":"\(False\)".*/\1/'<<<$response)
	if [ "$valid" == "False" ]; then
		echo "Couldn't find data for $file"
		continue
	fi
	# parse out title and year from response
	# title=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<"$response"|grep "\"Title\":\""|sed 's/\"Title\":\"//;s/\"//')
	title="$(sed 's/.*"Title":"\(.*\)","Year":.*/\1/'<<<$response)"
	# year=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<"$response"|grep "Year"|sed 's/\"Year\":\"//;s/\"//')
	year="$(sed 's/.*","Year":"\([12][0-9]\{3\}\)",".*/\1/'<<<$response)"
	# get file extension
	ext=$(sed 's/.*\(\....\)$/\1/'<<<$file)
	
	# handle movie rename
	if [ -z "$title" ]; then
		echo "Couldn't find data for $file"
	else
		fname="$title ($year)$ext"

		if [ "$file" == "$fname" ]; then
			echo "$file was already named correctly"
		else
			echo "$file ==> $parsedName"
			echo $fname
			confirm && mv "$file" "$fname" && echo "renamed \"$file\" to \"$fname\""
		fi
	fi
done