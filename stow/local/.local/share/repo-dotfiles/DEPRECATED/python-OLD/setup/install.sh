#!/usr/bin/env bash
{ set +x; } 2>/dev/null

# ( set -x; rm -fr /tmp/python )
( set -x; python3 setup.py install )
