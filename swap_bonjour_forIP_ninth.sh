#!/bin/bash

#
# Let's get rid of a Bonjour printer and install at as IP
# We could check for the printer first with If but it's already 4PM
#

#Kill the Batman--I mean The Printer
lpadmin -x HP_X576dw__Floor_9_South_

#Install it via IP and make sure printer sharing is not on
lpadmin -p "HP-576dw-9-S" -D "HP X576dw (9 South)" -E -v lpd://192.168.60.5 -P "/Library/Printers/PPDs/Contents/Resources/HP Officejet Pro X476-X576 MFP.gz" -o printer-is-shared=false
