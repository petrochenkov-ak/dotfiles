#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*}"; { set +x; } 2>/dev/null; }

{ set -o allexport; . .env.local || exit; }

( set -x; .venv/bin/python -m celery -A platform_celery_worker.app:app worker -Q "critical" -l debug ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

