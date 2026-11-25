#!/usr/bin/env bash
{ set +x; } 2>/dev/null

set -- defaults write com.apple.TextEdit

# Use plain text mode for new TextEdit documents
"$@" RichText -int 0

# Open and save files as UTF-8 in TextEdit
"$@" PlainTextEncoding -int 4
"$@" PlainTextEncodingForWrite -int 4
