#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*/*}"; { set +x; } 2>/dev/null; }

{ set -o allexport; . .env.local || exit; }

( set -x; .venv/bin/python ~/.local/share/django/manage.py tasks_critical_dispatcher ) || exit
( set -x; osascript -e "tell application \"Terminal\" to close window 1 saving no" )

