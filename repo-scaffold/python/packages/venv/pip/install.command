#!/usr/bin/env bash

cd "${BASH_SOURCE%/*/*/*/*/*}" || exit

( set -x; python -m repo_pyproject_gen ) || exit
for pkg in python/packages/*/; do
    [[ "$pkg" == *"__pycache__"* ]] && continue
    ( set -x; .venv/bin/python -m pip install -e "$pkg" --no-build-isolation --no-deps ) || exit
done || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

