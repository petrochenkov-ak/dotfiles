#!/usr/bin/env bash
{ set +x; } 2>/dev/null

( set -x; colima-start ) || exit 1
( set -x; colima status ) || exit 1
