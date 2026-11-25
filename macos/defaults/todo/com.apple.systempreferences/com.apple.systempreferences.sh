#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.systempreferences

# Disable Resume system-wide
"$@" NSQuitAlwaysKeepsWindows -bool FALSE
