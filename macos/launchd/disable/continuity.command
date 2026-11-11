#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.airplayxpchelper \
  com.apple.AirPlayUIAgent \
  com.apple.AMPArtworkAgent \
  com.apple.AMPDeviceDiscoveryAgent \
  com.apple.amp.mediasharingd \
  com.apple.campo \
  com.apple.CampoRemoteService \
  com.apple.cmio.ContinuityCaptureAgent \
  com.apple.companiond \
  com.apple.ContinuityCaptureAgent \
  com.apple.continuitycaptured \
  com.apple.CoreDevice.remotepairingd \
  com.apple.coreservices.UASharedPasteboardProgressUI \
  com.apple.coreservices.useractivityd \
  com.apple.corespeechd \
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
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  com.apple.AirPlayXPCHelper \
  com.apple.amp.mediasharingd \
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
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
