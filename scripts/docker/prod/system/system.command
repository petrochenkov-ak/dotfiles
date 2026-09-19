#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

. .env.prod || exit

( set -x; ssh "${SSH_NAME}" docker system prune -a -f --volumes ) || exit
( set -x; ssh "${SSH_NAME}" docker builder prune -a -f ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

