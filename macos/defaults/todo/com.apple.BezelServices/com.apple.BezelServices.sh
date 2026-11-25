#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.BezelServices

# Automatically illuminate built-in MacBook keyboard in low light
"$@" kDim -bool FALSE
