#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*}"; { set +x; } 2>/dev/null; }

PS_FORMAT="table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.CreatedAt}}\t{{.Ports}}"

( set -x; docker compose -f docker-compose.yaml ps -a --format "${PS_FORMAT}" )
