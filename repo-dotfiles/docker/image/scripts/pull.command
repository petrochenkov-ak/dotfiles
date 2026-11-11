#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

NAME=$(basename "${BASH_SOURCE%/*/*}")

( set -x; docker-pull-all-tags "$NAME" ) || exit 1
