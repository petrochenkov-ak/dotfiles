#!/usr/bin/env bash

SERVER_DIR="${BASH_SOURCE%/*/*}"
SSH_HOST="${SERVER_DIR##*/}"

( set -x; ssh "$SSH_HOST" )
