#!/usr/bin/env bash

. "${BASH_SOURCE[0]%/*}"/.context.sh || exit 1

( set -x; mussh -H "${BASH_SOURCE[0]%/*/*}"/hosts.txt -m 1 -c "set -x; cd ${REMOTE_DIR} && docker compose -f docker-compose.yaml pull" )
