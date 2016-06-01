#!/bin/bash

# <bitbar.title>VBBar</bitbar.title>
# <bitbar.version>v0.1 alpha1</bitbar.version>
# <bitbar.author>Joss Brown</bitbar.author>
# <bitbar.author.github>https://github.com/JayBrown</bitbar.author.github>
# <bitbar.desc>Access and search the Berlin and Brandenburg public transportation information from the OS X menu bar.</bitbar.desc>
# <bitbar.image>https://github.com/JayBrown/VBBar/blob/master/img/VBBar_grab.png</bitbar.image>
# <bitbar.dependencies>CoreLocationCLI,jq,mapbox,mlr,node,npm,terminal-notifier,vbb-dep,vbb-route,vbb-stations</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/JayBrown/VBBar/blob/master/README.md</bitbar.abouturl>
# <bitbar.droptypes>public.vcard</bitbar.droptypes>

####################
# SCRIPT FUNCTIONS #
####################

deg2rad () {
    bc -l <<< "$1 * 0.0174532925"
}

rad2deg () {
    bc -l <<< "$1 * 57.2957795"
}

acos () {
    pi="3.141592653589793"
    bc -l <<< "$pi / 2 - a($1 / sqrt(1 - $1 * $1))"
}

distance () {
    lat_1="$1"
    lon_1="$2"
    lat_2="$3"
    lon_2="$4"
    
    delta_lat=$(bc <<< "$lat_2 - $lat_1")
    delta_lon=$(bc <<< "$lon_2 - $lon_1")
    
    lat_1="$(deg2rad $lat_1)"
    lon_1="$(deg2rad $lon_1)"
    lat_2="$(deg2rad $lat_2)"
    lon_2="$(deg2rad $lon_2)"
    
    delta_lat="$(deg2rad $delta_lat)"
    delta_lon="$(deg2rad $delta_lon)"

    distance=$(bc -l <<< "s($lat_1) * s($lat_2) + c($lat_1) * c($lat_2) * c($delta_lon)")
    distance=$(acos $distance)
    distance="$(rad2deg $distance)"
    distance=$(bc -l <<< "$distance * 60 * 1852")
    distance=$(bc <<< "scale=4; $distance / 1")
    echo $distance
}

notify () {
 	if [[ "$NOTESTATUS" == "osa" ]] ; then
		/usr/bin/osascript -e 'display notification "$2" with title "VBBar" subtitle "$1"' &>/dev/null
	elif [[ "$NOTESTATUS" == "tn" ]] ; then
		"$TERMNOTE_LOC/Contents/MacOS/terminal-notifier" \
			-title "VBBar" \
			-subtitle "$1" \
			-message "$2" \
			-appIcon "$VBB_LOGOSMALL_FILE" \
			>/dev/null
	fi
}

####################
# INITIAL SETTINGS #
####################

# menu bar icon in base64
TEMPLATE_ICON="iVBORw0KGgoAAAANSUhEUgAAAB4AAAAkCAQAAAA02ELiAAAACXBIWXMAABYlAAAWJQFJUiTwAAABKklEQVR4nOyWTwqCQBTGxzSDFErdRIeILtBB2gatuk6roG0H6QLRIaJN/0CDTNPm+TJTdMaZWsYHOm/m/eZ7jPiUPBrLSeumRPVFYtB8Fqpk17dOposTIjK8XZ/MZ1oAgQgJFy1YTOmgeRdDEQfqddsOxPSGv1Dz3njIodQbB9UHU71CBc+NdarVa5T8w4IwO+EP/xbGnnS0y8ReSZzTliYhafATVkPdrwPovhrmYOglOGZ3FcByeTi9HsFtM+T5FuqF/eqewWeQeEMJ6YSv8+BAK8Al5VRqNS6UneE8tCSvDlK+DTk4cnhMSeKa+56M8b7nmtT14ETKtX1te8alc+6ydel4BuRGCvWNCX6dUUeb53eysiAhs9AzeHCkwFuIPxcxeQIAAP//AwA4xzQFWXpCfwAAAABJRU5ErkJggg=="

# initial settings
LANG=en_US.UTF-8
ACCOUNT=$(who am i | /usr/bin/awk {'print $1'})
export PATH=/usr/local/bin:$PATH
BASE_NAME=$(basename $0)
CURRENT_VERSION="0.1"
BETA="alpha1"
DEP_TEMP_LOC="/tmp/vbb-dep~temp.txt"
if [[ ! -e "$DEP_TEMP_LOC" ]] ; then
	touch "$DEP_TEMP_LOC"
fi

# VBB logo in base64
VBB_LOGO64="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"

