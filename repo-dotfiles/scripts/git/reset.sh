#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*}" || exit; { set +x; } 2>/dev/null; }

( set -x; git reset --hard HEAD && git clean -fd )
