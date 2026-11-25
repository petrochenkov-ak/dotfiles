#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set defaults write com.apple.finder

# show hidden files by default
"$@" AppleShowAllFiles -bool TRUE

# Desktop Icons
"$@" CreateDesktop -bool FALSE

# disable window animations and Get Info animations
"$@" DisableAllAnimations -bool FALSE

# When performing a search, search the current folder by default
"$@" FXDefaultSearchScope -string SCcf

# Disable the warning when changing a file extension
"$@" FXEnableExtensionChangeWarning -bool false

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
"$@" FXPreferredViewStyle -string Nlsv

# New window points to HOME
"$@" NewWindowTarget -string PfHm

# Quick Look
"$@" QLEnableTextSelection -bool TRUE # allow text selection
"$@" QLEnableXRayFolders -bool TRUE

"$@" ShowStatusBar -bool TRUE
"$@" ShowPathbar -bool TRUE

# Hide icons for hard drives, servers, and removable media on the desktop
"$@" ShowExternalHardDrivesOnDesktop -bool FALSE
"$@" ShowHardDrivesOnDesktop -bool FALSE
"$@" ShowMountedServersOnDesktop -bool FALSE
"$@" ShowRemovableMediaOnDesktop -bool FALSE

"$@" WarnOnEmptyTrash -bool FALSE
