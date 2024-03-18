#!/bin/bash

if [ -e /Applications/zoom.us.app ]; then
    zoomStatus=$(/usr/libexec/PlistBuddy -c "print ZITPackage" /Applications/zoom.us.app/Contents/Info.plist 2>/dev/null)
else echo "Zoom not installed"
exit 0
fi

if [[ $zoomStatus == true ]]; then
    zoomAppType="zoomforIT"
    echo "Zoom installed is already $zoomAppType"
    exit 0
else zoomAppType="consumer"
fi

echo "Zoom installed is $zoomAppType"

assertedApps="$(/usr/bin/pmset -g assertions | /usr/bin/awk '/NoDisplaySleepAssertion | PreventUserIdleDisplaySleep/ && match($0,/\(.+\)/) && ! /coreaudiod/ {gsub(/^.*\(/,"",$0); gsub(/\).*$/,"",$0); print};')"

if [[ "${assertedApps}" =~ zoom.us ]]; then
    echo "Zoom is running and in a video call."
    echo exit 1
fi

echo "Safe to update Zoom now. Proceeding.."

/usr/local/Installomator/Installomator.sh zoom NOTIFY=silent BLOCKING_PROCESS_ACTION=ignore INSTALL=force

if pgrep -xq "zoom.us"; then
    echo "Zoom is open, let's close and reopen it"
    killall "zoom.us"
    open -j -h "/Applications/zoom.us.app"
fi

exit 0