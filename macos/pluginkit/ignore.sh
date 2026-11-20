#!/usr/bin/env bash

for ext in $(pluginkit -m | awk '/^[[:space:]]*\+/ {print $2}' | grep -iE 'stocks|weather|home|podcast|reminder|screentime|tips|news|fitness|music|tv|books|pass|wallet|health|siri|maui|macintalk|kona|warda|share|social|cloud|photos|markup|findmy|spotlight|gamecenter|family|classroom|intents|widget|search'); do
  ( set -x; pluginkit -e ignore -i "${ext}" ) || true
done

for ext in \
  com.apple.AccessibilitySettingsWidgetExtension \
  com.apple.WorkflowUI.CatalystContentExtension \
  com.apple.siri.SiriPhoneAppIntentsExtension \
  com.apple.ContactsUI.ContactViewViewService \
  com.apple.mobiletimer.WorldClockIntentsExtension \
  com.apple.settings-intents.LockScreenIntents \
  com.apple.HomeKitEvents.HomeKitEventsDiagnosticExtension \
  com.apple.Home.HomeWidgetIntentsExtension \
  com.apple.mobiletimer-framework.MobileTimerIntents \
  com.apple.ScreenTimeUI.ScreenTimeFollowUpExtension \
  com.apple.siri.SiriSuggestionsLightHousePlugin \
  com.apple.MailCacheDelete \
  com.apple.zeolite.ZeoliteEvalExtension \
  com.apple.lighthouse.IFTelemetrySELFIngestor \
  com.apple.news.tag \
  com.apple.siri.car.PnRCarPlayOnDeviceWorker \
  com.apple.Home.HomeWidget.Interactive \
  com.apple.StoreKit.SKAskPermissionExtension \
  com.apple.VisionAppIntents \
  com.apple.Photos.MacMusicPickerExtension \
  com.apple.Batteries.BatteriesAvocadoWidgetExtension \
  com.apple.FaceTime.FaceTimeNotificationExtension \
  com.apple.ClassKit-Settings.extension \
  com.apple.preferencepane.security.AdvertisingExtension \
  com.apple.siri.ODDIMetricsExtension \
  com.apple.shortcuts.ThumbnailExtension \
  com.apple.unilog.SearchUploadWorker \
  com.apple.omniSearch.SearchToolDiagnosticExtension \
  com.apple.donotdisturb.DoNotDisturbAppIntents \
  com.apple.MobileSMS.MessagesActionExtension \
  com.apple.Notes.SharingExtension; do
  ( set -x; pluginkit -e ignore -i "${ext}" ) || true
done
