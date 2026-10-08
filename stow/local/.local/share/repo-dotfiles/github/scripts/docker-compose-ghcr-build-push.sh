#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*}"; { set +x; } 2>/dev/null; }

WORKFLOW_NAME="docker-compose-ghcr-build-push.yaml"

RUN_ID=$(set -x; gh run list --workflow="${WORKFLOW_NAME}" --limit 1 --json databaseId --jq '.[0].databaseId') || exit 1

if [ -z "${RUN_ID}" ] || [ "${RUN_ID}" = "null" ]; then
    ( set -x; gh workflow run "${WORKFLOW_NAME}" --ref main ) || exit 1
else
    ( set -x; gh run rerun "${RUN_ID}" ) || exit 1
fi
