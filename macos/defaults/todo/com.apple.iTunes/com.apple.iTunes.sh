#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.iTunes

# Disable radio stations in iTunes
"$@" disableCheckForUpdates -bool TRUE

# Disable the Genius sidebar in iTunes
"$@" disableGeniusSidebar -bool TRUE

# Disable all the other Ping stuff in iTunes
"$@" disablePing -bool TRUE

# Disable the Ping sidebar in iTunes
"$@" disablePingSidebar -bool TRUE

# Disable radio stations in iTunes
"$@" disableRadio -bool TRUE

"$@" show-store-link-arrows -bool FALSE
