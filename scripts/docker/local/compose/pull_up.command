#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; docker compose --progress plain -f docker/compose/docker-compose.base.yaml -f docker/compose/docker-compose.local.yaml pull ) || exit
( set -x; docker compose -f docker/compose/docker-compose.base.yaml -f docker/compose/docker-compose.local.yaml up -d  --force-recreate ) || exit
( set -x; docker compose -f docker/compose/docker-compose.base.yaml -f docker/compose/docker-compose.local.yaml ps -a --format "table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.CreatedAt}}\t{{.Ports}}" ) || exit
