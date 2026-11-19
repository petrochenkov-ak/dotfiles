#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.askpermissiond \
  com.apple.AskPermissionUI \
  com.apple.asktod \
  com.apple.cloudfamilyrestrictionsd-mac \
  com.apple.DeviceConfigurationAgent \
  com.apple.familycircled \
  com.apple.familycontrols.useragent \
  com.apple.FamilyControlsAgent \
  com.apple.familynotificationd \
  com.apple.guidedbrowsingd \
  com.apple.managedappdistributionagent \
  com.apple.ManagedClientAgent.agent \
  com.apple.ManagedSettingsAgent \
  com.apple.mdmclient.agent \
  com.apple.parentalcontrols.check \
  com.apple.RemoteDesktop.agent \
  com.apple.RemoteManagementAgent \
  com.apple.screentime \
  com.apple.screensharing.MessagesAgent \
  com.apple.ScreenTimeAgent \
  com.apple.ScreenTimeSettingsAgent \
  com.apple.studentd \
  com.apple.UsageTrackingAgent; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.askpermissiond \
  com.apple.familycontrols \
  com.apple.managedappdistributiond \
  com.apple.ManagedClient \
  com.apple.ManagedClient.cloudconfigurationd \
  com.apple.ManagedClient.enroll \
  com.apple.ManagedClient.startup \
  com.apple.mdmclient.daemon \
  com.apple.parentalcontrols.check \
  com.apple.parentalcontrolsd \
  com.apple.RemoteDesktop.PrivilegeProxy \
  com.apple.remotemanagementd \
  com.apple.screensharing \
  com.apple.studentd; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
