#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*/*}"; { set +x; } 2>/dev/null; }

{ set -o allexport; . .env.local || exit; }
export CELERY_WORKER_QUEUE="critical"

( set -x; .venv/bin/python -m celery -A platform_celery_worker.app:app worker -O fair ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )


