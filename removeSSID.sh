#!/bin/sh

#
# Check if an SSID exists and delete it if it does.
# Change the wifinetwork variable to the name of your SSID.
# Turn Wi-Fi off and on in order to disconnect from the removed network.
#

wifiInterface=$(networksetup -listallhardwareports | /usr/bin/awk '/Wi-Fi|AirPort/ {getline; print $NF}')
wifiNetwork="Contoso Inc"
activeWiFiNetwork=$(networksetup -getairportnetwork $wifiInterface | cut -c 24-)
searchResult=$(networksetup -listpreferredwirelessnetworks $wifiInterface | grep "$wifiNetwork")

# Search for it
# Depending on your needs you may have nothing else to do, uncomment line 18 if so
if [ "$searchResult" = "" ]; then
    echo "No saved $wifiNetwork found"
#    exit 0
else
    echo "$wifiNetwork found as a saved network. Removing.."
fi

# Delete it
networksetup -removepreferredwirelessnetwork $wifiInterface "$wifiNetwork"

# Check active SSID
if [ "$activeWiFiNetwork" = "$wifiNetwork" ]; then
    echo "Not currently connected to $wifiNetwork"
    exit 0
else
    echo "$wifiNetwork found as an active network, power cycling..."
fi

# Power cycle Wi-Fi so network is disconnected
networksetup -setairportpower $wifiInterface off
sleep 0.5
networksetup -setairportpower $wifiInterface on
