#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

pgrep -x "Docker Desktop" > /dev/null || { ( set -x; open -a Docker && sleep 10 ); }
( set -x; docker compose -f docker/compose/run.local.yaml down --remove-orphans ) || exit 1
( set -x; docker compose -f docker/compose/run.local.yaml --verbose up ) || exit 1
( set -x; sleep 20 )
( set -x; docker compose -f docker/compose/run.local.yaml ps -a --format "table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.CreatedAt}}\t{{.Ports}}" ) || exit
