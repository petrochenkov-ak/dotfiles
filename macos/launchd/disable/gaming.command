#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.gamecontroller.ConfigService \
  com.apple.gamecontroller.gamecontrolleragentd \
  com.apple.GameController.gamecontrolleragentd \
  com.apple.gamed \
  com.apple.GameOverlayUI \
  com.apple.GamePolicyAgent \
  com.apple.gamesaved \
  com.apple.gputoolsserviced; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.GameController.gamecontrollerd \
  com.apple.gamed \
  com.apple.gamepolicyd \
  com.apple.gputoolsserviced; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
