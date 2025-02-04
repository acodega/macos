#!/bin/bash
# Turn on Location Services programmatically
#
# People travel. Don't set the time zone manually.
#
# Adam Codega
# github.com/acodega
#
# Tested on macOS Sequoia 15.1.1 and earlier
#
# pre-SIP commands have been left for historical/education reasons
# Mac has to restart after running, Location Services will be enabled then
#

# unload locationd for pre-SIP systems, comment this out if SIP
# /bin/launchctl unload /System/Library/LaunchDaemons/com.apple.locationd.plist

# write enabled value to locationd plist
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1

# fix ownership of the locationd folder, just to be safe, comment this out if SIP
# /usr/sbin/chown -R _locationd:_locationd /var/db/locationd

# reload locationd for pre-SIP systems
# /bin/launchctl load /System/Library/LaunchDaemons/com.apple.locationd.plist
