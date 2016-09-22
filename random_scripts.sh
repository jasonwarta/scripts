
# batch rename
# replaces all spaces in filename with _
for f in *.jpeg; do 
	mv "$f" "${f/ /_}"; 
done

# batch compress jpeg with imagemagick utilities
# compresses all jpegs in folder significanly
for file in *.jpeg; do
	convert -strip -interlace Plane -gaussian-blur 0.05 -quality 85% $file "compressed_$file"; 
done