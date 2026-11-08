#!/usr/bin/env bash

( set -x; cd "${BASH_SOURCE%/*/*/*/*/*/*}"; repo-python-packages-ai-type-fixer --all )
