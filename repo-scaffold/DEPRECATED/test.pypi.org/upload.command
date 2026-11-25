#!/usr/bin/env bash

( set -x; rm -fr dist )
( set -x; python -m build ) || exit
( set -x; python -m twine upload --repository testpypi dist/* --verbose ) || exit
( set -x; open "https://test.pypi.org/project/$(python setup.py --name)" )
