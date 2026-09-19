#!/usr/bin/env bash
{ set +x; } 2>/dev/null

DJANGO_SETTINGS_MODULE="django_settings.package"
PYTHONPATH=~/.local/share/python/dev/site-packages
{ set -x; export DJANGO_SETTINGS_MODULE="$DJANGO_SETTINGS_MODULE"; { set +x; } 2>/dev/null; }
{ set -x; export PYTHONPATH="$PYTHONPATH"; { set +x; } 2>/dev/null; }

app="$(echo "${PWD##*/}" | awk -F"." '{print $1}' | sed 's/-/_/g')"
set -- "$app"

( set -x; django-admin.py migrate "$@" zero ) || exit
