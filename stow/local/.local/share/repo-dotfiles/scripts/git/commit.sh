#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*}" || exit; { set +x; } 2>/dev/null; }

( set -x; git init -q && git add -A ) || exit
( set -x; git-commit )
