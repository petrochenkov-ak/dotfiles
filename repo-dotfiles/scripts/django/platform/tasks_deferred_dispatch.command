#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*/*}"; { set +x; } 2>/dev/null; }

{ set -o allexport; . .env.local || exit; }

( set -x; .venv/bin/python ~/.local/share/django/manage.py tasks_deferred_dispatch ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

