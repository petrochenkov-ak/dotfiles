#!/usr/bin/env bash

( set -x; sudo rm -rf /Library/Developer/CommandLineTools )
( set -x; sudo xcode-select --install )
