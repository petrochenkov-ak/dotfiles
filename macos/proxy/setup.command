#!/usr/bin/env bash

( set -x; sudo networksetup -setautoproxyurl "Wi-Fi" "https://antizapret.prostovpn.org/proxy.pac" ) || exit 1
( set -x; networksetup -getautoproxyurl "Wi-Fi" )
