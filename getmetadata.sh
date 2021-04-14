#!/bin/sh
#need to have spec.txt in same folder as bash script
cat spec.txt > metadata.csv
find . -name "*.wav" | while read filename; do mediainfo --Output=file://spec.txt $filename >> metadata.csv; done;
