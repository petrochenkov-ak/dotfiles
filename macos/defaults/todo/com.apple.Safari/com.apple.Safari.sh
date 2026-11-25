#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.Safari

# Prevent Safari from opening ‘safe’ files automatically after downloading
"$@" AutoOpenSafeDownloads -bool FALSE

# Allow hitting the Backspace key to go to the previous page in history
"$@" com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool TRUE

# Enable the Develop menu and the Web Inspector in Safari
"$@" com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool TRUE

# Disable Safari’s thumbnail cache for History and Top Sites
"$@" DebugSnapshotsUpdatePolicy -int 2

# Make Safari’s search banners default to Contains instead of Starts With
"$@" FindOnPageMatchesWordStartsOnly -bool FALSE

# Enable the Develop menu and the Web Inspector in Safari
"$@" IncludeDevelopMenu -bool TRUE

# Enable Safari’s debug menu
"$@" IncludeInternalDebugMenu -bool TRUE

# Set Safari’s home page to `about:blank` for faster loading
"$@" HomePage -string "about:blank"

# Remove useless icons from Safari’s bookmarks bar
"$@" ProxiesInBookmarksBar -string "()"


# Hide Safari’s bookmarks bar by default
"$@" ShowFavoritesBar -bool FALSE

# Hide Safari’s sidebar in Top Sites
"$@" ShowSidebarInTopSites -bool FALSE

# Show the full URL in the address bar (note: this still hides the scheme)
"$@" ShowFullURLInSmartSearchField -bool TRUE

# Privacy: don’t send search queries to Apple
"$@" SuppressSearchSuggestions -bool TRUE
"$@" UniversalSearchEnabled -bool FALSE

# Press Tab to highlight each item on a web page
"$@" WebKitTabToLinksPreferenceKey -bool TRUE

"$@" WebKitDeveloperExtrasEnabledPreferenceKey -bool TRUE
