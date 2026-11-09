#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*}"; { set +x; } 2>/dev/null; }

( set -x; repo-gh-workflow-rerun "docker-compose-ghcr-push.yaml" )
