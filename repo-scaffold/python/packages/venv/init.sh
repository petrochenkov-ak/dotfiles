#!/usr/bin/env bash

( set -x; cd "${BASH_SOURCE%/*/*/*/*}" && python3.14 -m venv .venv --system-site-packages )
