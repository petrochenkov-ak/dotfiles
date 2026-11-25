#!/usr/bin/env bash
{ set +x; } 2>/dev/null

# do not save new documents to iCloud by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
