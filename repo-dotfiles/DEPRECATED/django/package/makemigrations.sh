#!/usr/bin/env bash
{ set +x; } 2>/dev/null

DJANGO_SETTINGS_MODULE="django_migrations_settings"
{ set -x; export DJANGO_SETTINGS_MODULE="$DJANGO_SETTINGS_MODULE"; { set +x; } 2>/dev/null; }
[ -e settings.py ] && { DJANGO_SETTINGS_MODULE="settings"; }

( set -x; find . \( -name "models.py" -o -name models \) -exec sh -c 'mkdir -p ${0%/*}/migrations; touch ${0%/*}/migrations/__init__.py' {} \; )

# app="$(echo "${PWD##*/}" | awk -F"." '{print $1}' | sed 's/-/_/g')"
# ="$(find "$PWD" -name "__init__.py" -maxdepth 2 | sed 's#/[^/]*$##' | awk -F"/" '{print $NF}')"
app="$(python3 -c 'import setuptools;print("\n".join(setuptools.find_packages()))' | grep -v \\.)"
set -- "$app"

( set -x; python3 -m pip uninstall --break-system-packages -y "$app" ) || exit
( set -x; find . -type d -name "*.egg-info" -exec rm -fr {} \; )
( set -x; python3 -m pip install --break-system-packages --isolated -e . ) || exit

( set -x; find . -type d -name migrations -exec rm -fr {} \; )
django_admin_path="$(which django-admin.py)" || exit
# https://docs.djangoproject.com/en/dev/ref/django-admin/#django-admin-makemigrations
# To add migrations to an app that doesn’t have a migrations directory, run makemigrations with the app’s app_label
( set -x; django-admin makemigrations "$app" ) || exit
