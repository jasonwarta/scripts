
# batch rename
# replaces all spaces in filename with _
for f in *.jpeg; do 
	mv "$f" "${f/ /_}"; 
done

# batch rename
# removes a string from every file in a list using sed
for file in *; do 
	mv "$file" "`echo $file | sed 's/.720p.BluRay.x264.ShAaNiG//'`"; 
done

# batch compress jpeg with imagemagick utilities
# compresses all jpegs in folder significanly
for file in *.jpeg; do
	convert -strip -interlace Plane -gaussian-blur 0.05 -quality 85% $file "compressed_$file"; 
done

# beets silent import script
beet import -qs -l /Volumes/JasonsMusic/._data/import_errors.log /Volumes/JasonsMusic/

# gsed rename
for file in *; do
	mv "$file" "`echo "$file" | gsed 's/\b[0-9]\b/0&/'`";
done

# tv season episode rename
for file in *.avi; do 
	echo "`echo "$file"|sed 's/\./ /g'|sed "s/[1-6]/s0&e/"|sed 's/ex/e/'|sed 's/ [Dd][Vv][Dd].*/\.avi/'|sed 's/-/ /g'`";
done