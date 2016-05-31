![VBBar-platform-osx](https://img.shields.io/badge/platform-osx-lightgrey.svg)
![VBBar-code-shell](https://img.shields.io/badge/code-shell-yellow.svg)
[![VBBar-prereq-bitbar](https://img.shields.io/badge/prerequisite-BitBar%202.0%20beta4-brightgreen.svg)](https://github.com/matryer/bitbar)
[![VBBar-api-vbb](https://img.shields.io/badge/api-VBB-orange.svg)](http://www.vbb.de/labs)
[![VBBar-api-mb](https://img.shields.io/badge/api-Mapbox-orange.svg)](https://www.mapbox.com/studio/signup/?plan=starter)
[![VBBar-depend-clcli](https://img.shields.io/badge/dependency-CoreLocationCLI%202.0.0-green.svg)](https://github.com/fulldecent/corelocationcli)
[![VBBar-depend-jq](https://img.shields.io/badge/dependency-jq%201.5-green.svg)](https://stedolan.github.io/jq/)
[![VBBar-depend-mapbox](https://img.shields.io/badge/dependency-mapbox%200.3.1-green.svg)](https://github.com/mapbox/mapbox-cli-py)
[![VBBar-depend-mlr](https://img.shields.io/badge/dependency-mlr%204.0.0-green.svg)](https://github.com/johnkerl/miller)
[![VBBar-depend-node](https://img.shields.io/badge/dependency-node%206.2.0-green.svg)](https://nodejs.org)
[![VBBar-depend-npm](https://img.shields.io/badge/dependency-npm%203.8.9-green.svg)](https://nodejs.org)
[![VBBar-depend-tnote](https://img.shields.io/badge/dependency-terminal--notifer%201.6.3-green.svg)](https://github.com/alloy/terminal-notifier)
[![VBBar-depend-vbbdep](https://img.shields.io/badge/dependency-vbb--dep%200.3.1-ff69b4.svg)](https://github.com/derhuerst/vbb-cli)
[![VBBar-depend-vbbst](https://img.shields.io/badge/dependency-vbb--stations%200.6.0-ff69b4.svg)](https://github.com/derhuerst/vbb-stations-cli)
[![VBBar-license](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/JayBrown/VBBar/blob/master/license.md)

# VBBar <img src="https://github.com/JayBrown/VBBar/blob/master/img/VBBar_icon.png" height="20px"/>

**BitBar plugin (shell script) to access and search the Berlin and Brandenburg public transportation information from the OS X menu bar**

![VBBar-screengrab](https://github.com/JayBrown/VBBar/blob/master/img/VBBar_grab.png)

## Current status
Alpha (pre-release)… the script is still pretty wild; if you know shell scripting, and if you have a bit of experience with the BitBar quirks, and if you know how to improve this thing, then make it so!

Minimum OS X for full functionality: **10.10**

## Prerequisites

### API tokens
First you need access keys/tokens for two APIs, one for the [VBB API](http://www.vbb.de/labs), and one for the public [Mapbox API](https://www.mapbox.com/studio/signup/?plan=starter).

For the former you need to apply by email, and you will receive an ID for the test API. This is usually only given out to developers, but if you plan on improving VBBar or vbb-cli/vbb-stations-cli, then getting an access ID shouldn't be a problem. Once the underlying software [vbb-cli](https://github.com/derhuerst/vbb-cli) is approved by VBB, VBBar should work without using an individual API access ID. (Fingers crossed.)

For the latter you just need to register for a free starter plan. Be sure to generate your own individual access token, i.e. don't use the Mapbox default public token. I'd prefer using a geocoding library/service that will work without API tokens, so if you know a better alternative, one that works like **mapbox** as a cli (bash), and one that also includes **automated walking directions** between two sets of coordinates, let us know.

The "Find Berlin Address" function currently does not use an API for street names, precincts and postal codes. It simply uses the cURL command on the public/free Berlin street database maintained by KAUPERTS. Eventually VBBar needs a more elegant solution in this regard.

### Manual installations
Install into `/Applications`
* [BitBar](https://github.com/matryer/bitbar): **v2 beta4** or higher needed
* Launch BitBar and set your BitBar plugins directory
* Quit BitBar

Install into `/usr/local/bin`
* [CoreLocationCLI](https://github.com/fulldecent/corelocationcli)
* Make executable with `chmod +x /usr/local/bin/CoreLocationCLI`
* Test CoreLocationCLI in your shell, e.g. with `CoreLocationCLI -h`
* If it doesn't work, dequarantine with `xattr -dr com.apple.quarantine /usr/local/bin/CoreLocationCLI`

### Homebrew installations (direct)
Install using [Homebrew](http://brew.sh)
* [mapbox](https://github.com/mapbox/mapbox-cli-py): `brew install mapbox/cli/mapbox`

### Homebrew installations (regular)
Install using [Homebrew](http://brew.sh) with `brew install <software-name>` (or with a similar manager) 

* [jq](https://stedolan.github.io/jq/)
* [miller](https://github.com/johnkerl/miller)
* [node](https://nodejs.org)
* [terminal-notifier](https://github.com/alloy/terminal-notifier)

You need to have Spotlight enabled for `mdfind` to locate the terminal-notifier.app on your volume; if you don't install terminal-notifier, or if you have deactivated Spotlight, VBBar will call notifications via AppleScript instead

### Node.js installations
After installing node, install the following software with `npm install -g <software-name>`
* [vbb-cli](https://github.com/derhuerst/vbb-cli): this will (among other things) put `vbb-dep` and `vbb-route` symlinks into `/usr/local/bin`
* [vbb-stations-cli](https://github.com/derhuerst/vbb-stations-cli)

## Installation

* [Download the main VBBar script and the VBBar subfolder containing the subscripts](https://github.com/JayBrown/VBBar/releases); expand the archive; move both main script and subfolder into your BitBar plugins directory
* Open your shell, `cd` to your BitBar plugins directory, and enter `chmod +x VBBar.30m.sh`
* Launch BitBar again; it should now load VBBar
* During load, VBBar will `chmod +x` the remaining subscripts
* Once you have your VBB and Mapbox access IDs/tokens, you can enter them in the VBBar submenu ("System"); they will be stored in the OS X keychain

## To-do

* If possible, use a tokenless geocoding alternative to Mapbox (bash/cli, address/coordinates geocoding incl. reverse, walking directions, walking distance)
* Refine address search, e.g. input house number directly; free alternative to kauperts Straßenverzeichnis => possible?
* When printer is selected (automatically or by user), script should check if printer is actually online (i.e. physically connected) => possible?
* Add functionality such as: previous searches, route to destination by departure/arrival time, favorite routes/stations/addresses
* sqlite db integration
* Add per-line information? E.g. all the stops for the U7 when clicked?
* Bundle VBBar with BitBarDistro and build an installer with Platypus including all prerequisites & dependencies?

## Why VBBar?

* There are people (like me) who don't have a smartphone, but need to look up public transportation information, manage routes/travel etc.
* There are people (like future me) who have a smartphone, but don't want to look at their smartphone every time they need public transportation information (and possibly get distracted by useless things in the process)

## Acknowledgements
VBBar wouldn't work without the awesome CLIs by [derhuerst](https://github.com/derhuerst?tab=repositories)

## Disclaimer (obligatory)
Powered by VBB GmbH. Subject to change. No liability assumed.

![VBB](https://github.com/JayBrown/VBBar/blob/master/img/VBB_logo.png)