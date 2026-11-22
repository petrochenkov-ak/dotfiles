#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; repo-prompts-build ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

