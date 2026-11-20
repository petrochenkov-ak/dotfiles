#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1

for agent in \
  com.apple.netauth.user.auth \
  com.apple.netauth.user.gui \
  com.apple.WiFiCloudAssetsXPCService \
  com.apple.WiFiVelocityAgent; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || true
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
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
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
done
