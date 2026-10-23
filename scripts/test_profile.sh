#!/bin/sh
# Private captures and child process groups are owned by the Python supervisor.
set +x
set -eu
# Local toolchain bootstrap for non-interactive agent shells:
# - disable Mix's TCP filesystem lock (fails with :eperm in sandboxes)
# - resolve Node v24 from nvm when it is not already on PATH
export MIX_OS_CONCURRENCY_LOCK="${MIX_OS_CONCURRENCY_LOCK:-0}"
if ! command -v node >/dev/null 2>&1 || ! node --version 2>/dev/null | grep -Eq '^v24\.'; then
  for d in "$HOME"/.nvm/versions/node/v24*/bin; do
    if [ -d "$d" ]; then PATH="$d:$PATH"; break; fi
  done
fi
export PATH
umask 077
exec python3 scripts/test_profile_runner.py "$@"
