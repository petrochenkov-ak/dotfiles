#!/usr/bin/env bash

TARGET_DIR="$HOME/.local/share/sing-box"
( set -x; mkdir -p "$TARGET_DIR" ) || exit 1

YOUTUBE_SRS="$TARGET_DIR/geosite-youtube.srs"
GOOGLE_SRS="$TARGET_DIR/geosite-google.srs"

HOST="https://raw.githubusercontent.com"
URI="/lyc8503/sing-box-rules/refs/heads/rule-set-geosite"

URL_YT="${HOST}${URI}/geosite-youtube.srs"
URL_GG="${HOST}${URI}/geosite-google.srs"

( set -x; curl -sS -L -o "$YOUTUBE_SRS" "$URL_YT" ) || exit 1
( set -x; curl -sS -L -o "$GOOGLE_SRS" "$URL_GG" ) || exit 1
