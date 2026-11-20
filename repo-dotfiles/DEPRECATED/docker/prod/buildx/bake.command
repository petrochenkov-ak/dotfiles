#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

export BUILDX_BAKE_ENTITLEMENTS_FS=0
export DOCKER_CONFIG="$HOME/.docker"

while read -r hcl; do
    (
        set -ex
        docker --context registry buildx bake \
        -f ~/.config/docker/docker-bake.base.hcl \
        -f "$hcl" \
        prod --progress=plain --no-cache
    ) || exit
done < <(find "$PWD" -type f -name "docker-bake.hcl") || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

