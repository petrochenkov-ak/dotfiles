#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*/*/*}" || exit; { set +x; } 2>/dev/null; }

( set -x; find python/packages -maxdepth 2 -name "pyproject.toml" -print0 | grep -z -v "__pycache__" | xargs -0 -I '{}' sh -c 'python3.14 -m pip install --break-system-packages --no-build-isolation -e "$(dirname "{}")"' )
