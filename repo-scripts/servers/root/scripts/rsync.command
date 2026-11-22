#!/usr/bin/env bash

mapfile -t src_paths < <(find "${BASH_SOURCE%/*/*}" -mindepth 1 -maxdepth 1 ! -name ".*" ! -name "_*" -type d)
for server_dir in "${src_paths[@]}"; do
    default_rootfs_dir="${BASH_SOURCE%/*/*}"/_default/rootfs
    server_rootfs_dir="${server_dir}/rootfs"
    ssh_host="${server_dir##*/}"
    [ -e "${default_rootfs_dir}" ] && {
        ( set -x; rsync -a --mkpath --no-perms --no-owner --no-group --no-times --exclude='.DS_Store' \
            --rsync-path="sudo rsync" \
            "${default_rootfs_dir}" "${ssh_host}:/"
        ) || exit 1
    }
    [ -e "${server_rootfs_dir}" ] && {
        ( set -x; rsync -a --mkpath --no-perms --no-owner --no-group --no-times --exclude='.DS_Store' \
            --rsync-path="sudo rsync" \
            "${server_rootfs_dir}/" "${ssh_host}:/"
        ) || exit 1
    }
    ( set -x; ssh "${ssh_host}" "sudo find /usr/local/bin/ -maxdepth 1 -type f -exec chmod +x {} +" ) || exit 1
done
