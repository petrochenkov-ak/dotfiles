#!/usr/bin/env bash
{ set +x; } 2>/dev/null

BIN="$(basename "${BASH_SOURCE%.*}")"

( set -x; cd "${BASH_SOURCE%/*}" && git-repos-bin-run "$BIN" "$@" ) || exit 1
