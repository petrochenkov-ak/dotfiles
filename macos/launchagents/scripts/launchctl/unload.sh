( set -x; find ~/Library/LaunchAgents -name "postgresql.*.plist" -exec launchctl bootout gui/$UID {} 2>/dev/null \; ) || exit
( set -x; find /Volumes/HDD/var/postgres -name postmaster.pid -exec rm {} \; )
