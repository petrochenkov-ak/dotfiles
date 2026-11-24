#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

for agent in \
  com.apple.AuthenticationServicesCore.AuthenticationServicesAgent \
  com.apple.Safari.History \
  com.apple.SafariBookmarksSyncAgent \
  com.apple.SafariCloudHistoryPushAgent \
  com.apple.safaridavclient \
  com.apple.SafariHistoryServiceAgent \
  com.apple.SafariLaunchAgent \
  com.apple.SafariNotificationAgent \
  com.apple.webprivacyd \
  com.apple.webpushd; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || true
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
done
