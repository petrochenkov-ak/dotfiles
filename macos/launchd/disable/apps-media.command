#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.amp.mediasharingd \
  com.apple.AMPArtworkAgent \
  com.apple.AMPDeviceDiscoveryAgent \
  com.apple.AMPDevicesAgent \
  com.apple.AMPLibraryAgent \
  com.apple.AMPSystemPlayerAgent \
  com.apple.amsaccountsd \
  com.apple.amsengagementd \
  com.apple.amsondevicestoraged \
  com.apple.appplaceholdersyncd \
  com.apple.appstoreagent \
  com.apple.appstorecomponentsd \
  com.apple.bookassetd \
  com.apple.bookdatastored \
  com.apple.commerce \
  com.apple.financed \
  com.apple.itunescloudd \
  com.apple.jetpackassetd \
  com.apple.mediastream.mstreamd \
  com.apple.mediaremoted \
  com.apple.shazamd \
  com.apple.shazameventsd \
  com.apple.sportsd \
  com.apple.StocksKitService \
  com.apple.storeassetd \
  com.apple.storelegacy \
  com.apple.tonelibraryd \
  com.apple.videosubscriptionsd \
  com.apple.voicememod \
  com.apple.watchlistd; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.amp.mediasharingd \
  com.apple.AMPDeviceDiscoveryAgent \
  com.apple.appstoreagent \
  com.apple.commerce \
  com.apple.fpsd \
  com.apple.storeassetd; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
