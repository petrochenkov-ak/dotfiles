#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.webpushd \
  com.apple.SafariBookmarksSyncAgent \
  com.apple.SafariLaunchAgent \
  com.apple.SafariNotificationAgent \
  com.apple.safaridavclient \
  com.apple.AuthenticationServicesCore.AuthenticationServicesAgent; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done
