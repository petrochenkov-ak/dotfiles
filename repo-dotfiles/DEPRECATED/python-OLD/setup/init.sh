#!/usr/bin/env bash
{ set +x; } 2>/dev/null

( set -x; python "${BASH_SOURCE[0]%/*}"/init.py )
