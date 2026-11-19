#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.arkitd \
  com.apple.CoreLocationAgent \
  com.apple.CoreRoutine.helperservice \
  com.apple.geod \
  com.apple.geodMachServiceBridge \
  com.apple.homed \
  com.apple.homeenergyd \
  com.apple.homeeventsd \
  com.apple.HomeWidgetIntentsExtension \
  com.apple.locationaccessstored \
  com.apple.maps.destinationd \
  com.apple.Maps.mapspushd \
  com.apple.Maps.mapssyncd \
  com.apple.Maps.pushdaemon \
  com.apple.navd \
  com.apple.routined \
  com.apple.ThreadCommissionerService; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.CoreLocationAgent \
  com.apple.geod \
  com.apple.homed \
  com.apple.homeenergyd \
  com.apple.locationd \
  com.apple.ThreadCommissionerService; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
