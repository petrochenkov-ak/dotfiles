#!/usr/bin/env bash


for dir in "${BASH_SOURCE[0]%/*/*}"/config/*/; do
    name="${dir%/}"
    conf="${name}/postgresql.conf"
    if [ -f "$conf" ]; then
        port=$(grep -E '^\s*port\s*=' "$conf" | awk -F= '{print $2}' | tr -d '[:space:]' | sed 's/#.*//')
        #(
       #     set -x
      #      psql -h 127.0.0.1 -p "$port" -d postgres -c "DO \$\$ BEGIN IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'postgres') THEN CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres'; END IF; END \$\$"
      #  ) || exit
        ( set -x; psql -h 127.0.0.1 -p "$port" -d postgres -c "CREATE DATABASE ${name}" 2>/dev/null )
    fi
done;:
