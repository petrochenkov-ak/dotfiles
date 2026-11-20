#!/usr/bin/env bash

cd "${BASH_SOURCE[0]%/*}"/macos/launchd/disable || exit 1

git add . || exit 1

( set -x; aider --subtree-only --model openai/gpt-6.1-sol --message-file "${BASH_SOURCE[0]%/*}"/mac-prompt.txt )
