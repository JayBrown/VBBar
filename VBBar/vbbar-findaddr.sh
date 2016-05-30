#!/bin/bash

# subscript for VBBar BitBar plugin
# FIND EITHER DESTINATION OR DEPARTURE ADDRESS AND LOOK FOR NEARBY STATIONS

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
PREFS="local.lcars.VBBar"
PREFS_DIR="${HOME}/Library/Preferences/VBBar"
VBB_LOGO="VBBLogo.png"
VBB_LOGOSMALL="VBBLogoSmall.png"
VBB_LOGOSMALL_FILE="$PREFS_DIR/$VBB_LOGOSMALL"
NOTESTATUS=$(defaults read "$PREFS" noteStatus)
if [[ "$NOTESTATUS" == "tn" ]] ; then
	TERMNOTE_LOC=$(defaults read "$PREFS" tnLocation)
fi
ADDR_TEMP_LOC="/tmp/vbb-addr~temp.txt"
if [[ ! -e "$ADDR_TEMP_LOC" ]] ; then
	touch "$ADDR_TEMP_LOC"
fi
RAW_TEMP_LOC="/tmp/vbb-addraw~temp.txt"
if [[ ! -e "$RAW_TEMP_LOC" ]] ; then
	touch "$RAW_TEMP_LOC"
fi

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

