#!/bin/bash

# subscript for VBBar BitBar plugin
# ABOUT VBBAR

LANG=en_US.UTF-8
PREFS="local.lcars.VBBar"
VBB_LOGO="VBBLogo.png"

CURRENT_VERSION="0.1"
BETA="alpha1"
REL_YEAR="2016"
REL_MONTH="05"
OS_NAME="OS X"
MINIMUM_OS="10.10"
BITBAR_VERSION="2 beta4"

ABOUT_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Preferences:VBBar:$VBB_LOGO"
	set userChoice to button returned of (display dialog "VBBar" & return & "Version $CURRENT_VERSION $BETA ($REL_YEAR-$REL_MONTH)" & return & ¬
		"Open source software" & return & return & ¬
		"Access and search the Berlin and Brandenberg public transportation information from the $OS_NAME menu bar." & return & return & ¬
		"▪▪▪ Minimum OS ▪▪▪" & return & ¬
		"$OS_NAME $MINIMUM_OS" & return & return & ¬
		"▪▪▪ Prerequisite ▪▪▪" & return & ¬
		"BitBar v$BITBAR_VERSION or higher" & return & return & ¬
		"▪▪▪ Acknowledgements ▪▪▪" & return & ¬
		"derhuerst" & return & return & ¬
		"«Wherever you go, there you are.»" & return & return & ¬
		"Powered by VBB GmbH. Subject to change. No liability assumed." & return & return & ¬
		"Berlin addresses provided by KAUPERTS (kaupert media gmbh)." ¬
		buttons {"kauperts.de", "vbb.de", "OK"} ¬
		default button 3 ¬
		with title "About VBBar" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
userChoice
EOT)
if [[ "$ABOUT_CHOICE" == "vbb.de" ]] ; then
	/usr/bin/open "http://www.vbb.de"
elif [[ "$ABOUT_CHOICE" == "kauperts.de" ]] ; then
	/usr/bin/open "https://berlin.kauperts.de/Strassenverzeichnis"
fi

exit