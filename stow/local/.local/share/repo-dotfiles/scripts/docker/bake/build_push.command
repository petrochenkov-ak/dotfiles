#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*}"; { set +x; } 2>/dev/null; }

export DOCKER_BUILDKIT=1
unset DOCKER_HOST

BAKE_FILES=("-f" "docker/docker-bake.hcl")
for f in docker/images/*/docker-bake.hcl; do
  BAKE_FILES+=("-f" "$f")
done

( set -x; docker run --privileged --rm tonistiigi/binfmt --install all ) || exit 1
if ( set -x; /opt/homebrew/bin/docker-buildx inspect my-local-builder ) &>/dev/null; then
  ( set -x; /opt/homebrew/bin/docker-buildx rm my-local-builder ) || exit 1
fi
( set -x; docker context use default ) || exit 1
( set -x; /opt/homebrew/bin/docker-buildx bake "${BAKE_FILES[@]}" --progress=plain --set="*.output=type=registry" )
