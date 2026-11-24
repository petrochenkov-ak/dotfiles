#!/bin/bash
set -u
umask 077

if [ "$(id -u)" -eq 0 ]; then
    echo "Запусти БЕЗ sudo."
    exit 1
fi

DOMAIN="gui/$(id -u)"
STATE="$HOME/Library/Application Support/macos-trim"
LIST="$STATE/disabled-by-script.txt"
RESTORE="$HOME/Desktop/restore-macos-services.sh"

mkdir -p "$STATE" || exit 1
touch "$LIST" || exit 1

DISABLED="$(launchctl print-disabled "$DOMAIN" 2>/dev/null)"

disable_service() {
    local label="$1"

    if printf '%s\n' "$DISABLED" |
        grep -Fq "\"$label\" => true"; then
        echo "Уже отключено: $label"
        return
    fi

    if ! launchctl print "$DOMAIN/$label" >/dev/null 2>&1 &&
       [ ! -f "/System/Library/LaunchAgents/$label.plist" ] &&
       [ ! -f "/Library/LaunchAgents/$label.plist" ] &&
       [ ! -f "$HOME/Library/LaunchAgents/$label.plist" ]; then
        return
    fi

    if launchctl disable "$DOMAIN/$label"; then
        if ! grep -Fxq "$label" "$LIST"; then
            printf '%s\n' "$label" >> "$LIST"
        fi

        echo "Отключено: $label"

        # Если система разрешает — останавливаем сразу.
        # Иначе изменение может потребовать перезагрузки.
        launchctl bootout "$DOMAIN/$label" >/dev/null 2>&1 || true
    else
        echo "macOS запретила отключение: $label"
    fi
}

while IFS= read -r label; do
    [ -n "$label" ] && disable_service "$label"
done <<'SERVICES'
com.apple.assistantd
com.apple.assistant_service
com.apple.assistant_cdmd
com.apple.siri.context.service
com.apple.siriactionsd
com.apple.siriknowledged
com.apple.siriinferenced
com.apple.siriappintentsd
com.apple.sirittsd
com.apple.SiriTTSTrainingAgent
com.apple.generativeexperiencesd
com.apple.GenerativeFunctions.agentstored
com.apple.intelligenceplatformd
com.apple.intelligencetasksd
com.apple.intelligenceflowd
com.apple.intelligencecontextd
com.apple.privatecloudcomputed
com.apple.imageplaygroundd
com.apple.visualintelligenced
com.apple.chronod
com.apple.widgets
com.apple.mediacontinuityd
com.apple.cmio.ContinuityCaptureAgent
com.apple.sidecar-relay
com.apple.sidecar-display-agent
com.apple.AMPDeviceDiscoveryAgent
com.apple.AMPDevicesAgent
com.apple.notes.exchangenotesd
com.apple.LinkedNotesUIService
com.apple.gamed
com.apple.gamesaved
com.apple.GameOverlayUI
SERVICES
