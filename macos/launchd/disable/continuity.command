#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.airplayxpchelper \
  com.apple.AirPlayUIAgent \
  com.apple.campo \
  com.apple.CampoRemoteService \
  com.apple.cmio.ContinuityCaptureAgent \
  com.apple.companiond \
  com.apple.ContinuityCaptureAgent \
  com.apple.continuitycaptured \
  com.apple.CoreDevice.remotepairingd \
  com.apple.coreservices.UASharedPasteboardProgressUI \
  com.apple.coreservices.useractivityd \
  com.apple.CoreThreadCommissionerServiced \
  com.apple.ecosystemagent \
  com.apple.ensemble \
  com.apple.handoff.receiver \
  com.apple.mbproximityhelper \
  com.apple.mediacontinuityd \
  com.apple.mediaremoteagent \
  com.apple.nearbyd \
  com.apple.nexusd \
  com.apple.rapportd \
  com.apple.RapportUIAgent \
  com.apple.remoted \
  com.apple.remotepairingd \
  com.apple.remotespatialpreviewd \
  com.apple.sharing.airdropui \
  com.apple.sharingd \
  com.apple.sidecar-display-agent \
  com.apple.SidecarDisplayAgent \
  com.apple.sidecar-hid-relay \
  com.apple.sidecar-relay \
  com.apple.tvremoted \
  com.apple.universalcontrol \
  com.apple.useractivityd; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.AirPlayXPCHelper \
  com.apple.CoreDevice.remotepairingd \
  com.apple.CoreThreadCommissionerServiced \
  com.apple.mbproximityhelper \
  com.apple.mobiledeviceupdater \
  com.apple.nearbyd \
  com.apple.rapportd \
  com.apple.remoted \
  com.apple.remotepairingd \
  com.apple.sidecar-display-agent \
  com.apple.usbmuxd; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
