#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.accessoryaccess.uiagent \
  com.apple.accessorysensormgrd \
  com.apple.apfsuseragent \
  com.apple.assessmentagent \
  com.apple.AssetCacheLocatorService \
  com.apple.backgroundassets.user \
  com.apple.ContainerMigrationService \
  com.apple.diskspaced \
  com.apple.donotdisturbd \
  com.apple.dt.AutomationModeUI \
  com.apple.dt.previewsd \
  com.apple.dt.previewsviewservice \
  com.apple.FileStatsAgent \
  com.apple.frauddefensed \
  com.apple.imklaunchagent \
  com.apple.installandsetup.migrationhelper.user \
  com.apple.keyboardservicesd \
  com.apple.linkd \
  com.apple.localizationswitcherd \
  com.apple.lockdownmoded \
  com.apple.lockoutagent \
  com.apple.menuextra.battery.helper \
  com.apple.midiserver \
  com.apple.milod \
  com.apple.mobiledeviceupdater \
  com.apple.mobilerepaird \
  com.apple.ndoagent \
  com.apple.PasswordBreachAgent \
  com.apple.powerchime \
  com.apple.previewshellapp \
  com.apple.RemoteDesktop.agent \
  com.apple.replicatord \
  com.apple.sensingpredictd \
  com.apple.SoftwareUpdateNotificationManager \
  com.apple.StatusKitAgent \
  com.apple.testmanagerd \
  com.apple.TMHelperAgent \
  com.apple.wallpaper.agent \
  com.apple.wallpaper.export \
  com.apple.wallpaperexportd \
  com.apple.warmd_agent \
  com.google.GoogleUpdater.wake; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.AssetCache.builtin \
  com.apple.AssetCacheManagerService \
  com.apple.AssetCacheSubscriber \
  com.apple.AssetCacheTetheratorService \
  com.apple.backupd \
  com.apple.backupd-helper \
  com.apple.bootcampd \
  com.apple.idleassetsd \
  com.apple.installandsetup.systemmigrationd \
  com.apple.milod \
  com.apple.PasscodeSettingsSubscriber \
  com.apple.SecuritySubscriber \
  com.apple.TMCacheDelete \
  com.apple.wallpaper.export \
  com.apple.wallpaperexportd \
  com.apple.warmd \
  com.apple.xartstorageremoted; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
