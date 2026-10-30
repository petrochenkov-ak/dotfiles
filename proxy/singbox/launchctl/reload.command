#!/bin/bash

VLESS_FILE="$HOME/vless.txt"
TEMPLATE_FILE="${BASH_SOURCE%/*/*}/template.json"
CONFIG_FILE="$HOME/config.json"
PLIST_FILE="$HOME/Library/LaunchAgents/com.singbox.macos.plist"
CACHE_PATH="$HOME/sing-box-cache.db"

YOUTUBE_SRS="$HOME/.local/share/sing-box/geosite-youtube.srs"
GOOGLE_SRS="$HOME/.local/share/sing-box/geosite-google.srs"

VLESS_URL=$(grep -v '^#' "$VLESS_FILE" | grep -v '^$' | head -n 1)
( set -x; test -n "$VLESS_URL" ) || exit 1

REMAINING=${VLESS_URL#vless://}
UUID=${REMAINING%%@*}
REMAINING=${REMAINING#*@}
SERVER_PORT_PART=${REMAINING%%\?*}
QUERY_PART=${REMAINING#*\?}
QUERY_PART=${QUERY_PART%%#*}
SERVER=${SERVER_PORT_PART%%:*}
PORT=${SERVER_PORT_PART#*:}

get_param() {
    echo "$QUERY_PART" | grep -o "$1=[^&]*" | cut -d= -f2
}

FLOW=$(get_param "flow")
SECURITY=$(get_param "security")
SNI=$(get_param "sni")
PUBLIC_KEY=$(get_param "pbk")
SHORT_ID=$(get_param "sid")
NETWORK=$(get_param "type")
SERVICE_NAME=$(get_param "serviceName")

[ -z "$FLOW" ] && FLOW=""

if [ "$SECURITY" = "reality" ]; then
    REALITY_ENABLED="true"
else
    REALITY_ENABLED="false"
fi

if [ "$NETWORK" = "grpc" ]; then
    [ -z "$SERVICE_NAME" ] && SERVICE_NAME="/grpc"
    SERVICE_NAME="${SERVICE_NAME//%2F//}"
    TRANSPORT_BLOCK="{\"type\":\"grpc\",\"service_name\":\"$SERVICE_NAME\"}"
else
    TRANSPORT_BLOCK="null"
fi

rm -f "$CONFIG_FILE"

( set -x; sed -e "s/SERVER_ADDRESS/$SERVER/g" \
    -e "s/SERVER_PORT/$PORT/g" \
    -e "s/UUID/$UUID/g" \
    -e "s/FLOW/$FLOW/g" \
    -e "s/SNI/$SNI/g" \
    -e "s/REALITY_ENABLED/$REALITY_ENABLED/g" \
    -e "s/PUBLIC_KEY/$PUBLIC_KEY/g" \
    -e "s/SHORT_ID/$SHORT_ID/g" \
    -e "s|TRANSPORT_BLOCK|$TRANSPORT_BLOCK|g" \
    -e "s|GEOSITE_YOUTUBE_PATH|$YOUTUBE_SRS|g" \
    -e "s|GEOSITE_GOOGLE_PATH|$GOOGLE_SRS|g" \
    -e "s|CACHE_FILE_PATH|$CACHE_PATH|g" \
    "$TEMPLATE_FILE" > "$CONFIG_FILE" ) || exit 1

( set -x; rm /tmp/singbox.err /tmp/singbox.log &> /dev/null )
if launchctl print gui/$UID/com.singbox.macos >/dev/null 2>&1; then
    ( set -x; launchctl kickstart -k gui/$UID/com.singbox.macos ) || exit 1
else
    ( set -x; launchctl bootstrap gui/$UID "$PLIST_FILE" ) || exit 1
fi

( set -x; sleep 2 ) || exit 1
( set -x; sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder )
if ! launchctl print gui/$UID/com.singbox.macos | grep -q "state = running"; then
    tail -n 20 /tmp/singbox.err
    exit 1
fi
