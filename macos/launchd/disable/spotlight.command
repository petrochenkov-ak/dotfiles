#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.Spotlight \
  com.apple.corespotlightd \
  com.apple.corespotlightservice \
  com.apple.mdworker.application \
  com.apple.mdworker.shared \
  com.apple.mdworker.single.arm64 \
  com.apple.mdworker.single.x86_64 \
  com.apple.mdworker.sizing \
  com.apple.mediaanalysisd \
  com.apple.metadata.mdbulkimport \
  com.apple.metadata.mdflagwriter \
  com.apple.metadata.mdwrite \
  com.apple.photoanalysisd \
  com.apple.progressd \
  com.apple.spotlightknowledged \
  com.apple.spotlightknowledged.importer \
  com.apple.spotlightknowledged.updater; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done

for daemon in \
  com.apple.mdworker.shared \
  com.apple.mdworker.single.arm64 \
  com.apple.mdworker.single.x86_64 \
  com.apple.mdworker.sizing \
  com.apple.metadata.mdbulkimport \
  com.apple.metadata.mdflagwriter \
  com.apple.metadata.mds \
  com.apple.metadata.mds.index \
  com.apple.metadata.mds.scan \
  com.apple.metadata.mds.spindump \
  com.apple.metadata.mdwrite; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
