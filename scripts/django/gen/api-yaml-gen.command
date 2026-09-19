#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; repo-django-api-yaml-gen ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

