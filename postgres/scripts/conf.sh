#!/usr/bin/env bash

BASE_DIR="/Volumes/HDD/var/postgres"
DOTFILES_DIR="${BASH_SOURCE%/*/*}/config"

for dot_dir in "$DOTFILES_DIR"/*/; do
    dot_dir="${dot_dir%/}"
    name="${dot_dir##*/}"
    src_file_path="$dot_dir/postgresql.conf"
    dst_file_path="$BASE_DIR/$name/postgresql.conf"
    [ -f "$src_file_path" ] || continue

    [ -L "$dst_file_path" ] && { ( set -x; rm "$dst_file_path" ) || exit; }
    ( set -x; cp "$src_file_path" "$dst_file_path" ) || exit
done;:
