#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*}" || exit; { set +x; } 2>/dev/null; }

( set -x; repo-python-setup ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

