#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.printtool.agent \
  com.apple.printuitool.agent \
  com.apple.icdd; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  org.cups.cupsd \
  org.cups.cups-lpd \
  com.apple.printtool.daemon; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
