#!/usr/bin/env bash
{ set +x; } 2>/dev/null

( set -x; docker-host-local-orphan-clean ) || exit 1
