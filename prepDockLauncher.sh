#!/bin/bash

# Define LaunchDaemon variables
launchdaemon_identifier="com.contoso.docksettings"
launchdaemon_filepath="/Library/LaunchDaemons/${launchdaemon_identifier}.plist"
launchdaemon_program_filepath="/tmp/setDock.sh"
launchdaemon_watchpath="/Applications/zoom.us.app"

# Create LaunchDaemon that launches script after last Auto App is installed
cat <<EOF > "${launchdaemon_filepath}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>${launchdaemon_identifier}</string>
        <key>Program</key>
        <string>${launchdaemon_program_filepath}</string>
        <key>RunAtLoad</key>
        <false/>
        <key>WatchPaths</key>
        <array>
            <string>${launchdaemon_watchpath}</string>
        </array>
    </dict>
</plist>
EOF

# Create program script
cat <<EOF > "${launchdaemon_program_filepath}"
#!/bin/zsh
autoload is-at-least
installedOSversion=\$(sw_vers -productVersion)
launchdaemon_filepath="/Library/LaunchDaemons/com.contoso.docksettings.plist"
currentUser=\$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print \$3 }' )
uid=\$(id -u "\$currentUser")
echo "\$currentUser and \$uid"

if is-at-least 13 "\$installedOSversion"; then
  settingsPath=/System/Applications/System\ Settings.app
  else
    settingsPath=/System/Applications/System\ Preferences.app
fi

runAsUser() {  
  if [ "\$currentUser" != "loginwindow" ]; then
    launchctl asuser "\$uid" sudo -u "\$currentUser" "\$@"
  else
    echo "no user logged in"
  fi
}

dock_item() {
  printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>', "\$1"
}

sleep 5

runAsUser defaults write com.apple.terminal SecureKeyboardEntry -bool "true"
runAsUser defaults delete com.apple.dock persistent-apps
runAsUser defaults write com.apple.dock "show-recents" -bool "false"

runAsUser defaults write com.apple.dock persistent-apps -array \
  "\$(dock_item /System/Applications/Launchpad.app)" \
  "\$(dock_item /Applications/Google\ Chrome.app)" \
  "\$(dock_item /Applications/Slack.app)" \
  "\$(dock_item /Applications/zoom.us.app)" \
  "\$(dock_item /Applications/Self Service.app)" \
  "\$(dock_item "\$settingsPath")"

killall Dock

launchctl unload "\${launchdaemon_filepath}"
rm "\${launchdaemon_filepath}"
rm "/tmp/setDock.sh"

exit 0

EOF

chmod a+x "${launchdaemon_program_filepath}"

# Load LaunchDaemon
launchctl load "${launchdaemon_filepath}"

# Exit
exit 0
