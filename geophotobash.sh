#!/usr/bin/env bash
OPTIND=1

# Check whether the Photon service is reachable
wget -q --spider http://photon.komoot.de/
if [ $? -ne 0 ]; then
    echo "Photon is not reachable. Check your Internet connection."
    exit 1
fi 

# Use GETOPS to read the parameter supplied with the command
# Supported parameters: -h and -? (help), -f (forward geocoding)
while getopts "h?f" opt; do
  case $opt in
  f)
  # Shift one position to read the [CITY] value
  shift $((OPTIND-1))
  city=$1
  
  # Use the curl tool to fetch geographical data via an HTTP request using the Nominatim service
  # Pipe the output in the JSON format to the jq tool to extract the latitude value
  # Use the tr tool to remove the quotes around the returned latitude value
  lat=$(curl "photon.komoot.de/api/?q=$1" | jq '.features | .[0] | .geometry | .coordinates | .[1]')
  
  # Calculate the latitude and longitude references
  # The latitude reference is N if the latitude value is positive
  # The latitude reference is S if the latitude value is negative
  # Use the bc tool to compare the value of the $lat variable and assign the correct latitude reference
  if (( $(echo "$lat > 0" |bc -l) )); then
    latref="N"
  else
    latref="S"
  fi
  
  # Use the curl tool to fetch geographical data via an HTTP request using the Nominatim service
  # Pipe the output in the JSON format to the jq tool to extract the longitude value
  # Use the tr tool to remove the quotes around the returned longitude value
  lon=$(curl "photon.komoot.de/api/?q=$1" | jq '.features | .[0] | .geometry | .coordinates | .[0]')
  
  # Calculate the correct longitude references for the given longitude value
  # The longitude reference is E if the longitude value is positive
  # The longitude reference is W if the longitude value is negative
  if (( $(echo "$lon > 0" |bc -l) )); then
    lonref="E"
  else
    lonref="W"
  fi
  
  # Write the obtained geographical coordinates into EXIF metadata of each photo in the current directory
  exiftool -overwrite_original -GPSLatitude=$lat -GPSLatitudeRef=$latref -GPSLongitude=$lon -GPSLongitudeRef=$lonref .
  
  # Add the city as a keyword to each photo
  exiftool -overwrite_original -keywords+="$city" .
  
  # Rename all photos in the current directory sing the yearmonthday-hoursminutesseconds.ext format
  exiftool "-FileName<CreateDate" -d "%Y%m%d-%H%M%S.%%e" .
  
  # Move the photos to the target directory
  exiftool '-Directory<CreateDate' -d "$city"/%Y-%m-%d . 
  ;;
  h|\?)
  cat <<EOF
  
  USAGE
  =====
  
  To geotag and organize photos: $0 -f [CITY] e.g., $0 -f Tokyo
  
  To orgazine geotagged photos: $0 geophotobash -r
  
EOF
  exit 2
;;
esac
done
