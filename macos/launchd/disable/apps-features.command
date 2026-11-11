#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.amp.mediasharingd \
  com.apple.AMPLibraryAgent \
  com.apple.arkitd \
  com.apple.bookassetd \
  com.apple.gamesaved \
  com.apple.homed \
  com.apple.homeenergyd \
  com.apple.LinkedNotesUIService \
  com.apple.maps.destinationd \
  com.apple.mediastream.mstreamd \
  com.apple.ThreadCommissionerService \
  com.apple.tonelibraryd; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  com.apple.amp.mediasharingd \
  com.apple.homeenergyd \
  com.apple.ThreadCommissionerService; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
