#!/bin/bash

osascript -e 'tell application "V2Box" to quit'
sleep 3

rm -rf -- \
  "$HOME/Library/Containers/hossin.asaadi.V2Box.PacketTunnel" \
  "$HOME/Library/Containers/hossin.asaadi.V2Box" \
  "$HOME/Library/Group Containers/group.hossin.asaadi.V2Box"

open /Applications/V2Box.app
