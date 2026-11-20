#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.avconferenced \
  com.apple.callhistoryd \
  com.apple.CallHistoryPluginHelper \
  com.apple.CallHistorySyncHelper \
  com.apple.callverificationd \
  com.apple.cmfsyncagent \
  com.apple.CMFSyncAgent \
  com.apple.CommCenter-osx \
  com.apple.communicationtrustd \
  com.apple.facetimemessagestored \
  com.apple.idsfoundation.IDSRemoteURLConnectionAgent \
  com.apple.imagent \
  com.apple.imautomatichistorydeletionagent \
  com.apple.imcore.imtransferagent \
  com.apple.imdpersistence.IMDPersistenceAgent \
  com.apple.IMDPersistenceAgent \
  com.apple.imtransferagent \
  com.apple.imtransferservices.IMTransferAgent \
  com.apple.MessagesActionExtension \
  com.apple.messagesescrowd \
  com.apple.sociallayerd \
  com.apple.ssinvitationagent \
  com.apple.stickersd \
  com.apple.telephonyutilities.callservicesd \
  com.apple.videoconference.camera; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.appleh13camerad \
  com.apple.avconferenced \
  com.apple.CommCenter \
  com.apple.stickersd; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
