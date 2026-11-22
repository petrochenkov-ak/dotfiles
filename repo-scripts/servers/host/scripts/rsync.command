#!/usr/bin/env bash

DEFAULT_ROOTFS_DIR="${BASH_SOURCE%/*/*/*}/_default/rootfs"
SERVER_DIR="${BASH_SOURCE%/*/*}"
SERVER_ROOTFS_DIR="${SERVER_DIR}/rootfs"
SSH_HOST="${SERVER_DIR##*/}"

[ -e "${DEFAULT_ROOTFS_DIR}" ] && {
    ( set -x; rsync -a --mkpath --no-perms --no-owner --no-group --no-times --exclude='.DS_Store' \
        --rsync-path="sudo rsync" \
        "${DEFAULT_ROOTFS_DIR}/" "${SSH_HOST}:/"
    ) || exit 1
}
[ -e "${SERVER_ROOTFS_DIR}" ] && {
    ( set -x; rsync -a --mkpath --no-perms --no-owner --no-group --no-times --exclude='.DS_Store' \
        --rsync-path="sudo rsync" \
        "${SERVER_ROOTFS_DIR}/" "${SSH_HOST}:/"
    ) || exit 1
}
( set -x; ssh "${SSH_HOST}" "sudo find /usr/local/bin/ -maxdepth 1 -type f -exec chmod +x {} +" ) || exit 1
