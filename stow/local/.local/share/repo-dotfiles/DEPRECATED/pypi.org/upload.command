#!/usr/bin/env bash

( set -x; rm -fr dist )
( set -x; python -m build ) || exit
( set -x; python -m twine upload --repository pypi dist/* --verbose ) || exit
( set -x; open "https://pypi.org/project/$(python setup.py --name)" )
