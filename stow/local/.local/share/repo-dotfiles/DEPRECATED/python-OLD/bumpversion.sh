#!/usr/bin/env bash
{ set +x; } 2>/dev/null

! [ -e setup.py ] && echo "SKIP ($PWD): setup.py NOT EXISTS" && exit

name="$(python3 setup.py --name)" || exit
url="https://pypi.org/pypi/"$name"/json"

v="$(python3 setup.py --version)" || exit
json="$(set -x; curl -fLs "$url")"
pv="$(echo "$json" | jq -r '.info.version')" || exit

[[ -z "$v" ]] && echo "ERROR: version unknown" && exit 1
[[ -z "$pv" ]] && echo "SKIP: https://pypi.org/project/$name/ NOT REGISTERED" && exit

sdist="$( set -x; bash ~/git/pypi-metadata/scripts/sdist.sh )" || exit
diff="$(
    cd "$(mktemp -d)" || exit
    pypi_sdist="$(pypi-download "$name" | grep tar.gz)" || exit
    tar-diff "$sdist" "$pypi_sdist"
)" || exit
[[ -z "$diff" ]] && echo "SKIP: uptodate" && exit
echo "$diff"

new_version="$(echo "$version" | awk -F. '{OFS="."; $NF+=1; print $0}')"
( set -x; echo "$new_version" | tee .pypi_metadata/version.txt )
( set -x; bash ~/git/pypi-metadata/scripts/init.sh )
