#!/usr/bin/env bash

ENV_DIR="${BASH_SOURCE%/.scripts/*}"
ENV_NAME="${ENV_DIR##*/}"
PROJECT_DIR="${ENV_DIR%/*}"
PROJECT_NAME="${PROJECT_DIR##*/}"
REMOTE_DIR=/opt/${PROJECT_NAME}/${ENV_NAME}
