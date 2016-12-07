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
	    # -e=*|--extension=*)
	    # extension="${i#*=}"
	    # shift # past argument=value
	    # ;;
	 #    -h|--help)
		# echo "Movie Rename"
		# echo "usage: movie_rename [options]"
		# echo
		# echo "Options:"
		# echo "  -t=<title>, --title=<title> 			provide a title"
		# echo "  -y=<year>, --year=<year> 			provide a year"
		# echo "  -e=<extension>, --extension=<extension>    	provide an extension"
		# echo "  -h, --help         				display this help"
		# echo
		# echo "You will be promted before renaming a file."
		# exit
		# shift
		# ;;
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
		s/\(E[0-9][0-9]\).*/\1/;
		s/S\([0-9][0-9]\)/\&season=\1/;
		s/E\([0-9][0-9]\)/\&episode=\1/;
		s,^,http://www.omdbapi.com/?,' <<<$file)"
	# echo $url
	response=`curl -s $url`
	# echo $response
	# seriesID=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "seriesID"|sed 's/\"seriesID\":\"//;s/\"//')
	# seriesQuery=`curl -s "http://omdbapi.com/?i=$seriesID"`
	# series=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$seriesQuery|grep "Title"|sed 's/\"Title\":\"//;s/\"//')
	title=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "Title"|sed 's/\"Title\":\"//;s/\"//')
	
	# season=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "Season"|sed 's/\"Season\":\"//;s/\"//')
	# episode=$(sed 's/[{}]//g;s/\",\"/\"\n\"/g'<<<$response|grep "Episode"|sed 's/\"Episode\":\"//;s/\"//')
	
	ext=$(sed 's/.*\(\....\)$/\1/'<<<$file)
	
	if [ -z "$title" ]; then
		echo "Couldn't find data for $file"
	else
		# fname="$series S$(echo $season)E$(echo $episode) $title$ext"
		fname="$(sed "s/\./ /g;s/\(S[0-9][0-9]E[0-9][0-9]\).*/\1 $title$ext/"<<<$file)"
		echo $fname
		if [[ $yes = true ]]; then
			mv "$file" "$fname" && echo "renamed \"$file\" to \"$fname\""
		else
			confirm && mv "$file" "$fname" && echo "renamed \"$file\" to \"$fname\""
		fi
	fi

done

