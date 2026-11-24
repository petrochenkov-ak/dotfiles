#!/usr/bin/env bash
{ set +x; } 2>/dev/null

CMD="$(basename "${0%.*}")"

( set -x; cd "${BASH_SOURCE%/*}" && git-repos-bin-run "${CMD}" )
