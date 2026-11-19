#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
( set -x; defaults write com.apple.speech.synthesis.general.prefs SpokenUIUseSpeakHotKeyFlag -bool false ) || exit 1

for agent in \
  com.apple.accessibility.axassetsd \
  com.apple.accessibility.AXVisualSupportAgent \
  com.apple.accessibility.dfrhud \
  com.apple.accessibility.heard \
  com.apple.accessibility.LiveTranscriptionAgent \
  com.apple.accessibility.mediaaccessibilityd \
  com.apple.accessibility.MotionTrackingAgent \
  com.apple.AccessibilityUIServer \
  com.apple.AssistiveControl \
  com.apple.DictationIM \
  com.apple.DwellControl \
  com.apple.KeyboardAccessAgent \
  com.apple.KonaSynthesizer \
  com.apple.MacinTalkAUSP \
  com.apple.MauiAUSP \
  com.apple.ScreenReaderUIServer \
  com.apple.scrod \
  com.apple.SpeakSelection \
  com.apple.speech.localspeechrecognition \
  com.apple.speech.speechdatainstallerd \
  com.apple.speech.speechrecognitiond \
  com.apple.speech.speechsynthesisd \
  com.apple.speech.speechsynthesisd.arm64 \
  com.apple.speech.speechsynthesisd.x86_64 \
  com.apple.speech.synthesisserver \
  com.apple.speechmaintenanced \
  com.apple.SpeechRecognitionCore.brokerd \
  com.apple.UniversalAccessAuthWarn \
  com.apple.universalaccesscontrol \
  com.apple.universalaccessd \
  com.apple.voicebankingd \
  com.apple.VoiceOver \
  com.apple.WardaSynthesizer; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; sudo launchctl disable "${domain}/${agent}" ) || true
    if sudo launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; sudo launchctl bootout "${domain}/${agent}" ) || true
    fi
  done
done

for daemon in \
  com.apple.speech.speechsynthesisd; do
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
done
