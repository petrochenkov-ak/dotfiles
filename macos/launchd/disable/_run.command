#!/usr/bin/env bash

cd "${BASH_SOURCE[0]%/*}" || exit 1

for file in *.command; do
    [ -e "$file" ] || continue
    [ "$file" = "${BASH_SOURCE[0]##*/}" ] && continue
    ( set -x; bash "$file" ) || exit 1
done
