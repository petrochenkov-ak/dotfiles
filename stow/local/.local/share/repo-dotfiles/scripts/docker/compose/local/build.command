#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
( set -x; docker compose -f docker/compose/build.yaml build ) || exit 1
