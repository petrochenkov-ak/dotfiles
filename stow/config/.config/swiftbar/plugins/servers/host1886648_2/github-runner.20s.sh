#!/bin/bash

output="$(ssh host1886648_2 "docker ps | grep github-runner")" || exit 1
[[ -n $output ]] && exit
echo "github-runner NOT RUNNING"
echo "---"
ssh host1886648_2 "docker ps -a | grep github-runner"
