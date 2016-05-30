#!/bin/bash

# subscript for VBBar BitBar plugin
# SET VBBAR REFRESH RATE

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
PREFS="local.lcars.VBBar"
BASE_NAME=$(defaults read "$PREFS" name)
PREFS_DIR="${HOME}/Library/Preferences/VBBar"
VBB_LOGO="VBBLogo.png"
VBB_LOGOSMALL="VBBLogoSmall.png"
VBB_LOGOSMALL_FILE="$PREFS_DIR/$VBB_LOGOSMALL"
NOTESTATUS=$(defaults read "$PREFS" noteStatus)
if [[ "$NOTESTATUS" == "tn" ]] ; then
	TERMNOTE_LOC=$(defaults read "$PREFS" tnLocation)
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

RATE=$(echo "$BASE_NAME" | /usr/bin/awk -F"." '{print $2}')
RATE_NO="${RATE%?}"
FORMAT="${RATE: -1}"
if [[ "$FORMAT" == "m" ]] ; then
	FULL_FORMAT="minute"
elif [[ "$FORMAT" == "s" ]] ; then
	FULL_FORMAT="second"
elif [[ "$FORMAT" == "d" ]] ; then
	FULL_FORMAT="day"
fi
if [[ "$RATE_NO" == "1" ]] ; then
	PLURAL=""
else
	PLURAL="s"
fi
NAME=$(echo "$BASE_NAME" | /usr/bin/awk -F"." '{print $1}')
BITBAR_DIR=$(defaults read "$PREFS" BitBarDir)

RATE_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Preferences:VBBar:$VBB_LOGO"
	set theRate to text returned of (display dialog "Enter the new VBBar refresh rate. Please use the format 30s, 15m, or 1d for thirty seconds, fifteen minutes, or one day. Your current refresh rate is set to $RATE_NO $FULL_FORMAT$PLURAL." ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		default answer "" ¬
		with title "Enter New Refresh Rate" ¬
		with icon file theLogoPath ¬
		giving up after 120)
end tell
theRate
EOT)
if [[ "$RATE_CHOICE" == "" ]] || [[ "$RATE_CHOICE" == "false" ]] ; then
	exit
fi
RATE_ENTRY=$(echo "$RATE_CHOICE" | /usr/bin/tr '[:upper:]' '[:lower:]')
FORMAT_ENTER="${RATE_ENTRY: -1}"
if [[ "$FORMAT_ENTER" != "s" ]] && [[ "$FORMAT_ENTER" != "m" ]] && [[ "$FORMAT_ENTER" != "d" ]] ; then
	notify "Error" "Invalid input"
	exit
fi
RATE_ENTER="${RATE_ENTRY%?}"
if [[ "$RATE_ENTER" -eq "$RATE_ENTER" ]] 2>/dev/null
then
	if [[ "$RATE_ENTER" -lt "30" ]] && [[ "$FORMAT_ENTER" == "s" ]] ; then
		notify "Error" "Rate too low"
		exit
	else
		NEW_BASE_NAME="$NAME.$RATE_ENTRY.sh"
		/usr/bin/osascript -e 'tell application "BitBar" to quit' &>/dev/null && sleep 1
		mv "$BITBAR_DIR"/"$BASE_NAME" "$BITBAR_DIR"/"$NEW_BASE_NAME"
		/usr/bin/open -b com.matryer.BitBar
	fi
else
    notify "Error" "Invalid input"
    exit
fi
exit