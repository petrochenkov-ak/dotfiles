#!/usr/bin/env bash


url="https://raw.githubusercontent.com/petrochenkov-ak/dotfiles/refs/heads/main/proxy/proxy.pac"

( set -x; networksetup -listallnetworkservices )
( set -x; sudo networksetup -setautoproxyurl "Wi-Fi" "$url" )
( set -x; networksetup -getautoproxyurl "Wi-Fi" )
( set -x; scutil --proxy | grep -i ProxyAutoConfig )
# sudo networksetup -setautoproxystate "Wi-Fi" off
