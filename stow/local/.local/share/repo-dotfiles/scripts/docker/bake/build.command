#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*}"; { set +x; } 2>/dev/null; }

export DOCKER_BUILDKIT=1

BAKE_FILES=("-f" "docker/docker-bake.hcl")
for f in docker/images/*/docker-bake.hcl; do
  BAKE_FILES+=("-f" "$f")
done

( set -x; docker run --privileged --rm tonistiigi/binfmt --install all ) || exit 1
if ! ( set -x; docker buildx inspect my-local-builder ) &>/dev/null; then
  ( set -x; docker buildx create --name my-local-builder --driver docker-container ) || exit 1
fi
( set -x; docker buildx inspect --bootstrap ) || exit 1
( set -x; /opt/homebrew/bin/docker-buildx bake "${BAKE_FILES[@]}" --progress=plain --load ) || exit 1
