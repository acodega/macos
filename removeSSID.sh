#!/bin/sh

#
# Check if an SSID exists and delete it if it does.
# Change the wifinetwork variable to the name of your SSID.
#

wifiNetwork="Contoso Inc"
searchResult=$(networksetup -listpreferredwirelessnetworks en0 | grep $wifiNetwork)

# Search for it
if [ "$searchResult" = "" ]; then
    echo "No $wifiNetwork SSID Found"
    exit 0
else
    echo "$wifiNetwork SSID Found, Removing..."
fi

# Delete it
networksetup -removepreferredwirelessnetwork en0 $wifiNetwork
echo "$wifiNetwork SSID Removed"
exit 0
