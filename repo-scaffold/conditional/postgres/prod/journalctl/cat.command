#!/usr/bin/env bash

( set -x; cd "${BASH_SOURCE%/*/*/*/*/*}" )

. .env.prod || exit

( set -x; ssh "${SSH_NAME}" "sudo journalctl -n 50 -u postgresql@18-${PGDATABASE}.service" ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

