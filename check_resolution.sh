for file in *; do 
	hw=`mediainfo "$file"|grep -E "Width|Height"|sed 's/ //g'`
	# echo $hw
	h="$(sed 's/.*Height:\([0-9]\{3,4\}\)pixels.*/\1/'<<<$hw)"
	w="$(sed 's/.*Width:\([0-9]\{3,4\}\)pixels.*/\1/'<<<$hw)"
	# echo $h
	# echo $w
	# sed 's/ //g;s/^.*:\(.*\)pixels/\1/'
	# echo "$file" >> "$h.txt"
	if [[ $h -gt 720 ]]; then
		echo "$file" >> "larger-than-720p.txt"
	elif [[ $h -ge 480 ]] && [[ $h -le 720 ]]; then
		echo "$file" >> "480p-720p.txt"
	else
		echo "$file" >> "smaller-than-480p.txt"
	fi
done