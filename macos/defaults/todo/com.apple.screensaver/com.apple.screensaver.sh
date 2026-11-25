#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.screensaver

"$@" idleTime -int 0
"$@" askForPassword -int 0
