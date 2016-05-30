#!/bin/bash

# subscript for VBBar BitBar plugin
# DETECT/SELECT PRINTERS & PRINT DEPARTURES & WALKING DIRECTIONS TO STATION

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
PREFS="local.lcars.VBBar"
PREFS_DIR="${HOME}/Library/Preferences/VBBar"
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


PRINTER_LIST=$(/usr/bin/lpstat -a 2>/dev/null | /usr/bin/awk '{print $1}')
if [[ "$PRINTER_LIST" == "" ]] ; then
	notify "Printing aborted" "No peripherals detected"
	exit
fi
PRINTER_NO=$(echo "$PRINTER_LIST" | wc -l | xargs)
if [[ "$PRINTER_NO" -gt "1" ]] ; then
	PRINTER_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set thePrinterList to {}
	set thePrinters to paragraphs of "$PRINTER_LIST"
	repeat with aPrinter in thePrinters
		set thePrinterList to thePrinterList & {(aPrinter) as string}
	end repeat
	set AppleScript's text item delimiters to return & linefeed
	set userChoice to (choose from list thePrinterList with prompt "Several peripherals detected. Please choose the printer." with title "Select Printer" without multiple selections allowed)
	return the result as string
	set AppleScript's text item delimiters to ""
end tell
userChoice
EOT)
	if [[ "$PRINTER_CHOICE" == "" ]] || [[ "$PRINTER_CHOICE" == "false" ]] ; then
		exit
	fi
else
	PRINTER_CHOICE="$PRINTER_LIST"
fi
notify "Waiting for printer…" "$PRINTER_CHOICE"
/usr/bin/lp -d "$PRINTER_CHOICE" "/tmp/$1-vbbPrint~temp.txt"
exit