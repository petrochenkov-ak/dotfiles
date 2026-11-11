#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.AMPArtworkAgent \
  com.apple.AMPDeviceDiscoveryAgent \
  com.apple.AMPDevicesAgent \
  com.apple.AMPSystemPlayerAgent \
  com.apple.amsaccountsd \
  com.apple.amsengagementd \
  com.apple.amsondevicestoraged \
  com.apple.appplaceholdersyncd \
  com.apple.appstoreagent \
  com.apple.appstorecomponentsd \
  com.apple.askpermissiond \
  com.apple.bookdatastored \
  com.apple.businessservicesd \
  com.apple.chronod \
  com.apple.commerce \
  com.apple.CoreLocationAgent \
  com.apple.CoreRoutine.helperservice \
  com.apple.DictionaryServiceHelper \
  com.apple.financed \
  com.apple.geod \
  com.apple.geodMachServiceBridge \
  com.apple.helpd \
  com.apple.homed \
  com.apple.homeenergyd \
  com.apple.homeeventsd \
  com.apple.HomeWidgetIntentsExtension \
  com.apple.itunescloudd \
  com.apple.jetpackassetd \
  com.apple.liveactivitiesd \
  com.apple.locationaccessstored \
  com.apple.Maps.mapspushd \
  com.apple.Maps.mapssyncd \
  com.apple.mediaremoted \
  com.apple.navd \
  com.apple.newsd \
  com.apple.Notes.datastore \
  com.apple.passd \
  com.apple.postersyncd \
  com.apple.routined \
  com.apple.shazamd \
  com.apple.shazameventsd \
  com.apple.sportsd \
  com.apple.StocksKitService \
  com.apple.storeassetd \
  com.apple.storelegacy \
  com.apple.tipsd \
  com.apple.videosubscriptionsd \
  com.apple.voicememod \
  com.apple.WallpaperAerialsExtension \
  com.apple.WallpaperImageExtension; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  com.apple.AMPDeviceDiscoveryAgent \
  com.apple.appstoreagent \
  com.apple.askpermissiond \
  com.apple.commerce \
  com.apple.CoreLocationAgent \
  com.apple.geod \
  com.apple.homed \
  com.apple.homeenergyd \
  com.apple.installd \
  com.apple.locationd \
  com.apple.storeassetd; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
