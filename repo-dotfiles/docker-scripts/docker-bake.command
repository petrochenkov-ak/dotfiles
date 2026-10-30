#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

. ~/.bashrc || exit 1

NAME=$(basename "${BASH_SOURCE%/*/*}")

( set -x; time docker-bake-target "$NAME" )
