killall SwiftBar SwiftBar-LaunchAtLoginHelper 2>/dev/null

TARGET_DIR="$HOME/.config/swiftbar/plugins"
mkdir -p "$TARGET_DIR"

SANDBOX_PLIST="$HOME/Library/Containers/com.ameba.SwiftBar/Data/Library/Preferences/com.ameba.SwiftBar.plist"

if [ -d "$(dirname "$SANDBOX_PLIST")" ]; then
    defaults write "$SANDBOX_PLIST" PluginDirectory -string "$TARGET_DIR"
    defaults write "$SANDBOX_PLIST" PluginDeveloperMode -bool YES
    defaults write "$SANDBOX_PLIST" MakePluginExecutable -bool YES
fi

defaults write com.ameba.SwiftBar PluginDirectory -string "$TARGET_DIR"
defaults write com.ameba.SwiftBar PluginDeveloperMode -bool YES
defaults write com.ameba.SwiftBar MakePluginExecutable -bool YES

killall cfprefsd

open -a SwiftBar
