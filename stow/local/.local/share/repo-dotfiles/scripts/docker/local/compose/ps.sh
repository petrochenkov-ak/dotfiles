#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

ps_format="table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.CreatedAt}}\t{{.Ports}}"
( set -x; docker compose -f docker/compose/run.local.yaml ps -a --format "$ps_format" )
