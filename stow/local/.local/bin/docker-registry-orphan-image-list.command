#!/usr/bin/env bash
{ set +x; } 2>/dev/null

( set -x; docker-registry-orphan-image-list ) || exit 1