MB_TOKEN=$(/usr/bin/security 2>&1 >/dev/null find-generic-password -s VBBar_mapbox -ga "$ACCOUNT" | /usr/bin/ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/' | xargs)
if [[ "$MB_TOKEN" == "" ]] ; then
	MB_STATUS="n/a"
else
	export MAPBOX_ACCESS_TOKEN=$MB_TOKEN
	MB_STATUS="true"
fi

if [[ "$1" == "dest" ]] ; then
	POINT="destination"
	POINT_NOTE="Destination"
elif [[ "$1" == "dep" ]] ; then
	POINT="departure"
	POINT_NOTE="Departure"
fi
echo -n "" > "$ADDR_TEMP_LOC"
echo -n "" > "$RAW_TEMP_LOC"
STREET_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Preferences:VBBar:$VBB_LOGO"
	set theStreet to text returned of (display dialog "Please enter the street or plaza name (without the house number and the area code). Your query will be processed case-insensitive. " & ¬
		"You can enter short forms like «Str.», «str», «Pl», «pl.» etc." ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		default answer "" ¬
		with title "Enter $POINT_NOTE Street Name" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theStreet
EOT)
if [[ "$STREET_CHOICE" == "" ]] || [[ "$STREET_CHOICE" == "false" ]] ; then
	exit
fi
if [[ "$STREET_CHOICE" == "@@@" ]] || [[ "$STREET_CHOICE" == "Departure@@@" ]] || [[ "$STREET_CHOICE" == "Destination@@@" ]] ; then
	notify "Aborted" "Internal error"
	exit
fi
 
# ADDRESS_ENTRY=$(echo "$STREET_CHOICE" | /usr/bin/awk -F"@@@" '{print substr($0, index($0,$2))}')
LETTER=$(echo ${STREET_CHOICE:0:1} | /usr/bin/tr '[a-z]' '[A-Z]')
VZ=$(/usr/bin/curl -sG "https://berlin.kauperts.de/Strassenverzeichnis/$LETTER")
ADDR_VZ=$(echo "$STREET_CHOICE " | /usr/bin/awk '{ \
	gsub("str\\. ","straße "); \
	gsub("str ","straße "); \
	gsub("strasse ","straße "); \
	gsub("Strasse ","Straße "); \
	gsub("Str\\. ","Straße "); \
	gsub("Str ","Straße "); \
	gsub(" Str\\. "," Straße "); \
	gsub(" str\\. "," Straße "); \
	gsub(" Str "," Straße "); \
	gsub(" str "," Straße "); \
	gsub(" Strasse "," Straße "); \
	gsub(" strasse "," Straße "); \
	gsub("-Str\\. ","-Straße "); \
	gsub("-str\\. ","-Straße "); \
	gsub("-Str ","-Straße "); \
	gsub("-str ","-Straße "); \
	gsub("-Strasse ","-Straße "); \
	gsub("-strasse ","-Straße "); \
	gsub("pl\\. ","platz "); \
	gsub("pl ","platz "); \
	gsub(" Pl\\. "," Platz "); \
	gsub(" pl\\. "," Platz "); \
	gsub(" Pl "," Platz "); \
	gsub(" pl "," Platz "); \
	gsub("-Pl\\. ","-Platz "); \
	gsub("-pl\\. ","-Platz "); \
	gsub("-Pl ","-Platz "); \
	gsub("-pl ","-Platz "); \
	gsub(" Br\\. "," Brücke "); \
	gsub(" br\\. "," Brücke "); \
	gsub(" Br "," Brücke "); \
	gsub(" br "," Brücke "); \
	gsub("-Br\\. ","-Brücke "); \
	gsub("-br\\. ","-Brücke "); \
	gsub("-Br ","-Brücke "); \
	gsub("-br ","-Brücke "); \
	gsub("br\\. ","brücke "); \
	gsub("br ","brücke "); \
	print}')
QUERY_ADDR=$(echo "$ADDR_VZ" | /usr/bin/sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
VZ_RESULT=$(echo "$VZ" | /usr/bin/grep -i -A 1 "$QUERY_ADDR")
if [[ "$VZ_RESULT" == "" ]] ; then
	notify "Nothing found" "Enter a more precise query"
	exit
fi
ENTRIES_NO=$(echo "$VZ_RESULT" | /usr/bin/grep "\-\-" | /usr/bin/wc -l | xargs)
if [[ $ENTRIES_NO -gt 47 ]] ; then # too many results
	notify "Aborted" "Too many results"
	exit
fi
(( ENTRIES_NO = ENTRIES_NO + 1 ))
if [[ $ENTRIES_NO -gt 1 ]] ; then # more than one street
	((RAW_COUNT = 0))
	((ADDR_COUNT = 0))
	echo "$VZ_RESULT" | while IFS= read -r LINE
	do
		ADDR_VZ_RAW=$(echo "$LINE" | /usr/bin/grep "<td><a href" | /usr/bin/awk -F"/Strassen/" '{print $2}' | /usr/bin/sed s@'\">.*'@''@)
		if [[ "$ADDR_VZ_RAW" != "" ]] ; then
			((RAW_COUNT = RAW_COUNT + 1))
			echo "$RAW_COUNT | $ADDR_VZ_RAW" >> "$RAW_TEMP_LOC"
		fi
		STREET=$(echo "$LINE" | /usr/bin/grep "<td><a href=\"/Strassen/" | /usr/bin/awk -F"\">" '{print $2}' | /usr/bin/sed s@'</a></td>.*'@''@)
		if [[ "$STREET" != "" ]] ; then
			((ADDR_COUNT = ADDR_COUNT + 1))
			echo -n "$ADDR_COUNT | $STREET, " >> "$ADDR_TEMP_LOC"
			PLZ=$(/bin/cat "$RAW_TEMP_LOC" | /usr/bin/grep "$ADDR_COUNT | " | /usr/bin/awk -F"|" '{print substr($0, index($0,$2))}' | rev | /usr/bin/awk -F"-" '{print $2}' | rev)
		fi
		PRECINCT=$(echo "$LINE" | /usr/bin/grep "<td class=\"secondary\">" | /usr/bin/awk -F"secondary\">" '{print $2}' | /usr/bin/sed s@'</td>.*'@''@)
		if [[ "$PRECINCT" != "" ]] ; then
			echo "$PRECINCT, $PLZ Berlin" >> "$ADDR_TEMP_LOC"
		fi
	done
	TRUE_NO=$(/bin/cat "$RAW_TEMP_LOC" | wc -l | xargs)
	ADDRESS_LIST=$(/bin/cat "$ADDR_TEMP_LOC" | /usr/bin/grep -E "\|")
	ADDR_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theAddressList to {}
	set theAddresses to paragraphs of "$ADDRESS_LIST"
	repeat with anAddress in theAddresses
		set theAddressList to theAddressList & {(anAddress) as string}
	end repeat
	set AppleScript's text item delimiters to return & linefeed
	set userChoice to (choose from list theAddressList with prompt "Several streets match your query. Please select the correct one." with title "Select Street" without multiple selections allowed)
	return the result as string
	set AppleScript's text item delimiters to ""
end tell
userChoice
EOT)
	if [[ "$ADDR_CHOICE" == "" ]] || [[ "$ADDR_CHOICE" == "false" ]] ; then
		exit
	fi
	
	GCALL_ADDR=$(echo "$ADDR_CHOICE" | /usr/bin/awk -F"|" '{print substr($0, index($0,$2))}' | xargs)
elif [[ $ENTRIES_NO -eq 1 ]] ; then # just one street
	ADDR_VZ_RAW=$(echo "$VZ_RESULT" | /usr/bin/grep "<td><a href" | /usr/bin/awk -F"/Strassen/" '{print $2}' | /usr/bin/sed s@'\">.*'@''@)
	STREET=$(echo "$VZ_RESULT" | /usr/bin/grep "<td><a href=\"/Strassen/" | /usr/bin/awk -F"\">" '{print $2}' | /usr/bin/sed s@'</a></td>.*'@''@)
	PRECINCT=$(echo "$VZ_RESULT" | /usr/bin/grep "<td class=\"secondary\">" | /usr/bin/awk -F"secondary\">" '{print $2}' | /usr/bin/sed s@'</td>.*'@''@)
	PLZ=$(echo "$VZ_RESULT" | /usr/bin/grep "<td><a href=\"/Strassen/" | /usr/bin/awk -F"\">" '{print $1}' | rev | /usr/bin/awk -F"-" '{print $2}' | rev)
	GCALL_ADDR="$STREET, $PRECINCT, $PLZ Berlin, Germany"
fi

NUMBER_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Preferences:VBBar:$VBB_LOGO"
	set {theButton, theNumber} to {button returned, text returned} of (display dialog "Now please enter the house number for $GCALL_ADDR. (Leave blank if unknown.)" ¬
		buttons {"Cancel", "Unknown", "Enter"} ¬
		default button 3 ¬
		default answer "" ¬
		with title "Enter House Number" ¬
		with icon file theLogoPath ¬
		giving up after 120)
end tell
theButton & "@@@" & theNumber
EOT)
if [[ "$NUMBER_CHOICE" == "" ]] || [[ "$NUMBER_CHOICE" == "false" ]] ; then
	exit
