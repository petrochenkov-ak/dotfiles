( set -x; find /Volumes/HDD/var/postgres -name postmaster.pid -exec rm {} \; )
( set -x; find ~/Library/LaunchAgents -name "postgresql.*.plist" -exec sh -c '
    for plist; do
        label=$(plutil -extract Label raw "$plist")
        launchctl enable "gui/$UID/$label" 2>/dev/null
        launchctl kickstart -kp "gui/$UID/$label"
    done
' _ {} + ) || exit
( set -x; launchctl list | grep postgresql );:
