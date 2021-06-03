#!/bin/bash
# 
# Check /etc/hosts and add entry if it's not found
#

SUCCESS=0
domain=domain.com
needle=subdomain.$domain
hostline="127.0.0.1 $needle"
filename=/etc/hosts

# Determine if the line already exists in /etc/hosts
grep -q "$needle" "$filename"  # -q is for quiet. Shhh...

# Grep's return error code can then be checked. No error=success
if [ $? -eq $SUCCESS ]
then
  exit 0;
else
  # If the line wasn't found, add it using an echo append >>
  echo "$hostline" >> "$filename"
    # Let's recheck to be sure it was added.
    grep -q "$needle" "$filename"

    if [ $? -eq $SUCCESS ]
        then
            exit 0;
        else
            exit 1;
    fi
fi
