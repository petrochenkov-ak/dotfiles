#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.DeviceConfigurationAgent \
  com.apple.familycircled \
  com.apple.FamilyControlsAgent \
  com.apple.managedappdistributionagent \
  com.apple.ManagedClientAgent.agent \
  com.apple.ManagedSettingsAgent \
  com.apple.mdmclient.agent \
  com.apple.parentalcontrols.check \
  com.apple.RemoteDesktop.agent \
  com.apple.RemoteManagementAgent \
  com.apple.screensharing.MessagesAgent \
  com.apple.ScreenTimeAgent \
  com.apple.ScreenTimeSettingsAgent \
  com.apple.studentd \
  com.apple.UsageTrackingAgent; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  com.apple.familycontrols \
  com.apple.ManagedClient \
  com.apple.ManagedClient.cloudconfigurationd \
  com.apple.ManagedClient.enroll \
  com.apple.ManagedClient.startup \
  com.apple.mdmclient.daemon \
  com.apple.parentalcontrols.check \
  com.apple.RemoteDesktop.PrivilegeProxy \
  com.apple.screensharing \
  com.apple.studentd; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
