#!/usr/bin/env bash

( set -x; cd "${BASH_SOURCE%/*/*/*/*/*}" && repo-sql-src-local ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

