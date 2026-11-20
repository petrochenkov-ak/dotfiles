#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*/*}" || exit; { set +x; } 2>/dev/null; }

( set -x; git fetch origin --prune -q ) || exit 1
( set -x; git checkout -B main origin/main -q ) || exit 1
( set -x; git branch | grep -v '^\* main$' | xargs -r git branch -D ) || exit 1
