#!/bin/bash

THRESHOLD_MB=5120 # 5120 Mb
FREE_SPACE_MB="$(ssh host1886648_2 "df -m / | awk 'NR==2 {print \$4}'")" || exit 1

[ $? -ne 0 ] && echo "ERROR: FAILED TO CONNECT" && exit 1

if [ "$FREE_SPACE_MB" -lt "$THRESHOLD_MB" ]; then
    echo "WARNING: ${FREE_SPACE_MB}Mb FREE SPACE"
fi;:
