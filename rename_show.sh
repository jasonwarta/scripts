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

for file in *; do 
	url="$(sed '
			s/ /+/g;
			s/\....$//;
			s/^/t=/;
			s/S0/\&season=/;
			s/E/\&episode=/;
			s,^,http://www.omdbapi.com/?,' <<<$file)"
	title="$(curl -s "$url" |sed 's/[{}]//g;s/\",\"/\"\n\"/g'|grep "Title"|sed 's/\"Title\":\"//;s/\"//')"
	fname="$(sed "s/\(\....$\)/ $title\1/"<<<$file)"
	echo $fname
	confirm && mv "$file" "$fname"
	echo "renamed \"$file\" to \"$fname\""
done

