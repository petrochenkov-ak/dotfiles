#!/usr/bin/env bash

services=$(networksetup -listallnetworkservices | tail -n +2 | grep -v "^\*")

echo "$services" | while read -r service; do
    ( set -x; sudo networksetup -setproxybypassdomains "$service" \
        *.steamcommunity.com \
        *.steamcontent.com \
        *.steampowered.com \
        *.steamusercontent.com \
        *.steamstatic.com \
        *.alpine-mirror.com \
        dl-cdn.alpinelinux.org \
        *.docker.com \
        *.docker.internal \
        github.com \
        gitlab.com \
        google.com \
        *registry* \
        ru \
        local \
        localhost \
        proxy.internal \
        registry.docker.internal \
        127.0.0.1 ) || exit 1
done
