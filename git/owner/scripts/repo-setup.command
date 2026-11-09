#!/usr/bin/env bash
{ set +x; } 2>/dev/null

owner=$(git-owner "$0") || exit 1
CMD="$(basename "${0%.*}")"

( set -x; git-owner-repos-exec "$owner" "${CMD}" )
