#!/bin/zsh --no-rcs

if [ -e /Applications/zoom.us.app ]; then
    zoomStatus=$(/usr/libexec/PlistBuddy -c "print ZITPackage" /Applications/zoom.us.app/Contents/Info.plist 2>/dev/null)
else echo "Zoom not installed"
exit 0
fi

if [[ $zoomStatus == true ]]; then
    zoomAppType="zoomforIT"
else zoomAppType="consumer"
fi

echo "Zoom installed is $zoomAppType"