# VBB small logo in base64
VBB_LOGOSMALL64="iVBORw0KGgoAAAANSUhEUgAAAEMAAABICAAAAACIZhdsAAAACXBIWXMAABYlAAAW
JQFJUiTwAAAAAnRSTlMA/1uRIrUAAAWISURBVHiczJd7UJRVFMAv74eKrIuhMBJI
ETiJjag55ow5KhYPG7CcIGsGAzUjc7IaQrChslJ8TAVURP9gSRRhgmMaMCoMEojm
C0SBlnRKYYJVMFkE9nTv+Z6737f7rTv90fljz7nnnvvb+93HufcS0JKcoK0l1Wd7
zbYjiLrb3FGytoQz3yFU3KYu2LC/+34YXbsX+xKSJGOgTFpW8IeDjJOpk7FJlMmK
QUX/crM2w3wiwZWP9+1SMgjxXNOqxRiPl8Kr1BiUvfmGxre0eIvBeeoMQsIrNMZj
vRj6DJbfVDKIy2tD6gwjp3oChMjZw6zcmL/9lbhIXyvKEoMaoz6qnDN2YFDourKr
42Ll8NUDaQ9aQB5uVTKOTSFTWtC6FUE8EiqMio8cKH/KTQaZ3mjNqPOn7ojraH+T
dEoB4Pu6SgYJFJYKzzgbiO6ld2w0FuXgLAkS0iFnXIvk3WljWpC/N0qQuf0yxlbR
vVOLAfD1JDE6ZVxi9GbwzhnHtRlQFyhCiiQGwFf+OKHnHUAA/DpdYOguyxhwOoaO
9BmHEAANOgGSMC5fYwNpE484iAD4wV2A/Gi5X845jKAZUmA8dtdWLtSU4cUCpNRp
Bpz2ERaJyWkGvKUP4KTeeca9m5zcGHKeIcl/yvg9I53Kpl5mFzJz3VHYno6SsTm/
HvfiaI7oaBhTYVzkRpltZ8MEZvl0/ekpbdHlBvY/4soiLisMSsZ1PJi8GSMbo3Lg
sCzhkNhRgJ/kjpWjCoYxmFV40T3UF8Ss4F7IlTfx7rI6Jny6FQwTpiHPdoC9GLIL
YCXT8yo/m4Y1lL6MGQsqP30A/+6KgmFeiJFtMPQIM8KNfM+2AaxjOuQ29CPsXYAX
mQ4bUjDgaVbhcRFKsRtfADTjwVsF5seZTqcnDTqOwPg8pjcqxxTWsgr3i2MLmJ79
D51h/OrGtkwXqv3bAD5hDt+mS5uY1nWoMF5HxpUa1oIcAL7Hrv5eTOkrqSMFHTp0
BBxSWR/wPqtyu5TI1MIRgJFHpTkI+00cdU7CL4Aaowi7XsiOfZfDtNwpO2I9NtDF
0CHdCIjnq2rrFMqREcV+l7OACuxXyvo52KgO4Dv82FTecUKNUSP+iTvW451hxggY
cAHnA2xhOnQUuvF82aPGaBXuUNxlzryEmXF0E2CTIjA/wfQqernA7VSoxugUkpsX
3gr6pjJ7F599XZvgpp4ZewGy0HFKjcHFUHkJiydxjp/dFo/dm2uCOqxcsy0OK2JM
aoyhUA4xsR2Lu4lMXOn17mMLR7Xq3I5Gc9WZXPE5WQt3OqKQJHfIRtQiF+K2IJN7
uF4FSWvhyZ+pY1A6qL2WHgMbjP05ubm5Od9zhYH3cjnZUXoer/v9eaLjgtX9/3+T
128bb3Fi54GixagMCuZkl/OMwZn8aOuuOs3gUzCVRM07oU3GQJgA2Xcf7S5ZMKBY
YPjWOow45Cd7OVCGaZEACXLsWkhTPn1bLG6TMaBJ2PXkoXaHEGdmsODAMhkD8sSt
MLPFAURNMBfs8oZRYphiRUhAhd3mKNlidJ7EgGvh0rbOGrLXHv8ymY+N/kvGgGa9
CCHza7Qg/TEYGMxPsLDnjkqPAeKWqnjC8tK4mstfHWxE9A1gyYAqP1me8l5drfwi
Y0W8B4m5i3bdBDL1OFgzoHYakUtE5sGee2LleHd5OreeP+ccX0Y2gZIB5+YQS/GL
Tt7yUQE7auFOlOAM6ePHBNQY0PcCURFu/laI5SzFR1rmseJAJeNDrHlb6t1l+wzo
XOumziiTHKnWGU+RT2tjVRkXPPiia2K9JgPMvyRPUDIGuZe6X8oJRQP1vN7+wXxP
Kwa7V/os2qmaL22cDWPnC56fNUnO2JdS3GYj9ds5X0yG+m+zdQLDjvwLAAD//wMA
gc7nz8Sn8FcAAAAASUVORK5CYII="

# preferences
PREFS_DIR="${HOME}/Library/Preferences/VBBar"
PREFS="local.lcars.VBBar"
PREFS_FILE="${HOME}/Library/Preferences/$PREFS.plist"

# VBB logo
VBB_LOGO64_FILE="$PREFS_DIR/VBBLogo.base64"
VBB_LOGO="VBBLogo.png"
VBB_LOGO_FILE="$PREFS_DIR/$VBB_LOGO"

# VBB small logo
VBB_LOGOSMALL64_FILE="$PREFS_DIR/VBBLogoSmall.base64"
VBB_LOGOSMALL="VBBLogoSmall.png"
VBB_LOGOSMALL_FILE="$PREFS_DIR/$VBB_LOGOSMALL"

# network maps settings
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

# check for existence of preferences directory, preferences, logo files
if [[ ! -e "$PREFS_FILE" ]] ; then
	touch "$PREFS_FILE"
fi
if [[ ! -e "$PREFS_DIR" ]] ; then
	mkdir -p "$PREFS_DIR"
	echo "$VBB_LOGO64" > "$VBB_LOGO64_FILE"
	/usr/bin/base64 -D -i "$VBB_LOGO64_FILE" -o "$VBB_LOGO_FILE"
	rm -rf "$VBB_LOGO64_FILE"
	echo "$VBB_LOGOSMALL64" > "$VBB_LOGOSMALL64_FILE"
	/usr/bin/base64 -D -i "$VBB_LOGOSMALL64_FILE" -o "$VBB_LOGOSMALL_FILE"
	rm -rf "$VBB_LOGOSMALL64_FILE"
else
	if [[ -e "$VBB_LOGO64_FILE" ]] ; then
		rm -rf "$VBB_LOGO64_FILE"
	fi
	if [[ ! -e "$VBB_LOGO_FILE" ]] ; then
		if [[ ! -e "$VBB_LOGO64_FILE" ]] ; then
			echo "$VBB_LOGO64" > "$VBB_LOGO64_FILE"
			/usr/bin/base64 -D -i "$VBB_LOGO64_FILE" -o "$VBB_LOGO_FILE"
			rm -rf "$VBB_LOGO64_FILE"
		else
			/usr/bin/base64 -D -i "$VBB_LOGO64_FILE" -o "$VBB_LOGO_FILE"
			rm -rf "$VBB_LOGO64_FILE"
		fi
	fi
	if [[ -e "$VBB_LOGOSMALL64_FILE" ]] ; then
		rm -rf "$VBB_LOGOSMALL64_FILE"
	fi
	if [[ ! -e "$VBB_LOGOSMALL_FILE" ]] ; then
		if [[ ! -e "$VBB_LOGOSMALL64_FILE" ]] ; then
			echo "$VBB_LOGOSMALL64" > "$VBB_LOGOSMALL64_FILE"
			/usr/bin/base64 -D -i "$VBB_LOGOSMALL64_FILE" -o "$VBB_LOGOSMALL_FILE"
			rm -rf "$VBB_LOGOSMALL64_FILE"
		else
			/usr/bin/base64 -D -i "$VBB_LOGOSMALL64_FILE" -o "$VBB_LOGOSMALL_FILE"
			rm -rf "$VBB_LOGOSMALL64_FILE"
		fi
	fi
fi

# determine full path to script
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]] ; do
	DIR="$(cd -P "$(/usr/bin/dirname "$SOURCE")" && pwd)"
	SOURCE="$(/usr/bin/readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
BITBAR_DIR="$(cd -P "$(/usr/bin/dirname "$SOURCE")" && pwd)"
SCRIPT_PATH="$BITBAR_DIR/$BASE_NAME"
SUBSCR="$BITBAR_DIR/VBBar"
if [[ ! -e "$SUBSCR" ]] ; then
	mkdir "$SUBSCR"
