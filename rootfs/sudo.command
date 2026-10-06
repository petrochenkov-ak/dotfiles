#!/usr/bin/env bash
{ set +x; } 2>/dev/null

( set -x; cd "${BASH_SOURCE[0]%/*}" && sudo cp -r --preserve=mode --no-preserve=ownership etc / )
