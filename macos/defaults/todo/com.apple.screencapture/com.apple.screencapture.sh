#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults com.apple.screencapture

"$@" location -string ~/Desktop
"$@" type -string png
"$@" disable-shadow -bool FALSE
