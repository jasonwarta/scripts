#!/bin/bash

confirm () {
    read -r -p "${1:-Are you sure you want to rename the file? [y/N]} " response </dev/tty
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
	exit
}

trap cleanup SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP

for i in "$@"; do
	case $i in
	    -t=*|--title=*)
	    title="${i#*=}"
	    shift # past argument=value
	    ;;
	    -y=*|--year=*)
	    year="${i#*=}"
	    shift # past argument=value
	    ;;
	    -e=*|--extension=*)
	    extension="${i#*=}"
	    shift # past argument=value
	    ;;
	    -h|--help)
		echo "Movie Rename"
		echo "usage: movie_rename [options]"
		echo
		echo "Options:"
		echo "  -t=<title>, --title=<title> 			provide a title"
		echo "  -y=<year>, --year=<year> 			provide a year"
		echo "  -e=<extension>, --extension=<extension>    	provide an extension"
		echo "  -h, --help         				display this help"
		echo
		echo "You will be promted before renaming a file."
		exit
		shift
		;;
	esac
done

# for file in "`ls {*.mp4,*.mkv,*.avi} 2>/dev/null`"; do
ls {*.mp4,*.mkv,*.avi} 2>/dev/null |
while read file; do

	if [ -z $title ]; then
		title="`sed 's/\./ /g; s/\([A-Za-z'\'']*\([ ]*[A-Za-z'\'']\)*\).*/\1/' <<< "$file"`";
	fi
	if [ -z $year ]; then
		year="`sed 's/.*\([12][0-9]\{3\}\).*/\1/' <<< "$file"`";
	fi
	if [ -z $extension ]; then
		extension="`sed 's/.*\(\....\)/\1/' <<< "$file"`";
	fi
	# title="`echo "$file"|sed 's/\./ /g'|sed 's/\([A-Za-z]*\([ ]*[A-Za-z]\)*\).*/\1/'`";
	# year="`echo "$file"| sed 's/^.*\([0-9]\{4\}\).*/\1/'`";
	# extension="`echo "$file"| sed 's/.*\(\.[A-Za-z0-9]\{3\}$\)/\1/'`";
	echo "title: $title"
	echo "year: $year"
	echo "extension: $extension"

	fname="$title ($year)$extension"
	echo "new filename: \"$fname\""
	confirm && mv "$file" "$fname"

	unset title
	unset year
	unset extension
done
