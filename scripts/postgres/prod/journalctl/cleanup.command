#!/usr/bin/env bash

( set -x; cd "${BASH_SOURCE%/*/*/*/*/*}" )

. .env.prod || exit

( set -x; ssh "${SSH_NAME}" "sudo journalctl --rotate && sudo journalctl --vacuum-time=1s" ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )


