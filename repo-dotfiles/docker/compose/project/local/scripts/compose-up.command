#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*}"; { set +x; } 2>/dev/null; }

( set -x; docker compose -f docker-compose.yaml down --remove-orphans ) || exit 1
( set -x; docker compose -f docker-compose.yaml up -d --force-recreate --wait ) || exit 1
( set -x; docker compose -f docker-compose.yaml ps -a --format "table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.CreatedAt}}\t{{.Ports}}" ) || exit
