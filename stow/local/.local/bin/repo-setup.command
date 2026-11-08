#!/usr/bin/env bash

( set -x; find -H ~/git -maxdepth 2 -mindepth 2 -type d -exec bash -c 'cd "$1" && repo-setup' _ {} \; )
