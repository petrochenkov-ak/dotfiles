#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; docker-start ) || exit 1
( set -x; docker-registry-check ) || exit 1
( set -x; repo-docker-bake-default ) || exit 1
