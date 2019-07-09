#!/bin/bash

#
# Purpose: Removes all non-local accounts on computers to help stop drives from filling up.
# Will spare the 'ladmin' and 'Shared' home directories.
#

users=$(find /Users -type d -maxdepth 1 | cut -d"/" -f3)

echo "Time to clean users.."
echo "Found these $users"
echo "Removing users.."

for i in $users; do
  if [[ $i = "ladmin" ]] || [[ $i = "Shared" ]]; then continue
  else
  	echo "Removing $i.."
    rm -Rf /Users/"$i"
  fi
done

echo "Finished cleaning users."
