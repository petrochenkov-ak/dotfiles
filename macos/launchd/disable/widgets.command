#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; defaults write com.apple.WindowManager StandardHideWidgets -bool true ) || exit 1
( set -x; defaults write com.apple.WindowManager StageManagerHideWidgets -bool true ) || exit 1
( set -x; defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true ) || exit 1
( set -x; defaults write com.apple.notificationcenterui widgets-enabled -bool false ) || exit 1

for agent in \
  com.apple.chronod \
  com.apple.liveactivitiesd \
  com.apple.newsd \
  com.apple.WallpaperAerialsExtension \
  com.apple.WallpaperImageExtension \
  com.apple.widgetkit.simulator; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || true
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
done

while IFS= read -r id; do
  if [ -n "$id" ]; then
    ( set -x; pluginkit -e ignore -i "$id" ) || exit 1
  fi
done < <(pluginkit -m -p com.apple.widgetkit-extension 2>/dev/null | grep -v -i "bluetooth" | sed -E 's/^[+-]?[[:space:]]*//; s/[[:space:]]*\(.*//')
