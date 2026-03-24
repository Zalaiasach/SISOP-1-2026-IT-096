#!/bin/bash

file="titik-penting.txt"
file_output="posisipusaka.txt"

lat1=$(awk -F',' 'NR==1 {print $3}' "$file")
lon1=$(awk -F',' 'NR==1 {print $4}' "$file")

lat2=$(awk -F',' 'NR==3 {print $3}' "$file")
lon2=$(awk -F',' 'NR==3 {print $4}' "$file")

lat_akhir=$(echo "scale=5;($lat1+$lat2) /2"|bc)
lon_akhir=$(echo "scale=5;($lon1+$lon2) /2"|bc)

echo "Koordinat pusatnya di: $lat_akhir, $lon_akhir"
echo "$lat_akhir, $lon_akhir" > $file_output
echo "Posisi pusaka sudah tercatat di $file_output"
