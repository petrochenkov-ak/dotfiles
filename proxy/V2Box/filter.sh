#!/bin/bash

URL="https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/BLACK_VLESS_RUS.txt"
FILE_PATH=~/vless.txt
( set -x; curl -s "$URL" ) | grep "vless://" > /tmp/vless.txt

echo "" > "$FILE_PATH"
while read -r url; do
    server=$(echo "$url" | sed -e 's/vless:\/\///' -e 's/.*@//' -e 's/:.*//')
    port=$(echo "$url" | sed -e 's/.*://' -e 's/?.*//' -e 's/#.*//')
    name=$(echo "$url" | sed -e 's/.*#//')
    decoded_name=$(echo -e "${name//%/\\x}")

    if ( set -x; nc -z -G 1 "$server" "$port" ) 2>/dev/null; then
        echo "🟢success: $decoded_name"
        echo "$url" >> "$FILE_PATH"
    fi
done < /tmp/vless.txt
