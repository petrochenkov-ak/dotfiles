#!/usr/bin/env bash
{ set +x; } 2>/dev/null

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -boolean false
