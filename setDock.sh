#!/bin/zsh --no-rcs

# Tested successfully on macOS Monterey and macOS Ventura

autoload is-at-least
installedOSversion=$(sw_vers -productVersion)
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser")

if is-at-least 13 "$installedOSversion"; then
  settingsPath=/System/Applications/System\ Settings.app
  else
    settingsPath=/System/Applications/System\ Preferences.app
fi

runAsUser() {  
  if [ "$currentUser" != "loginwindow" ]; then
    launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
    echo "No user logged in, exiting."
    exit 1
  fi
}

dock_item() {
  printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>', "$1"
}

runAsUser defaults delete com.apple.dock persistent-apps
runAsUser defaults write com.apple.dock "show-recents" -bool "false"

runAsUser defaults write com.apple.dock persistent-apps -array \
  "$(dock_item /System/Applications/Launchpad.app)" \
  "$(dock_item /Applications/Google\ Chrome.app)" \
  "$(dock_item /Applications/Slack.app)" \
  "$(dock_item /Applications/zoom.us.app)" \
  "$(dock_item "$settingsPath")"

killall Dock

exit 0
