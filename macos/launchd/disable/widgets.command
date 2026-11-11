#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

uid=$(id -u)

( set -x; defaults write com.apple.WindowManager StandardHideWidgets -bool true ) || true
( set -x; defaults write com.apple.WindowManager StageManagerHideWidgets -bool true ) || true
( set -x; defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true ) || true

for agent in \
  com.apple.chronod \
  com.apple.newsd \
  com.apple.widgetkit.simulator; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || true
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || true
done

while IFS= read -r id; do
  if [ -n "$id" ]; then
    ( set -x; pluginkit -e ignore -i "$id" ) || true
  fi
done < <(pluginkit -m -p com.apple.widgetkit-extension 2>/dev/null | grep -v -i "bluetooth" | sed -E 's/^[+-]?[[:space:]]*//; s/[[:space:]]*\(.*//')
