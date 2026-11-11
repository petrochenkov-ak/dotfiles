#!/usr/bin/env bash

uid=$(id -u)

for agent in \
  com.apple.accessibility.AXVisualSupportAgent \
  com.apple.accessibility.dfrhud \
  com.apple.accessibility.heard \
  com.apple.accessibility.mediaaccessibilityd \
  com.apple.accessibility.MotionTrackingAgent \
  com.apple.AccessibilityUIServer \
  com.apple.AssistiveControl \
  com.apple.DictationIM \
  com.apple.DwellControl \
  com.apple.KeyboardAccessAgent \
  com.apple.ScreenReaderUIServer \
  com.apple.scrod \
  com.apple.SpeakSelection \
  com.apple.speech.speechdatainstallerd \
  com.apple.speech.speechsynthesisd \
  com.apple.speech.speechsynthesisd.arm64 \
  com.apple.UniversalAccessAuthWarn \
  com.apple.universalaccesscontrol \
  com.apple.universalaccessd \
  com.apple.VoiceOver; do
  if launchctl print "gui/${uid}/${agent}" >/dev/null 2>&1; then
    ( set -x; launchctl bootout "gui/${uid}/${agent}" ) || exit 1
  fi
  ( set -x; launchctl disable "gui/${uid}/${agent}" ) || exit 1
done
