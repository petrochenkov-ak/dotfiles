#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

uid=$(id -u)

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

agents=(
  com.apple.inputanalyticsd
  com.apple.analyticsagent
  com.apple.diagnostics_agent
  com.apple.diagnosticspushd
  com.apple.DiagnosticsReporter
  com.apple.diagnosticextensionsd
  com.apple.enhancedloggingd
  com.apple.feedbackd
  com.apple.sharereportingd
  com.apple.symptomsd-diag.agent
  com.apple.sysdiagnose_agent
  com.apple.ReportCrash
  com.apple.UsageTrackingAgent
  com.apple.geoanalyticsd
  com.apple.ap.adprivacyd
  com.apple.ap.promotedcontentd
  com.apple.appleseed.seedusaged
  com.apple.appleseed.seedusaged.postinstall
  com.apple.betaenrollmentagent
  com.apple.parsec-fbf
  com.apple.parsecd
  com.apple.assistant_service
  com.apple.Siri.agent
  com.apple.triald
)

for agent in "${agents[@]}"; do
  for domain in "gui/${uid}" "user/${uid}"; do
    ( set -x; launchctl bootout "${domain}/${agent}" ) 2>/dev/null || true
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
done

daemons=(
  com.apple.analyticsd
  com.apple.symptomsd
  com.apple.symptomsd-diag
  com.apple.symptomsd-diag.agent
  com.apple.sysdiagnose
  com.apple.sysdiagnose_agent
  com.apple.enhancedloggingd
  com.apple.ecosystemanalyticsd
  com.apple.cloudtelemetryd
  com.apple.SubmitDiagInfo
  com.apple.ReportCrash.Root
  com.apple.spindump
  com.apple.tailspind
  com.apple.PerfPowerServices
  com.apple.PerfPowerServicesExtended
  com.apple.powerlogHelperd
  com.apple.osanalytics.osanalyticshelper
  com.apple.wifianalyticsd
  com.apple.awdd
  com.apple.CrashReporterSupportHelper
  com.apple.betaenrollmentd
  com.apple.triald.system
)

for daemon in "${daemons[@]}"; do
  ( set -x; sudo launchctl bootout "system/${daemon}" ) 2>/dev/null || true
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
done

defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false
defaults write com.apple.assistant.support "Siri Data Sharing Opt-In Status" -int 2
defaults write com.apple.CrashReporter DialogType -string "none"

sudo defaults write "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist" AutoSubmit -bool false
sudo defaults write "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist" ThirdPartyDataSubmit -bool false
