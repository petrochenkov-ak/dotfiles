#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- com.apple.menuextra.clock

"$@" IsAnalog -bool FALSE
"$@" FlashDateSeparators -bool FALSE
