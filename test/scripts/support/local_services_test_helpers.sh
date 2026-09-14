#!/bin/sh
set -eu
fail() { echo "FAIL: $*" >&2; exit 1; }
assert_contains() { printf '%s' "$1" | grep -F "$2" >/dev/null || fail "expected: $2"; }
docker_available() { docker info >/dev/null 2>&1; }
redact() { sed -E 's#(://)[^/@:]+:[^/@]+@#\1[REDACTED]@#g'; }
