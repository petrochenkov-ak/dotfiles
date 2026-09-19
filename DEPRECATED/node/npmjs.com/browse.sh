#!/usr/bin/env bash
{ set +x; } 2>/dev/null

name="$(node -e "console.log(require('./package.json').name);")" || exit
url="https://www.npmjs.com/package/$name"
( set -x; open "$url" )
