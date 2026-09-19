#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*}"; { set +x; } 2>/dev/null; }

( set -x; repo-dotfiles-sync )
