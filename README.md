# Geophotobash

Bash shell script for automated photographic workflow.

## Dependencies

- Git
- cURL
- bc
- jq
- ExifTool

## Requirements

A Linux machine with the Bash shell and an Internet connection.

## Installation

To install Geophotobash on Ubuntu and Linux Mint distributions, use the following commands:

```
sudo apt install git-core curl bc jq exiftool
git clone https://github.com/dmpop/geophotobash.git
cp geophotobash/geophotobash.sh $HOME/bin/geophotobash
```

## Usage

To geotag and organize photos:

`geophotobash -g [CITY]`

Example:

`geophotobash -g Tokyo`

The [Linux Photography](https://gumroad.com/l/linux-photography) book provides detailed information on using Geophotobash. Get your copy at [Google Play Store](https://play.google.com/store/books/details/Dmitri_Popov_Linux_Photography?id=cO70CwAAQBAJ) or [Gumroad](https://gumroad.com/l/linux-photography).

<img src="https://cameracode.coffee/uploads/linux-photography.png" title="Linux Photography" width="300"/>

## Author
Dmitri Popov [dmpop@cameracode.coffee](mailto:cameracode.coffee)

## License

The [GNU General Public License version 3](http://www.gnu.org/licenses/gpl-3.0.en.html)
 
