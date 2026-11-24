#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

IMAGE="docker-dockerfile-fix-gha:latest"

( set -x; repo-gha-docker-run "$IMAGE" )
