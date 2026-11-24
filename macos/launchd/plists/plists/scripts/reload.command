#!/usr/bin/env bash

( set -x; find /Volumes/HDD/var/postgres -name postmaster.pid -exec rm {} + )

( set -x; find "$HOME/Library/LaunchAgents" -name "*.plist" -exec sh -c '
    for plist; do
        label=$(plutil -extract Label raw "$plist" 2>/dev/null) || continue
        launchctl bootstrap "gui/$UID" "$plist" 2>/dev/null
        launchctl enable "gui/$UID/$label" 2>/dev/null
        launchctl kickstart -kp "gui/$UID/$label"
    done
' _ {} + ) || exit 1

launchctl list | grep -Ff <(
    for plist in "$HOME/Library/LaunchAgents/"*.plist; do
        plutil -extract Label raw "$plist" 2>/dev/null
    done
)
