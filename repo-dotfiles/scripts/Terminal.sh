#!/usr/bin/env bash
{ set +x; } 2>/dev/null

{ set -x; cd "${BASH_SOURCE[0]%/*/*}"; { set +x; } 2>/dev/null; }

osascript <<EOF
tell application "Terminal"
    do script with command "cd '$PWD'"
    activate
end tell
EOF
