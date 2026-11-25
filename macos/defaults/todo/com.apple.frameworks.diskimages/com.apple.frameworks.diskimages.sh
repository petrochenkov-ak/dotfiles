#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.frameworks.diskimages

# Disable disk image verification
"$@" skip-verify -bool TRUE
"$@" skip-verify-locked -bool TRUE
"$@" skip-verify-remote -bool TRUE

# Automatically open a new Finder window when a volume is mounted
# defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
"$@" auto-open-ro-root -bool TRUE
"$@" auto-open-rw-root -bool TRUE
