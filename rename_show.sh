#!/bin/bash

confirm () {
    read -r -p "${1:-Are you sure you want to rename the file? [Y/n]} " response </dev/tty
    case $response in
        [yY][eE][sS]|[yY]|"") 
            true
            ;;
        *)
            false
            ;;
    esac
}

function cleanup {
	exit
}

trap cleanup SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP

for i in "$@"; do
	case $i in
	    -s=*|--series=*)
	    series="${i#*=}"
	    shift # past argument=value
	    ;;
	    -y)
	    yes=true
	    shift # past argument=value
	    ;;
	esac
done

ls -1 {*.mp4,*.mkv,*.avi,*.m4v} 2>/dev/null |
while read file;do
# for file in "$(ls -1 {*.mp4,*.mkv,*.avi} 2>/dev/null)";do
	# echo $file
	
	url="$(sed '
		s/ /+/g;
		s/\....$//;
		s/^/t=/;
		s/\([0-9]\{1,2\}\)x\([0-9][0-9]\)/S0\1E\2/;
		s/\(E[0-9][0-9]\).*/\1/;
		s/S\([0-9][0-9]\)/\&season=\1/;
		s/E\([0-9][0-9]\)/\&episode=\1/;
		s,^,http://www.omdbapi.com/?,' <<<$file)"
	# echo $url
	response=`curl -s $url`
	# echo $response
	seriesID=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "seriesID"|sed 's/\"seriesID\":\"//;s/\"//')
	seriesQuery=`curl -s "http://omdbapi.com/?i=$seriesID"`
	series=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$seriesQuery|grep "Title"|sed 's/\"Title\":\"//;s/\"//')
	title=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "Title"|sed 's/\"Title\":\"//;s/\"//')
	
	season=$(sed 's/.*\([0-9]\{1,2\}\)x\([0-9][0-9]\).*/S0\1E\2/;s/.*\(S[0-9][0-9]\).*/\1/'<<<$file)
	episode=$(sed 's/.*\([0-9]\{1,2\}\)x\([0-9][0-9]\).*/S0\1E\2/;s/.*\(E[0-9][0-9]\).*/\1/'<<<$file)
	# echo $season
	# echo $episode
	# season=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "Season"|sed 's/\"Season\":\"//;s/\"//')
	# episode=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "Episode"|sed 's/\"Episode\":\"//;s/\"//')
	
	ext=$(sed 's/.*\(\....\)$/\1/'<<<$file)
	
	if [ -z "$title" ]; then
		echo "Couldn't find data for $file"
	else
		# fname="$series S$(echo $season)E$(echo $episode) $title$ext"
		# \(S[0-9][0-9]E[0-9][0-9]\)
		fname="$(sed "s/.*/$series $season$episode $title$ext/"<<<$file)"
		if [[ $yes = true ]]; then
			mv "$file" "$fname" && echo "renamed \"$file\" to \"$fname\""
		else
			echo $fname
			confirm && mv "$file" "$fname" && echo "renamed \"$file\" to \"$fname\""
		fi
	fi

done

