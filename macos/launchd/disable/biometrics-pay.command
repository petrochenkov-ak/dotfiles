#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1

for agent in \
  com.apple.biometrickitd \
  com.apple.coreidvd \
  com.apple.passd \
  com.apple.seserviced; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || true
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
done

for daemon in \
  com.apple.biometrickitd \
  com.apple.nfcd \
  com.apple.NFStorageServer \
  com.apple.seld \
  com.apple.usbsmartcardreaderd; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
done
