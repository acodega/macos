#!/bin/zsh --no-rcs
# shellcheck shell=bash
# set -x

# setDefaultBrowser.zsh
# v0.1

# This sets Chrome as the default browser without a prompt or restart needed.
# Call it a bug, Apple may fix this so it doesn't work in the future

currentUser=$(scutil <<<"show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')

if [ -z "$currentUser" ] || [ "$currentUser" = "loginwindow" ]; then
    exit 1
fi

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

sudo -u "$currentUser" /usr/bin/defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerRoleAll='"com.google.Chrome"';LSHandlerURLScheme=http;}'
sudo -u "$currentUser" /usr/bin/defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerRoleAll='"com.google.Chrome"';LSHandlerURLScheme=https;}'
sudo -u "$currentUser" /usr/bin/defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.html;LSHandlerRoleAll='"com.google.Chrome"';}'
sudo -u "$currentUser" /usr/bin/defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add '{LSHandlerContentType=public.xhtml;LSHandlerRoleAll='"com.google.Chrome"';}'

/usr/bin/killall cfprefsd
/usr/bin/killall -HUP lsd
