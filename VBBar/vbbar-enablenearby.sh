#!/bin/bash

# subscript for VBBar BitBar plugin
# ENABLE NEARBY STATION UPDATES AND INFORMATION

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
PREFS="local.lcars.VBBar"

DISABLED_STATIONS=$(defaults read "$PREFS" disabledNearby 2>/dev/null | /usr/bin/sed 's/[(,)]//g' | /usr/bin/sed '/^$/d' | /usr/bin/sed "s/^[ \t]*//")
LINE_COUNT=$(echo "$DISABLED_STATIONS" | /usr/bin/wc -l | xargs)
if [[ "$LINE_COUNT" == "1" ]] ; then
	defaults write "$PREFS" disabledNearby -array
else
	DIFF=$(/usr/bin/comm -13 <( echo "$1" | /usr/bin/sort -n ) <( echo "$DISABLED_STATIONS" | /usr/bin/sort -n ) | xargs)
	defaults write "$PREFS" disabledNearby -array "$DIFF"
fi

/usr/bin/open "bitbar://refreshPlugin?name=VBBar.*?.sh"

exit