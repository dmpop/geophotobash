#!/usr/bin/env bash
OPTIND=1

# Check whether the Nominatim service is reachable
wget -q --spider http://nominatim.openstreetmap.org/
if [ $? -ne 0 ]; then
    echo "Nominatim is not reachable. Check your Internet connection."
    exit 1
fi 

# Use GETOPS to read the parameter supplied with the command
# Supported parameters: -h and -? (help), -f (forward geocoding), -r (reverse geocoding)
while getopts "h?fr" opt; do
  case $opt in
  f)
  # Shift one position to read the [CITY] and [COUNTRY] options
  shift $((OPTIND-1))
  city=$1
  country=$2
  
  # Use the curl tool to fetch geographical data via an HTTP request using the Nominatim service
  # Pipe the output in the JSON format to the jq tool to extract the latitude value
  # Use the tr tool to remove the quotes around the returned latitude value
  lat=$(curl "http://nominatim.openstreetmap.org/search?city=$city&country=$country&format=json" | jq '.[0] | .lat' | tr -d '"')
  
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
  lon=$(curl "http://nominatim.openstreetmap.org/search?city=$city&country=$country&format=json" | jq '.[0] | .lon' | tr -d '"')
  
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
  
  # Add city and country keywords to each photo
  exiftool -overwrite_original -keywords+="$country" -keywords+="$city" .
  
  # Rename all photos in the current directory sing the yearmonthday-hoursminutesseconds.ext format
  exiftool "-FileName<CreateDate" -d "%Y%m%d-%H%M%S.%%e" .
  
  # Move the photos to the target directory
  exiftool '-Directory<CreateDate' -d "$country"/"$city"/%Y-%m-%d . 
  ;;
  r)
  # For each file in the current directory, obtain the latitude and longitude values
  # Use the tr tool to discard the unwanted text
  for i in *.* ; do
    lat=$(exiftool -gpslatitude -n "$i" | tr -d 'GPS Latitude : ')
    lon=$(exiftool -gpslongitude -n "$i" | tr -d 'GPS Longitude : ')
    
    # Use the curl tool to perform reverse geocoding via an HTTP request using the Nominatim service
    # Pipe the output in the JSON format to the jq tool to extract city and country
    # Use the tr tool to remove the quotes around the returned values
    if [ ! -z $lat ] || [ ! -z $lon ]; then
      city=$(curl "http://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon" | jq '.address.city' | tr -d '"')
      country=$(curl "http://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon" | jq '.address.country' | tr -d '"')
      
      # Create the target directory if it doesn't exist
        if [ ! -d "$country"/"$city" ]; then
          mkdir -p "$country"/"$city"
        fi
        
     # Move the photo to the target directory
     mv "$i" "$country"/"$city"
    fi
  done
  
  # Move the photos to the target directory and group them by date
  exiftool '-Directory<CreateDate' -d "$country"/"$city"/%Y-%m-%d "$country"/"$city"
  
  # Rename all photos in the current directory sing the yearmonthday-hoursminutesseconds.ext format
  exiftool "-FileName<CreateDate" -d "%Y%m%d-%H%M%S.%%e" -r "$country/$city"
  
  # Add city and country keywords to each photo
  exiftool -overwrite_original -keywords+="$country" -keywords+="$city" "$country/$city"
  ;;
  h|\?)
  cat <<EOF
  
  USAGE
  =====
  
  To geotag and organize photos: $0 -f [CITY] [COUNTRY] e.g., $0 -f Tokyo Japan
  
  To orgazine geotagged photos: $0 geophotobash -r
  
EOF
  exit 2
;;
esac
done
