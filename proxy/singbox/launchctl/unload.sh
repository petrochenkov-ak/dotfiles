#!/bin/bash

PLIST_FILE="$HOME/Library/LaunchAgents/com.singbox.macos.plist"

( set -x; launchctl bootout gui/$UID "$PLIST_FILE" )
