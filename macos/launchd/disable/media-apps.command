#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.AMPArtworkAgent \
  com.apple.AMPDeviceDiscoveryAgent \
  com.apple.AMPLibraryAgent \
  com.apple.gamed \
  com.apple.helpd \
  com.apple.homed \
  com.apple.Maps.mapspushd \
  com.apple.Maps.pushdaemon \
  com.apple.newsd \
  com.apple.passd \
  com.apple.SafariCloudHistoryPushAgent \
  com.apple.SafariHistoryServiceAgent \
  com.apple.screentime \
  com.apple.ScreenTimeAgent \
  com.apple.tipsd \
  com.apple.triald \
  com.apple.weatherd; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  com.apple.fpsd \
  com.apple.triald.system; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
