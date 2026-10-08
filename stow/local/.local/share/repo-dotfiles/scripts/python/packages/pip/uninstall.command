#!/usr/bin/env bash

{ set -x; cd "${BASH_SOURCE[0]%/*/*/*/*/*}" || exit; { set +x; } 2>/dev/null; }

find "${BASH_SOURCE%/*/*/*/*/*}"/python/packages -maxdepth 2 -name "pyproject.toml" | grep -z -v "__pycache__" | while read -r file; do
    pkg_dir=$(dirname "$file")
    pkg_name=$(python3.14 -c "import tomllib; print(tomllib.load(open('$file', 'rb'))['project']['name'])" 2>/dev/null || basename "$pkg_dir")
    python3.14 -m pip uninstall -y --break-system-packages "$pkg_name"
done;:
