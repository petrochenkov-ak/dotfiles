#!/usr/bin/env bash
{ set +x; } 2>/dev/null

defaults write com.apple.CrashReporter DialogType none
# restore:
# defaults write com.apple.CrashReporter DialogType crashreport

# notification only:
# defaults write com.apple.CrashReporter DialogType UseUNC 1
