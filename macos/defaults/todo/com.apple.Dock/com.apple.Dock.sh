#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.Dock

# Enable spring loading for all Dock items
"$@" enable-spring-load-actions-on-all-items -bool TRUE

# Don’t group windows by application in Mission Control (i.e. use the old Exposé behavior instead)
"$@" expose-group-by-app -bool FALSE

# Speed up Mission Control animation
"$@" mouse-over-hilite-stack -bool TRUE

# Change minimize/maximize window effect
"$@" mouse-over-hilite-stack -string scale

# Minimize windows into their application’s icon
"$@" minimize-to-application -bool TRUE

# New window points to home
"$@" NewWindowTarget -string PfHm

# Show indicator lights for open applications in the Dock
"$@" show-process-indicators -bool TRUE

"$@" tilesize -int 64

"$@" trash-full -bool TRUE

