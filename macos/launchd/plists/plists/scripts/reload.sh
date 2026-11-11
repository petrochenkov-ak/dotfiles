( set -x; find /Volumes/HDD/var/postgres -name postmaster.pid -exec rm {} \; )
( set -x; find ~/Library/LaunchAgents -name "*.plist" -exec sh -c '
    for plist; do
        launchctl bootstrap "gui/$UID" "$plist" 2>/dev/null

        label=$(plutil -extract Label raw "$plist")
        launchctl enable "gui/$UID/$label" 2>/dev/null
        launchctl kickstart -kp "gui/$UID/$label"
    done
' _ {} + ) || exit
launchctl list | grep -Ff <(plutil -extract Label raw "$HOME/Library/LaunchAgents/"*.plist 2>/dev/null);:
