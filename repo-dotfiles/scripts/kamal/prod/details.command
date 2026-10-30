#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; kamal details -c config/kamal.prod.yaml )
