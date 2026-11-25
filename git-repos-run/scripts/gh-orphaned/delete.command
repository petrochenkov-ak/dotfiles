#!/usr/bin/env bash

OWNER=$(set -x; gh-parse-path-owner "$0") || exit 1
ORPHANED_REPO_NAME_LIST=$( set -x; gh-orphaned-github-repo-name-list "$OWNER" ) || exit 1

if [ -z "$ORPHANED_REPO_NAME_LIST" ]; then
  echo "https://github.com/$OWNER orphaned repos not found"
  exit 0
fi

COUNT=$(echo "$ORPHANED_REPO_NAME_LIST" | wc -l | tr -d ' ')

echo "https://github.com/$OWNER orphaned repos ($COUNT):"
while IFS= read -r repo_name; do
    echo "https://github.com/$OWNER/$repo_name"
done <<< "$ORPHANED_REPO_NAME_LIST"

echo "Deleting in 30 seconds..."
( set -x; sleep 30 )

while IFS= read -r repo_name; do
    ( set -x; gh repo delete "$OWNER/$repo_name" --yes ) || exit 1
done <<< "$ORPHANED_REPO_NAME_LIST"
