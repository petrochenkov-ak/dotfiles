#!/usr/bin/env bash
{ set +x; } 2>/dev/null

( set -x; cd "${BASH_SOURCE[0]%/*}" && sudo stow --adopt --no-folding -t /etc etc )
