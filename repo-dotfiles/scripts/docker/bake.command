#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*}"; { set +x; } 2>/dev/null; }

. ~/.bashrc || exit 1

( set -x; time docker-bake-default )
