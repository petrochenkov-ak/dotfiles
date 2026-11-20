#!/usr/bin/env bash

( set -x; networksetup -getautoproxyurl "Wi-Fi" )
( set -x; scutil --proxy )
