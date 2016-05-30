#!/bin/bash

# subscript for VBBar BitBar plugin
# CHANGE SCANNING RANGE FOR EITHER NEARBY OR REMOTE STATIONS

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

if [[ "$1" == "nearby" ]] ; then
	RANGE=$(defaults read "$PREFS" nearbyRange)
	TITLE_BAR="Nearby"
fi
if [[ "$1" == "remote" ]] ; then
	RANGE=$(defaults read "$PREFS" remoteRange)
	TITLE_BAR="Remote"
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

RANGE_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theRangeList to {"250 meters (approx. 273 yards)", "300 meters (approx. 328 yards)", "400 meters (approx. 437 yards)", "500 meters (approx. 547 yards)", "600 meters (approx. 656 yards)", "750 meters (approx. 820 yards)", "1000 meters (approx. 1094 yards)", "Individual setting"}
	set userChoice to (choose from list theRangeList with prompt "Please choose the $1 stations scanning range. " & ¬
	"Your current $1 range is set to $RANGE meters. " & ¬
	"High values will increase scanning/loading times. " & ¬
	"Please note that VBBar will automatically expand the scanning range until it receives a result." ¬
	with title "Select $TITLE_BAR Range" without multiple selections allowed)
	return the result as string
end tell
userChoice
EOT)
if [[ "$RANGE_CHOICE" == "" ]] || [[ "$RANGE_CHOICE" == "false" ]] ; then
	exit
fi
if [[ "$RANGE_CHOICE" == "Individual setting" ]] ; then
	INDIVIDUAL=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Preferences:VBBar:$VBB_LOGO"
	set theRange to text returned of (display dialog "Please enter your $1 stations scanning range (in meters). The maximum value is 1000. Your current $1 range is set to $RANGE meters." ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		default answer "" ¬
		with title "Enter $TITLE_BAR Range" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theRange
EOT)
	if [[ "$INDIVIDUAL" == "" ]] || [[ "$INDIVIDUAL" == "false" ]] ; then
		exit
	fi
	if [[ "${INDIVIDUAL//[0-9]}" == "" ]] ; then
		if [[ "$INDIVIDUAL" -lt "50" ]] ; then
			notify "Error" "Range too small"
			exit
		elif [[ "$INDIVIDUAL" -gt "1000" ]] ; then
			notify "Error" "Range too high"
			exit
		else
			defaults write "$PREFS" "$1" Range "$INDIVIDUAL"
			/usr/bin/open "bitbar://refreshPlugin?name=VBBar.*?.sh"
			exit
		fi
	else
		notify "Error" "Invalid input"
		exit
	fi
else
	NEW_RANGE=$(echo "$RANGE_CHOICE" | /usr/bin/awk '{print $1}' | xargs)
	defaults write "$PREFS" "$1" Range "$NEW_RANGE"
	/usr/bin/open "bitbar://refreshPlugin?name=VBBar.*?.sh"
fi
exit