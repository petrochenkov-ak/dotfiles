#!/usr/bin/env bash
{ set +x; } 2>/dev/null

# disable Game Center daemon
defaults write com.apple.gamed Disabled -bool true
