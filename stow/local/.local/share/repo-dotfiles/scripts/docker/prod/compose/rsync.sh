#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

. .env.prod || exit

( set -x; rsync -e ssh \
    --mkpath \
    --chmod=D700,F600 \
    docker/compose/prod/docker-compose.yaml "${SSH_NAME}":/opt/"${SSH_NAME}"/docker-compose.yaml ) || exit
( set -x; rsync -e ssh \
    --chmod=D700,F600 \
    .env.prod "${SSH_NAME}":/opt/"${SSH_NAME}"/.env ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