fi

# locate terminal-notifier.app
TERMNOTE_LOC=$(/usr/bin/mdfind kMDItemCFBundleIdentifier = "nl.superalloy.oss.terminal-notifier" 2>/dev/null)
if [[ "$TERMNOTE_LOC" == "" ]] ; then
	NOTESTATUS="osa"
else
	NOTESTATUS="tn"
fi

# Write globals to preferences
defaults write "$PREFS" name "$BASE_NAME"
defaults write "$PREFS" noteStatus "$NOTESTATUS"
defaults write "$PREFS" tnLocation "$TERMNOTE_LOC"
defaults write "$PREFS" BitBarDir "$BITBAR_DIR"

# chmod subscripts
cd "$SUBSCR" && for SUBSCRIPT in "vbbar-"*".sh"
do
	/bin/chmod +x "$SUBSCRIPT" &>/dev/null
done

# Menu bar title
echo "| templateImage=$TEMPLATE_ICON dropdown=false"

# Menu bar separator
echo "---"

# check if computer is online
PING_FREQ="3"
((COUNT = $PING_FREQ))
while [[ $COUNT -ne 0 ]] ; do
    ping -q -c 1 8.8.8.8 &> /dev/null
    RC=$?
    if [[ $RC -eq 0 ]] ; then
        ((COUNT = 1))
    fi
    ((COUNT = COUNT - 1))
done
if [[ $RC -eq 0 ]] ; then
	CURRENT_INTERNET_STATUS="online"
else
	CURRENT_INTERNET_STATUS="offline"
fi

# check Airport/WiFi status
AIRPORT_STATUS=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I)
if [[ "$AIRPORT_STATUS" == "AirPort: Off" ]] ; then
	WIFI_STATUS="inactive"
else
	WIFI_STATUS=$(echo "$AIRPORT_STATUS" | /usr/bin/awk '/state: / {print $2}') # init | running
fi

# check interface, SSID & BSSID
INTERFACE=$(route get 0.0.0.0 2>/dev/null | /usr/bin/awk '/interface: / {print $2}')
if [[ "$WIFI_STATUS" == "running" ]] ; then
	if [[ "$INTERFACE" == "" ]] ; then
		INTERFACE="n/a"
		SSID="n/a"
	else
		SSID=$(networksetup -getairportnetwork "$INTERFACE" | /usr/bin/awk '/Current/ {print substr($0, index($0,$4))}')
		if [[ "$SSID" == "" ]] ; then
			SSID="n/a"
		fi
	fi
	BSSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | /usr/bin/awk '/BSSID: / {print $2}' | /usr/bin/tr '[:lower:]' '[:upper:]')
	if [[ "$BSSID" == "" ]] ; then
		BSSID="n/a"
	fi
else
	INTERFACE="n/a"
	SSID="n/a"
	BSSID="n/a"
fi

