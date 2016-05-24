# VBBar
**BitBar script to access and search the Berlin and Brandenburg public transportation information from the OS X menu bar**

## Current status
alpha (pre-release)

## Prerequisite
[BitBar](https://github.com/matryer/bitbar) **v2 beta4** and higher

Minimum OS X for full functionality: **10.10**

## APIs
First you need access keys/tokens for two APIs, one for the [VBB API](http://www.vbb.de/labs), and one for the public [Mapbox API](https://www.mapbox.com/studio/signup/?plan=starter).

For the former you need to apply by email, and you will receive an ID for the developer test API. In the end, once the underlying software [vbb-cli](https://github.com/derhuerst/vbb-cli) is approved by VBB, VBBar should work without using an individual API access ID. (Fingers crossed.)

For the latter you just need to register for a free starter plan. Be sure to generate your own individual access token, i.e. don't use the Mapbox default public token. I'd prefer using a geocoding library/service that will work without API tokens, so if you know a better alternative, one that works like **mapbox** as a cli (bash), and one that also includes **automated walking directions** between two sets of coordinates, let us know.

## Installation & Dependencies

### Manual installations
Install into `/Applications`
* [BitBar](https://github.com/matryer/bitbar) 
* Launch BitBar and set your BitBar plugins directory; quit BitBar

Install into `/usr/local/bin`
* [CoreLocationCLI](https://github.com/fulldecent/corelocationcli)
* Make executable with `chmod +x /usr/local/bin/CoreLocationCLI`
* Test CoreLocationCLI in your shell, e.g. with `CoreLocationCLI -h`
* If it doesn't work, dequarantine with `xattr -dr com.apple.quarantine /usr/local/bin/CoreLocationCLI`

### Homebrew installations (tap)
Install with [Homebrew](http://brew.sh)
* [mapbox](https://github.com/mapbox/mapbox-cli-py): `brew install mapbox/cli/mapbox`

### Homebrew installations (regular)
Install with [Homebrew](http://brew.sh) (or a similar manager) with `brew install <software-name>`

* [jq](https://stedolan.github.io/jq/)
* [miller](https://github.com/johnkerl/miller)
* [node](https://nodejs.org)

You need to install Node.js to install further software with `npm`(see below)

* [terminal-notifier](https://github.com/alloy/terminal-notifier)

You need to have Spotlight enabled for `mdfind` to locate the terminal-notifier.app on your volume; if you don't install terminal-notifier or deactivate Spotlight, VBBar will call notifications via AppleScript instead

### Node.js installations
Install with `npm install -g`
* [vbb-cli](https://github.com/derhuerst/vbb-cli): this will (among other things) put `vbb-dep` and `vbb-route` into `/usr/local/bin`
* [vbb-stations-cli](https://github.com/derhuerst/vbb-stations-cli)

### Final steps with VBBar/BitBar
* Download the main VBBar script and the VBBar subfolder containing the subscripts; move both main script and subfolder into your BitBar plugins directory
* Open your shell, `cd` to your BitBar plugins directory, and enter `chmod +x VBBar.30m.sh`
* Once launched, VBBar will `chmod +x` the remaining subscripts by itself
* Regarding the main script, you can change "30m" to e.g. "15m", if you want a faster refresh rate (15 minutes instead of the default 30 minutes)
* Launch BitBar; VBBar should now load
* Once you have your VBB and Mapbox access IDs/tokens, you can enter them in the VBBar submenu ("System")

## To-do

* If possible, use a geocoding alternative to Mapbox (bash/cli, address/coordinates geocoding incl. reverse, walking directions, walking distance)
* Include network lines operating from nearby stations
* Refine address search (possibly needed: free alternative to kauperts Straßenverzeichnis)
* Add functionality such as: previous searches, route to destination by departure/arrival time, favorite routes/stations/addresses
* sqlite db integration

## Why VBBar?

* There are people (like me) who don't have a smartphone, but need to look up public transportation information, manage routes/travel etc.
* There are people (like future me) who have a smartphone, but don't want to look at their smartphone every time they need public transportation information (and possibly get distracted by useless things in the process)
