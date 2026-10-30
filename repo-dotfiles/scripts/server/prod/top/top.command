#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

. .env.prod || exit

( set -x; ssh -t "${SSH_NAME}" )