fi
BUTTON_RESULT=$(echo "$NUMBER_CHOICE" | /usr/bin/awk -F"@@@" '{print $1}')
if [[ "$BUTTON_RESULT" == "Unknown" ]] ; then
	HOUSE_NUMBER="1"
else
	HOUSE_NUMBER=$(echo "$NUMBER_CHOICE" | /usr/bin/awk -F"@@@" '{print $2}')
	if [[ "$HOUSE_NUMBER" == "" ]] ; then
		HOUSE_NUMBER="1"
	fi
	case ${HOUSE_NUMBER#[-+]} in
 		*[!0-9]* ) HOUSE_NUMBER="1" ;;
 		* ) ;;
	esac
fi

GCALL_FINAL="$HOUSE_NUMBER $GCALL_ADDR"
if [[ "$MB_STATUS" == "true" ]] ; then
	GMAPS_ADDR=$(/usr/local/bin/mapbox geocoding "$GCALL_FINAL")
	FORM_ADDR=$(echo "$GMAPS_ADDR" | /usr/local/bin/jq '.features[0] .place_name' -M -r)
	ADDR_COORD_RAW=$(echo "$GMAPS_ADDR" | /usr/local/bin/jq '.features[0] .center' -M -r | xargs)
	ADDR_LAT=$(echo "$ADDR_COORD_RAW" | /usr/bin/awk '{print $3}')
	ADDR_LONG=$(echo "$ADDR_COORD_RAW" | /usr/bin/awk '{print $2}' | /usr/bin/sed 's/,$//')
else
	GMAPS_ADDR=$(/usr/bin/curl -sG --data-urlencode 'address='"$GCALL_FINAL"'' 'http://maps.googleapis.com/maps/api/geocode/json?sensor=false')
	sleep 1
	FORM_ADDR=$(echo "$GMAPS_ADDR" | /usr/local/bin/jq '.results[0].formatted_address' -M -r)
	ADDR_LAT=$(echo "$GMAPS_ADDR" | /usr/local/bin/jq ".results[0].geometry.location.lat" -M -r)
	ADDR_LONG=$(echo "$GMAPS_ADDR" | /usr/local/bin/jq ".results[0].geometry.location.lng" -M -r)
fi

