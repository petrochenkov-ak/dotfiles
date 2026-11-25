#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write org.m0k.transmission

# Trash original torrent files
"$@" DeleteOriginalTorrent -bool TRUE

# Hide the donate message
"$@" WarningDonate -bool FALSE

# Hide the legal disclaimer
"$@" WarningLegal -bool FALSE

# Don’t prompt for confirmation before downloading
# defaults write org.m0k.transmission DownloadAsk -bool false

# Use `~/Documents/Torrents` to store incomplete downloads
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string ~/Downloads/Torrents
