#!/usr/bin/env bash
{ set +x; } 2>/dev/null

OWNER=$(set -x; gh-parse-path-owner "$0") || exit 1

( set -x; gh-orphaned-github-repo-name-list "$OWNER" ) || exit 1
