#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*}"; { set +x; } 2>/dev/null; }

. .env.prod || exit

( set -x; ssh "${SSH_NAME}" ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

