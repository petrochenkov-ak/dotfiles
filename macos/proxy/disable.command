#!/usr/bin/env bash

( set -x; sudo networksetup -setwebproxystate "Wi-Fi" off )
( set -x; sudo networksetup -setsecurewebproxystate "Wi-Fi" off )
( set -x; networksetup -getautoproxyurl "Wi-Fi" )
( set -x; scutil --proxy )
