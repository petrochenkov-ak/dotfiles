#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1

for daemon in \
  com.apple.InternetSharing \
  com.apple.ODSAgent \
  com.apple.RFBEventHelper \
  com.apple.rpmuxd \
  com.apple.snmptrapd \
  com.apple.tftpd \
  com.apple.ucupdate.plist \
  com.apple.uucp; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
done
