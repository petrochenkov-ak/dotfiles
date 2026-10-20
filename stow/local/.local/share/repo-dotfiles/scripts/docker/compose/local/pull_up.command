#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; docker compose --progress plain -f docker/compose/run.local.yaml pull ) || exit 1
( set -x; docker compose -f docker/compose/run.local.yaml up -d  --force-recreate ) || exit 1
( set -x; docker compose -f docker/compose/run.local.yaml ps -a --format "table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.CreatedAt}}\t{{.Ports}}" ) || exit 1
