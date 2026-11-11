#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.netauth.user.auth \
  com.apple.netauth.user.gui \
  com.apple.WiFiVelocityAgent; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  com.apple.afpfs_afpLoad \
  com.apple.afpfs_checkafp \
  com.apple.awacsd \
  com.apple.eapolcfg_auth \
  com.apple.ftp-proxy \
  com.apple.netbiosd \
  com.apple.nis.ypbind \
  com.apple.ppp.l2tp \
  com.apple.ppp.pptp \
  com.apple.racoon \
  com.apple.smb.preferences \
  com.apple.wifivelocityd; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
