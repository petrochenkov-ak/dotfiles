# ( set -x; launchctl list | grep postgresql );:
launchctl list | grep -Ff <(plutil -extract Label raw "$HOME/Library/LaunchAgents/"*.plist 2>/dev/null);:
