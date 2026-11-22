#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

NAME=$(basename "${BASH_SOURCE%/*/*}")

( set -x; docker-start ) || exit 1
( set -x; docker-registry-check ) || exit 1
( set -x; repo-docker-bake-target "$NAME" ) || exit 1
( set -x; docker-pull-all "$NAME" ) || exit 1
