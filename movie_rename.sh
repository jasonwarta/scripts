#!/bin/bash

confirm () {
    read -r -p "${1:-Are you sure? [y/N]} " response
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
	esac
done

for file in "`ls {*.mp4,*.mkv,*.avi} 2>/dev/null`"; do

	if [ -z $title ]; then
		title="`echo "$file"|sed 's/\./ /g'|sed 's/\([A-Za-z'\'']*\([ ]*[A-Za-z'\'']\)*\).*/\1/'`";
	fi
	if [ -z $year ]; then
		year="`echo "$file"| sed 's/.*\([12][0-9]\{3\}\).*/\1/'`";
	fi
	if [ -z $extension ]; then
		extension="`echo "$file"|sed 's/.*\(\....\)/\1/'`";
	fi
	# title="`echo "$file"|sed 's/\./ /g'|sed 's/\([A-Za-z]*\([ ]*[A-Za-z]\)*\).*/\1/'`";
	# year="`echo "$file"| sed 's/^.*\([0-9]\{4\}\).*/\1/'`";
	# extension="`echo "$file"| sed 's/.*\(\.[A-Za-z0-9]\{3\}$\)/\1/'`";
	echo "title :$title"
	echo "year :$year"
	echo "extension :$extension"

	fname="$title ($year)$extension"
	echo "new filename: \"$fname\""
	confirm && mv "$file" "$fname"
done
