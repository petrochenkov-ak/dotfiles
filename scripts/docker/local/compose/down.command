#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; docker compose -f docker/compose/docker-compose.base.yaml -f docker/compose/docker-compose.local.yaml down ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

