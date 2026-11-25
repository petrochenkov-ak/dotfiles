#!/usr/bin/env bash

( set -x; cd "${BASH_SOURCE[0]%/*}" && make )