LATRAD_BASE=".0044992351" # 500m
LONGRAD_BASE=".0069988802" # 500m
REMOTE_RANGE=$(defaults read "$PREFS" remoteRange 2>/dev/null)
if [[ "$REMOTE_RANGE" == "" ]] ; then
	REMOTE_RANGE="600"
	defaults write "$PREFS" remoteRange "$REMOTE_RANGE"
fi
RANGE_FACTOR=$(bc -l <<< "$REMOTE_RANGE / 500")
LATRAD=$(bc -l <<< "$LATRAD_BASE * $RANGE_FACTOR")
LONGRAD=$(bc -l <<< "$LONGRAD_BASE * $RANGE_FACTOR")
REMOTE_STATIONS=""
while [[ $(echo "$REMOTE_STATIONS") == "" ]]
do
	REMOTE_STATIONS=$(/usr/local/bin/vbb-stations \
		"(s) => s.latitude > $ADDR_LAT - $LATRAD" "(s) => s.latitude < $ADDR_LAT + $LATRAD" \
		"(s) => s.longitude > $ADDR_LONG - $LONGRAD" "(s) => s.longitude < $ADDR_LONG + $LONGRAD" \
		--format csv | \
		/usr/local/bin/mlr --icsv --onidx --ofs @ --rs lf cut -f id,name,latitude,longitude)
	LAT_ADD=".0044992351"
	LONG_ADD=".0069988802"
	LATRAD=$(bc <<< "$LATRAD + $LAT_ADD")
	LONGRAD=$(bc <<< "$LONGRAD + $LONG_ADD")
done
REMOTE_LIST=$(echo "$REMOTE_STATIONS" | /usr/bin/awk -F"@" '{print $1" | "$2}')

REMOTE_COUNT=$(echo "$REMOTE_LIST" | /usr/bin/wc -l | xargs)
if [[ "$REMOTE_COUNT" -eq "1" ]] ; then
	NOTE_NAME=$(echo "$REMOTE_LIST" | /usr/bin/awk -F"|" '{print substr($0, index($0,$2))}')
	notify "Found only one station" "$NOTE_NAME"
	REMOTE_CHOICE_ID=$(echo "$REMOTE_LIST" | /usr/bin/awk -F"|" '{print $1}' | xargs)
	REMOTE_CHOICE_COORD=$(/usr/local/bin/vbb-stations --id "$REMOTE_CHOICE_ID" --format csv | /usr/local/bin/mlr --icsv --onidx --rs lf --ofs , cut -f latitude,longitude) 
else
	/usr/bin/open "http://maps.apple.com/?ll=$ADDR_LAT,$ADDR_LONG&q=${FORM_ADDR//\"}&spn=$LATRAD,$LONGRAD&t=r"
	sleep 1
	REMOTE_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theStationList to {}
	set theStations to paragraphs of "$REMOTE_LIST"
	repeat with aStation in theStations
		set theStationList to theStationList & {(aStation) as string}
	end repeat
	set AppleScript's text item delimiters to return & linefeed
	set userChoice to (choose from list theStationList with prompt "The following stations are near the location you entered. Please select your $POINT." with title "Select Station" without multiple selections allowed)
	return the result as string
	set AppleScript's text item delimiters to ""
end tell
userChoice
EOT)
	if [[ "$REMOTE_CHOICE" == "" ]] || [[ "$REMOTE_CHOICE" == "false" ]] ; then
		exit
	fi
	REMOTE_CHOICE_ID=$(echo "$REMOTE_CHOICE" | /usr/bin/awk -F"|" '{print $1}' | xargs)
	REMOTE_CHOICE_COORD=$(/usr/local/bin/vbb-stations --id "$REMOTE_CHOICE_ID" --format csv | /usr/local/bin/mlr --icsv --onidx --rs lf --ofs , cut -f latitude,longitude)  
fi

if [[ "$POINT" == "destination" ]] ; then
	/usr/bin/open "http://maps.apple.com/?saddr=$REMOTE_CHOICE_COORD&daddr=$ADDR_LAT,$ADDR_LONG&dirflg=w&t=r"
elif [[ "$POINT" == "departure" ]] ; then
	/usr/bin/open "http://maps.apple.com/?saddr=$ADDR_LAT,$ADDR_LONG&daddr=$REMOTE_CHOICE_COORD&dirflg=w&t=r"
fi

exit