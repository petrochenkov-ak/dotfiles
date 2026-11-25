#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

IMAGE="docker-dockerfile-check-gha:latest"

( set -x; repo-gha-docker-run "$IMAGE" )
