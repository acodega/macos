#!/bin/bash

# Should be in the format domain.vendor.app (e.g. com.google.chrome or com.apple.safari)
browserAgentString="com.google.chrome"

# Should be in the format domain.vendor.app (e.g. com.google.chrome or com.apple.mail)
emailAgentString="com.google.chrome"

loggedInUser=$(/usr/bin/stat -f%Su "/dev/console")
loggedInUserHome=$(/usr/bin/dscl . -read "/Users/$loggedInUser" NFSHomeDirectory | /usr/bin/awk '{print $NF}')
launchServicesPlistFolder="$loggedInUserHome/Library/Preferences/com.apple.LaunchServices"
launchServicesPlist="$launchServicesPlistFolder/com.apple.launchservices.secure.plist"
plistbuddyPath="/usr/libexec/PlistBuddy"
plistbuddyPreferences=(
  "Add :LSHandlers:0:LSHandlerRoleAll string $browserAgentString"
  "Add :LSHandlers:0:LSHandlerURLScheme string http"
  "Add :LSHandlers:1:LSHandlerRoleAll string $browserAgentString"
  "Add :LSHandlers:1:LSHandlerURLScheme string https"
  "Add :LSHandlers:2:LSHandlerRoleViewer string $browserAgentString"
  "Add :LSHandlers:2:LSHandlerContentType string public.html"
  "Add :LSHandlers:3:LSHandlerRoleViewer string $browserAgentString"
  "Add :LSHandlers:3:LSHandlerContentType string public.url"
  "Add :LSHandlers:4:LSHandlerRoleViewer string $browserAgentString"
  "Add :LSHandlers:4:LSHandlerContentType string public.xhtml"
  "Add :LSHandlers:5:LSHandlerRoleAll string $emailAgentString"
  "Add :LSHandlers:5:LSHandlerURLScheme string mailto"
)
lsregisterPath="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

########## main process ##########

# Clear out LSHandlers array data from $launchServicesPlist, or create new plist if file does not exist.
if [[ -e "$launchServicesPlist" ]]; then
  "$plistbuddyPath" -c "Delete :LSHandlers" "$launchServicesPlist"
  echo "Reset LSHandlers array from $launchServicesPlist."
else
  /bin/mkdir -p "$launchServicesPlistFolder"
  "$plistbuddyPath" -c "Save" "$launchServicesPlist"
  echo "Created $launchServicesPlist."
fi

# Add new LSHandlers array.
"$plistbuddyPath" -c "Add :LSHandlers array" "$launchServicesPlist"
echo "Initialized LSHandlers array."

# Set handler for each URL scheme and content type to specified browser and email client.
for plistbuddyCommand in "${plistbuddyPreferences[@]}"; do
  "$plistbuddyPath" -c "$plistbuddyCommand" "$launchServicesPlist"
  if [[ "$plistbuddyCommand" = *"$browserAgentString"* ]] || [[ "$plistbuddyCommand" = *"$emailAgentString"* ]]; then
    arrayEntry=$(echo "$plistbuddyCommand" | /usr/bin/awk -F: '{print $2 ":" $3 ":" $4}' | /usr/bin/sed 's/ .*//')
    prefLabel=$(echo "$plistbuddyCommand" | /usr/bin/awk '{print $4}')
    echo "Set $arrayEntry to $prefLabel."
  fi
done

# Fix permissions on $launchServicesPlistFolder.
/usr/sbin/chown -R "$loggedInUser" "$launchServicesPlistFolder"
echo "Fixed permissions on $launchServicesPlistFolder."

# Reset Launch Services database.
"$lsregisterPath" -kill -r -domain local -domain system -domain user
echo "Reset Launch Services database. A restart may also be required for these new default client changes to take effect."

# Try to modify CHrome so it doesn't prompt for first run. I think this is not needed if you use GCBM/config profiles
# if [ ! -d $loggedInUserHome/Library/Application\ Support/Google/Chrome ]; then
#   echo "Chrome has not been launched. Doing the needed prep.."
#   /bin/mkdir -p $loggedInUserHome/Library/Application\ Support/Google/Chrome
#   /usr/bin/touch $loggedInUserHome/Library/Application\ Support/Google/Chrome/First\ Run
#   /usr/sbin/chown -R "$loggedInUser" $loggedInUserHome/Library/Application\ Support/Google/Chrome
# fi

exit 0
