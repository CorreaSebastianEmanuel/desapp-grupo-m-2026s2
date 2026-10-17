#!/bin/sh
profile_event() {
  [ -z "${PROFILE_EVENTS:-}" ] || python3 - "$PROFILE_SHELL_FILE" "$1" "$2" <<'PY'
import json, os, sys
with open(os.environ['PROFILE_EVENTS'], 'a') as stream:
    stream.write(json.dumps(dict(nonce=os.environ.get('PROFILE_NONCE'), runner='shell', file=sys.argv[1], case_id=sys.argv[2], state=sys.argv[3]))+'\n')
PY
}
profile_case_start() { profile_event "$1" started; }
profile_case_pass() { profile_event "$1" passed; }
