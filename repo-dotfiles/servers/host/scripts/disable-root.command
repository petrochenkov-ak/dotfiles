#!/usr/bin/env bash

SERVER_DIR="${BASH_SOURCE%/*/*}"
SSH_HOST="${SERVER_DIR##*/}"

( set -x; ssh -tt "${SSH_HOST}" "sudo sh -c 'echo \"PermitRootLogin no\" > /etc/ssh/sshd_config.d/disable-root.conf' && (sudo systemctl restart ssh || sudo systemctl restart sshd)" )
