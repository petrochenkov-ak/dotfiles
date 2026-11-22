#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*}" || exit; { set +x; } 2>/dev/null; }

RUN_ID=$(gh run list --status failure --limit 1 --json databaseId --jq '.[0].databaseId') || exit 1
[[ -z $RUN_ID ]] && exit

( set -x; gh run view $RUN_ID --log-failed )
