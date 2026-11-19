#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

( set -x; sudo -v ) || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

for agent in \
  com.apple.adprivacyd \
  com.apple.analyticsagent \
  com.apple.ap.adprivacyd \
  com.apple.ap.promotedcontentd \
  com.apple.appleseed.seedusaged \
  com.apple.appleseed.seedusaged.postinstall \
  com.apple.betaenrollmentagent \
  com.apple.cloudtelemetryd \
  com.apple.diagnosticextensionsd \
  com.apple.diagnostics_agent \
  com.apple.diagnosticspushd \
  com.apple.DiagnosticsReporter \
  com.apple.dprivacyd \
  com.apple.enhancedloggingd \
  com.apple.feedbackd \
  com.apple.geoanalyticsd \
  com.apple.inputanalyticsd \
  com.apple.loginwindow.LWWeeklyMessageTracer \
  com.apple.metrickitd \
  com.apple.osanalyticshelper \
  com.apple.promotedcontentd \
  com.apple.ReportCrash \
  com.apple.securityuploadd \
  com.apple.sharereportingd \
  com.apple.spindump_agent \
  com.apple.symptomsd.distributed-agent \
  com.apple.symptomsd-diag.agent \
  com.apple.sysdiagnose_agent; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || true
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
done

for daemon in \
  com.apple.analyticsd \
  com.apple.appleseed.fbahelperd \
  com.apple.audioanalyticsd \
  com.apple.awdd \
  com.apple.betaenrollmentd \
  com.apple.cloudtelemetryd \
  com.apple.CrashReporterSupportHelper \
  com.apple.diagnosticd \
  com.apple.diagnosticservicesd \
  com.apple.ecosystemanalyticsd \
  com.apple.enhancedloggingd \
  com.apple.feedbackd \
  com.apple.osanalytics.osanalyticshelper \
  com.apple.osanalyticshelper \
  com.apple.PerfPowerServices \
  com.apple.PerfPowerServicesExtended \
  com.apple.PerfPowerTelemetryClientRegistrationService \
  com.apple.powerlogHelperd \
  com.apple.ReportCrash.Root \
  com.apple.rtcreportingd \
  com.apple.spindump \
  com.apple.SubmitDiagInfo \
  com.apple.symptomsd \
  com.apple.symptomsd-diag \
  com.apple.symptomsd-diag.agent \
  com.apple.sysdiagnose \
  com.apple.sysdiagnose_agent \
  com.apple.systemstats.analysis \
  com.apple.systemstats.daily \
  com.apple.systemstats.microstackshot_periodic \
  com.apple.tailspind \
  com.apple.wifianalyticsd; do
  if sudo launchctl print "system/${daemon}" >/dev/null 2>&1; then
    ( set -x; sudo launchctl bootout "system/${daemon}" ) || true
  fi
  ( set -x; sudo launchctl disable "system/${daemon}" ) || true
done

( set -x; defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false ) || exit 1
( set -x; defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false ) || exit 1
( set -x; defaults write com.apple.assistant.support "Siri Data Sharing Opt-In Status" -int 2 ) || exit 1
( set -x; defaults write com.apple.CrashReporter DialogType -string "none" ) || exit 1
( set -x; sudo defaults write "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist" AutoSubmit -bool false ) || exit 1
( set -x; sudo defaults write "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist" ThirdPartyDataSubmit -bool false ) || exit 1
