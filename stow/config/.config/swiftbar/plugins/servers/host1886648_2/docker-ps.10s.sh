#!/bin/bash

output="$(ssh host1886648_2 "docker ps -a -f status=exited --format 'table {{.Names}}\t{{.Status}}'")" || exit 1
[[ -z $output ]] && exit 0
echo "host1886648_2 DOCKER ERRORS"
echo "---"
echo "$output"
