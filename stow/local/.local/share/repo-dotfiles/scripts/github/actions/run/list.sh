#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*}" || exit; { set +x; } 2>/dev/null; }

( set -x; gh run list --json name,status,conclusion,createdAt --template '{{range .}}{{tablerow .name .status .conclusion (timeago .createdAt)}}{{end}}' )