# check for VBB API access key
API_ID=$(/usr/bin/security 2>&1 >/dev/null find-generic-password -s VBBar_vbb -ga "$ACCOUNT" | /usr/bin/ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/' | xargs)
if [[ "$API_ID" == "" ]] ; then
	VBB_NOTIFIED=$(defaults read "$PREFS" vbbKeyNotified 2>/dev/null)
	if [[ "$VBB_NOTIFIED" == "" ]] ; then
		notify "No VBB API access" "Enter key in VBBar submenu"
		defaults write "$PREFS" vbbKeyNotified "true"
	fi
	VBB_STATUS="n/a"
else
	export NODE_CONFIG='{ "key": "'"$API_ID"'" }'
	VBB_STATUS="true"
fi

# check for Mapbox API access token
MB_TOKEN=$(/usr/bin/security 2>&1 >/dev/null find-generic-password -s VBBar_mapbox -ga "$ACCOUNT" | /usr/bin/ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/' | xargs)
if [[ "$MB_TOKEN" == "" ]] ; then
	MB_NOTIFIED=$(defaults read "$PREFS" mbKeyNotified 2>/dev/null)
	if [[ "$MB_NOTIFIED" == "" ]] ; then
		notify "No Mapbox API access" "Enter token in VBBar submenu"
		defaults write "$PREFS" mbKeyNotified "true"
	fi
	MB_STATUS="n/a"
else
	export MAPBOX_ACCESS_TOKEN=$MB_TOKEN
	MB_STATUS="true"
fi

# determine current location
CURRENT_LOCATION=""
if [[ "$WIFI_STATUS" == "init" ]] || [[ "$WIFI_STATUS" == "running" ]]; then
	while [[ $(echo "$CURRENT_LOCATION") == "" ]]
	do
		CURRENT_LOCATION=$(/usr/local/bin/CoreLocationCLI -once YES -format '%latitude@@@%longitude' 2>/dev/null)
		sleep .5
	done
	CURRENT_LAT=$(echo "$CURRENT_LOCATION" | /usr/bin/awk -F"@@@" '{print $1}')
	CURRENT_LONG=$(echo "$CURRENT_LOCATION" | /usr/bin/awk -F"@@@" '{print $2}')
	CURRENT_COORD="$CURRENT_LAT,$CURRENT_LONG"
else
	CURRENT_LAT="n/a"
	CURRENT_LONG="n/a"
fi

# uncomment for testing or edit in your own lat/long

# Berliner Philharmonie
# CURRENT_LAT="52.510032"
# CURRENT_LONG="13.369693"
# CURRENT_COORD="$CURRENT_LAT,$CURRENT_LONG"

# Haus des Lehrers
# CURRENT_LAT="52.521389"
# CURRENT_LONG="13.416389"
# CURRENT_COORD="$CURRENT_LAT,$CURRENT_LONG"

# Landwehrkanal
# CURRENT_LAT="52.496112"
# CURRENT_LONG="13.421249"
# CURRENT_COORD="$CURRENT_LAT,$CURRENT_LONG"

# Spree/Jannowitzbrücke
# CURRENT_LAT="52.513056"
# CURRENT_LONG="13.419722"
# CURRENT_COORD="$CURRENT_LAT,$CURRENT_LONG"

# get address & check for correct region
if [[ "$CURRENT_INTERNET_STATUS" == "online" ]] ; then
	if [[ "$MB_STATUS" == "true" ]] ; then
		CURRENT_GMAPS=$(/usr/local/bin/mapbox geocoding --reverse "[$CURRENT_LONG, $CURRENT_LAT]" -t address)
		CURRENT_ADDR=$(echo "$CURRENT_GMAPS" | /usr/local/bin/jq '.features[0] .place_name' -M -r)
	else
		CURRENT_GMAPS=$(/usr/bin/curl -sG --data-urlencode 'address='"$CURRENT_COORD"'' 'http://maps.googleapis.com/maps/api/geocode/json?sensor=false')
		sleep 1
		CURRENT_ADDR=$(echo "$CURRENT_GMAPS" | /usr/local/bin/jq '.results[0].formatted_address')
	fi
	if [[ (($CURRENT_LAT>53.559955)) ]] || [[ (($CURRENT_LAT<51.359063)) ]] || [[ (($CURRENT_LONG>14.765478)) ]] || [[ (($CURRENT_LONG<11.268721)) ]] ; then
		REGION="false"
	else
		REGION="true"
	fi
else
	CURRENT_ADDR="n/a"
fi

#############
# MAIN MENU #
#############

echo "---"

# future functionality -- IN FLUX

echo "Favorites"
echo "Routes"
echo "Destinations"
echo "Departures"

echo "---"

echo "Find"
echo "VBB Station"
echo "--As Destination"
echo "--As Departure"
echo "-----"
echo "--Previous Stations"
echo "-----"
echo "--Add to Favorites"
echo "--Clear"
echo "Berlin Address"
echo "--As Destination | terminal=false bash=$SUBSCR/vbbar-findaddr.sh param1=dest" # still raw alpha, will be extended
echo "--As Departure | terminal=false bash=$SUBSCR/vbbar-findaddr.sh param1=dep" # still raw alpha, will be extended
echo "-----"
echo "--Previous Addresses"
echo "-----"
echo "--Add to Favorites"
echo "--Clear"

echo "---"

# nearby stations submenus
echo "Nearby Departures"
if [[ "$REGION" == "false" ]] ; then
	echo "[Out of Region] | color=brown"
elif [[ "$WIFI_STATUS" == "inactive" ]] ; then
	echo "[Wi-Fi Inactive] | color=red"
else
	NEARBY_TOGGLE=$(defaults read "$PREFS" nearbyDepartures 2>/dev/null)
	if [[ "$NEARBY_TOGGLE" == "" ]] ; then
		NEARBY_TOGGLE="on"
		defaults write "$PREFS" nearbyDepartures "$NEARBY_TOGGLE"
	fi
	DISABLED_NEARBY=$(defaults read "$PREFS" disabledNearby -array 2>/dev/null | /usr/bin/sed 's/[(,)]//g' | /usr/bin/sed '/^$/d' | /usr/bin/sed "s/^[ \t]*//")
	LATRAD_BASE=".0044992351" # 500m
	LONGRAD_BASE=".0069988802" # 500m
	NEARBY_RANGE=$(defaults read "$PREFS" nearbyRange 2>/dev/null)
	if [[ "$NEARBY_RANGE" == "" ]] ; then
		NEARBY_RANGE="500"
		defaults write "$PREFS" nearbyRange "$NEARBY_RANGE"
	fi
	RANGE_FACTOR=$(bc -l <<< "$NEARBY_RANGE / 500")
	LATRAD=$(bc -l <<< "$LATRAD_BASE * $RANGE_FACTOR")
	LONGRAD=$(bc -l <<< "$LONGRAD_BASE * $RANGE_FACTOR")
	NEARBY_STATIONS=""
	while [[ $(echo "$NEARBY_STATIONS") == "" ]]
	do
		NEARBY_STATIONS=$(/usr/local/bin/vbb-stations \
			"(s) => s.latitude > $CURRENT_LAT - $LATRAD" "(s) => s.latitude < $CURRENT_LAT + $LATRAD" \
			"(s) => s.longitude > $CURRENT_LONG - $LONGRAD" "(s) => s.longitude < $CURRENT_LONG + $LONGRAD" \
			--format csv | \
			/usr/local/bin/mlr --icsv --onidx --ofs @ --rs lf cut -f id,name,latitude,longitude)
		LAT_ADD=".0044992351"
		LONG_ADD=".0069988802"
		LATRAD=$(bc -l <<< "$LATRAD + $LAT_ADD")
		LONGRAD=$(bc -l <<< "$LONGRAD + $LONG_ADD")
	done
	LATRAD=$(bc -l <<< "$LATRAD - .00224961755")
	LONGRAD=$(bc -l <<< "$LONGRAD - .0034994401")
	NEARBY_LIST=$(echo "$NEARBY_STATIONS" | /usr/bin/awk -F"@" '{print $1" | "$2}')
	NEARBY_ID_LIST=$(echo "$NEARBY_STATIONS" | /usr/bin/awk -F"@" '{print $1}')
	echo "$NEARBY_ID_LIST" | while IFS= read -r STATION_ID
	do
		echo -n "" > "$DEP_TEMP_LOC"
		DISABLED_STATUS=""
		while IFS= read -r DISABLED_STATION
		do
			if [[ "$DISABLED_STATION" == "$STATION_ID" ]] ; then
				DISABLED_STATUS="true"
			fi
		done < <(echo "$DISABLED_NEARBY")
		STATION_RAW=$(/usr/local/bin/vbb-stations --id $STATION_ID --format csv)
		STATION_NAME=$(echo "$STATION_RAW" | /usr/local/bin/mlr --icsv --onidx --ofs @ --rs lf cut -f name)
		STATION_LINES_RAW=$(echo "$STATION_RAW" | /usr/local/bin/mlr --icsv --onidx --ofs @ --rs lf cut -f lines)
		STATION_LINES=$(echo "$STATION_LINES_RAW" | /usr/bin/tr , ' ' | xargs -n 1 | /usr/bin/sort -u | xargs)
		STATION_LAT=$(echo "$STATION_RAW" | /usr/local/bin/mlr --icsv --onidx --ofs @ --rs lf cut -f latitude)
		STATION_LONG=$(echo "$STATION_RAW" | /usr/local/bin/mlr --icsv --onidx --ofs @ --rs lf cut -f longitude)
		STATION_COORD="$STATION_LAT,$STATION_LONG"
		if [[ "$CURRENT_INTERNET_STATUS" == "online" ]] && [[ "$DISABLED_STATUS" != "true" ]] ; then
			if [[ "$MB_STATUS" == "true" ]] ; then
				STATION_GMAPS=$(/usr/local/bin/mapbox geocoding --reverse "[$STATION_LONG, $STATION_LAT]" -t address)
				STATION_ADDR=$(echo "$STATION_GMAPS" | /usr/local/bin/jq '.features[0] .place_name' -M -r)
			else
				STATION_GMAPS=$(/usr/bin/curl -sG --data-urlencode 'address='"$STATION_COORD"'' 'http://maps.googleapis.com/maps/api/geocode/json?sensor=false')
				sleep 1
				STATION_ADDR=$(echo "$STATION_GMAPS" | /usr/local/bin/jq '.results[0].formatted_address' -M -r)
			fi
		elif [[ "$DISABLED_STATUS" == "true" ]] ; then
			STATION_ADDR="n/a"
		else
			STATION_ADDR="n/a"
		fi
		ADDR_SUBSTRING="Berlin, "
		if [[ "$STATION_ADDR" == *"$ADDR_SUBSTRING"* ]] ; then
			STATION_ADDR="${STATION_ADDR//$ADDR_SUBSTRING}"
		fi
		DISTANCE=$(distance $CURRENT_LAT $CURRENT_LONG $STATION_LAT $STATION_LONG)
		if [[ "$MB_STATUS" == "true" ]] && [[ "$DISABLED_STATUS" != "true" ]] ; then
			MB_DIRECTIONS=$(/usr/local/bin/mapbox directions "[$CURRENT_LONG, $CURRENT_LAT]" "[$STATION_LONG, $STATION_LAT]" --profile mapbox.walking --alternatives)
			WDISTANCE=$(echo "$MB_DIRECTIONS" | /usr/local/bin/jq '.routes[0] .distance' -M -r)
			WALK_TIME=$(bc <<< "$(echo "$MB_DIRECTIONS" | /usr/local/bin/jq '.routes[0] .duration' -M -r) / 60")
		else
			WALK_TIME=$(bc <<< "$DISTANCE / 50")
			WDISTANCE="n/a"
		fi
		if [[ "$WALK_TIME" == "" ]] ; then
			WALK_TIME="9"
		fi
		WALK_TIME=$(bc <<< "$WALK_TIME + 1")
		if [[ "$CURRENT_INTERNET_STATUS" == "online" ]] ; then
			if [[ "$NEARBY_TOGGLE" == "off" ]] || [[ "$DISABLED_STATUS" == "true" ]] ; then
				DEPARTURES=""
				LAST_REFRESH="n/a"
				REFRESH_DATE="n/a"
			elif [[ "$NEARBY_TOGGLE" == "on" ]] ; then
				QUERY_TIME=$(date -v +"$WALK_TIME"M +%T)
				DEPARTURES=$(/usr/local/bin/vbb-dep "$STATION_ID" -w "$QUERY_TIME" -r 20 2>/dev/null | /usr/bin/sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g')
				LAST_REFRESH=$(date +"%T %Z")
				REFRESH_DATE=$(date +"%a %e %B %Y")
			fi	
		else
			DEPARTURES=""
			LAST_REFRESH="n/a"
			REFRESH_DATE="n/a"
		fi
		SUBSTRING=" (Berlin)"
		if [[ "$STATION_NAME" != *"$SUBSTRING"* ]] ; then
			echo "$STATION_NAME | length=40"
		else
			echo "${STATION_NAME//$SUBSTRING} | length=40"
		fi
		echo "--$STATION_NAME"
		echo "--ID: $STATION_ID | alternate=true"
		echo "--$STATION_LINES"
		echo "-----"
		if [[ "$DEPARTURES" == "" ]] ; then
			if [[ "$NEARBY_TOGGLE" == "off" ]] && [[ "$DISABLED_STATUS" == "" ]] ; then
				echo "--Nearby departures disabled by user. | font=AndaleMono size=12 color=brown"
			elif [[ "$DISABLED_STATUS" == "true" ]] ; then
				echo "--Station updates & information disabled by user. | font=AndaleMono size=12 color=blue"
			else
				echo "--No data available. | font=AndaleMono size=12 color=red"
			fi
		else
			echo "$DEPARTURES" | while IFS= read -r DEPARTURE
			do
				MODE=$(echo "$DEPARTURE" | /usr/bin/awk '{print $1}')
				if [[ "$MODE" == "U" ]] ; then
					MODE_COLOR="#0015FF" # blue
				elif [[ "$MODE" == "S" ]] ; then
					MODE_COLOR="#00600E" # green
				elif [[ "$MODE" == "T" ]] ; then
					MODE_COLOR="#C80000" # red
				elif [[ "$MODE" == "R" ]] ; then
					MODE_COLOR="#4F4F4F" # gray
				elif [[ "$MODE" == "B" ]] ; then
					MODE_COLOR="#A100C1" # magenta
				elif [[ "$MODE" == "F" ]] ; then
					MODE_COLOR="#005BAB" # lighter blue
				else
					MODE_COLOR="#000000" # black
				fi
				DEP_COUNT=$(echo "$DEPARTURE" | /usr/bin/awk '{print $3}' | /usr/bin/tr '[:lower:]' '[:upper:]' | xargs 2>/dev/null)
				DEP_DELAY=$(echo "$DEPARTURE" | /usr/bin/awk '{print $4}' | /usr/bin/tr '[:lower:]' '[:upper:]' | xargs 2>/dev/null)
				if [[ "$DEP_COUNT" != "" ]] && [[ "$DEPARTURE" != "No departures." ]]; then
					if [[ "$DEP_COUNT" != "-"* ]] ; then
						DEP_COUNT=$(echo "+$DEP_COUNT")
					fi
					if [[ "$DEP_DELAY" == "-"* ]] || [[ "$DEP_DELAY" == "+"* ]] ; then
						DEP_TIME_ADD=$(echo "$DEP_DELAY")
					else
						DEP_TIME_ADD="+0M"
					fi
					DEP_CALC=$(date -v $DEP_COUNT -v $DEP_TIME_ADD +"%H:%M")
					DEP_TIME="est dep $DEP_CALC"
					if [[ "$DEP_COUNT" == *"H" ]] || [[ "$DEP_COUNT" == *"D" ]] ; then
						DEP_TIME="est dep ––:––"
					fi
				elif [[ "$DEPARTURE" == "No departures." ]] ; then
					DEP_TIME=""
				else
					DEP_TIME="est dep ––:––"
				fi
				DEPARTURE_FULL=$(echo "$DEPARTURE  $DEP_TIME")
				echo "$DEPARTURE_FULL" >> "$DEP_TEMP_LOC"
				echo "--$DEPARTURE_FULL | color=$MODE_COLOR font=AndaleMono size=12"
			done
		fi
		echo "-----"
		if [[ "$DISABLED_STATUS" != "true" ]] ; then
			if [[ "$NEARBY_TOGGLE" != "off" ]] ; then
				echo "--Last Refresh at $LAST_REFRESH on $REFRESH_DATE"
				echo "-----"
			fi
		fi
		echo "--Address: ${STATION_ADDR//\"}"
		echo "--Coordinates: $STATION_LAT, $STATION_LONG | alternate=true"
		if [[ "$DISTANCE" == "1" ]] ; then
			LDPLURAL=""
		else
			LDPLURAL="s"
		fi
		if [[ "$WDISTANCE" == "1" ]] ; then
			WDPLURAL=""
		else
			WDPLURAL="s"
		fi
		if [[ "$WALK_TIME" == "1" ]] ; then
			TPLURAL=""
		else
			TPLURAL="s"
		fi
		if [[ "$MB_STATUS" != "true" ]] || [[ "$DISABLED_STATUS" == "true" ]]; then
			echo "--Walking Distance: n/a"
			echo "--Linear Distance: $DISTANCE Meter$LDPLURAL | alternate=true"		
		else
			echo "--Walking Distance: $WDISTANCE Meter$WDPLURAL"
			echo "--Linear Distance: $DISTANCE Meter$LDPLURAL | alternate=true"		
		fi
		echo "--Approximate Walking Time: $WALK_TIME Minute$TPLURAL"
		if [[ "$MB_STATUS" == "true" ]] ; then
			MB_INSTRUCTIONS=$(echo "$MB_DIRECTIONS" | /usr/local/bin/jq '.routes[0].steps[] .maneuver.instruction' -M -r)
			MB_DISTANCES=$(echo "$MB_DIRECTIONS" | /usr/local/bin/jq '.routes[0].steps[] .distance' -M -r)
			DIRECTIONS=$(/usr/bin/paste <(echo "$MB_DISTANCES") <(echo " ") <(echo "$MB_INSTRUCTIONS"))
		else
			DIRECTIONS="No walking directions available. Please install mapbox and enter your API access token."
		fi
		DEP_MERGE=$(/bin/cat "$DEP_TEMP_LOC")
		if [[ "$DEP_MERGE" == "" ]] ; then
			if [[ "$NEARBY_TOGGLE" == "off" ]] && [[ "$DISABLED_STATUS" == "" ]] ; then
				DEP_MERGE="Nearby departures disabled by user."
			elif [[ "$DISABLED_STATUS" == "true" ]] ; then
				DEP_MERGE="Station updates & information disabled by user."
				DIRECTIONS="No walking directions available."
			else
				DEP_MERGE="No data available."
			fi
		fi
		echo "DEPARTURES
From station: $STATION_NAME
Operating lines: $STATION_LINES
Station ID: $STATION_ID
Accessed at $LAST_REFRESH on $REFRESH_DATE

$DEP_MERGE

WALKING DISTANCES (IN METERS) & DIRECTIONS
From: ${CURRENT_ADDR//\"} [$CURRENT_LAT,$CURRENT_LONG]
To: ${STATION_ADDR//\"} [$STATION_LAT,$STATION_LONG]
Automated directions are not always correct; make sure to check the route on a map.

$DIRECTIONS

Linear Distance: $DISTANCE Meter$LDPLURAL
Walking Distance: $WDISTANCE Meter$WDPLURAL
Approximate Walking Time: $WALK_TIME Minute$TPLURAL" > /tmp/"$STATION_ID"-vbbPrint~temp.txt
		echo "-----"
		if [[ "$CURRENT_INTERNET_STATUS" == "online" ]] ; then
			echo "--Maps"
			if [[ "$DISABLED_STATUS" == "true" ]] ; then
				echo "----Show in Apple Maps… | terminal=false bash=/usr/bin/open param1=\"http://maps.apple.com/?saddr=$CURRENT_LAT,$CURRENT_LONG&daddr=$STATION_LAT,$STATION_LONG&dirflg=w&t=r\""
			else
				echo "----Show in Apple Maps… | terminal=false bash=/usr/bin/open param1=\"http://maps.apple.com/?saddr=$CURRENT_LAT,$CURRENT_LONG&daddr=$STATION_LAT,$STATION_LONG&q=${CURRENT_ADDR//\"}&dirflg=w&t=r\""
			fi
			echo "----Show in Google Maps… | terminal=false bash=/usr/bin/open param1=\"https://www.google.com/maps/dir/$CURRENT_LAT,$CURRENT_LONG/$STATION_LAT,$STATION_LONG/@$CURRENT_LAT,$CURRENT_LONG,17z/data=!4m2!4m1!3e2\""
			echo "----Show in OpenStreetMap… | terminal=false bash=/usr/bin/open param1=\"https://www.openstreetmap.org/directions?engine=graphhopper_foot&route=$CURRENT_LAT%2C$CURRENT_LONG%3B$STATION_LAT%2C$STATION_LONG#map=17/$CURRENT_LAT/$CURRENT_LONG\""
			if [[ "DISABLED_STATUS" != "true" ]] ; then
				echo "--Walking Directions"
				echo "$DIRECTIONS" | while IFS= read -r DIR_STEP
				do
					echo "----$DIR_STEP | font=AndaleMono size=12 color=black"
				done
				echo "-------"
				echo "----Automated directions are not always correct. | font=AndaleMono size=12 color=blue"
				echo "----Make sure to check the route on a map. | font=AndaleMono size=12 color=blue"
			fi
		else
			echo "--Show in Apple Maps… | terminal=false bash=/usr/bin/open param1=\"http://maps.apple.com/?ll=$STATION_LAT,$STATION_LONG&spn=0.00674885265,0.0104983203&t=r\""
		fi
		echo "-----"
		echo "--Print… | terminal=false bash=$SUBSCR/vbbar-print.sh param1=$STATION_ID"
		echo "--Open… | alternate=true terminal=false bash=/usr/bin/open param1=/tmp/$STATION_ID-vbbPrint~temp.txt"
		echo "-----"
		if [[ "$DISABLED_STATUS" == "true" ]] ; then
			echo "--Enable Station Updates & Information | terminal=false bash=$SUBSCR/vbbar-enablenearby.sh param1=$STATION_ID"
		else
			echo "--Disable Station Updates & Information | refresh=true terminal=false bash=/usr/bin/defaults param1=write param2=\"$PREFS\" param3=disabledNearby param4=-array-add param5=\"$STATION_ID\""
		fi
	done
fi

echo "---"

if [[ "$WIFI_STATUS" != "inactive" ]] ; then
	echo "Current Location"
	ADDR_SUBSTRING="Berlin, "
	if [[ "$CURRENT_ADDR" == *"$ADDR_SUBSTRING"* ]] ; then
		CURRENT_ADDR="${CURRENT_ADDR//$ADDR_SUBSTRING}"
	fi
	echo "--Address: ${CURRENT_ADDR//\"}"
	echo "--Coordinates: $CURRENT_LAT, $CURRENT_LONG | alternate=true"
	echo "-----"
	if [[ "$CURRENT_INTERNET_STATUS" == "online" ]] ; then
		echo "--Maps"
		echo "----Show in Apple Maps… | terminal=false bash=/usr/bin/open param1=\"http://maps.apple.com/?ll=$CURRENT_LAT,$CURRENT_LONG&q=${CURRENT_ADDR//\"}&spn=0.00674885265,0.0104983203&t=r\""
		echo "----Show in Google Maps… | terminal=false bash=/usr/bin/open param1=\"https://www.google.com/maps/place/$CURRENT_LAT,$CURRENT_LONG/@$CURRENT_LAT,$CURRENT_LONG,17z\"" 
		echo "----Show in OpenStreeMap… | terminal=false bash=/usr/bin/open param1=\"https://www.openstreetmap.org/search?query=$CURRENT_LAT%2C$CURRENT_LONG#map=17/$CURRENT_LAT/$CURRENT_LONG\""
	else
		echo "--Show in Apple Maps… | terminal=false bash=/usr/bin/open param1=\"http://maps.apple.com/?ll=$CURRENT_LAT,$CURRENT_LONG&spn=0.00674885265,0.0104983203&t=r\""
	fi
fi
echo "Refresh… | refresh=true"

echo "---"

echo "Network Maps"
if ls "$PREFS_DIR"/*.pdf 1>/dev/null 2>&1 ; then
	if [[ ! -e "$MAP_REGIONAL_FILE" ]] || [[ ! -e "$MAP_BERLINABC_FILE" ]] || [[ ! -e "$MAP_BERLINNIGHT_FILE" ]] || [[ ! -e "$MAP_BERLINABTRAM_FILE" ]] || [[ ! -e "$MAP_BERLINAB_FILE" ]] ; then
		if [[ "$CURRENT_INTERNET_STATUS" == "online" ]] ; then
			echo "--Update Network Maps… | terminal=false bash=$SUBSCR/vbbar-mapsdl.sh param1=update"
		else
			echo "--Update Network Maps…"
		fi
		echo "-----"
	fi
	if [[ -e "$MAP_BERLINAB_FILE" ]] ; then
		echo "--Berlin AB (S+U, RE+RB, TXL) | terminal=false bash=/usr/bin/open param1=\"$MAP_BERLINAB_FILE\""
	else
		echo "--Berlin AB (S+U, RE+RB, TXL)"
	fi
	if [[ -e "$MAP_BERLINABTRAM_FILE" ]] ; then
		echo "--Berlin AB (Tram) | terminal=false bash=/usr/bin/open param1=\"$MAP_BERLINABTRAM_FILE\""
	else
		echo "--Berlin AB (Tram)"
	fi
	echo "-----"
	if [[ -e "$MAP_BERLINABC_FILE" ]] ; then
		echo "--Berlin ABC (S+U, RE+RB, TXL+SXF) | terminal=false bash=/usr/bin/open param1=\"$MAP_BERLINABC_FILE\""
	else
		echo "--Berlin ABC (S+U, RE+RB, TXL+SXF)"
	fi
	if [[ -e "$MAP_BERLINNIGHT_FILE" ]] ; then
		echo "--Berlin ABC (Nighttime Services) | terminal=false bash=/usr/bin/open param1=\"$MAP_BERLINNIGHT_FILE\""
	else
		echo "--Berlin ABC (Nighttime Services)"
	fi
	echo "-----"
	if [[ -e "$MAP_REGIONAL_FILE" ]] ; then
		echo "--Berlin-Brandenburg (RE+RB, SXF) | terminal=false bash=/usr/bin/open param1=\"$MAP_REGIONAL_FILE\""
	else
		echo "--Berlin-Brandenburg (RE+RB, SXF)"
	fi
	if [[ "$CURRENT_INTERNET_STATUS" != "offline" ]] ; then
		echo "-----"
		echo "--More Network Maps Online… | terminal=false bash=/usr/bin/open param1=\"http://www.vbb.de/de/article/fahrplan/liniennetze/liniennetze/897.html\""
	fi
else
	if [[ "$CURRENT_INTERNET_STATUS" == "online" ]] ; then
		echo "--Download Network Maps… | terminal=false bash=$SUBSCR/vbbar-mapsdl.sh param1=initial"
	else
		echo "--Download Network Maps…"
	fi
fi
echo "-----"
if [[ "$CURRENT_INTERNET_STATUS" == "online" ]] ; then
	echo "--Berlin Lines"
	echo "----BVG | terminal=false bash=/usr/bin/open param1=\"https://www.bvg.de/en/Travel-information\""
	echo "----S-Bahn | terminal=false bash=/usr/bin/open param1=\"http://www.s-bahn-berlin.de/fahrplanundnetz/linien\""
else
	echo "--Berlin Lines"
fi
echo "---"

if [[ "$NEARBY_RANGE" == "" ]] ; then
	NEARBY_RANGE=$(defaults read "$PREFS" nearbyRange 2>/dev/null)
	if [[ "$NEARBY_RANGE" == "" ]] ; then
		NEARBY_RANGE="500"
		defaults write "$PREFS" nearbyRange "$NEARBY_RANGE"
	fi
fi
REMOTE_RANGE=$(defaults read "$PREFS" remoteRange 2>/dev/null)
if [[ "$REMOTE_RANGE" == "" ]] ; then
	REMOTE_RANGE="600"
	defaults write "$PREFS" remoteRange "$REMOTE_RANGE"
fi

vbbar-submenu () {
	echo "--Scanning Range"
	echo "----For Nearby Stations | terminal=false bash=$SUBSCR/vbbar-range.sh param1=nearby"
	echo "----Currently: $NEARBY_RANGE Meters | alternate=true terminal=false bash=$SUBSCR/vbbar-range.sh param1=nearby"
	echo "----For Remote Stations | terminal=false bash=$SUBSCR/vbbar-range.sh param1=remote"
	echo "----Currently: $REMOTE_RANGE Meters | alternate=true terminal=false bash=$SUBSCR/vbbar-range.sh param1=remote"
	echo "--Nearby Stations"
	if [[ "$NEARBY_TOGGLE" == "on" ]] ; then
		echo "----Departures On | checked=true"
		echo "----Departures Off | refresh=true terminal=false bash=/usr/bin/defaults param1=write param2=\"$PREFS\" param3=nearbyDepartures param4=\"off\""
	elif [[ "$NEARBY_TOGGLE" == "off" ]] ; then
		echo "----Departures On | refresh=true terminal=false bash=/usr/bin/defaults param1=write param2=\"$PREFS\" param3=nearbyDepartures param4=\"on\""
		echo "----Departures Off | checked=true"
	fi
	if [[ "$DISABLED_NEARBY" != "" ]] ; then
		DISABLED_STATIONS=$(defaults read "$PREFS" disabledNearby 2>/dev/null | /usr/bin/sed 's/[(,)]//g' | /usr/bin/sed '/^$/d' | /usr/bin/sed "s/^[ \t]*//")
		STATION_MATCH=$(/usr/bin/comm -12 <( echo "$NEARBY_ID_LIST" | /usr/bin/sort -n ) <( echo "$DISABLED_STATIONS" | /usr/bin/sort -n ) | xargs)
		if [[ "$STATION_MATCH" != "" ]] ; then
			echo "-------"
			echo "----Enable All | refresh=true terminal=false bash=/usr/bin/defaults param1=write param2=\"$PREFS\" param3=disabledNearby param4=-array"
		fi
	fi
	echo "-------"
	BASE_NAME_RATE=$(echo "$BASE_NAME" | /usr/bin/awk -F"." '{print $2}')
	REFRESH_RATE="${BASE_NAME_RATE%?}"
	REFRESH_FORMAT="${BASE_NAME_RATE: -1}"
	if [[ "$REFRESH_FORMAT" == "m" ]] ; then
		FULL_FORMAT="Minute"
	elif [[ "$REFRESH_FORMAT" == "s" ]] ; then
		FULL_FORMAT="Second"
	elif [[ "$REFRESH_FORMAT" == "d" ]] ; then
		FULL_FORMAT="Day"
	fi
	if [[ "$REFRESH_RATE" == "1" ]] ; then
		REFPLURAL=""
	else
		REFPLURAL="s"
	fi
	echo "----Set New Refresh Rate | terminal=false bash=$SUBSCR/vbbar-refreshrate.sh"
	echo "----Currently: $REFRESH_RATE $FULL_FORMAT$REFPLURAL | alternate=true"
	echo "-----"
	echo "--System"
    if [[ "$VBB_STATUS" == "true" ]] ; then
		echo "----VBB API Access ID | checked=true terminal=false bash=$SUBSCR/vbbar-api.sh param1=vbb"
	else
		echo "----Enter VBB API Access ID | terminal=false bash=$SUBSCR/vbbar-api.sh param1=vbb"
	fi
	if [[ "$MB_STATUS" == "true" ]] ; then
		echo "----Mapbox API Access Token | checked=true terminal=false bash=$SUBSCR/vbbar-api.sh param1=mb"
	else
		echo "----Enter Mapbox API Access Token | terminal=false bash=$SUBSCR/vbbar-api.sh param1=mb"
	fi	
	echo "-------"
	if [[ "$(which -a CoreLocationCLI)" == "CoreLocationCLI not found" ]] ; then
		CLC_STATUS=""
	else
		CLC_STATUS="checked=true"
	fi
	if [[ "$(which -a jq)" == "jq not found" ]] ; then
		JQ_STATUS=""
	else
		JQ_STATUS="checked=true"
	fi
	if [[ "$(which -a mapbox)" == "mapbox not found" ]] ; then
		MBX_STATUS=""
	else
		MBX_STATUS="checked=true"
	fi
	if [[ "$(which -a mlr)" == "mlr not found" ]] ; then
		MLR_STATUS=""
	else
		MLR_STATUS="checked=true"
	fi
	if [[ "$(which -a node)" == "node not found" ]] ; then
		NODE_STATUS=""
	else
		NODE_STATUS="checked=true"
	fi
	if [[ "$(which -a npm)" == "npm not found" ]] ; then
		NPM_STATUS=""
	else
		NPM_STATUS="checked=true"
	fi
	if [[ "$NOTESTATUS" == "tn" ]] ; then
		TN_STATUS="checked=true"
	else
		TN_STATUS=""
	fi
	if [[ "$(which -a vbb-dep)" == "vbb-dep not found" ]] ; then
		VD_STATUS=""
	else
		VD_STATUS="checked=true"
	fi
	if [[ "$(which -a vbb-route)" == "vbb-route not found" ]] ; then
		VR_STATUS=""
	else
		VR_STATUS="checked=true"
	fi
	if [[ "$VD_STATUS" == "checked=true" ]] && [[ "$VR_STATUS" == "checked=true" ]]; then
		VC_STATUS="checked=true"
	else
		VC_STATUS=""
	fi
	if [[ "$(which -a vbb-stations)" == "vbb-stations not found" ]] ; then
		VS_STATUS=""
	else
		VS_STATUS="checked=true"
	fi
	echo "----CoreLocationCLI | $CLC_STATUS"
	echo "----jq | $JQ_STATUS "
	echo "----mapbox | $MBX_STATUS "
	echo "----mlr | $MLR_STATUS "
	echo "----node | $NODE_STATUS"
	echo "----npm | $NPM_STATUS "
	echo "----terminal-notifier | $TN_STATUS "
	echo "----vbb-cli | $VC_STATUS"
	echo "----vbb-dep | $VD_STATUS"
	echo "----vbb-route | $VR_STATUS"
	echo "----vbb-stations | $VS_STATUS" 
	echo "-------"
	echo "----Wi-Fi Status: $WIFI_STATUS"
	echo "----Interface: $INTERFACE"
	echo "----SSID: $SSID"
	echo "----BSSID: $BSSID | alternate=true"
	echo "-------"
	if [[ "$NOTESTATUS" == "tn" ]] ; then
		echo "----NSNotification: terminal-notifier"
	elif [[ "$NOTESTATUS" == "osa" ]] ; then
		echo "----NSNotification: osascript"
	fi
	echo "--About VBBar | terminal=false bash=$SUBSCR/vbbar-about.sh"
	echo "-----"
	echo "--Open in Editor…"
	echo "----$BASE_NAME | terminal=false bash=/usr/bin/open param1=\"$SCRIPT_PATH\""
	echo "-------"
	echo "----Subscripts"
	cd "$SUBSCR" && for SUBSCRIPT in *
	do
		echo "----$SUBSCRIPT | terminal=false bash=/usr/bin/open param1=\"$SUBSCR/$SUBSCRIPT\""
	done
	echo "-----"
	echo "--Latest BitBar Release… | terminal=false bash=/usr/bin/open param1=https://github.com/matryer/bitbar/releases/latest"
}

echo "VBBar"
vbbar-submenu
echo "v$CURRENT_VERSION $BETA | alternate=true"
vbbar-submenu

echo "---"
if [[ "$VBB_STATUS" != "true" ]] ; then
	echo "[No VBB API Access ID] | color=brown"
fi
if [[ "$MB_STATUS" != "true" ]] ; then
	echo "[No Mapbox API Access Token] | color=brown"
fi
if [[ "$WIFI_STATUS" == "init" ]] ; then
	echo "[Wi-Fi Active] | color=blue"
fi
if [[ "$CURRENT_INTERNET_STATUS" == "offline" ]] ; then
	echo "[Internet Offline] | color=red"
fi

echo "---"

echo "Powered by VBB GmbH"
echo "Powered by derhuerst | alternate=true"