#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.loginwindow

"$@" AdminHostInfo -string HostName

