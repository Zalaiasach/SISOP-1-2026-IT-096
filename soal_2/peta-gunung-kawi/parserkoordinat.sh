#!/bin/bash

input_file="gsxtrack.json"
output_file="titik-penting.txt"

grep -E '"id"|"site_name"|"latitude"|"longitude"' "$input_file"|\
sed -E 's/.*: //; s/[",]//g' | \
awk '{
	id=$0; getline;
	name=$0; getline;
	lat=$0; getline;
	lon=$0;
	printf "%s, %s, %s, %s\n",id, name, lat, lon
}' | sort > "$output_file"

echo "File $output_file yang dinginkan telah selesai dibuat"
