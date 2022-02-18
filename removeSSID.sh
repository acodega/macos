#!/bin/sh

#
# Check if an SSID exists and delete it if it does.
# Change the wifinetwork variable to the name of your SSID.
# Turn Wi-Fi off and on in order to disconnect from the removed network.
#

wifiInterface=$(/usr/sbin/networksetup -listallhardwareports | /usr/bin/awk '/Wi-Fi|AirPort/ {getline; print $NF}')
wifiNetwork="Contoso Inc"
searchResult=$(networksetup -listpreferredwirelessnetworks en0 | grep "$wifiNetwork")

# Search for it
if [ "$searchResult" = "" ]; then
    echo "No $wifiNetwork SSID Found"
    exit 0
else
    echo "$wifiNetwork SSID Found, Removing..."
fi

# Delete it
networksetup -removepreferredwirelessnetwork $wifiInterface "$wifiNetwork"

networksetup -setairportpower $wifiInterface off
sleep 0.5
networksetup -setairportpower $wifiInterface on
