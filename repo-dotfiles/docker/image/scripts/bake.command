#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

. ~/.bashrc || exit 1
export NO_PROXY="localhost,127.0.0.1,registry.docker.internal"

NAME=$(basename "${BASH_SOURCE%/*/*}")

( set -x; orb-start ) || exit 1
( set -x; docker-registry-check ) || exit 1
( set -x; time docker-bake-target "$NAME" ) || exit 1
( set -x; docker-pull-all "$NAME" ) || exit 1
