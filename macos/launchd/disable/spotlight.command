#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

( set -x; sudo mdutil -a -i off ) || exit 1
( set -x; sudo mdutil -a -E ) || exit 1

for agent in \
  com.apple.assistant_service \
  com.apple.assistantd \
  com.apple.BiomeAgent \
  com.apple.corespotlightd \
  com.apple.corespotlightservice \
  com.apple.DataDetectorsLocalSources \
  com.apple.generativeexperiencesd \
  com.apple.intelligenceplatformd \
  com.apple.knowledge-agent \
  com.apple.managedcorespotlightd \
  com.apple.mdworker.application \
  com.apple.mdworker.mail \
  com.apple.mdworker.shared \
  com.apple.mdworker.single.arm64 \
  com.apple.mdworker.single.x86_64 \
  com.apple.mdworker.sizing \
  com.apple.mediaanalysisd \
  com.apple.metadata.mdbulkimport \
  com.apple.metadata.mdflagwriter \
  com.apple.metadata.mdwrite \
  com.apple.parsecd \
  com.apple.progressd \
  com.apple.Siri.agent \
  com.apple.siriactionsd \
  com.apple.siriknowledged \
  com.apple.Spotlight \
  com.apple.spotlightknowledged \
  com.apple.spotlightknowledged.importer \
  com.apple.spotlightknowledged.updater \
  com.apple.suggestd; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.biomed \
  com.apple.managedcorespotlightd \
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
  com.apple.metadata.mdwrite \
  com.apple.progressd; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
