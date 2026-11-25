#!/usr/bin/env bash
{ set +x; } 2>/dev/null

! [ -e package.json ] && echo "SKIP ($PWD): package.json NOT EXISTS" && exit

name="$(node -e "console.log(require('./package.json').name);")" || exit
version="$(node -e "console.log(require('./package.json').version);")" || exit

[[ -z "$name" ]] && echo "ERROR ($PWD): name EMPTY" 1>&2 && exit 1
[[ -z "$version" ]] && echo "ERROR ($PWD): version EMPTY" 1>&2 && exit 1

uptodate="$(npm view "$name" versions --json 2> /dev/null | grep "\"$version\"")"
[[ -n "$uptodate" ]] && echo "SKIP ($PWD): uptodate" && exit

# ( set -x;repo:web:travis-ci.org:check ) || exit

# https://docs.npmjs.com/files/package.json#files
# README.md always included
# custom npmjs.com README: replace README.md

( set -x; npm publish )
