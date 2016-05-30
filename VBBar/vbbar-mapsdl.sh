#!/bin/bash

# subscript for VBBar BitBar plugin
# DOWNLOAD OR UPDATE VBB NETWORK MAPS

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
PREFS="local.lcars.VBBar"
PREFS_DIR="${HOME}/Library/Preferences/VBBar"

MAP_REGIONAL_URL="http://images.vbb.de/assets/downloads/file/362037.pdf"
MAP_BERLINABC_URL="http://images.vbb.de/assets/downloads/file/277044.pdf"
MAP_BERLINNIGHT_URL="https://www.bvg.de/de/index.php?section=downloads&cmd=58&download=398"
MAP_BERLINABTRAM_URL="https://www.bvg.de/de/index.php?section=downloads&cmd=58&download=401"
MAP_BERLINAB_URL="https://www.bvg.de/de/index.php?section=downloads&cmd=58&download=400"

MAP_REGIONAL_VERSION="2016-04"
MAP_BERLINABC_VERSION="2016-01"
MAP_BERLINNIGHT_VERSION="2015-12"
MAP_BERLINABTRAM_VERSION="2016-04"
MAP_BERLINAB_VERSION="2016-01"

MAP_REGIONAL_FILE_BASE="$PREFS_DIR/Berlin-Brandenburg RE+RB"
MAP_BERLINABC_FILE_BASE="$PREFS_DIR/Berlin ABC S+U RE+RB TXL"
MAP_BERLINNIGHT_FILE_BASE="$PREFS_DIR/Berlin ABC Nighttime Services"
MAP_BERLINABTRAM_FILE_BASE="$PREFS_DIR/Berlin AB Tram"
MAP_BERLINAB_FILE_BASE="$PREFS_DIR/Berlin AB S+U RE+RB TXL"

MAP_REGIONAL_FILE="$MAP_REGIONAL_FILE_BASE ($MAP_REGIONAL_VERSION).pdf"
MAP_BERLINABC_FILE="$MAP_BERLINABC_FILE_BASE ($MAP_BERLINABC_VERSION).pdf"
MAP_BERLINNIGHT_FILE="$MAP_BERLINNIGHT_FILE_BASE ($MAP_BERLINNIGHT_VERSION).pdf"
MAP_BERLINABTRAM_FILE="$MAP_BERLINABTRAM_FILE_BASE ($MAP_BERLINABTRAM_VERSION).pdf"
MAP_BERLINAB_FILE="$MAP_BERLINAB_FILE_BASE ($MAP_BERLINAB_VERSION).pdf"

MAP_DOWNLOAD=""

if [[ "$1" == "initial" ]] ; then
	/usr/bin/curl -o "$MAP_REGIONAL_FILE" "$MAP_REGIONAL_URL" &> /dev/null
	/usr/bin/curl -o "$MAP_BERLINABC_FILE" "$MAP_BERLINABC_URL" &> /dev/null
	/usr/bin/curl -o "$MAP_BERLINNIGHT_FILE" "$MAP_BERLINNIGHT_URL" &> /dev/null
	/usr/bin/curl -o "$MAP_BERLINABTRAM_FILE" "$MAP_BERLINABTRAM_URL" &> /dev/null
	/usr/bin/curl -o "$MAP_BERLINAB_FILE" "$MAP_BERLINAB_URL" &> /dev/null
	MAP_DOWNLOAD="true"
elif [[ "$1" == "update" ]] ; then
	if [[ ! -e "$MAP_REGIONAL_FILE" ]] ; then
		rm -rf "$MAP_REGIONAL_FILE_BASE"*.pdf &> /dev/null
		MAP_DOWNLOAD="true"
		/usr/bin/curl -o "$MAP_REGIONAL_FILE" "$MAP_REGIONAL_URL" &> /dev/null
	fi
	if [[ ! -e "$MAP_BERLINABC_FILE" ]] ; then
		rm -rf "$MAP_BERLINABC_FILE_BASE"*.pdf &> /dev/null
		MAP_DOWNLOAD="true"
		/usr/bin/curl -o "$MAP_BERLINABC_FILE" "$MAP_BERLINABC_URL" &> /dev/null
	fi
	if [[ ! -e "$MAP_BERLINNIGHT_FILE" ]] ; then
		rm -rf "$MAP_BERLINNIGHT_FILE_BASE"*.pdf &> /dev/null
		MAP_DOWNLOAD="true"
		/usr/bin/curl -o "$MAP_BERLINNIGHT_FILE" "$MAP_BERLINNIGHT_URL" &> /dev/null
	fi
	if [[ ! -e "$MAP_BERLINABTRAM_FILE" ]] ; then
		rm -rf "$MAP_BERLINABTRAM_FILE_BASE"*.pdf &> /dev/null
		MAP_DOWNLOAD="true"
		/usr/bin/curl -o "$MAP_BERLINABTRAM_FILE" "$MAP_BERLINABTRAM_URL" &> /dev/null
	fi
	if [[ ! -e "$MAP_BERLINAB_FILE" ]] ; then
		rm -rf "$MAP_BERLINAB_FILE_BASE"*.pdf &> /dev/null
		MAP_DOWNLOAD="true"
		/usr/bin/curl -o "$MAP_BERLINAB_FILE" "$MAP_BERLINAB_URL" &> /dev/null
	fi
else
	MAP_DOWNLOAD="false"
fi

if [[ "$MAP_DOWNLOAD" == "true" ]] ; then
	/usr/bin/open "bitbar://refreshPlugin?name=VBBar.*?.sh"
	exit
fi