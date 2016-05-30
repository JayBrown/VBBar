#!/bin/bash

# subscript for VBBar BitBar plugin
# ENTER EITHER ACCESS ID FOR THE VBB API OR ACCESS TOKEN FOR THE MAPBOX API

LANG=en_US.UTF-8
ACCOUNT=$(who am i | /usr/bin/awk {'print $1'})
PREFS="local.lcars.VBBar"
VBB_LOGO="VBBLogo.png"

if [[ "$1" == "vbb" ]] ; then
	API_ID_ENTRY=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Preferences:VBBar:$VBB_LOGO"
	set theKey to text returned of (display dialog "Please enter your access ID for the VBB API (demo.hafas). The ID will be stored in your system keychain. Currently VBBar will not output departure and route information without a valid personal ID for the VBB demo system." ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		default answer "" ¬
		with title "Enter VBB API Access ID" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theKey
EOT)
	if [[ "$API_ID_ENTRY" == "" ]] || [[ "$API_ID_ENTRY" == "false" ]] ; then
		exit
	else
		/usr/bin/security add-generic-password -s VBBar_vbb -a "$ACCOUNT" -w "$API_ID_ENTRY"
		defaults write "$PREFS" vbbKeyNotified ""
		defaults write "$PREFS" statusVBB "true"
		/usr/bin/open "bitbar://refreshPlugin?name=VBBar.*?.sh"
		exit
	fi
elif [[ "$1" == "mb" ]] ; then
	MB_TOKEN_ENTRY=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Preferences:VBBar:$VBB_LOGO"
	set theKey to text returned of (display dialog "Please enter your access token for the Mapbox API. The token will be stored in your system keychain. Without a valid token VBBar will not provide any walking distances and directions. Auxiliary information will then be obtained via the public Google Geocoding API." ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		default answer "" ¬
		with title "Enter Mapbox API Access Token" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theKey
EOT)
	if [[ "$MB_TOKEN_ENTRY" == "" ]] || [[ "$MB_TOKEN_ENTRY" == "false" ]] ; then
		exit
	else
		/usr/bin/security add-generic-password -s VBBar_mapbox -a "$ACCOUNT" -w "$MB_TOKEN_ENTRY"
		defaults write "$PREFS" mbKeyNotified ""
		defaults write "$PREFS" statusMB "true"
		/usr/bin/open "bitbar://refreshPlugin?name=VBBar.*?.sh"
		exit
	fi
fi