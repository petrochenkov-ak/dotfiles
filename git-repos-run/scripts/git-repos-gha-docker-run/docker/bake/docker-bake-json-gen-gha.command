#!/usr/bin/env bash
{ set +x; } 2>/dev/null

IMAGE_NAME="$(basename "${BASH_SOURCE%.*}")"
set -- -- test -d docker/images

( set -x; cd "${BASH_SOURCE%/*}" && git-repos-gha-docker-run "$IMAGE_NAME" "$@" ) || exit 1
