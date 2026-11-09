#!/usr/bin/env bash

. "${BASH_SOURCE[0]%/*}"/.context.sh || exit 1

( set -x; mussh -H "${BASH_SOURCE[0]%/*/*}"/hosts.txt -b -c "
    cd ${REMOTE_DIR} && {
        set -x
        docker compose -f docker-compose.yaml down --remove-orphans &&
        docker compose -f docker-compose.yaml pull &&
        docker compose -f docker-compose.yaml up -d --force-recreate --wait &&
        docker compose -f docker-compose.yaml ps -a --format 'table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.CreatedAt}}\t{{.Ports}}'
    }
" ) || exit 1
