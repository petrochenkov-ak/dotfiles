#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*}"; { set +x; } 2>/dev/null; }

( set -x; grep -v '^#' "${BASH_SOURCE[0]%/*/*}"/requirements/pipx-requirements.txt | xargs -L 1 pipx install
