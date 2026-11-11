#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

uid=$(id -u)

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

( set -x; defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool false ) || true
( set -x; defaults write com.apple.assistant.support "Assistant Enabled" -bool false ) || true
( set -x; defaults write com.apple.Siri StatusMenuVisible -bool false ) || true
( set -x; defaults write com.apple.Siri UserHasDeclinedEnable -bool true ) || true
( set -x; defaults write com.apple.GenerativeModels.preferences Enabled -bool false ) || true
( set -x; defaults write com.apple.gm.safety_settings Enabled -bool false ) || true
( set -x; defaults write com.apple.SiriVoiceTrigger "VoiceTrigger Enabled" -bool false ) || true

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
  ( set -x; pluginkit -e ignore -i "${plugin}" ) || true
done

for agent in \
  com.apple.AppleIntelligenceReportingSELFIngestor \
  com.apple.assistant_cdmd \
  com.apple.assistant_service \
  com.apple.assistantd \
  com.apple.BiomeAgent \
  com.apple.biomeagent \
  com.apple.biomed \
  com.apple.biomesyncd \
  com.apple.callintelligenced \
  com.apple.ContextStoreAgent \
  com.apple.corespeechd \
  com.apple.duetexpertd \
  com.apple.generativeexperiencesd \
  com.apple.generativemodelsd \
  com.apple.hybridsearchd \
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
  com.apple.parsec-fbf \
  com.apple.parsecd \
  com.apple.photoanalysisd \
  com.apple.privatecloudcomputed \
  com.apple.proactiveeventtrackerd \
  com.apple.searchtoold \
  com.apple.siri.AppleIntelligenceReportingSELFIngestor \
  com.apple.siri.BiomeSELFIngestor \
  com.apple.siri.context.service \
  com.apple.siri.GMSSELFIngestor \
  com.apple.siri.IFTelemetrySELFIngestor \
  com.apple.siri.IFTranscriptSELFIngestor \
  com.apple.siriactionsd \
  com.apple.siriinferenced \
  com.apple.siriknowledged \
  com.apple.sirittsd \
  com.apple.SiriTTSTrainingAgent \
  com.apple.speech.localspeechrecognition \
  com.apple.speech.speechrecognitiond \
  com.apple.speech.speechsynthesisd \
  com.apple.suggestd \
  com.apple.synapse.contentlinkingd \
  com.apple.textunderstandingd \
  com.apple.translationd \
  com.apple.triald \
  com.apple.visualintelligenced \
  com.apple.voicebankingd; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || true
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
done

for daemon in \
  com.apple.aned \
  com.apple.biomed \
  com.apple.contextstored \
  com.apple.corespeechd \
  com.apple.generativeexperiencesd \
  com.apple.generativemodelsd \
  com.apple.intelligenceplatformd \
  com.apple.intelligentroutingd \
  com.apple.mlhostd \
  com.apple.modelcatalogd \
  com.apple.modelmanagerd \
  com.apple.ospredictiond \
  com.apple.privatecloudcomputed \
  com.apple.siriinferenced \
  com.apple.triald.system \
  com.apple.visualintelligenced; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
done
