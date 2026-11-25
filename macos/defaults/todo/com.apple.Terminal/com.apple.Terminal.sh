#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.Terminal

# Restore profiles: Settings -> Profiles -> Default profiles

# Default Window Settings
"$@" "Default Window Settings" -string Pro
"$@" "FocusFollowsMouse" -bool TRUE

"$@" "FontAntialias" -int 1

# UTF-8 Only in Terminal.app
"$@" "StringEncodings" -array 4

"$@" "Shell" -string "/bin/bash"

"$@" "Startup Window Settings" -string "Pro"

"$@" "TerminalOpaqueness" -int 1

