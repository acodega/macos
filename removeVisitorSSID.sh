#!/bin/sh

#
# Check if Swipely Visitor SSID exists and delete it if it does.
#

# Grep for it
vresult=`networksetup -listpreferredwirelessnetworks en0 | grep Swipely\ Visitor`

# If it
if [ "$vresult" = "" ]; then
    echo "No Visitor SSID Found"
    exit 0
else
    echo "Visitor SSID Found, Removing..."
fi

# Delete it
networksetup -removepreferredwirelessnetwork en0 Swipely\ Visitor
echo "Visitor SSID Removed"
exit 0