#!/usr/bin/env bash
{ set +x; } 2>/dev/null

( set -x; docker-images-orphan-clean ) || exit 1
