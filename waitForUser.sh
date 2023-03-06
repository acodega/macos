#!/bin/bash

# Bash/zsh snippet to wait until Setup Assistant is complete and the user is logged in 

waitForUser(){
    setupAssistantProcess=$(pgrep -l "Setup Assistant")
    until [ "$setupAssistantProcess" = "" ]; do
        echo "Setup Assistant Still Running. PID $setupAssistantProcess"
        sleep 1
        setupAssistantProcess=$(pgrep -l "Setup Assistant")
    done
    echo "Out of Setup Assistant"
    echo "Logged in user is $(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')"

    finderProcess=$(pgrep -l "Finder")
    until [ "$finderProcess" != "" ]; do
    echo "Finder process not found. Assuming device is at login screen. PID $finderProcess"
        sleep 1
        finderProcess=$(pgrep -l "Finder")
    done
    echo "Finder is running"
    echo "Logged in user is $(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')"
}
