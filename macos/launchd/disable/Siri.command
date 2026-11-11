#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

uid=$(id -u)

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

( set -x; sudo mdutil -a -i off ) || exit 1
( set -x; sudo mdutil -a -E ) || exit 1

( set -x; defaults write com.apple.assistant.support "Assistant Enabled" -bool false ) || exit 1
( set -x; defaults write com.apple.Siri StatusMenuVisible -bool false ) || exit 1
( set -x; defaults write com.apple.Siri UserHasDeclinedEnable -bool true ) || exit 1
( set -x; defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false ) || exit 1
( set -x; defaults write com.apple.Siri TypeToSiriEnabled -bool false ) || exit 1
( set -x; defaults write com.apple.Siri LockscreenEnabled -bool false ) || exit 1
( set -x; defaults write com.apple.suggestions SuggestionsAllowLocal -bool false ) || exit 1
( set -x; defaults write com.apple.suggestions AppCanShowSiriSuggestionsBlacklist -array ) || exit 1
( set -x; defaults write com.apple.speech.synthesis.general.prefs SpokenUIUseSpeakHotKeyFlag -bool false ) || exit 1

for agent in \
  com.apple.accessibility.axassetsd \
  com.apple.accessibility.LiveTranscriptionAgent \
  com.apple.AddressBook.AssistantService \
  com.apple.assistant_cdmd \
  com.apple.assistant_service \
  com.apple.assistantd \
  com.apple.biomeagent \
  com.apple.corespotlightd \
  com.apple.corespotlightservice \
  com.apple.DataDetectorsLocalSources \
  com.apple.intelligencecontextd \
  com.apple.intelligenceflowd \
  com.apple.intelligenceplatformd \
  com.apple.knowledge-agent \
  com.apple.managedcorespotlightd \
  com.apple.mdworker.mail \
  com.apple.mdworker.shared \
  com.apple.mdworker.sizing \
  com.apple.parsec-fbf \
  com.apple.parsecd \
  com.apple.proactived \
  com.apple.reversetemplated \
  com.apple.Siri.agent \
  com.apple.siri.context.service \
  com.apple.siri.morphunassetsupdaterd \
  com.apple.siriactionsd \
  com.apple.siriappintentsd \
  com.apple.SiriAUSP \
  com.apple.siriinferenced \
  com.apple.siriknowledged \
  com.apple.SiriSetupSettingsIntents \
  com.apple.SiriSuggestionsBookkeepingService \
  com.apple.sirittsd \
  com.apple.SiriTTSTrainingAgent \
  com.apple.speech.speechsynthesisd \
  com.apple.speech.speechsynthesisd.arm64 \
  com.apple.speech.speechsynthesisd.x86_64 \
  com.apple.speech.synthesisserver \
  com.apple.speechmaintenanced \
  com.apple.Spotlight \
  com.apple.suggestd \
  com.apple.textunderstandingd \
  com.apple.voicebankingd; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || exit 1
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || exit 1
  done
done

for daemon in \
  com.apple.biomed \
  com.apple.corespeechd \
  com.apple.intelligenceplatformd \
  com.apple.managedcorespotlightd \
  com.apple.metadata.mds \
  com.apple.metadata.mds.index \
  com.apple.metadata.mds.scan \
  com.apple.metadata.mds.spindump \
  com.apple.modelmanagerd \
  com.apple.siri.acousticsIGN \
  com.apple.siri.context.service \
  com.apple.siri.morphunassetsupdaterd \
  com.apple.siriappintentsd \
  com.apple.SiriAUSP \
  com.apple.speech.speechsynthesisd; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || exit 1
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || exit 1
done
