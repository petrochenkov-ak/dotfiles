#!/usr/bin/env bash

. "${BASH_SOURCE[0]%/*/*}" || exit 1


while read -r SSH_HOST || [[ -n "$SSH_HOST" ]]; do
    ( set -x; rsync -a --delete --mkpath --exclude='.scripts' --rsync-path="sudo rsync" "${BASH_SOURCE%/*/*}/" "${SSH_HOST}:${REMOTE_DIR}/" ) || exit 1
done < "${BASH_SOURCE[0]%/*/*}/hosts.txt"
