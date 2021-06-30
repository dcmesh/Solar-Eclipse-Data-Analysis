#!/bin/sh
# need to have spec.txt in same folder as bash script

# adds labels
cat spec.txt | sed 's/%//g' | sed 's/^.*;//g' > temp

# finds all wav files and gets metadata from
find . -name "*.wav" | while read filename; do mediainfo --Output=file://spec.txt $filename >> temp; done;

# removes duplicates
echo "$(awk '!a[$1]++' temp)" > metadata.csv

rm temp
