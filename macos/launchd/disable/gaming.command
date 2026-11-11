#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.FileStatsAgent \
  com.apple.gamecontroller.ConfigService \
  com.apple.gamecontroller.gamecontrolleragentd \
  com.apple.GameController.gamecontrolleragentd \
  com.apple.GameOverlayUI \
  com.apple.GamePolicyAgent \
  com.apple.localizationswitcherd \
  com.apple.reversetemplated \
  com.apple.warmd_agent; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  com.apple.GameController.gamecontrollerd \
  com.apple.gamed \
  com.apple.gamepolicyd \
  com.apple.gputoolsserviced \
  com.apple.InternetSharing \
  com.apple.ODSAgent \
  com.apple.RFBEventHelper \
  com.apple.rpmuxd \
  com.apple.snmptrapd \
  com.apple.tftpd \
  com.apple.ucupdate.plist \
  com.apple.uucp \
  com.apple.warmd \
  com.apple.xartstorageremoted; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
