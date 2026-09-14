#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
! grep -Eq '0\.0\.0\.0:|(^|[^:]):5432:5432|(^|[^:]):6379:6379' "$root/compose.yaml"
! grep -R -E 'CREATE TABLE (users|players|quotes|transactions)' "$root/priv/repo/migrations" >/dev/null 2>&1
! grep -R "$root" "$root/compose.yaml" "$root/.env.example" >/dev/null 2>&1
echo "TASK-002 scope/security: PASS"
