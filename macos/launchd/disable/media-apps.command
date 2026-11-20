#!/usr/bin/env bash

uid=$(id -u)

if [ "$EUID" -eq 0 ]; then
  exit 1
fi

for agent in \
  com.apple.AddressBook.abd \
  com.apple.AddressBook.SourceSync \
  com.apple.businessservicesd \
  com.apple.calaccessd \
  com.apple.calendar.CalendarAgentBookmarkMigrationService \
  com.apple.CalendarAgent \
  com.apple.CalendarIntentsExtension \
  com.apple.CategoriesService \
  com.apple.ClockAngel \
  com.apple.contacts.donation-agent \
  com.apple.contactsd \
  com.apple.dataaccess.dataaccessd \
  com.apple.DictionaryServiceHelper \
  com.apple.email.maild \
  com.apple.exchange.exchangesyncd \
  com.apple.helpd \
  com.apple.LinkedNotesUIService \
  com.apple.mobiletimerd \
  com.apple.Notes.datastore \
  com.apple.recentsd \
  com.apple.remindd \
  com.apple.tipsd \
  com.apple.weatherd \
  com.apple.WorkflowKit.ShortcutsViewService; do
  for domain in "gui/${uid}" "user/${uid}"; do
    if launchctl print "${domain}/${agent}" >/dev/null 2>&1; then
      ( set -x; launchctl bootout "${domain}/${agent}" ) || true
    fi
    ( set -x; launchctl disable "${domain}/${agent}" ) || true
  done
done
