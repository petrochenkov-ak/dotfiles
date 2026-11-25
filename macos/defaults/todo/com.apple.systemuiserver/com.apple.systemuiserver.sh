#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.systemuiserver

# https://www.jamf.com/jamf-nation/discussions/9745/show-vpn-on-the-menu-bar


# <string>/System/Library/CoreServices/Menu Extras/TimeMachine.menu</string>
# <string>/System/Library/CoreServices/Menu Extras/TextInput.menu</string>
# <string>/System/Library/CoreServices/Menu Extras/AirPort.menu</string>
# <string>/System/Library/CoreServices/Menu Extras/Clock.menu</string>

killall SystemUIServer -HUP
