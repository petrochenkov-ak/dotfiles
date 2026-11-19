#!/bin/bash

chmod 700 ~/.ssh || exit
/usr/sbin/chown -R $(id -u):$(id -g) ~/.ssh || exit
find ~/.ssh -type f ! -name "*.pub" ! -name "known_hosts" -exec chmod 600 {} +
find ~/.ssh -type f \( -name "*.pub" -o -name "known_hosts" \) -exec chmod 644 {} +
