#!/bin/bash

#
# Let's get rid of a Bonjour printer and install at as IP
# We could check for the printer first with If but it's already 4PM
#

#Kill the Batman--I mean The Printer
lpadmin -x HP_X576dw__Floor_3_South_
lpadmin -x HP_X476dw__Floor_3_North_

#Install it via IP and make sure printer sharing is not on
lpadmin -p "HP-576dw-3-S" -D "HP X576dw (3 South)" -E -v lpd://192.168.60.53 -P "/Library/Printers/PPDs/Contents/Resources/HP Officejet Pro X476-X576 MFP.gz" -o printer-is-shared=false
lpadmin -p "HP-476dw-3-N" -D "HP X476dw (3 North)" -E -v lpd://192.168.60.51 -P "/Library/Printers/PPDs/Contents/Resources/HP Officejet Pro X476-X576 MFP.gz" -o printer-is-shared=false
