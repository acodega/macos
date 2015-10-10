#!/bin/sh

# kill and relaunch Google Chrome in kiosk mode

killall Google\ Chrome

sleep 5

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --kiosk