#!/bin/bash

confirm () {
    read -r -p "${1:-Are you sure you want to continue? [Y/n]} " response </dev/tty
    case $response in
        [yY][eE][sS]|[yY]|"") 
            true
            ;;
        *)
            false
            ;;
    esac
}

usage () {
	echo "Usage: "
	echo "	addsubs [video file] [subs file] [output file]"
	echo "NOTE: only mkv and mp4 files are supported."
	echo "      The output filetype must be the same as the input filetype"
	exit
}

function cleanup {
	exit
}

trap cleanup SIGHUP SIGINT SIGKILL SIGTERM SIGSTOP

for i in "$@"; do
	case $i in
	    # -f=*|--format=*)
	    # f="${i#*=}"
	    # shift # past argument=value
	    # ;;
	    -h=*|--help=*)
	    usage
	    shift # past argument=value
	    ;;
	esac
done

vidfile="$1"
subs="$2"
output="$3"
filetype="$(sed 's/.*\(\....\).*/\1/'<<<$vidfile)"
echo $vidfile $subs $output $filetype

# if [ -z "$f" ]; then
# 	echo "You must specify a type using -f=[type]";
if [ -z "$vidfile" ] || [ -z "$subs" ] || [ -z "$output" ]; then
	echo "You must specify a video file, a subtitles file, and an output file."
	usage
elif [ "$vidfile" = "$output" ]; then
	echo "You must use a different filename for the output file!"
elif [ "$filetype" = ".mkv" ]; then
	echo "You are adding"
	echo "  $subs to"
	echo "  $vidfile,"
	echo "  and outputting to"
	echo "  $output."
	confirm &&
	ffmpeg -i "$vidfile" -f srt -i "$subs" \
	-map 0:0 -map 0:1 -map 1:0 -c:v copy -c:a copy \
	-c:s srt "$output"
elif [ "$filetype" = ".mp4" ]; then
	ffmpeg -i "$vidfile" -f srt -i "$subs" \
	-map 0:0 -map 0:1 -map 1:0 -c:v copy -c:a copy \
	-c:s mov_text "$output"
else
	echo "something went wrong"
fi






