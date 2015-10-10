#!/bin/sh

#
# Check if Swipely Inc SSID exists and delete it if it does.
#

# Grep for it
result=`networksetup -listpreferredwirelessnetworks en0 | grep Swipely\ Inc`

# If it
if [ "$result" = "" ]; then
    echo "No Inc SSID Found"
    exit 0
else
    echo "Inc SSID Found, Removing..."
fi

# Delete it
networksetup -removepreferredwirelessnetwork en0 Swipely\ Inc
echo "Inc SSID Removed"
exit 0