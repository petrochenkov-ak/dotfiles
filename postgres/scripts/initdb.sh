#!/usr/bin/env bash

BASE_DIR="/Volumes/HDD/var/postgres"
DOTFILES_DIR="${BASH_SOURCE[0]%/*/*}/config"

for dot_dir in "$DOTFILES_DIR"/*/; do
    dot_dir="${dot_dir%/}"
    name="${dot_dir##*/}"
    [ -d "$dot_dir" ] || continue

    src_conf="$dot_dir/postgresql.conf"
    [ -f "$src_conf" ] || continue

    target_dir="$BASE_DIR/$name"

    if [ ! -f "$target_dir/PG_VERSION" ]; then
        mkdir -p "$target_dir"
        (
            set -x
            initdb -D "$target_dir" --username=postgres --auth=trust
        ) || exit 1

        rm -f "$target_dir/postgresql.conf"
        ln -s "$src_conf" "$target_dir/postgresql.conf"
    fi
done;:
