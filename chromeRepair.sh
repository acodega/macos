#!/bin/bash

loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}' )
url="https://dl.google.com/chrome/mac/stable/accept_tos%3Dhttps%253A%252F%252Fwww.google.com%252Fintl%252Fen_ph%252Fchrome%252Fterms%252F%26_and_accept_tos%3Dhttps%253A%252F%252Fpolicies.google.com%252Fterms/googlechrome.pkg"
expectedTeamID="EQHXZ8M8AV"

paths=(
  "/Applications/Google Chrome.app"
  "/Library/LaunchAgents/com.google.keystone*"
  "/Library/LaunchAgents/com.google.Keystone*"
  "/Library/Preferences/com.google.keystone*"
  "/Library/Google/Chrome/"
  "/Library/Application Support/Google/Chrome/"
  "/var/db/receipts/com.google.Chrome.bom"
  "/var/db/receipts/com.google.Chrome.plist"
)

for path in "${paths[@]}"; do
  if [ ! -e "${path}" ]; then
    echo "Not found: '${path}'"
  else
    echo "Found: '${path}'"
    rm -rf "${path}" && echo "'${path}' deleted"
  fi
done

sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Application\ Support/Google/Chrome/
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Application\ Support/Google/RLZ
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Application\ Support/CrashReporter/Google\ Chrome*
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Preferences/com.google.Chrome*
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Caches/com.google.Chrome*
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Saved\ Application\ State/com.google.Chrome.savedState/
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Google/GoogleSoftwareUpdate/Actives/com.google.Chrome
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Google/Google\ Chrome*
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/LaunchAgents/com.google.*
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Preferences/com.google.Chrome.plist
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Preferences/com.google.Keystone.Agent.plist
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Library/Caches/com.google.*
sudo -u "$loggedInUser" rm -rf /Users/"$loggedInUser"/Applications/Chrome\ Apps.localized/

# create temporary working directory
workDirectory=$( /usr/bin/basename "$0" )
tempDirectory=$( /usr/bin/mktemp -d "/private/tmp/$workDirectory.XXXXXX" )
echo "Created working directory '$tempDirectory'"

# download the installer package
echo "Downloading Chrome package"
/usr/bin/curl --location --silent "$url" -o "$tempDirectory/Chrome.pkg"

# verify the download
teamID=$(/usr/sbin/spctl -a -vv -t install "$tempDirectory/Chrome.pkg" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()')
echo "Team ID for downloaded package: $teamID"

# install the package if Team ID validates
if [ "$expectedTeamID" = "$teamID" ] || [ "$expectedTeamID" = "" ]; then
  echo "Package verified. Installing package Chrome.pkg"
  /usr/sbin/installer -pkg "$tempDirectory/Chrome.pkg" -target /
  exitCode=0
else
    echo "Package verification failed before package installation could start. Download link may be invalid."
    exitCode=1
fi

# remove the temporary working directory when done
echo "Deleting working directory '$tempDirectory' and its contents"
/bin/rm -Rf "$tempDirectory"

sudo -u "$loggedInUser" osascript -e "display alert \"Google Chrome has been repaired\" message \"Google Chrome was been removed and reinstalled. Please open Google Chrome now to test.\""

exit $exitCode