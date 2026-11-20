#!/usr/bin/env bash
{ set +x; } 2>/dev/null

CMD="$(basename "${0%.*}")"

( set -x; git-all-repos-exec "${CMD}" )
