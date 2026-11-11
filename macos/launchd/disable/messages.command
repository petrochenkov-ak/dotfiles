#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

uid=$(id -u)

for agent in \
  com.apple.asktod \
  com.apple.AskPermissionUI \
  com.apple.callhistoryd \
  com.apple.CallHistoryPluginHelper \
  com.apple.CallHistorySyncHelper \
  com.apple.callverificationd \
  com.apple.cmfsyncagent \
  com.apple.facetimemessagestored \
  com.apple.familycontrols.useragent \
  com.apple.familynotificationd \
  com.apple.imagent \
  com.apple.imautomatichistorydeletionagent \
  com.apple.imdpersistence.IMDPersistenceAgent \
  com.apple.imtransferagent \
  com.apple.messagesescrowd \
  com.apple.sociallayerd \
  com.apple.ssinvitationagent \
  com.apple.telephonyutilities.callservicesd; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || true
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
done
