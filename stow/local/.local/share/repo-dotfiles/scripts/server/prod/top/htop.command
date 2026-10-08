#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE%/*/*/*/*/*}"; { set +x; } 2>/dev/null; }

. .env.prod || exit

# sudo apt update && sudo apt install -y htop
( set -x; ssh -t "${SSH_NAME}" htop )
