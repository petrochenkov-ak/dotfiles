#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; cd "${BASH_SOURCE[0]%/*}" ) || exit 1
cd "${BASH_SOURCE[0]%/*}" || exit 1

for file in *.command; do
  [ -e "$file" ] || continue
  [ "$file" = "${BASH_SOURCE[0]##*/}" ] && continue
  ( set -x; bash "$file" ) || exit 1
done
