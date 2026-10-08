#!/usr/bin/env bash

[[ $# != 1 ]] && echo "usage: ${0##*/} path" && exit 1

# xxx.command - macOS Terminal.app
[[ $1 == *.command ]] && { ( set -x; open -a Terminal "$1" ); exit $?; }

# xxx.sh - default bash
/usr/bin/env bash -l "$1"
