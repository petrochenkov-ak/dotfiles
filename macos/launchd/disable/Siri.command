#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

( set -x; defaults write com.apple.assistant.support "Assistant Enabled" -bool false ) || exit 1
( set -x; defaults write com.apple.Siri StatusMenuVisible -bool false ) || exit 1
( set -x; defaults write com.apple.Siri UserHasDeclinedEnable -bool true ) || exit 1
( set -x; defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false ) || exit 1
( set -x; defaults write com.apple.Siri TypeToSiriEnabled -bool false ) || exit 1
( set -x; defaults write com.apple.Siri LockscreenEnabled -bool false ) || exit 1
( set -x; defaults write com.apple.suggestions SuggestionsAllowLocal -bool false ) || exit 1
( set -x; defaults write com.apple.suggestions AppCanShowSiriSuggestionsBlacklist -array ) || exit 1
( set -x; defaults write com.apple.SiriVoiceTrigger "VoiceTrigger Enabled" -bool false ) || exit 1

for agent in \
  com.apple.AddressBook.AssistantService \
  com.apple.assistant_cdmd \
  com.apple.assistant_service \
  com.apple.assistantd \
  com.apple.corespeechd \
  com.apple.Siri \
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
  com.apple.SiriTTSTrainingAgent; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.corespeechd \
  com.apple.siri.acousticsIGN \
  com.apple.siri.context.service \
  com.apple.siri.morphunassetsupdaterd \
  com.apple.siriappintentsd \
  com.apple.SiriAUSP \
  com.apple.siriinferenced; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
