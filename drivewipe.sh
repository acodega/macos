#!/bin/bash
# Written by Rusty Myers
# 2013-07-12
# Erase FV Volume
# Uses rtroutons code: https://github.com/rtrouton/rtrouton_scripts/blob/master/rtrouton_scripts/filevault_2_encryption_check/filevault_2_status_check.sh
# updated #1

function Log ()
{
    logText=$1
    # indent lines except for program entry and exit
    if [[ "${logText}" == "-->"* ]];then
        logText="${logText} : launched..."
    else
        if [[ "${logText}" == "<--"* ]];then
            logText="${logText} : ...terminated"
        else
        logText="   ${logText}"
        fi
    fi
    date=$(/bin/date)
    echo "${date/E[DS]T /} ${logText}"
}

function buildDiskArray () {
    # Resent Variables
    SSD=""
    HDD=""
    UUID=""
    DiskListArrayNumber=0
    DiskList=""
    # Reset Array
    unset DiskListArray
    GROUPNAME="CLCLVG"

    # Build array of internal disks in Mac (disk0, disk1, disk2, etc...)
    DiskList=$(diskutil list | grep -i ^/dev | awk '{print $1}')

    for i in $DiskList; do
        # Run through each disk connected
        # put each disk's info into a plist
        diskutil info -plist $i > "$TMP_LOCATION/tmpdisk.plist"
        # Yes if internal
        if [[ $(defaults read "$TMP_LOCATION/tmpdisk.plist" Internal) == 1 ]]; then
            Log "Disk $i is Internal"
            Log "Disk array number: $DiskListArrayNumber"
            # Set array with internal disk
            DiskListArray[$DiskListArrayNumber]="$i"
            # Increment array
            DiskListArrayNumber=$(expr $DiskListArrayNumber + 1)
        fi
    done
    Log "There are ${#DiskListArray[@]} internal disks in the DiskListArray"
}

function ifError () {
    # check return code passed to function
    exitStatus=$?
    if [[ $exitStatus -ne 0 ]]; then
    # if rc > 0 then print error msg and quit
    echo -e "$0 Time:$TIME $1 Exit: $exitStatus"
    exit $exitStatus
    fi
}

Log "-->"
Log "Hello Computer."

# Variables
TIME=`date "+2013-07-12-21-43-51"`
VOLUMENAME="Macintosh HD"
# net install env have the /System/Installation/ as rw
TMP_LOCATION="/private/tmp"
CORESTORAGESTATUS="$TMP_LOCATION/corestatus.txt"

# Check for the number of internal disks
buildDiskArray

# If there is one internal drive, there is NO LVG
if [[ "${#DiskListArray[@]}" -lt 2 ]];then
    # one disk means disk 0 is our target
    Log "Internal Disk: ${DiskListArray[0]}"
    INTERNALDISK="${DiskListArray[0]}"

    diskutil cs info "$INTERNALDISK" > "$CORESTORAGESTATUS" 2>&1

    # If the Mac is running 10.7 or higher, but the boot volume
    # is not a CoreStorage volume, the following message is
    # displayed without quotes:
    #
    # "FileVault 2 Encryption Not Enabled"

    if grep -iE 'is not a CoreStorage disk' $CORESTORAGESTATUS 1>/dev/null; then
       Log "FileVault 2 Encryption Not Enabled"
       rm -f "$CORESTORAGESTATUS"
       # do one pass wipe
       diskutil secureErase 1 "$INTERNALDISK"
       ifError "Erasing internal disk $INTERNALDISK failed. We've got to do this by hand!"
    else
       Log "FileVault 2 Encryption is Enabled"
       CoreStorageUUID=`/usr/sbin/diskutil cs list | awk '/Logical Volume Group/ {print $5}'`
       /usr/sbin/diskutil cs delete $CoreStorageUUID
       ifError "Erasing internal disk $INTERNALDISK failed. We've got to do this by hand!"
    fi
    Log "************"
    Log "******  All Done. Thanks!  ******"
    Log "************"

fi
Log "<--"

exit 0
