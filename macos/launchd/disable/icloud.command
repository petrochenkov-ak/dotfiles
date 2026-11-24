#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.accounts.dom \
  com.apple.accountsd \
  com.apple.akd \
  com.apple.AOSHeartbeat \
  com.apple.AOSPushRelay \
  com.apple.AppleIDSettings \
  com.apple.appleidsetupd \
  com.apple.avatarsd \
  com.apple.bird \
  com.apple.cdp.daemon \
  com.apple.cdpd \
  com.apple.ckdiscretionaryd \
  com.apple.cksharingmanagementd \
  com.apple.cloudd \
  com.apple.cloudpaird \
  com.apple.cloudphotod \
  com.apple.CloudPhotosConfiguration \
  com.apple.CloudSettingsSyncAgent \
  com.apple.cloudsettingssyncagent \
  com.apple.contacts.postersyncd \
  com.apple.EscrowSecurityAlert \
  com.apple.findmy.findmylocateagent \
  com.apple.findmydevice-user-agent \
  com.apple.findmylocateagent \
  com.apple.findmymacmessenger \
  com.apple.followupd \
  com.apple.FollowUpUI \
  com.apple.icloud.findmydeviced.findmydevice-user-agent \
  com.apple.icloud.fmfd \
  com.apple.icloud.searchpartyuseragent \
  com.apple.iCloudHelper \
  com.apple.icloudmailagent \
  com.apple.iCloudNotificationAgent \
  com.apple.iCloudUserNotificationsd \
  com.apple.icloudwebd \
  com.apple.keychainsharingmessagingd \
  com.apple.photolibraryd \
  com.apple.PosterBoard \
  com.apple.postersyncd \
  com.apple.protectedcloudstorage.protectedcloudkeysyncing \
  com.apple.ProtectedCloudKeySyncing \
  com.apple.searchpartyuseragent \
  com.apple.SecureBackupDaemon \
  com.apple.security.cloudkeychainproxy3 \
  com.apple.security.keychain-circle-notification \
  com.apple.swtransparencyd \
  com.apple.syncdefaultsd \
  com.apple.syncservices.SyncServer \
  com.apple.transparency \
  com.apple.transparencyStaticKey \
  com.apple.TrustedPeersHelper \
  com.apple.UserPictureSyncAgent; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.akd \
  com.apple.appleidsetupd \
  com.apple.ckdiscretionaryd \
  com.apple.findmy.findmylocated \
  com.apple.findmybeaconingd \
  com.apple.findmydeviced \
  com.apple.findmymacd \
  com.apple.findmymacmessenger \
  com.apple.icloud.findmydeviced \
  com.apple.icloud.searchpartyd \
  com.apple.photolibraryd \
  com.apple.searchpartyd \
  com.apple.SecureBackupDaemon \
  com.apple.swtransparencyd; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
