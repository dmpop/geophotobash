# Geophotobash

Bash shell script for lean automated photographic workflow.

## Dependencies

- Fossil
- wget
- cURL
- bc
- jq
- ExifTool

# Requirements

A Linux machine with the Bash shell and an Internet connection.

## Installation

To deploy Geophotobash on Debian and Ubuntu-based Linux distributions, use the following commands:

`sudo apt install fossil wget curl bc jq libimage-exiftool-perl`

`mkdir geophotobash && cd $_`

`wget geophotobash.fossil`

`fossil open geophotobash.fossil`

`sudo cp geophotobash.sh /local/bin/geophotobash`

`sudo chown root:root /local/bin/geophotobash`

`sudo sudo chmod 755 /local/bin/geophotobash`

## Usage

To geotag and organize photos:

`geophotobash -f [CITY] [COUNTRY]`

Example:

`geophotobash -f Tokyo Japan`

To orgazine geotagged photos:

`geophotobash -r`

## Author

Dmitri Popov [dmpop@linux.com](mailto:dmpop@linux.com)

## License

The [GNU General Public License version 3](http://www.gnu.org/licenses/gpl-3.0.en.html)
 
