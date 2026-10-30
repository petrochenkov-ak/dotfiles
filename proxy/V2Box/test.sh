#!/bin/bash
set -euo pipefail
umask 077

FILE="$HOME/vless.txt"
ROOT="$HOME/Library/Group Containers/group.hossin.asaadi.V2Box/mmkv"
TEMPLATE="$HOME/.local/share/v2box/empty-mmkv"

test -s "$FILE"
test -d "$ROOT"
test -d "$TEMPLATE"

BACKUP="$(mktemp -d "$HOME/v2box-backup.XXXXXX")"
ditto "$ROOT" "$BACKUP/mmkv"
pbcopy < "$FILE"
find "$ROOT" -type f -delete
ditto "$TEMPLATE" "$ROOT"
open -b hossin.asaadi.V2Box
