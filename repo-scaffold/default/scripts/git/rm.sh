#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*}" || exit; { set +x; } 2>/dev/null; }

[ -d .git ] && set -- .git # repo/.git/

IFS=
# repo/submodule/.git
find="$(find . -type f -name ".git" -mindepth 2 | sed 's/.\{5\}$//')" || exit
[ -n "$find" ] && { IFS=$'\n'; set -- "$@" $find; }
[[ $# != 0 ]] && { ( set -x; rm -fr "$@" ) || exit; };:
