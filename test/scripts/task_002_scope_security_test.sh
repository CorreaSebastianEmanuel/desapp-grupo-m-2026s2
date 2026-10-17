#!/bin/sh
set -eu
PROFILE_SHELL_FILE=test/scripts/task_002_scope_security_test.sh
. "$(dirname "$0")/support/profile_events.sh"
profile_case_start 'task_002_scope_security'
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
! grep -Eq '0\.0\.0\.0:|(^|[^:]):5432:5432|(^|[^:]):6379:6379' "$root/compose.yaml"
! grep -R -E 'CREATE TABLE (users|players|quotes|transactions)' "$root/priv/repo/migrations" >/dev/null 2>&1
! grep -R "$root" "$root/compose.yaml" "$root/.env.example" >/dev/null 2>&1
echo "TASK-002 scope/security: PASS"
profile_case_pass 'task_002_scope_security'
