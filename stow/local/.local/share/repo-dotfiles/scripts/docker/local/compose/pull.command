#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; docker compose --progress plain -f docker/compose/run.local.yaml pull ) || exit 1
