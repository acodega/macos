#!/bin/zsh --no-rcs
#set -x

# Get the currently logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser")

# Run a command as the currently logged in user
RunAsUser() {  
	if [ "$currentUser" != "loginwindow" ]; then
		launchctl asuser "$uid" sudo -u "$currentUser" "$@"
	else
		echo "No user logged in, cannot proceed"
		# uncomment the exit command
		# to make the function exit with an error when no user is logged in
		exit 1
	fi
}	

# Get the current appearance
setAppearance=$(RunAsUser defaults read -g AppleInterfaceStyle 2>/dev/null)
setAutoAppearance=$(RunAsUser defaults read -g AppleInterfaceStyleSwitchesAutomatically 2>/dev/null)

# Check if the appearance is set to Light, Dark, or Auto.
if [ -z "$setAppearance" ] && [ -z "$setAutoAppearance" ]; then
	appearance="Light"
elif [ "$setAutoAppearance" = 1 ] && [ -z "$setAppearance" ]; then
	appearance="Auto (Light)"
elif  "$setAutoAppearance" = 1 ] && [ "$setAppearance" = Dark ]; then
	appearance="Auto (Dark)" 
else
	appearance="Dark"
fi

echo "<result>$appearance</result>
