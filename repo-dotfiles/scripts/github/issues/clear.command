#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*/*}" || exit; { set +x; } 2>/dev/null; }

( set -x; gh-issues-clean ) || exit 1

( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )
