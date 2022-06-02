#!/bin/bash

dmgNameIntel="Endpoint_for_MAC.dmg"
dmgNameARM="Endpoint_for_MAC_ARM.dmg"
downloadURLIntel="https://your-url.com/bitdefender/$dmgNameIntel"
downloadURLARM="https://your-url.com/bitdefender/$dmgNameARM"
pkgNameIntel="antivirus_for_mac.pkg"
pkgNameARM="antivirus_for_mac_arm.pkg"
expectedTeamID="GUNFMW623Y"
workDirectory=$( /usr/bin/basename "$0" )
tempDirectory=$( /usr/bin/mktemp -d "/private/tmp/$workDirectory.XXXXXX" )

printlog(){
  timestamp=$(date +%F\ %T)    
  echo "$timestamp" "BitDefender Install" "$1"
}

cleanupAndExit() { # $1 = exit code, $2 message
  if [[ -n $2 && $1 -ne 0 ]]; then
      printlog "ERROR: $2"
  fi
  if [ -n "$dmgMount" ]; then
      # unmount disk image
      printlog "Unmounting $dmgMount"
      sleep 2
      hdiutil detach "$dmgMount"
  fi
  exit "$1"
}

determinePlatform() {
  if [[ $(arch) == "arm64" ]]; then
    downloadURL="$downloadURLARM"
    dmgName="$dmgNameARM"
    pkgName="$pkgNameARM"
  elif [[ $(arch) == "i386" ]]; then
    downloadURL="$downloadURLIntel"
    dmgName="$dmgNameIntel"
    pkgName="$pkgNameIntel"
fi
}

mountDMG() {
  # mount the dmg
  printlog "Mounting $tempDirectory/$dmgName"
  # always pipe 'Y\n' in case the dmg requires an agreement
  if ! dmgMount=$(printlog 'Y'$'\n' | hdiutil attach "$tempDirectory/$dmgName" -nobrowse -readonly | tail -n 1 | cut -c 54- ); then
    cleanupAndExit 3 "Error mounting $tempDirectory/$dmgName"
  fi

  if [[ ! -e $dmgMount ]]; then
    printlog "Error mounting $tempDirectory/$dmgName"
    cleanupAndExit 3
  fi

  printlog "Mounted: $dmgMount"
}

# check for installation and exit if found
if [ -e "/Applications/Endpoint Security for Mac.app" ]; then
  printlog "Endpoint Security for Mac found. Exiting."
    cleanupAndExit 0
else printlog "Endpoint Security for Mac not found. Proceeding..."
fi

# create temporary working directory
printlog "Created working directory '$tempDirectory'"

determinePlatform

# download the installer dmg
printlog "Downloading dmg $downloadURL"
/usr/bin/curl --silent --location "$downloadURL" -o "$tempDirectory/$dmgName"

mountDMG

# Get the Team ID
teamID=$(/usr/sbin/spctl -a -vv -t install "$dmgMount/$pkgName" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()')
printlog "Team ID for downloaded package: $teamID"

# install the package if Team ID validates
if [ $expectedTeamID = "$teamID" ] || [ "$expectedTeamID" = "" ]; then
  printlog "Installing package $pkgName"
  /usr/sbin/installer -pkg "$dmgMount"/"$pkgName" -target /
  exitCode=0
else
  printlog "Package verification failed before package installation could start. Download link may be invalid."
  exitCode=1
fi

cleanupAndExit $exitCode
