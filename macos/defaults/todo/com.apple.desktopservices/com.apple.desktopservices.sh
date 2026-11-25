#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
