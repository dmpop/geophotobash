#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Please specify a city"
  exit 1
fi

wget -q --spider http://maps.googleapis.com/
if [ $? -ne 0 ]; then
    echo "Google Maps is not reachable. Check your Internet connection."
    exit 1
fi 

lat=$(curl -G -k --data "address=$1&sensor=false" \
http://maps.googleapis.com/maps/api/geocode/json | jq '.results[0].geometry.location.lat')
if (( $(echo "$lat > 0" |bc -l) )); then
  latref="N"
  else
  latref="S"
fi

lon=$(curl -G -k --data "address=$1&sensor=false" \
http://maps.googleapis.com/maps/api/geocode/json | jq '.results[0].geometry.location.lng')
if (( $(echo "$lon > 0" |bc -l) )); then
  lonref="E"
  else
  lonref="W"
fi

exiftool -overwrite_original -GPSLatitude=$lat -GPSLatitudeRef=$latref -GPSLongitude=$lon -GPSLongitudeRef=$lonref .