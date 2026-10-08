#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*}"; { set +x; } 2>/dev/null; }

RUN_ID=$(set -x; gh run list --workflow="docker-compose-ghcr-push.yaml" --limit 1 --json databaseId --jq '.[0].databaseId') || exit 1

( set -x; gh run rerun "${RUN_ID}" ) || exit 1
