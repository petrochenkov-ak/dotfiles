#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

( set -x; defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool false ) || exit 1
( set -x; defaults write com.apple.GenerativeModels.preferences Enabled -bool false ) || exit 1
( set -x; defaults write com.apple.gm.safety_settings Enabled -bool false ) || exit 1

for plugin in \
  com.apple.siri.GMSSELFIngestor \
  com.apple.siri.BiomeSELFIngestor \
  com.apple.siri.IFTelemetrySELFIngestor \
  com.apple.siri.IFTranscriptSELFIngestor \
  com.apple.AppleIntelligenceReportingSELFIngestor \
  com.apple.siri.AppleIntelligenceReportingSELFIngestor \
  com.apple.IntelligencePlatformComputeService \
  com.apple.generativeexperiences.SafetyIngestion \
  com.apple.TextToSpeech.VoiceBanking; do
  ( set -x; pluginkit -e ignore -i "${plugin}" ) || exit 1
done

for agent in \
  com.apple.AppleIntelligenceReportingSELFIngestor \
  com.apple.BiomeAgent \
  com.apple.biomeagent \
  com.apple.biomed \
  com.apple.biomesyncd \
  com.apple.callintelligenced \
  com.apple.ciphermld \
  com.apple.ContextStoreAgent \
  com.apple.duetexpertd \
  com.apple.GenerativeFunctions.agentstored \
  com.apple.generativeexperiencesd \
  com.apple.generativemodelsd \
  com.apple.hybridsearchd \
  com.apple.imageplaygroundd \
  com.apple.intelligencecontextd \
  com.apple.intelligenceflowd \
  com.apple.IntelligencePlatformComputeService \
  com.apple.intelligenceplatformd \
  com.apple.intelligencetasksd \
  com.apple.intelligentroutingd \
  com.apple.knowledge-agent \
  com.apple.knowledgeconstructiond \
  com.apple.mediaanalysisd \
  com.apple.mlhostd \
  com.apple.mlruntimed \
  com.apple.ModelCatalogAgent \
  com.apple.modelcatalogd \
  com.apple.modelmanagerd \
  com.apple.naturallanguaged \
  com.apple.parsec-fbf \
  com.apple.parsecd \
  com.apple.photoanalysisd \
  com.apple.privatecloudcomputed \
  com.apple.proactived \
  com.apple.proactiveeventtrackerd \
  com.apple.reversetemplated \
  com.apple.searchtoold \
  com.apple.siri.AppleIntelligenceReportingSELFIngestor \
  com.apple.siri.BiomeSELFIngestor \
  com.apple.siri.GMSSELFIngestor \
  com.apple.siri.IFTelemetrySELFIngestor \
  com.apple.siri.IFTranscriptSELFIngestor \
  com.apple.suggestd \
  com.apple.synapse.contentlinkingd \
  com.apple.textcomposerd \
  com.apple.textcontextd \
  com.apple.textunderstandingd \
  com.apple.translationd \
  com.apple.triald \
  com.apple.visualintelligenced; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.aned \
  com.apple.biomed \
  com.apple.contextstored \
  com.apple.generativeexperiencesd \
  com.apple.generativemodelsd \
  com.apple.intelligenceplatformd \
  com.apple.intelligentroutingd \
  com.apple.mlhostd \
  com.apple.modelcatalogd \
  com.apple.modelmanagerd \
  com.apple.ospredictiond \
  com.apple.privatecloudcomputed \
  com.apple.triald.system \
  com.apple.visualintelligenced; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
