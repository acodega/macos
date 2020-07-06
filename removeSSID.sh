#!/bin/sh

#
# Check if Swipely Inc SSID exists and delete it if it does.
#

wifinetwork="Swipely Inc"
searchresult=$(networksetup -listpreferredwirelessnetworks en0 | grep $wifinetwork)

# If it
if [ "$result" = "" ]; then
    echo "No $wifinetwork SSID Found"
    exit 0
else
    echo "$wifinetwork SSID Found, Removing..."
fi

# Delete it
networksetup -removepreferredwirelessnetwork en0 $wifinetwork
echo "$wifinetwork SSID Removed"
exit 0
