#!/bin/sh
# Private captures and child process groups are owned by the Python supervisor.
set +x
set -eu
umask 077
exec python3 scripts/test_profile_runner.py "$@"
