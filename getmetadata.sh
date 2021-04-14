#!/bin/sh
#need to have spec.txt in same folder as bash script
cat spec.txt > temp
find . -name "*.wav" | while read filename; do mediainfo --Output=file://spec.txt $filename >> temp; done;
echo "$(awk '!a[$1]++' temp)" > metadata.csv
rm temp
