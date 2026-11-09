#!/usr/bin/env bash
{ set +x; } 2>/dev/null

owner=$(repo-git-owner "$0") || exit 1
CMD="$(basename "${0%.*}")"

( set -x; repo-git-owner-repos-exec "$owner" "${CMD}" )
